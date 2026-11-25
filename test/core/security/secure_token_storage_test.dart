import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/exceptions.dart';
import 'package:shakwa_app/core/security/secure_token_storage.dart';
import 'package:shakwa_app/core/security/token_record.dart';

class MockFlutterSecureStorage implements FlutterSecureStorage {
  final Map<String, String> _data = {};
  bool shouldThrowPlatformExceptionOnWrite = false;

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (shouldThrowPlatformExceptionOnWrite) {
      throw PlatformException(
        code: 'KEYSTORE_ERROR',
        message: 'Keystore corrupted',
      );
    }
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('SecureTokenStorageImpl', () {
    late MockFlutterSecureStorage mockStorage;
    late SecureTokenStorageImpl tokenStorage;

    setUp(() {
      mockStorage = MockFlutterSecureStorage();
      tokenStorage = SecureTokenStorageImpl(storage: mockStorage);
    });

    test('2. Secure storage read/write/delete success', () async {
      final record = TokenRecord.create(
        accessToken: 'valid_access_token',
        refreshToken: 'valid_refresh_token',
      );

      await tokenStorage.saveTokenRecord(record);
      expect(tokenStorage.isVolatileSession, isFalse);

      final retrieved = await tokenStorage.getTokenRecord();
      expect(retrieved, isNotNull);
      expect(retrieved!.accessToken, equals('valid_access_token'));
      expect(retrieved.refreshToken, equals('valid_refresh_token'));

      await tokenStorage.clearTokenRecord();
      final afterDelete = await tokenStorage.getTokenRecord();
      expect(afterDelete, isNull);
    });

    test(
      '3. Secure storage write failure triggers volatile session and throws StorageWriteException',
      () async {
        mockStorage.shouldThrowPlatformExceptionOnWrite = true;
        final record = TokenRecord.create(
          accessToken: 'volatile_access',
          refreshToken: 'volatile_refresh',
        );

        await expectLater(
          () => tokenStorage.saveTokenRecord(record),
          throwsA(isA<StorageWriteException>()),
        );

        // Verifies that session status is explicitly marked as volatile
        expect(tokenStorage.isVolatileSession, isTrue);

        // In volatile mode, memory backup provides active in-flight session
        final retrieved = await tokenStorage.getTokenRecord();
        expect(retrieved, isNotNull);
        expect(retrieved!.accessToken, equals('volatile_access'));
      },
    );

    test(
      'Corrupted secure storage record is purged and throws CorruptedTokenRecordException',
      () async {
        await mockStorage.write(
          key: 'cms_token_record',
          value: 'corrupted_non_json_data',
        );

        await expectLater(
          () => tokenStorage.getTokenRecord(),
          throwsA(isA<CorruptedTokenRecordException>()),
        );

        // Verify corrupted entry was purged
        final purged = await mockStorage.read(key: 'cms_token_record');
        expect(purged, isNull);
      },
    );
  });
}
