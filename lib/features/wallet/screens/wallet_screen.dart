import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/wallet_card.dart';
import '../widgets/daily_login_card.dart';
import '../widgets/quests_list.dart';
import '../services/social_service.dart';
import '../repositories/wallet_repository.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: const Text('Ví greenCoins',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WalletCard(),
            const SizedBox(height: 20),
            const DailyLoginCard(),
            const SizedBox(height: 20),
            const QuestsList(),
            const SizedBox(height: 20),
            _EarnMoreSection(),
            const SizedBox(height: 24),
            const _TransactionList(),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  const _TransactionList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionStreamProvider);

    return transactions.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (docs) {
        if (docs.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lịch sử giao dịch',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...docs.map((doc) => _TransactionTile(data: doc.data() as Map<String, dynamic>)),
          ],
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> data;

  const _TransactionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final amount = (data['amount'] ?? 0) as int;
    final type = data['type'] ?? 'earn';
    final reason = data['reason'] ?? 'unknown';
    final isEarn = type == 'earn';
    final color = isEarn ? const Color(0xFF00C896) : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(isEarn ? Icons.add_circle : Icons.remove_circle, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(_reasonLabel(reason),
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
          Text('${isEarn ? '+' : ''}$amount',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  String _reasonLabel(String reason) {
    switch (reason) {
      case 'daily_login':
        return 'Điểm danh hằng ngày';
      case 'quest_complete':
        return 'Hoàn thành nhiệm vụ';
      case 'share_app':
        return 'Chia sẻ ứng dụng';
      case 'slot_unlock':
        return 'Mở khóa ô chậu';
      default:
        return reason;
    }
  }
}

class _EarnMoreSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kiếm thêm coins',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _EarnTile(
          icon: Icons.share,
          color: Colors.blueAccent,
          title: 'Chia sẻ Smart Pot',
          subtitle: 'Mời bạn bè cùng chăm cây',
          reward: '+20 coins',
          onTap: () async {
            final shared = await SocialService().shareApp();
            if (shared && context.mounted) {
              await ref.read(walletRepositoryProvider).addCoins(SocialService.shareReward, reason: 'share_app');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('+20 greenCoins!'), backgroundColor: Color(0xFF00C896)),
              );
            }
          },
        ),
        const SizedBox(height: 12),
        _EarnTile(
          icon: Icons.person_add,
          color: Colors.purpleAccent,
          title: 'Mời bạn bè',
          subtitle: 'Bạn bè đăng ký qua link của bạn',
          reward: '+50 coins',
          onTap: () => _showInviteDialog(context, ref),
        ),
        const SizedBox(height: 12),
        _EarnTile(
          icon: Icons.play_circle_outline,
          color: Colors.orangeAccent,
          title: 'Xem quảng cáo',
          subtitle: 'Nhận coins sau khi xem video',
          reward: '+5 coins',
          onTap: () {
            // TODO: Ads integration
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sắp có sẵn!'), backgroundColor: Colors.orangeAccent),
            );
          },
        ),
      ],
    );
  }

  void _showInviteDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Mời bạn bè', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Email bạn bè',
            labelStyle: TextStyle(color: Colors.white54),
            hintText: 'friend@example.com',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C896)),
            onPressed: () async {
              final email = controller.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(ctx);
              final success = await SocialService().inviteFriend(email);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Đã gửi lời mời! (+50 khi bạn bè tham gia)' : 'Lỗi gửi lời mời'),
                    backgroundColor: success ? const Color(0xFF00C896) : Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text('Gửi', style: TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}

class _EarnTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String reward;
  final VoidCallback onTap;

  const _EarnTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.reward,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            Text(reward, style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}