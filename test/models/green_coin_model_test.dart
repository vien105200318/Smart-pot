import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pot/models/green_coin_model.dart';

void main() {
  const userId = 'user-1';

  GreenCoinModel base() => GreenCoinModel(
        userId: userId,
        balance: 100,
        totalEarned: 200,
        streakDays: 3,
      );

  group('copyWith', () {
    test('returns same values when no arguments are provided', () {
      final copy = base().copyWith();
      expect(copy.userId, userId);
      expect(copy.balance, 100);
      expect(copy.totalEarned, 200);
      expect(copy.streakDays, 3);
      expect(copy.lastDailyLogin, isNull);
    });

    test('updates only the provided fields', () {
      final copy = base().copyWith(balance: 300, streakDays: 4);
      expect(copy.balance, 300);
      expect(copy.streakDays, 4);
      expect(copy.totalEarned, 200);
    });

    test('does not mutate the original model', () {
      final original = base();
      original.copyWith(balance: 999, totalEarned: 999);
      expect(original.balance, 100);
      expect(original.totalEarned, 200);
    });
  });

  group('toMap', () {
    test('contains all base fields', () {
      final map = base().toMap();
      expect(map['balance'], 100);
      expect(map['totalEarned'], 200);
      expect(map['streakDays'], 3);
    });

    test('lastDailyLogin is null when not set', () {
      final map = base().toMap();
      expect(map['lastDailyLogin'], isNull);
    });

    test('lastDailyLogin is stored as a Timestamp', () {
      final date = DateTime(2026, 7, 31, 10, 30);
      final map = base().copyWith(lastDailyLogin: date).toMap();
      expect(map['lastDailyLogin'], isA<Timestamp>());
      expect((map['lastDailyLogin'] as Timestamp).toDate(), date);
    });
  });
}
