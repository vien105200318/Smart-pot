import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/wallet_repository.dart';

class WalletCard extends ConsumerStatefulWidget {
  const WalletCard({super.key});

  @override
  ConsumerState<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends ConsumerState<WalletCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _balanceAnimation;
  int _displayedBalance = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _animateTo(int target) {
    _balanceAnimation = IntTween(begin: _displayedBalance, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() => _displayedBalance = _balanceAnimation.value);
      });
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletStreamProvider).value;

    if (wallet != null && wallet.balance != _displayedBalance && _controller.isCompleted) {
      _animateTo(wallet.balance);
    } else if (wallet != null && _displayedBalance == 0) {
      _displayedBalance = wallet.balance;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00C896), Color(0xFF007558)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C896).withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('greenCoins',
                  style: TextStyle(color: Colors.black87.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _displayedBalance.toString(),
            style: const TextStyle(color: Colors.black87, fontSize: 44, fontWeight: FontWeight.bold, height: 1),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stat('Đã kiếm', wallet?.totalEarned),
              const SizedBox(width: 24),
              _stat('Streak', wallet?.streakDays),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int? value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black87.withOpacity(0.6), fontSize: 12)),
        const SizedBox(height: 2),
        Text('$value', style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}