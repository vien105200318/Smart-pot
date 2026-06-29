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
      };
    });
  }
}