import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/features/complaints/data/models/complaint_attachment_model.dart';
import 'package:shakwa_app/features/complaints/data/models/complaint_category_model.dart';
import 'package:shakwa_app/features/complaints/data/models/complaint_comment_model.dart';
import 'package:shakwa_app/features/complaints/data/models/complaint_details_model.dart';
import 'package:shakwa_app/features/complaints/data/models/complaint_dto.dart';
import 'package:shakwa_app/features/complaints/data/models/complaint_history_model.dart';
import 'package:shakwa_app/features/complaints/data/models/create_comment_request_dto.dart';
import 'package:shakwa_app/features/complaints/data/models/create_complaint_request_dto.dart';
import 'package:shakwa_app/features/complaints/data/models/update_complaint_status_request_dto.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';

void main() {
  group('ComplaintCategoryModel Serialization & Mapping', () {
    test('parses camelCase JSON and maps to domain entity', () {
      final json = {
        'id': 1,
        'name': 'الكهرباء',
        'description': 'بلاغات الكهرباء والإنارة',
        'isActive': true,
      };

      final model = ComplaintCategoryModel.fromJson(json);
      expect(model.id, equals(1));
      expect(model.name, equals('الكهرباء'));
      expect(model.description, equals('بلاغات الكهرباء والإنارة'));
      expect(model.isActive, isTrue);

      final entity = model.toEntity();
      expect(entity.id, equals(1));
      expect(entity.name, equals('الكهرباء'));
      expect(entity.description, equals('بلاغات الكهرباء والإنارة'));
      expect(entity.isActive, isTrue);
    });

    test('parses PascalCase JSON from ASP.NET Core', () {
      final json = {
        'Id': 2,
        'Name': 'المياه والصرف الصحي',
        'Description': null,
        'IsActive': false,
      };

      final model = ComplaintCategoryModel.fromJson(json);
      expect(model.id, equals(2));
      expect(model.name, equals('المياه والصرف الصحي'));
      expect(model.description, isNull);
      expect(model.isActive, isFalse);
    });

    test('serializes to JSON correctly', () {
      const model = ComplaintCategoryModel(
        id: 3,
        name: 'الطرق والجسور',
        description: 'حفر وتعبيد',
        isActive: true,
      );

      final json = model.toJson();
      expect(json['id'], equals(3));
      expect(json['name'], equals('الطرق والجسور'));
      expect(json['description'], equals('حفر وتعبيد'));
      expect(json['isActive'], isTrue);
    });
  });

  group('ComplaintAttachmentModel Serialization & Mapping', () {
    test('parses PascalCase JSON and converts to entity with public URL', () {
      final json = {
        'Id': 105,
        'ComplaintId': 42,
        'UploadedByUserId': 9,
        'UploadedByUserName': 'أحمد السعيد',
        'UploadedByUserImageUrl': 'http://avatar.jpg',
        'FileName': 'abc123.jpg',
        'FilePath': 'C:\\inetpub\\Images\\abc123.jpg',
        'FileType': 'image/jpeg',
        'FileSize': 1048576,
        'UploadedAt': '2026-11-24T10:30:00Z',
      };

      final model = ComplaintAttachmentModel.fromJson(json);
      expect(model.id, equals(105));
      expect(model.complaintId, equals(42));
      expect(model.uploadedByUserId, equals(9));
      expect(model.uploadedByUserName, equals('أحمد السعيد'));
      expect(model.fileName, equals('abc123.jpg'));
      expect(model.fileSize, equals(1048576));

      final entity = model.toEntity(
        publicUrl: 'http://localhost:5000/Images/abc123.jpg',
      );
      expect(
        entity.publicUrl,
        equals('http://localhost:5000/Images/abc123.jpg'),
      );
      expect(entity.fileName, equals('abc123.jpg'));
    });

    test(
      'parses upload response format with fileSizeBytes and contentType',
      () {
        final json = {
          'fileName': 'server_name.png',
          'fileSizeBytes': 524288,
          'contentType': 'image/png',
        };

        final model = ComplaintAttachmentModel.fromJson(json);
        expect(model.fileName, equals('server_name.png'));
        expect(model.fileSize, equals(524288));
        expect(model.fileType, equals('image/png'));
      },
    );
  });

  group('ComplaintHistoryModel Serialization & Mapping', () {
    test('parses history record from ASP.NET Core API', () {
      final json = {
        'Id': 50,
        'ComplaintId': 12,
        'UserId': 3,
        'UserName': 'المشرف العام',
        'UserImageUrl': null,
        'Action': 'StatusChanged',
        'OldValue': 'قيد المراجعة',
        'NewValue': 'قيد المعالجة',
        'Description': 'تم تعيين المهندس المسؤول',
        'CreatedAt': '2026-11-24T12:00:00Z',
      };

      final model = ComplaintHistoryModel.fromJson(json);
      expect(model.id, equals(50));
      expect(model.action, equals('StatusChanged'));
      expect(model.oldValue, equals('قيد المراجعة'));
      expect(model.newValue, equals('قيد المعالجة'));

      final entity = model.toEntity();
      expect(entity.id, equals(50));
      expect(entity.complaintId, equals(12));
      expect(entity.userName, equals('المشرف العام'));
    });
  });

  group('CreateComplaintRequestDto Serialization', () {
    test('serializes with trimmed text and optional departmentId', () {
      const dto = CreateComplaintRequestDto(
        title: '  عطل في الإنارة العامة  ',
        description: '  العمود مكسور في شارع الستين  ',
        categoryId: 1,
        priorityId: 3,
        departmentId: 5,
      );

      final json = dto.toJson();
      expect(json['title'], equals('عطل في الإنارة العامة'));
      expect(json['description'], equals('العمود مكسور في شارع الستين'));
      expect(json['categoryId'], equals(1));
      expect(json['priorityId'], equals(3));
      expect(json['departmentId'], equals(5));
    });

    test('omits departmentId when null', () {
      const dto = CreateComplaintRequestDto(
        title: 'تسرب مياه',
        description: 'أمام المبنى',
        categoryId: 2,
        priorityId: 2,
      );

      final json = dto.toJson();
      expect(json.containsKey('departmentId'), isFalse);
    });
  });

  group('ComplaintDto Serialization & Entity Mapping', () {
    test('parses full complaint DTO and maps status & priority enums', () {
      final json = {
        'Id': 201,
        'UserId': 14,
        'UserName': 'سالم محمد',
        'UserImageUrl': 'http://image.jpg',
        'CategoryId': 2,
        'CategoryName': 'المياه',
        'DepartmentId': 4,
        'DepartmentName': 'إدارة التشغيل',
        'StatusId': 3,
        'StatusName': 'قيد المعالجة',
        'PriorityId': 4,
        'PriorityName': 'حرجة / طارئة',
        'Title': 'كسر أنبوب رئيسي',
        'Description': 'تدفق مياه قوي يغمر الشارع',
        'CreatedAt': '2026-11-24T08:00:00Z',
        'UpdatedAt': '2026-11-24T09:00:00Z',
        'ResolvedAt': null,
        'ClosedAt': null,
      };

      final dto = ComplaintDto.fromJson(json);
      expect(dto.id, equals(201));
      expect(dto.title, equals('كسر أنبوب رئيسي'));
      expect(dto.statusId, equals(3));
      expect(dto.priorityId, equals(4));

      final entity = dto.toEntity();
      expect(entity.id, equals(201));
      expect(entity.status, equals(ComplaintStatus.inProgress));
      expect(entity.priority, equals(ComplaintPriority.urgent));
      expect(entity.isClosed, isFalse);
      expect(entity.isEditable, isFalse);
    });

    test(
      'falls back to unknown enum when statusId or priorityId is unrecognized',
      () {
        final json = {
          'id': 99,
          'userId': 1,
          'categoryId': 1,
          'statusId': 999,
          'priorityId': 888,
          'title': 'تجربة',
          'description': 'وصف',
          'createdAt': '2026-11-24T08:00:00Z',
        };

        final dto = ComplaintDto.fromJson(json);
        final entity = dto.toEntity();

        expect(entity.status, equals(ComplaintStatus.unknown));
        expect(entity.priority, equals(ComplaintPriority.unknown));
      },
    );
  });

  group('ComplaintDetailsModel', () {
    test('maps aggregated model to ComplaintDetails entity', () {
      final complaintJson = {
        'id': 1,
        'userId': 10,
        'categoryId': 1,
        'statusId': 1,
        'priorityId': 1,
        'title': 'شكوى تجريبية',
        'description': 'تفاصيل',
        'createdAt': '2026-11-24T08:00:00Z',
      };

      final model = ComplaintDetailsModel(
        complaint: ComplaintDto.fromJson(complaintJson),
        history: [
          ComplaintHistoryModel.fromJson({
            'id': 1,
            'complaintId': 1,
            'action': 'Created',
            'createdAt': '2026-11-24T08:00:00Z',
          }),
        ],
        attachments: [
          ComplaintAttachmentModel.fromJson({
            'id': 1,
            'complaintId': 1,
            'fileName': 'img.jpg',
            'uploadedAt': '2026-11-24T08:00:00Z',
          }),
        ],
        primaryAttachmentUrl: 'http://cdn/img.jpg',
      );

      final entity = model.toEntity();
      expect(entity.complaint.id, equals(1));
      expect(entity.history.length, equals(1));
      expect(entity.attachments.length, equals(1));
      expect(entity.primaryAttachmentUrl, equals('http://cdn/img.jpg'));
    });
  });

  group('ComplaintCommentModel Serialization & Mapping', () {
    test(
      'parses PascalCase JSON from ASP.NET Core and maps to domain entity',
      () {
        final json = {
          'Id': 42,
          'ComplaintId': 100,
          'UserId': 7,
          'UserName': 'م. أحمد خالد',
          'UserImageUrl': 'http://cdn/user.jpg',
          'Comment': 'تم إصلاح العطل بنجاح',
          'CreatedAt': '2026-11-24T10:30:00Z',
          'UserRoleText': 'مشرف الصيانة',
        };

        final model = ComplaintCommentModel.fromJson(json);
        expect(model.id, equals(42));
        expect(model.complaintId, equals(100));
        expect(model.userId, equals(7));
        expect(model.userName, equals('م. أحمد خالد'));
        expect(model.userImageUrl, equals('http://cdn/user.jpg'));
        final entity = model.toEntity();
        expect(entity.id, equals(42));
        expect(entity.complaintId, equals(100));
        expect(entity.userName, equals('م. أحمد خالد'));
        expect(entity.comment, equals('تم إصلاح العطل بنجاح'));
        expect(entity.userRoleText, equals('فريق العمل'));
      },
    );

    test('parses camelCase JSON correctly', () {
      final json = {
        'id': 15,
        'complaintId': 200,
        'userId': 3,
        'userName': 'المشرف',
        'comment': 'قيد المعاينة',
        'createdAt': '2026-11-24T09:00:00Z',
      };

      final model = ComplaintCommentModel.fromJson(json);
      expect(model.id, equals(15));
      expect(model.complaintId, equals(200));
      expect(model.comment, equals('قيد المعاينة'));
    });

    test('serializes to JSON correctly', () {
      final model = ComplaintCommentModel(
        id: 1,
        complaintId: 10,
        userId: 2,
        userName: 'فني الصيانة',
        comment: 'ملاحظة تجريبية',
        createdAt: DateTime.parse('2026-11-24T08:00:00Z'),
      );

      final json = model.toJson();
      expect(json['id'], equals(1));
      expect(json['complaintId'], equals(10));
      expect(json['comment'], equals('ملاحظة تجريبية'));
    });
  });

  group('UpdateComplaintStatusRequestDto Serialization', () {
    test('serializes statusId to JSON contract', () {
      const dto = UpdateComplaintStatusRequestDto(statusId: 4);
      final json = dto.toJson();
      expect(json['statusId'], equals(4));
    });
  });

  group('CreateCommentRequestDto Serialization', () {
    test('serializes complaintId and comment to JSON contract', () {
      const dto = CreateCommentRequestDto(
        complaintId: 101,
        comment: 'ملاحظة فنية جديدة',
      );
      final json = dto.toJson();
      expect(json['complaintId'], equals(101));
      expect(json['comment'], equals('ملاحظة فنية جديدة'));
    });
  });
}
