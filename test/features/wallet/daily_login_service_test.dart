import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pot/features/wallet/services/daily_login_service.dart';

void main() {
  final service = DailyLoginService();

  group('hasClaimedToday', () {
    test('returns false when lastLogin is null (first ever login)', () {
      expect(service.hasClaimedToday(null), isFalse);
    });

    test('returns true when lastLogin is today', () {
      expect(service.hasClaimedToday(DateTime.now()), isTrue);
    });

    test('returns false when lastLogin was yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(service.hasClaimedToday(yesterday), isFalse);
    });

    test('returns false when lastLogin is many days ago', () {
      final past = DateTime.now().subtract(const Duration(days: 5));
      expect(service.hasClaimedToday(past), isFalse);
    });
  });

  group('calculateNewStreak', () {
    test('returns 1 on first ever login', () {
      expect(service.calculateNewStreak(lastLogin: null, oldStreak: 0), 1);
    });

    test('increments streak when logging in on consecutive day', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(service.calculateNewStreak(lastLogin: yesterday, oldStreak: 5), 6);
    });

    test('resets to 1 when a day was missed', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      expect(service.calculateNewStreak(lastLogin: twoDaysAgo, oldStreak: 5), 1);
    });

    test('resets to 1 when lastLogin is today (already claimed)', () {
      expect(service.calculateNewStreak(lastLogin: DateTime.now(), oldStreak: 5), 1);
    });
  });

  group('calculateReward', () {
    test('first day reward equals firstDayReward', () {
      expect(service.calculateReward(1), DailyLoginService.firstDayReward);
      expect(service.calculateReward(1), 10);
    });

    test('week completion gives weekStreakBonus', () {
      expect(service.calculateReward(7), DailyLoginService.weekStreakBonus);
      expect(service.calculateReward(7), 50);
    });

    test('middle days give consecutiveDayReward', () {
      for (var streak = 2; streak < 7; streak++) {
        expect(service.calculateReward(streak), DailyLoginService.consecutiveDayReward);
      }
      expect(service.calculateReward(2), 5);
      expect(service.calculateReward(6), 5);
    });

    test('streak beyond a week gives consecutiveDayReward', () {
      expect(service.calculateReward(8), DailyLoginService.consecutiveDayReward);
    });
  });
}
