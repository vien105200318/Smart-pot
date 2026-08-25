import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pot/core/widgets/shimmer_box.dart';
import '../providers/wallet_provider.dart';
import '../repositories/wallet_repository.dart';
import '../services/daily_login_service.dart';

class DailyLoginCard extends ConsumerStatefulWidget {
  const DailyLoginCard({super.key});

  @override
  ConsumerState<DailyLoginCard> createState() => _DailyLoginCardState();
}

class _DailyLoginCardState extends ConsumerState<DailyLoginCard> {
  bool _isClaiming = false;

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletStreamProvider).value;

    if (wallet == null) {
      return ShimmerBox(
        width: double.infinity,
        height: 150,
        radius: BorderRadius.circular(16),
      );
    }

    final service = DailyLoginService();
    final claimed = service.hasClaimedToday(wallet.lastDailyLogin);
    final nextStreak = service.calculateNewStreak(
      lastLogin: wallet.lastDailyLogin,
      oldStreak: wallet.streakDays,
    );
    final reward = service.calculateReward(nextStreak);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month, color: Color(0xFF00C896)),
              const SizedBox(width: 10),
              Text('Điểm danh hằng ngày',
                  style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(DailyLoginService.weekLength, (i) {
              final isDone = i < wallet.streakDays;
              return Expanded(child: _dayDot(active: isDone, highlight: i == nextStreak - 1));
            }),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(claimed ? 'Đã nhận hôm nay' : 'Nhận $reward greenCoins',
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 15, fontWeight: FontWeight.w600)),
                  Text('Streak: ${wallet.streakDays} ngày',
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                ],
              ),
              SizedBox(
                height: 40,
                child: claimed
                    ? const Chip(
                        avatar: Icon(Icons.check, color: Colors.black87, size: 16),
                        label: Text('Đã nhận'),
                        backgroundColor: Color(0xFF00C896),
                        side: BorderSide.none,
                      )
                    : ElevatedButton(
                        onPressed: _isClaiming ? null : _claim,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00C896),
                          foregroundColor: Colors.black87,
                          disabledBackgroundColor: const Color(0xFF00C896).withOpacity(0.3),
                        ),
                        child: _isClaiming
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2),
                              )
                            : const Text('Nhận', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _claim() async {
    setState(() => _isClaiming = true);
    try {
      ref.invalidate(dailyLoginClaimProvider);
      await ref.read(dailyLoginClaimProvider.future);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  Widget _dayDot({required bool active, required bool highlight}) {
    return Container(
      height: 6,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: highlight
            ? Colors.orangeAccent
            : active
                ? const Color(0xFF00C896)
                : Theme.of(context).colorScheme.outlineVariant,
      ),
    );
  }
}
