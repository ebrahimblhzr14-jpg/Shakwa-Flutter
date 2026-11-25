import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_attachment.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_category.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_details.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_history_item.dart';
import 'package:shakwa_app/features/complaints/domain/entities/complaint_status.dart';

void main() {
  group('ComplaintStatus Enum', () {
    test('correctly maps status IDs to enum values', () {
      expect(ComplaintStatus.fromId(1), equals(ComplaintStatus.pending));
      expect(ComplaintStatus.fromId(2), equals(ComplaintStatus.underReview));
      expect(ComplaintStatus.fromId(3), equals(ComplaintStatus.inProgress));
      expect(ComplaintStatus.fromId(4), equals(ComplaintStatus.resolved));
      expect(ComplaintStatus.fromId(5), equals(ComplaintStatus.closed));
      expect(ComplaintStatus.fromId(999), equals(ComplaintStatus.unknown));
      expect(ComplaintStatus.fromId(null), equals(ComplaintStatus.unknown));
    });

    test('correctly maps status string names to enum values', () {
      expect(
        ComplaintStatus.fromString('Pending'),
        equals(ComplaintStatus.pending),
      );
      expect(
        ComplaintStatus.fromString('جديدة'),
        equals(ComplaintStatus.pending),
      );
      expect(
        ComplaintStatus.fromString('Under Review'),
        equals(ComplaintStatus.underReview),
      );
      expect(
        ComplaintStatus.fromString('قيد المراجعة'),
        equals(ComplaintStatus.underReview),
      );
      expect(
        ComplaintStatus.fromString('In Progress'),
        equals(ComplaintStatus.inProgress),
      );
      expect(
        ComplaintStatus.fromString('قيد المعالجة'),
        equals(ComplaintStatus.inProgress),
      );
      expect(
        ComplaintStatus.fromString('Resolved'),
        equals(ComplaintStatus.resolved),
      );
      expect(
        ComplaintStatus.fromString('تم الحل'),
        equals(ComplaintStatus.resolved),
      );
      expect(
        ComplaintStatus.fromString('Closed'),
        equals(ComplaintStatus.closed),
      );
      expect(
        ComplaintStatus.fromString('مغلقة'),
        equals(ComplaintStatus.closed),
      );
      expect(
        ComplaintStatus.fromString('UnknownValue'),
        equals(ComplaintStatus.unknown),
      );
      expect(ComplaintStatus.fromString(null), equals(ComplaintStatus.unknown));
      expect(ComplaintStatus.fromString(''), equals(ComplaintStatus.unknown));
    });

    test('boolean helper getters return accurate states', () {
      expect(ComplaintStatus.pending.isPending, isTrue);
      expect(ComplaintStatus.pending.isClosed, isFalse);
      expect(ComplaintStatus.closed.isClosed, isTrue);
      expect(ComplaintStatus.inProgress.isInProgress, isTrue);
      expect(ComplaintStatus.resolved.isResolved, isTrue);
      expect(ComplaintStatus.underReview.isUnderReview, isTrue);
    });

    test('provides Arabic and English localized labels', () {
      expect(ComplaintStatus.pending.labelArabic, equals('جديدة'));
      expect(ComplaintStatus.pending.labelEnglish, equals('Pending'));
      expect(ComplaintStatus.closed.labelArabic, equals('مغلقة'));
      expect(ComplaintStatus.closed.labelEnglish, equals('Closed'));
    });
  });

  group('ComplaintPriority Enum', () {
    test('correctly maps priority IDs to enum values', () {
      expect(ComplaintPriority.fromId(1), equals(ComplaintPriority.low));
      expect(ComplaintPriority.fromId(2), equals(ComplaintPriority.medium));
      expect(ComplaintPriority.fromId(3), equals(ComplaintPriority.high));
      expect(ComplaintPriority.fromId(4), equals(ComplaintPriority.urgent));
      expect(ComplaintPriority.fromId(99), equals(ComplaintPriority.unknown));
      expect(ComplaintPriority.fromId(null), equals(ComplaintPriority.unknown));
    });

    test('correctly maps priority strings to enum values', () {
      expect(
        ComplaintPriority.fromString('Low'),
        equals(ComplaintPriority.low),
      );
      expect(
        ComplaintPriority.fromString('منخفضة'),
        equals(ComplaintPriority.low),
      );
      expect(
        ComplaintPriority.fromString('Medium'),
        equals(ComplaintPriority.medium),
      );
      expect(
        ComplaintPriority.fromString('High'),
        equals(ComplaintPriority.high),
      );
      expect(
        ComplaintPriority.fromString('Urgent'),
        equals(ComplaintPriority.urgent),
      );
      expect(
        ComplaintPriority.fromString('طارئة'),
        equals(ComplaintPriority.urgent),
      );
      expect(
        ComplaintPriority.fromString('Other'),
        equals(ComplaintPriority.unknown),
      );
      expect(
        ComplaintPriority.fromString(null),
        equals(ComplaintPriority.unknown),
      );
    });
  });

  group('Domain Entities Equality & Integrity', () {
    test('ComplaintCategory supports value equality', () {
      const cat1 = ComplaintCategory(
        id: 1,
        name: 'كهرباء',
        description: 'أعطال',
      );
      const cat2 = ComplaintCategory(
        id: 1,
        name: 'كهرباء',
        description: 'أعطال',
      );
      const cat3 = ComplaintCategory(id: 2, name: 'مياه');

      expect(cat1, equals(cat2));
      expect(cat1, isNot(equals(cat3)));
    });

    test('ComplaintAttachment supports value equality', () {
      final now = DateTime(2026, 11, 24);
      final att1 = ComplaintAttachment(
        id: 10,
        complaintId: 101,
        uploadedByUserId: 5,
        fileName: 'pic.jpg',
        filePath: '/img/pic.jpg',
        uploadedAt: now,
      );
      final att2 = ComplaintAttachment(
        id: 10,
        complaintId: 101,
        uploadedByUserId: 5,
        fileName: 'pic.jpg',
        filePath: '/img/pic.jpg',
        uploadedAt: now,
      );

      expect(att1, equals(att2));
    });

    test('ComplaintHistoryItem supports value equality', () {
      final now = DateTime(2026, 11, 24);
      final item1 = ComplaintHistoryItem(
        id: 1,
        complaintId: 101,
        action: 'Created',
        createdAt: now,
      );
      final item2 = ComplaintHistoryItem(
        id: 1,
        complaintId: 101,
        action: 'Created',
        createdAt: now,
      );

      expect(item1, equals(item2));
    });

    test('Complaint entity correctly reports isClosed and isEditable', () {
      final now = DateTime(2026, 11, 24);
      final pendingComplaint = Complaint(
        id: 1,
        userId: 10,
        categoryId: 1,
        statusId: 1,
        status: ComplaintStatus.pending,
        priorityId: 2,
        priority: ComplaintPriority.medium,
        title: 'عطل كهربائي',
        description: 'انقطاع التيار',
        createdAt: now,
      );

      expect(pendingComplaint.isEditable, isTrue);
      expect(pendingComplaint.isClosed, isFalse);

      final closedComplaint = Complaint(
        id: 2,
        userId: 10,
        categoryId: 1,
        statusId: 5,
        status: ComplaintStatus.closed,
        priorityId: 1,
        priority: ComplaintPriority.low,
        title: 'شكوى مغلقة',
        description: 'تم الانتهاء',
        createdAt: now,
        closedAt: now.add(const Duration(hours: 4)),
      );

      expect(closedComplaint.isEditable, isFalse);
      expect(closedComplaint.isClosed, isTrue);
    });

    test('ComplaintDetails aggregates complaint, history, and attachments', () {
      final now = DateTime(2026, 11, 24);
      final complaint = Complaint(
        id: 1,
        userId: 10,
        categoryId: 1,
        statusId: 1,
        status: ComplaintStatus.pending,
        priorityId: 1,
        priority: ComplaintPriority.low,
        title: 'تفاصيل الشكوى',
        description: 'شرح',
        createdAt: now,
      );

      final history = [
        ComplaintHistoryItem(
          id: 1,
          complaintId: 1,
          action: 'Created',
          createdAt: now,
        ),
      ];

      final attachments = [
        ComplaintAttachment(
          id: 1,
          complaintId: 1,
          uploadedByUserId: 10,
          fileName: 'f.png',
          filePath: '/path',
          uploadedAt: now,
        ),
      ];

      final details = ComplaintDetails(
        complaint: complaint,
        history: history,
        attachments: attachments,
        primaryAttachmentUrl: 'https://example.com/img.png',
      );

      expect(details.complaint.id, equals(1));
      expect(details.history.length, equals(1));
      expect(details.attachments.length, equals(1));
      expect(
        details.primaryAttachmentUrl,
        equals('https://example.com/img.png'),
      );
    });
  });
}
