import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/errors/exceptions.dart';
import 'package:shakwa_app/core/security/token_record.dart';

void main() {
  group('TokenRecord', () {
    test('1. Serializes and deserializes token record correctly', () {
      final now = DateTime.now();
      final expires = now.add(const Duration(minutes: 15));
      final record = TokenRecord(
        accessToken: 'access_123',
        refreshToken: 'refresh_456',
        createdAt: now,
        expiresAt: expires,
      );

      final json = record.toJson();
      expect(json['access_token'], equals('access_123'));
      expect(json['refresh_token'], equals('refresh_456'));

      final jsonStr = record.toJsonString();
      final restored = TokenRecord.fromJsonString(jsonStr);

      expect(restored.accessToken, equals('access_123'));
      expect(restored.refreshToken, equals('refresh_456'));
      expect(
        restored.expiresAt.millisecondsSinceEpoch ~/ 1000,
        equals(expires.millisecondsSinceEpoch ~/ 1000),
      );
      expect(restored.isExpired, isFalse);
    });

    test('Throws CorruptedTokenRecordException on empty or missing fields', () {
      expect(
        () =>
            TokenRecord.fromJson({'access_token': '', 'refresh_token': 'ref'}),
        throwsA(isA<CorruptedTokenRecordException>()),
      );

      expect(
        () => TokenRecord.fromJsonString('{"invalid": 123}'),
        throwsA(isA<CorruptedTokenRecordException>()),
      );

      expect(
        () => TokenRecord.fromJsonString('not_json'),
        throwsA(isA<CorruptedTokenRecordException>()),
      );
    });

    test('Detects expiration correctly', () {
      final pastRecord = TokenRecord(
        accessToken: 'acc',
        refreshToken: 'ref',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      expect(pastRecord.isExpired, isTrue);
    });
  });
}
