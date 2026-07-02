import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return SensorRepository(FirebaseFirestore.instance);
});

final sensorStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final repository = ref.watch(sensorRepositoryProvider);
  return repository.getSensorDataStream();
});

class SensorRepository {
  final FirebaseFirestore _firestore;

  SensorRepository(this._firestore);

  Stream<Map<String, dynamic>> getSensorDataStream() {
    return _firestore
        .collection('pots')
        .doc('pot_001') 
        .snapshots() 
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return snapshot.data()!;
      }
      return {
        'moisture': 0.0,
        'temperature': 0.0,
        'humidity': 0.0,
        'waterLevel': 0.0,
        'pumpStatus': false,
        'mistStatus': false,
      };
    });
  }

  // Hàm điều khiển máy bơm nước
  Future<void> triggerWaterPump(bool isOn) async {
    try {
      await _firestore.collection('pots').doc('pot_001').update({
        'pumpStatus': isOn, 
      });
    } catch (e) {
      throw Exception('Lỗi bật máy bơm: $e');
    }
  }

  Future<void> triggerMister(bool isOn) async {
    try {
      await _firestore.collection('pots').doc('pot_001').update({
        'mistStatus': isOn, 
      });
    } catch (e) {
      throw Exception('Lỗi bật phun sương: $e');
    }
  }
}