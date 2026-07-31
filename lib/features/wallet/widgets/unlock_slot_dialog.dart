import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/wallet_constants.dart';
import '../services/slot_service.dart';

class UnlockSlotDialog extends ConsumerWidget {
  final int slotIndex;

  const UnlockSlotDialog({super.key, required this.slotIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: const Color(0xFF161B22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text(
        'Mở khóa ô chậu',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock_open, color: Color(0xFF00C896), size: 48),
          const SizedBox(height: 16),
          const Text(
            'Mở khóa ô chậu mới để trồng thêm cây?',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00C896).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00C896).withOpacity(0.3)),
            ),
            child: Text(
              '${WalletConstants.slotCost} greenCoins',
              style: const TextStyle(
                color: Color(0xFF00C896),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          onPressed: () => _handleUnlock(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C896),
            foregroundColor: Colors.black87,
          ),
          child: const Text('Mở khóa', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Future<void> _handleUnlock(BuildContext context, WidgetRef ref) async {
    final slotService = ref.read(slotServiceProvider);
    final success = await slotService.unlockSlot(slotIndex);

    if (context.mounted) {
      Navigator.pop(context, success);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Đã mở khóa ô chậu!' : 'Không đủ greenCoins!'),
          backgroundColor: success ? const Color(0xFF00C896) : Colors.redAccent,
        ),
      );
    }
  }
}