import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dashboard/device/wifi_setup_bottom_sheet.dart';
import '../../dashboard/repositories/pots_repository.dart';
import '../constants/wallet_constants.dart';
import '../widgets/unlock_slot_dialog.dart';
import '../widgets/wallet_bottom_sheet.dart';

class PotGardenScreen extends ConsumerStatefulWidget {
  const PotGardenScreen({super.key});

  @override
  ConsumerState<PotGardenScreen> createState() => _PotGardenScreenState();
}

class _PotGardenScreenState extends ConsumerState<PotGardenScreen> {
  @override
  void initState() {
    super.initState();
    // Gán slotIndex cho thiết bị CŨ (chưa có field) — chạy 1 lần khi vào tab
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(potsRepositoryProvider).claimFreeSlots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final slotStatuses = ref.watch(slotStatusProvider);
    final activeIndex = ref.watch(activeSlotIndexProvider);

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
                Text(
                  '${slotStatuses.where((s) => s.state != SlotState.locked).length} / ${WalletConstants.maxSlots}',
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Chạm ô trống để kết nối ESP · Chạm ô có cây để xem',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemCount: WalletConstants.maxSlots,
                itemBuilder: (context, index) {
                  return _SlotCell(
                    index: index,
                    info: slotStatuses[index],
                    isActive: activeIndex == index,
                  );
                },
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
  final SlotInfo info;
  final bool isActive;

  const _SlotCell({
    required this.index,
    required this.info,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (info.state) {
      case SlotState.locked:
        return _buildLocked(context, ref);
      case SlotState.empty:
        return _buildEmpty(context, ref);
      case SlotState.connected:
        return _buildConnected(context, ref);
    }
  }

  Widget _buildLocked(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        showDialog<bool>(
          context: context,
          builder: (context) => UnlockSlotDialog(slotIndex: index),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white38, size: 30),
            const SizedBox(height: 8),
            Text('${WalletConstants.slotCost}',
                style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text('Ô ${index + 1}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const WifiSetupBottomSheet(),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF00C896).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00C896).withOpacity(0.4),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline, color: Color(0xFF00C896), size: 32),
            const SizedBox(height: 8),
            Text('Ô ${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            const Text('Kết nối ESP',
                style: TextStyle(color: Color(0xFF00C896), fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildConnected(BuildContext context, WidgetRef ref) {
    final online = info.pot?.isOnline ?? false;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        ref.read(activeSlotIndexProvider.notifier).setActive(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF00C896).withOpacity(0.2)
              : const Color(0xFF00C896).withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? const Color(0xFF00C896)
                : const Color(0xFF00C896).withOpacity(0.6),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_florist,
                color: online ? const Color(0xFF00C896) : Colors.white38, size: 36),
            const SizedBox(height: 8),
            Text('Ô ${index + 1}',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(
              isActive ? 'Đang xem' : (online ? 'Online' : 'Offline'),
              style: TextStyle(
                color: isActive ? const Color(0xFF00C896) : Colors.white54,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}