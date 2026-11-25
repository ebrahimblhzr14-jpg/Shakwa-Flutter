import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/network/api_client.dart';
import 'package:shakwa_app/core/network/attachment_upload_service.dart';
import 'package:shakwa_app/core/security/secure_token_storage.dart';
import 'package:shakwa_app/core/security/token_manager.dart';
import '../security/secure_token_storage_test.dart';

void main() {
  group('AttachmentUploadService', () {
    late ApiClient mockApiClient;
    late AttachmentUploadService uploadService;
    late List<Map<String, dynamic>> uploadedRequests;

    setUp(() {
      uploadedRequests = [];
      final mockDio = Dio(BaseOptions(baseUrl: 'https://test.local/api'));
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (options.path.contains('/Attachment/Upload/')) {
              final formData = options.data as FormData;
              final hasImageFile = formData.files.any(
                (f) => f.key == 'imageFile',
              );
              uploadedRequests.add({
                'path': options.path,
                'hasImageFile': hasImageFile,
                'fileName': formData.files.first.value.filename,
              });

              if (formData.files.first.value.filename?.contains('fail') ??
                  false) {
                return handler.reject(
                  DioException(
                    requestOptions: options,
                    response: Response(
                      requestOptions: options,
                      statusCode: 400,
                      data: {'message': 'Upload failed'},
                    ),
                    type: DioExceptionType.badResponse,
                  ),
                );
              }

              return handler.resolve(
                Response(
                  requestOptions: options,
                  statusCode: 200,
                  data: {
                    'fileName': 'server_guid_123.jpg',
                    'fileSizeBytes': 1024,
                    'contentType': 'image/jpeg',
                  },
                ),
              );
            }
            handler.next(options);
          },
        ),
      );

      final tokenStorage = SecureTokenStorageImpl(
        storage: MockFlutterSecureStorage(),
      );
      final tokenManager = TokenManager(tokenStorage);
      mockApiClient = ApiClient(dio: mockDio, tokenManager: tokenManager);
      uploadService = AttachmentUploadService(apiClient: mockApiClient);
    });

    test(
      '21. Formats multipart upload request using field imageFile',
      () async {
        final item = AttachmentUploadItem(
          id: '1',
          fileName: 'damage.jpg',
          fileBytes: Uint8List.fromList([1, 2, 3, 4]),
        );

        final result = await uploadService.uploadSingleAttachment(
          complaintId: 42,
          item: item,
        );

        expect(result.status, equals(AttachmentUploadStatus.uploaded));
        expect(result.serverFileName, equals('server_guid_123.jpg'));
        expect(uploadedRequests.length, equals(1));
        expect(uploadedRequests.first['hasImageFile'], isTrue);
        expect(
          uploadedRequests.first['path'],
          contains('/Attachment/Upload/42'),
        );
      },
    );

    test('22. Executes sequential multi-attachment uploads', () async {
      final items = [
        AttachmentUploadItem(
          id: '1',
          fileName: 'photo1.jpg',
          fileBytes: Uint8List.fromList([1, 2]),
        ),
        AttachmentUploadItem(
          id: '2',
          fileName: 'photo2.jpg',
          fileBytes: Uint8List.fromList([3, 4]),
        ),
      ];

      final results = await uploadService.uploadSequentialAttachments(
        complaintId: 10,
        items: items,
      );

      expect(results.every((i) => i.isSuccessful), isTrue);
      expect(uploadedRequests.length, equals(2));
      expect(uploadedRequests[0]['fileName'], equals('photo1.jpg'));
      expect(uploadedRequests[1]['fileName'], equals('photo2.jpg'));
    });

    test(
      '23. Retries failed-only attachments without re-uploading succeeded attachments',
      () async {
        final items = [
          AttachmentUploadItem(
            id: '1',
            fileName: 'good.jpg',
            fileBytes: Uint8List.fromList([1, 2]),
          ),
          AttachmentUploadItem(
            id: '2',
            fileName: 'fail.jpg',
            fileBytes: Uint8List.fromList([3, 4]),
          ),
        ];

        // Initial sequential upload
        await uploadService.uploadSequentialAttachments(
          complaintId: 10,
          items: items,
        );
        expect(items[0].status, equals(AttachmentUploadStatus.uploaded));
        expect(items[1].status, equals(AttachmentUploadStatus.failed));
        expect(uploadedRequests.length, equals(2));

        // Clear record
        uploadedRequests.clear();

        // Fix failure condition and retry
        items[1] = AttachmentUploadItem(
          id: '2',
          fileName: 'fixed.jpg',
          fileBytes: Uint8List.fromList([5, 6]),
          status: AttachmentUploadStatus.failed,
        );

        await uploadService.retryFailedAttachments(
          complaintId: 10,
          items: items,
        );

        // Only the failed item was retried; good.jpg was NOT re-uploaded!
        expect(uploadedRequests.length, equals(1));
        expect(uploadedRequests.first['fileName'], equals('fixed.jpg'));
        expect(items[1].status, equals(AttachmentUploadStatus.uploaded));
      },
    );
  });
}
