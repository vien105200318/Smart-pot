import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pot/core/widgets/shimmer_box.dart';
import 'package:smart_pot/core/widgets/error_state_widget.dart';
import 'package:smart_pot/l10n/app_localizations.dart';
import '../repositories/quest_repository.dart';
import '../repositories/wallet_repository.dart';

class QuestsList extends ConsumerWidget {
  const QuestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questStreamProvider);
    final lang = AppLocalizations.of(context)!;

    return quests.when(
      loading: () => _buildQuestsSkeleton(),
      error: (e, _) {
        debugPrint('Quests stream lỗi: $e');
        return ErrorStateWidget(
          title: 'Không tải được nhiệm vụ',
          onRetry: () => ref.invalidate(questStreamProvider),
        );
      },
      data: (docs) {
        if (docs.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(lang.questsTitle,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...docs.map((doc) => _QuestTile(data: doc.data() as Map<String, dynamic>, questId: doc.id)),
          ],
        );
      },
    );
  }

  Widget _buildQuestsSkeleton() {
    return Column(
      children: List.generate(
        2,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ShimmerBox(
            width: double.infinity,
            height: 130,
            radius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _QuestTile extends ConsumerStatefulWidget {
  final Map<String, dynamic> data;
  final String questId;

  const _QuestTile({required this.data, required this.questId});

  @override
  ConsumerState<_QuestTile> createState() => _QuestTileState();
}

class _QuestTileState extends ConsumerState<_QuestTile> {
  bool _isClaiming = false;

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final type = widget.data['type'] ?? '';
    final target = (widget.data['target'] ?? 1) as int;
    final progress = (widget.data['progress'] ?? 0) as int;
    final reward = (widget.data['reward'] ?? 0) as int;
    final isCompleted = widget.data['isCompleted'] ?? false;
    final claimed = widget.data['claimed'] ?? false;
    final canClaim = isCompleted && !claimed;

    final title = _questTitle(type, target, lang);
    final desc = _questDesc(type, target, lang);
    final value = (progress / (target == 0 ? 1 : target)).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canClaim
              ? const Color(0xFF00C896)
              : (isCompleted
                  ? const Color(0xFF00C896).withOpacity(0.5)
                  : colorScheme.outlineVariant),
          width: canClaim ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ),
              if (canClaim)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00C896), Color(0xFF007558)]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(lang.questReady,
                      style: const TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.bold)),
                )
              else if (isCompleted)
                const Icon(Icons.check_circle, color: Color(0xFF00C896), size: 20)
              else
                Icon(Icons.monetization_on_outlined, color: Colors.orangeAccent, size: 20),
              const SizedBox(width: 8),
              Text('$reward', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: colorScheme.outlineVariant,
              valueColor: AlwaysStoppedAnimation(canClaim ? Colors.orangeAccent : const Color(0xFF00C896)),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$progress / $target',
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              if (canClaim)
                ElevatedButton(
                  onPressed: _isClaiming ? null : () => _claimQuest(reward),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C896),
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: _isClaiming
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2),
                        )
                      : Text(lang.questClaim, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _claimQuest(int reward) async {
    setState(() => _isClaiming = true);
    try {
      final claimed = await ref.read(questRepositoryProvider).claimQuest(widget.questId);
      if (claimed) {
        await ref.read(walletRepositoryProvider).addCoins(reward, reason: 'quest_complete');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('+$reward greenCoins!'), backgroundColor: const Color(0xFF00C896)),
          );
        }
      }
    } catch (e) {
      debugPrint('Claim quest lỗi: $e');
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  String _questTitle(String type, int target, AppLocalizations lang) {
    if (type == 'waterPlant') {
      return target >= 3 ? lang.waterStreakQuestTitle : lang.waterQuestTitle;
    }
    if (type == 'dailyLogin') return lang.dailyLoginQuestTitle;
    return type;
  }

  String _questDesc(String type, int target, AppLocalizations lang) {
    if (type == 'waterPlant') {
      return target >= 3 ? lang.waterStreakQuestDesc : lang.waterQuestDesc;
    }
    if (type == 'dailyLogin') return lang.dailyLoginQuestDesc;
    return '';
  }
}
