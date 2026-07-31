import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/quest_repository.dart';
import '../repositories/wallet_repository.dart';
import '../services/social_service.dart';
import 'daily_login_card.dart';
import 'quests_list.dart';
import 'wallet_card.dart';

Future<void> showWalletBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const WalletBottomSheet(),
  );
}

class WalletBottomSheet extends ConsumerStatefulWidget {
  const WalletBottomSheet({super.key});

  @override
  ConsumerState<WalletBottomSheet> createState() => _WalletBottomSheetState();
}

class _WalletBottomSheetState extends ConsumerState<WalletBottomSheet> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(questRepositoryProvider).ensureDefaultQuests());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF0D1117),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ví greenCoins',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  const WalletCard(),
                  const SizedBox(height: 20),
                  const DailyLoginCard(),
                  const SizedBox(height: 20),
                  const QuestsList(),
                  const SizedBox(height: 20),
                  _shareTile(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleShare() async {
    final shared = await SocialService().shareApp();
    if (!shared || !mounted) return;
    await ref.read(walletRepositoryProvider).addCoins(SocialService.shareReward, reason: 'share_app');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('+20 greenCoins!'), backgroundColor: Color(0xFF00C896)),
      );
    }
  }

  Widget _shareTile() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.share, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chia sẻ Smart Pot',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 2),
                Text('Mời bạn bè cùng chăm cây', style: TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          TextButton(
            onPressed: _handleShare,
            child: const Text('+20',
                style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
