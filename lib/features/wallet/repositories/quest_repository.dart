import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final questRepositoryProvider = Provider<QuestRepository>((ref) {
  return QuestRepository(FirebaseFirestore.instance);
});

final questStreamProvider = StreamProvider<List<QueryDocumentSnapshot>>((ref) {
  final repository = ref.watch(questRepositoryProvider);
  return repository.getQuestsStream();
});

class QuestRepository {
  final FirebaseFirestore _firestore;

  QuestRepository(this._firestore);

  CollectionReference get _questsRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('Chưa đăng nhập');
    }
    return _firestore.collection('users').doc(user.uid).collection('quests');
  }

  Stream<List<QueryDocumentSnapshot>> getQuestsStream() {
    return _questsRef.snapshots().map((snapshot) => snapshot.docs);
  }

  Future<void> ensureDefaultQuests() async {
    final existing = await _questsRef.limit(1).get();
    if (existing.docs.isNotEmpty) return;
    await createDefaultQuests();
  }

  Future<void> createDefaultQuests() async {
    final defaultQuests = [
      {
        'type': 'waterPlant',
        'reward': 20,
        'target': 1,
        'progress': 0,
        'isCompleted': false,
      },
      {
        'type': 'waterPlant',
        'reward': 50,
        'target': 3,
        'progress': 0,
        'isCompleted': false,
      },
      {
        'type': 'dailyLogin',
        'reward': 10,
        'target': 1,
        'progress': 0,
        'isCompleted': false,
      },
    ];

    final batch = _firestore.batch();
    for (final quest in defaultQuests) {
      batch.set(_questsRef.doc(), quest);
    }
    await batch.commit();
  }
}
