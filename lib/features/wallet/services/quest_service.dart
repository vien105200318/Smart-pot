import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/quest_model.dart';
import '../utils/date_utils.dart';

final questServiceProvider = Provider<QuestService>((ref) {
  return QuestService(FirebaseFirestore.instance);
});

class QuestService {
  final FirebaseFirestore _firestore;

  QuestService(this._firestore);

  CollectionReference get _questsRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }
    return _firestore.collection('users').doc(user.uid).collection('quests');
  }

  Future<void> incrementProgress(QuestType type) async {
    final today = todayKey();
    final snapshot = await _questsRef.where('type', isEqualTo: type.name).get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    var changed = false;

    for (final doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      var isCompleted = data['isCompleted'] ?? false;
      var claimed = data['claimed'] ?? false;
      var progress = (data['progress'] ?? 0) as int;

      if ((data['dateKey'] ?? '') != today) {
        progress = 0;
        isCompleted = false;
        claimed = false;
        batch.update(doc.reference, {
          'dateKey': today,
          'progress': 0,
          'isCompleted': false,
          'claimed': false,
          'completedAt': null,
        });
        changed = true;
      }

      if (isCompleted || claimed) continue;

      final target = (data['target'] ?? 1) as int;
      final newProgress = progress + 1;
      final done = newProgress >= target;

      batch.update(doc.reference, {
        'dateKey': today,
        'progress': newProgress,
        'isCompleted': done,
        'completedAt': done ? FieldValue.serverTimestamp() : null,
      });
      changed = true;
    }

    if (changed) await batch.commit();
  }
}
