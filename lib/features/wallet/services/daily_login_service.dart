class DailyLoginService {
  static const int firstDayReward = 10;
  static const int consecutiveDayReward = 5;
  static const int weekStreakBonus = 50;
  static const int weekLength = 7;

  bool hasClaimedToday(DateTime? lastLogin) {
    if (lastLogin == null) return false;

    final now = DateTime.now();
    final lastLoginDay = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
    final today = DateTime(now.year, now.month, now.day);

    return lastLoginDay == today;
  }

  int calculateNewStreak({
    required DateTime? lastLogin,
    required int oldStreak,
  }) {
    if (lastLogin == null) return 1;

    final now = DateTime.now();
    final lastLoginDay = DateTime(lastLogin.year, lastLogin.month, lastLogin.day);
    final today = DateTime(now.year, now.month, now.day);
    final diffDays = today.difference(lastLoginDay).inDays;

    if (diffDays == 1) return oldStreak + 1;

    return 1;
  }

  int calculateReward(int streak) {
    if (streak == 1) return firstDayReward;
    if (streak == weekLength) return weekStreakBonus;
    return consecutiveDayReward;
  }
}