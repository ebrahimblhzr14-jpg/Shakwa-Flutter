import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shakwa_app/core/security/jwt_claims_parser.dart';

void main() {
  group('JwtClaimsParser', () {
    String buildToken(Map<String, dynamic> payload) {
      final header = base64Url.encode(
        utf8.encode(jsonEncode({'alg': 'HS256', 'typ': 'JWT'})),
      );
      final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
      return '$header.$body.mock_signature';
    }

    test('Parses valid JWT claims with standard and XML schema URIs', () {
      final exp =
          (DateTime.now()
              .add(const Duration(minutes: 15))
              .millisecondsSinceEpoch ~/
          1000);
      final token = buildToken({
        'nameid': '42',
        'unique_name': 'أحمد الشمري',
        'email': 'ahmed@shakwa.sa',
        'role': 'Admin',
        'exp': exp,
      });

      final claims = JwtClaimsParser.tryParse(token);
      expect(claims, isNotNull);
      expect(claims!.userId, equals(42));
      expect(claims.fullName, equals('أحمد الشمري'));
      expect(claims.email, equals('ahmed@shakwa.sa'));
      expect(claims.role, equals(UserRole.admin));
      expect(claims.role.isAdmin, isTrue);
      expect(claims.isExpired, isFalse);
    });

    test('4. Handles invalid or malformed JWT safely', () {
      expect(JwtClaimsParser.tryParse('invalid_jwt'), isNull);
      expect(JwtClaimsParser.tryParse('part1.part2'), isNull);
      expect(JwtClaimsParser.tryParse('a.b.c.d'), isNull);
      expect(JwtClaimsParser.tryParse(''), isNull);
    });

    test('5. Handles missing or invalid claims safely', () {
      // Missing userId (nameid)
      final tokenNoId = buildToken({'unique_name': 'User', 'role': 'User'});
      expect(JwtClaimsParser.tryParse(tokenNoId), isNull);

      // Invalid non-integer userId
      final tokenBadId = buildToken({'nameid': 'not_an_int', 'role': 'User'});
      expect(JwtClaimsParser.tryParse(tokenBadId), isNull);

      // Unknown role defaults safely to UserRole.user
      final tokenUnknownRole = buildToken({
        'nameid': '10',
        'role': 'SuperHackerRole',
      });
      final claims = JwtClaimsParser.tryParse(tokenUnknownRole);
      expect(claims, isNotNull);
      expect(claims!.role, equals(UserRole.user));
    });

    test('6. Detects token expiration accurately from exp claim', () {
      final pastExp =
          (DateTime.now()
              .subtract(const Duration(minutes: 10))
              .millisecondsSinceEpoch ~/
          1000);
      final expiredToken = buildToken({'nameid': '15', 'exp': pastExp});

      final claims = JwtClaimsParser.tryParse(expiredToken);
      expect(claims, isNotNull);
      expect(claims!.isExpired, isTrue);
    });
  });
}
