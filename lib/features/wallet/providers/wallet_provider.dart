import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/quest_model.dart';
import '../repositories/wallet_repository.dart';
import '../services/quest_service.dart';

// selector balance
final walletBalanceProvider = Provider<int>((ref) {
  final wallet = ref.watch(walletStreamProvider);
  return wallet.maybeWhen(
    data: (model) => model.balance,
    orElse: () => 0,
  );
});

// selector streakDays
final walletStreakProvider = Provider<int>((ref) {
  final wallet = ref.watch(walletStreamProvider);
  return wallet.maybeWhen(
    data: (model) => model.streakDays,
    orElse: () => 0,
  );
});

// Provider  claim daily login
final dailyLoginClaimProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(walletRepositoryProvider);
  final wallet = ref.watch(walletStreamProvider).value;

  if (wallet == null) return;

  final now = DateTime.now();
  final lastLogin = wallet.lastDailyLogin;
  final today = DateTime(now.year, now.month, now.day);

  // skip
  if (lastLogin != null) {
    final lastLoginDay = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
    if (lastLoginDay == today) return;
  }

  // Streak + reward 
  final newStreak = _calculateNewStreak(
    lastLogin: lastLogin,
    oldStreak: wallet.streakDays,
    today: today,
  );
  final reward = _calculateReward(newStreak);

  await repository.addCoins(reward, reason: 'daily_login');
  await repository.updateDailyLogin(loginDate: now, newStreak: newStreak);

  // Hook quest dailyLogin
  await ref.read(questServiceProvider).incrementProgress(QuestType.dailyLogin);
});

// Logic  streak
int _calculateNewStreak({
  required DateTime? lastLogin,
  required int oldStreak,
  required DateTime today,
}) {
  if (lastLogin == null) return 1;
  final lastLoginDay = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
  final difference = today.difference(lastLoginDay).inDays;
  if (difference == 1) return oldStreak + 1;
  return 1;
}

// Logic  reward
int _calculateReward(int streak) {
  if (streak == 7) return 50;
  if (streak == 1) return 10;
  return 5;
}