import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';
import '../repositories/wallet_repository.dart';
import '../services/daily_login_service.dart';

Future<void> showDailyLoginDialog(BuildContext context, WidgetRef ref) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const DailyLoginDialog(),
  );
}

class DailyLoginDialog extends ConsumerStatefulWidget {
  const DailyLoginDialog({super.key});

  @override
  ConsumerState<DailyLoginDialog> createState() => _DailyLoginDialogState();
}

class _DailyLoginDialogState extends ConsumerState<DailyLoginDialog> with SingleTickerProviderStateMixin {
  bool _isClaiming = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletStreamProvider).value;

    if (wallet == null) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C896)));
    }

    final service = DailyLoginService();
    final claimed = service.hasClaimedToday(wallet.lastDailyLogin);
    final nextStreak = service.calculateNewStreak(
      lastLogin: wallet.lastDailyLogin,
      oldStreak: wallet.streakDays,
    );
    final reward = service.calculateReward(nextStreak);

    return Dialog(
      backgroundColor: const Color(0xFF161B22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Color(0xFF00C896), size: 28),
                const SizedBox(width: 12),
                const Text('Điểm danh hằng ngày',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
                  CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
                ),
                child: _buildCalendar(wallet.streakDays, nextStreak, claimed),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0D1117),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00C896), Color(0xFF007558)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('$reward',
                        style: const TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(claimed ? 'Đã nhận hôm nay' : 'Nhận hôm nay',
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                        Text('Streak ${wallet.streakDays} ngày | Sắp tới: $nextStreak ngày',
                            style: const TextStyle(color: Colors.white54, fontSize: 13)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 48,
                    child: claimed
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00C896),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check, color: Colors.black87, size: 20),
                                  SizedBox(width: 8),
                                  Text('Đã nhận', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: _isClaiming ? null : _claim,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00C896),
                              foregroundColor: Colors.black87,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                            ),
                            child: _isClaiming
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2),
                                  )
                                : const Text('NHẬN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(int currentStreak, int nextStreak, bool claimed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (i) {
        final isCompleted = i < currentStreak;
        final isNext = i == nextStreak - 1 && !claimed;
        final isToday = i == DateTime.now().weekday - 1;

        return Column(
          children: [
            Text(
              ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][i],
              style: TextStyle(color: isToday ? const Color(0xFF00C896) : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isCompleted
                    ? const LinearGradient(colors: [Color(0xFF00C896), Color(0xFF007558)])
                    : isNext
                        ? const LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange])
                        : null,
                color: !isCompleted && !isNext ? const Color(0xFF0D1117) : null,
                border: Border.all(
                  color: isNext ? Colors.orangeAccent : (isToday ? const Color(0xFF00C896) : Colors.white12),
                  width: isNext || isToday ? 2 : 1,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.black87, size: 20)
                    : Text('${i + 1}',
                        style: TextStyle(
                          color: isNext ? Colors.black87 : (isToday ? const Color(0xFF00C896) : Colors.white38),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )),
              ),
            ),
            const SizedBox(height: 4),
            if (isNext)
              const Text('NGÀY MAI', style: TextStyle(color: Colors.orangeAccent, fontSize: 9, fontWeight: FontWeight.bold))
            else if (isCompleted)
              const Text('ĐÃ NHẬN', style: TextStyle(color: Color(0xFF00C896), fontSize: 9,               fontWeight: FontWeight.bold))
            else if (isToday)
              const Text('HÔM NAY', style: TextStyle(color: Color(0xFF00C896), fontSize: 9, fontWeight: FontWeight.bold)),
          ],
        );
      }),
    );
  }

  Future<void> _claim() async {
    setState(() => _isClaiming = true);
    try {
      ref.invalidate(dailyLoginClaimProvider);
      await ref.read(dailyLoginClaimProvider.future);
      if (mounted) Navigator.pop(context);
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
}