import 'package:intellivault/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Validators.email', () {
    test('rejects empty input', () {
      expect(Validators.email(''), isNotNull);
    });
    test('rejects malformed addresses', () {
      expect(Validators.email('not-an-email'), isNotNull);
      expect(Validators.email('a@b'), isNotNull);
    });
    test('accepts valid addresses', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('first.last+tag@sub.domain.io'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects short passwords', () {
      expect(Validators.password('1234567'), isNotNull);
    });
    test('accepts 8+ characters', () {
      expect(Validators.password('12345678'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects mismatch', () {
      expect(Validators.confirmPassword('abc12345', 'abc12346'), isNotNull);
    });
    test('accepts match', () {
      expect(Validators.confirmPassword('abc12345', 'abc12345'), isNull);
    });
  });
}
