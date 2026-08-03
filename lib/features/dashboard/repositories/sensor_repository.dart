import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'pots_repository.dart';

final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return SensorRepository(FirebaseFirestore.instance);
});

final sensorStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final activeIndex = ref.watch(activeSlotIndexProvider);
  final pots = ref.watch(potsStreamProvider);
  return pots.when(
    loading: () => Stream.value(_defaultEmptyData()),
    error: (e, _) => Stream.value(_defaultEmptyData()),
    data: (list) => Stream.value(_pickActivePot(list, activeIndex)),
  );
});

Map<String, dynamic> _pickActivePot(List<PotModel> pots, int activeIndex) {
  if (pots.isEmpty) return _defaultEmptyData();

  PotModel? match;
  for (final p in pots) {
    if (p.slotIndex == activeIndex) {
      match = p;
      break;
    }
  }
  final pot = match ?? pots.first;

  FirebaseMessaging.instance.subscribeToTopic('pot_${pot.docId}');

  return {
    'docId': pot.docId,
    'moisture': pot.moisture,
    'temperature': pot.temperature,
    'humidity': pot.humidity,
    'waterLevel': pot.waterLevel,
    'pumpStatus': pot.pumpStatus,
    'mistStatus': pot.mistStatus,
    'isOnline': pot.isOnline,
  };
}

Map<String, dynamic> _defaultEmptyData() {
  return {
    'docId': '',
    'moisture': 0.0,
    'temperature': 0.0,
    'humidity': 0.0,
    'waterLevel': 0.0,
    'pumpStatus': false,
    'mistStatus': false,
    'isOnline': false,
  };
}

class SensorRepository {
  final FirebaseFirestore _firestore;
  SensorRepository(this._firestore);

  Future<void> triggerWaterPump(String docId, bool isOn) async {
    if (docId.isEmpty) throw Exception('Không tìm thấy thiết bị nào của bạn!');
    await _firestore.collection('pots').doc(docId).update({'pumpStatus': isOn});
  }

  Future<void> triggerMister(String docId, bool isOn) async {
    if (docId.isEmpty) throw Exception('Không tìm thấy thiết bị nào của bạn!');
    await _firestore.collection('pots').doc(docId).update({'mistStatus': isOn});
  }
}