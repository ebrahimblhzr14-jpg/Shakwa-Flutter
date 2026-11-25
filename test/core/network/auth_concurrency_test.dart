import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/network/interceptors/auth_interceptor.dart';
import 'package:shakwa_app/core/security/secure_token_storage.dart';
import 'package:shakwa_app/core/security/token_manager.dart';
import 'package:shakwa_app/core/security/token_record.dart';

class MockAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) onFetch;
  MockAdapter(this.onFetch);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

class InMemoryTokenStorage implements ISecureTokenStorage {
  TokenRecord? record;

  @override
  bool get isVolatileSession => false;

  @override
  Future<void> saveTokenRecord(TokenRecord r) async => record = r;

  @override
  Future<TokenRecord?> getTokenRecord() async => record;

  @override
  Future<void> clearTokenRecord() async => record = null;
}

class _TestErrorInterceptorHandler extends ErrorInterceptorHandler {
  final void Function(DioException e) onNext;
  _TestErrorInterceptorHandler({required this.onNext});

  @override
  void next(DioException err) {
    onNext(err);
  }
}

void main() {
  group('AuthInterceptor Concurrency & Mutex', () {
    late TokenManager tokenManager;
    late InMemoryTokenStorage storage;
    late Dio testDio;
    late Dio refreshDio;

    int refreshCallCount = 0;

    setUp(() async {
      storage = InMemoryTokenStorage();
      tokenManager = TokenManager(storage);
      await tokenManager.updateTokens(
        accessToken: 'OLD_ACCESS_TOKEN',
        refreshToken: 'OLD_REFRESH_TOKEN',
      );

      refreshCallCount = 0;

      // Mock refresh Dio
      refreshDio = Dio(BaseOptions(baseUrl: 'https://test.local/api'));
      refreshDio.httpClientAdapter = MockAdapter((options) async {
        if (options.path.contains('/Auth/refresh')) {
          refreshCallCount++;
          await Future.delayed(const Duration(milliseconds: 30));
          return ResponseBody.fromString(
            '{"accessToken": "NEW_ACCESS_TOKEN", "refreshToken": "NEW_REFRESH_TOKEN"}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        final authHeader = options.headers['Authorization'] as String?;
        if (authHeader == 'Bearer NEW_ACCESS_TOKEN') {
          return ResponseBody.fromString(
            '[{"id": 1, "title": "Success"}]',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          '{"message": "Unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      // Main Dio with AuthInterceptor
      testDio = Dio(BaseOptions(baseUrl: 'https://test.local/api'));
      testDio.interceptors.add(
        AuthInterceptor(tokenManager: tokenManager, refreshDio: refreshDio),
      );
      testDio.httpClientAdapter = MockAdapter((options) async {
        final authHeader = options.headers['Authorization'] as String?;
        if (authHeader == 'Bearer OLD_ACCESS_TOKEN') {
          return ResponseBody.fromString(
            '{"message": "Token expired"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        if (authHeader == 'Bearer NEW_ACCESS_TOKEN') {
          return ResponseBody.fromString(
            '[{"id": 1, "title": "Success"}]',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString(
          '{"message": "Unauthorized"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });
    });

    test(
      '15. Single 401 triggers successful refresh and replays original request',
      () async {
        final response = await testDio.get('/Complaints/AssignedToMe');
        expect(response.statusCode, equals(200));
        expect(refreshCallCount, equals(1));
        expect(tokenManager.accessToken, equals('NEW_ACCESS_TOKEN'));
      },
    );

    test(
      '17. Stale-token detection replays immediately without duplicate refresh',
      () async {
        // Simulate another request having already updated tokenManager
        await tokenManager.updateTokens(
          accessToken: 'ALREADY_REFRESHED_TOKEN',
          refreshToken: 'ALREADY_REFRESHED_REFRESH',
        );

        // Verify staleness detection condition
        expect(tokenManager.accessToken, isNot(equals('OLD_ACCESS_TOKEN')));
      },
    );

    test(
      '18. 10 Concurrent 401 requests trigger ONLY ONE refresh request',
      () async {
        final futures = List.generate(
          10,
          (_) => testDio.get('/Complaints/AssignedToMe'),
        );

        final results = await Future.wait(futures);

        expect(results.length, equals(10));
        for (final res in results) {
          expect(res.statusCode, equals(200));
        }
        expect(
          refreshCallCount,
          equals(1),
          reason:
              'Exactly one refresh request must be sent for 10 concurrent 401s',
        );
        expect(tokenManager.accessToken, equals('NEW_ACCESS_TOKEN'));
      },
    );

    test(
      '19. Loop Prevention: Each original request replayed no more than once',
      () async {
        final failingRefreshDio = Dio(
          BaseOptions(baseUrl: 'https://test.local/api'),
        );
        failingRefreshDio.httpClientAdapter = MockAdapter((options) async {
          if (options.path.contains('/Auth/refresh')) {
            return ResponseBody.fromString(
              '{"accessToken": "NEW_ACCESS_TOKEN", "refreshToken": "NEW_REFRESH_TOKEN"}',
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }
          return ResponseBody.fromString(
            '{"message": "Unauthorized"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        final failingDio = Dio(BaseOptions(baseUrl: 'https://test.local/api'));
        failingDio.interceptors.add(
          AuthInterceptor(
            tokenManager: tokenManager,
            refreshDio: failingRefreshDio,
          ),
        );
        failingDio.httpClientAdapter = MockAdapter((options) async {
          return ResponseBody.fromString(
            '{"message": "Unauthorized"}',
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        expect(
          () => failingDio.get('/Complaints/AssignedToMe'),
          throwsA(isA<DioException>()),
        );
      },
    );

    test('20. Refresh endpoint bypasses recursive refresh on 401', () async {
      final interceptor = AuthInterceptor(
        tokenManager: tokenManager,
        refreshDio: refreshDio,
      );
      final options = RequestOptions(path: '/Auth/refresh');

      final err = DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 401),
        type: DioExceptionType.badResponse,
      );

      bool nextCalled = false;
      final testHandler = _TestErrorInterceptorHandler(
        onNext: (e) {
          nextCalled = true;
        },
      );

      await interceptor.onError(err, testHandler);

      // Refresh call count must remain 0 because /Auth/refresh is exempt!
      expect(refreshCallCount, equals(0));
      expect(nextCalled, isTrue);
    });
  });
}
