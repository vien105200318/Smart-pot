import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/wallet_constants.dart';
import '../services/slot_service.dart';
import '../widgets/unlock_slot_dialog.dart';
import '../widgets/wallet_bottom_sheet.dart';

class PotGardenScreen extends ConsumerWidget {
  const PotGardenScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(unlockedSlotStreamProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Vườn chậu cây',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => showWalletBottomSheet(context),
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00C896).withOpacity(0.15),
                      border: Border.all(color: const Color(0xFF00C896).withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.account_balance_wallet, color: Color(0xFF00C896), size: 20),
                  ),
                ),
                slots.when(
                  loading: () => const Text('...', style: TextStyle(color: Colors.white54)),
                  error: (e, _) => const SizedBox.shrink(),
                  data: (unlocked) => Text(
                    '${unlocked.length} / ${WalletConstants.maxSlots}',
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Mở khóa ô chậu để trồng thêm cây',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: slots.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C896))),
                error: (e, _) => Center(child: Text('Lỗi: $e', style: const TextStyle(color: Colors.redAccent))),
                data: (unlocked) => GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: WalletConstants.maxSlots,
                  itemBuilder: (context, index) {
                    return _SlotCell(index: index, unlocked: unlocked.contains(index));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotCell extends ConsumerWidget {
  final int index;
  final bool unlocked;
  const _SlotCell({required this.index, required this.unlocked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: unlocked
          ? null
          : () {
              showDialog<bool>(
                context: context,
                builder: (context) => UnlockSlotDialog(slotIndex: index),
              );
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: unlocked ? const Color(0xFF00C896).withOpacity(0.12) : const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: unlocked ? const Color(0xFF00C896).withOpacity(0.6) : Colors.white.withOpacity(0.08),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (unlocked) ...[
              const Icon(Icons.local_florist, color: Color(0xFF00C896), size: 36),
              const SizedBox(height: 8),
              Text('Ô ${index + 1}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ] else ...[
              const Icon(Icons.lock_outline, color: Colors.white38, size: 30),
              const SizedBox(height: 8),
              Text('${WalletConstants.slotCost}',
                  style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('Ô ${index + 1}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ],
        ),
      ),
    );
  }
}