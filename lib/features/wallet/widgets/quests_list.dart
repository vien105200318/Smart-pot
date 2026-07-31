import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pot/l10n/app_localizations.dart';
import '../repositories/quest_repository.dart';

class QuestsList extends ConsumerWidget {
  const QuestsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questStreamProvider);

    return quests.when(
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C896))),
      error: (e, _) => Text('Lỗi: $e', style: const TextStyle(color: Colors.redAccent)),
      data: (docs) {
        if (docs.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nhiệm vụ',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...docs.map((doc) => _QuestTile(data: doc.data() as Map<String, dynamic>)),
          ],
        );
      },
    );
  }
}

class _QuestTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _QuestTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final type = data['type'] ?? '';
    final target = (data['target'] ?? 1) as int;
    final progress = (data['progress'] ?? 0) as int;
    final reward = (data['reward'] ?? 0) as int;
    final isCompleted = data['isCompleted'] ?? false;

    final title = _questTitle(type, target, lang);
    final desc = _questDesc(type, target, lang);
    final value = (progress / (target == 0 ? 1 : target)).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? const Color(0xFF00C896).withOpacity(0.5) : Colors.white.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              Icon(isCompleted ? Icons.check_circle : Icons.monetization_on_outlined,
                  color: isCompleted ? const Color(0xFF00C896) : Colors.orangeAccent, size: 20),
              const SizedBox(width: 4),
              Text('$reward', style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00C896)),
            ),
          ),
          const SizedBox(height: 6),
          Text('$progress / $target', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
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
