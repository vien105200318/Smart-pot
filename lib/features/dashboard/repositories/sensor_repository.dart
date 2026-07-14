import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Stream.value(_defaultEmptyData()); 
    }

    return _firestore
        .collection('pots')
        .where('ownerId', isEqualTo: user.uid) 
        .limit(1) 
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
          final data = snapshot.docs.first.data();
          final potId = snapshot.docs.first.id;
          data['docId'] = potId;
          
          FirebaseMessaging.instance.subscribeToTopic('pot_$potId');
          
          return data;
        }
      return _defaultEmptyData();
    });
  }

  Future<void> triggerWaterPump(bool isOn) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');

      final snapshot = await _firestore.collection('pots')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'pumpStatus': isOn,
        });
      } else {
        throw Exception('Không tìm thấy thiết bị nào của bạn!');
      }
    } catch (e) {
      throw Exception('Lỗi bật máy bơm: $e');
    }
  }

  Future<void> triggerMister(bool isOn) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Chưa đăng nhập');

      final snapshot = await _firestore.collection('pots')
          .where('ownerId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        await snapshot.docs.first.reference.update({
          'mistStatus': isOn,
        });
      } else {
        throw Exception('Không tìm thấy thiết bị nào của bạn!');
      }
    } catch (e) {
      throw Exception('Lỗi bật phun sương: $e');
    }
  }

  Map<String, dynamic> _defaultEmptyData() {
    return {
      'moisture': 0.0,
      'temperature': 0.0,
      'humidity': 0.0,
      'waterLevel': 0.0,
      'pumpStatus': false,
      'mistStatus': false,
      'isOnline': false,
    };
  }
}