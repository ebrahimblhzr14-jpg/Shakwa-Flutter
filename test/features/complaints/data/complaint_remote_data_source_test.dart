import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/exceptions.dart';
import 'package:shakwa_app/core/network/api_client.dart';
import 'package:shakwa_app/core/network/attachment_upload_service.dart';
import 'package:shakwa_app/core/security/secure_token_storage.dart';
import 'package:shakwa_app/core/security/token_manager.dart';
import 'package:shakwa_app/core/security/token_record.dart';
import 'package:shakwa_app/features/complaints/data/datasources/complaint_remote_data_source.dart';
import 'package:shakwa_app/features/complaints/data/models/create_complaint_request_dto.dart';

class _FakeTokenStorage implements ISecureTokenStorage {
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

void main() {
  group('ComplaintRemoteDataSourceImpl', () {
    late ApiClient apiClient;
    late AttachmentUploadService uploadService;
    late ComplaintRemoteDataSourceImpl dataSource;
    late Dio mockDio;

    setUp(() {
      final tokenStorage = _FakeTokenStorage();
      final tokenManager = TokenManager(tokenStorage);

      mockDio = Dio(BaseOptions(baseUrl: 'https://test.local/api'));
      apiClient = ApiClient(dio: mockDio, tokenManager: tokenManager);
      uploadService = AttachmentUploadService(apiClient: apiClient);
      dataSource = ComplaintRemoteDataSourceImpl(
        apiClient: apiClient,
        attachmentUploadService: uploadService,
      );
    });

    test('getMyComplaints returns list of ComplaintDto on 200 OK', () async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/Complaints/AllByUserID/10')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'Id': 101,
                      'UserId': 10,
                      'CategoryId': 1,
                      'StatusId': 1,
                      'PriorityId': 2,
                      'Title': 'انقطاع تيار كهربائي',
                      'Description': 'تفاصيل البلاغ',
                      'CreatedAt': '2026-11-24T10:00:00Z',
                    },
                    {
                      'Id': 102,
                      'UserId': 10,
                      'CategoryId': 2,
                      'StatusId': 3,
                      'PriorityId': 1,
                      'Title': 'تسرب مياه',
                      'Description': 'تفاصيل أخرى',
                      'CreatedAt': '2026-11-24T11:00:00Z',
                    },
                  ],
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final result = await dataSource.getMyComplaints(10);
      expect(result.length, equals(2));
      expect(result[0].id, equals(101));
      expect(result[0].title, equals('انقطاع تيار كهربائي'));
      expect(result[1].id, equals(102));
      expect(result[1].title, equals('تسرب مياه'));
    });

    test(
      'getMyComplaints returns empty list when response list is empty',
      () async {
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              return handler.resolve(
                Response(requestOptions: options, statusCode: 200, data: []),
              );
            },
          ),
        );

        final result = await dataSource.getMyComplaints(10);
        expect(result, isEmpty);
      },
    );

    test('getComplaintById returns ComplaintDto on 200 OK', () async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/Complaints/FindBy/45')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'Id': 45,
                    'UserId': 10,
                    'CategoryId': 1,
                    'StatusId': 1,
                    'PriorityId': 1,
                    'Title': 'شكوى فردية',
                    'Description': 'تفاصيل الشكوى',
                    'CreatedAt': '2026-11-24T10:00:00Z',
                  },
                ),
              );
            }
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 404,
                  data: {'message': 'Complaint not found.'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      final complaint = await dataSource.getComplaintById(45);
      expect(complaint.id, equals(45));
      expect(complaint.title, equals('شكوى فردية'));
    });

    test('getComplaintById throws NotFoundException on 404', () async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 404,
                  data: {'message': 'Complaint not found.'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      expect(
        () => dataSource.getComplaintById(999),
        throwsA(isA<NotFoundException>()),
      );
    });

    test(
      'createComplaint posts request and returns created ComplaintDto on 201',
      () async {
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path.contains('/Complaints/Create')) {
                final body = options.data as Map<String, dynamic>;
                expect(body['title'], equals('ماس كهربائي'));
                expect(body['categoryId'], equals(1));
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 201,
                    data: {
                      'Id': 78,
                      'UserId': 10,
                      'CategoryId': 1,
                      'StatusId': 1,
                      'PriorityId': 3,
                      'Title': 'ماس كهربائي',
                      'Description': 'خطر شديد',
                      'CreatedAt': '2026-11-24T12:00:00Z',
                    },
                  ),
                );
              }
              return handler.next(options);
            },
          ),
        );

        const request = CreateComplaintRequestDto(
          title: 'ماس كهربائي',
          description: 'خطر شديد',
          categoryId: 1,
          priorityId: 3,
        );

        final created = await dataSource.createComplaint(request);
        expect(created.id, equals(78));
        expect(created.title, equals('ماس كهربائي'));
      },
    );

    test(
      'updateComplaint puts request and returns updated ComplaintDto',
      () async {
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path.contains('/Complaints/Update/78')) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: {
                      'Id': 78,
                      'UserId': 10,
                      'CategoryId': 1,
                      'StatusId': 1,
                      'PriorityId': 2,
                      'Title': 'عنوان معدل',
                      'Description': 'وصف معدل',
                      'CreatedAt': '2026-11-24T12:00:00Z',
                    },
                  ),
                );
              }
              return handler.next(options);
            },
          ),
        );

        const request = CreateComplaintRequestDto(
          title: 'عنوان معدل',
          description: 'وصف معدل',
          categoryId: 1,
          priorityId: 2,
        );

        final updated = await dataSource.updateComplaint(78, request);
        expect(updated.id, equals(78));
        expect(updated.title, equals('عنوان معدل'));
      },
    );

    test('getCategories returns category list on 200 OK', () async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/Categories/All')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {'Id': 1, 'Name': 'كهرباء', 'IsActive': true},
                    {'Id': 2, 'Name': 'مياه', 'IsActive': true},
                  ],
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final cats = await dataSource.getCategories();
      expect(cats.length, equals(2));
      expect(cats[0].name, equals('كهرباء'));
      expect(cats[1].name, equals('مياه'));
    });

    test('getComplaintHistory returns history items on 200 OK', () async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/ComplaintHistory')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: [
                    {
                      'Id': 1,
                      'ComplaintId': 50,
                      'Action': 'Created',
                      'CreatedAt': '2026-11-24T10:00:00Z',
                    },
                  ],
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final history = await dataSource.getComplaintHistory(50);
      expect(history.length, equals(1));
      expect(history[0].action, equals('Created'));
    });

    test('getImagePath returns image URL string on 200 OK', () async {
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/Attachment/GetImagePath/50')) {
              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: 'https://test.local/Images/img123.jpg',
                ),
              );
            }
            return handler.next(options);
          },
        ),
      );

      final url = await dataSource.getImagePath(50);
      expect(url, equals('https://test.local/Images/img123.jpg'));
    });

    test(
      'uploadAttachment delegates to AttachmentUploadService and uploads file',
      () async {
        mockDio.interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) {
              if (options.path.contains('/Attachment/Upload/50')) {
                return handler.resolve(
                  Response(
                    requestOptions: options,
                    statusCode: 200,
                    data: {
                      'fileName': 'uploaded_server.jpg',
                      'fileSizeBytes': 1024,
                      'contentType': 'image/jpeg',
                    },
                  ),
                );
              }
              return handler.next(options);
            },
          ),
        );

        final item = AttachmentUploadItem(
          id: '1',
          fileName: 'local.jpg',
          fileBytes: Uint8List.fromList([1, 2, 3, 4]),
        );

        final uploaded = await dataSource.uploadAttachment(50, item);
        expect(uploaded.isSuccessful, isTrue);
        expect(uploaded.serverFileName, equals('uploaded_server.jpg'));
      },
    );
  });
}
