import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pot/features/wallet/utils/date_utils.dart';

void main() {
  group('todayKey', () {
    test('returns date in yyyy-MM-dd format', () {
      final key = todayKey();
      expect(RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key), isTrue);
    });

    test('matches current local date', () {
      final now = DateTime.now();
      final expected = '${now.year}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      expect(todayKey(), expected);
    });

    test('is stable across calls within the same day', () {
      expect(todayKey(), todayKey());
    });
  });
}
