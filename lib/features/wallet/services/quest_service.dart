import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/quest_model.dart';

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

  /// Tăng progress cho quest cùng [type], tự động đánh dấu completed khi đủ target.
  /// Bỏ qua quest đã hoàn thành hoặc đã claim.
  Future<void> incrementProgress(QuestType type) async {
    final snapshot = await _questsRef.where('type', isEqualTo: type.name).get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    var changed = false;

    for (final doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final isCompleted = data['isCompleted'] ?? false;
      final claimed = data['claimed'] ?? false;
      if (isCompleted || claimed) continue;

      final target = (data['target'] ?? 1) as int;
      final progress = (data['progress'] ?? 0) as int;

      final newProgress = progress + 1;
      final done = newProgress >= target;

      batch.update(doc.reference, {
        'progress': newProgress,
        'isCompleted': done,
        'completedAt': done ? FieldValue.serverTimestamp() : null,
      });
      changed = true;
    }

    if (changed) await batch.commit();
  }
}
