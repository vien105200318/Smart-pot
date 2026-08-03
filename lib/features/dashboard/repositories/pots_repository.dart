import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/constants/wallet_constants.dart';
import '../../wallet/services/slot_service.dart';

class PotModel {
  final String docId;
  final int? slotIndex;
  final double moisture;
  final double temperature;
  final double humidity;
  final double waterLevel;
  final bool pumpStatus;
  final bool mistStatus;
  final bool isOnline;

  const PotModel({
    required this.docId,
    this.slotIndex,
    this.moisture = 0,
    this.temperature = 0,
    this.humidity = 0,
    this.waterLevel = 0,
    this.pumpStatus = false,
    this.mistStatus = false,
    this.isOnline = false,
  });

  factory PotModel.fromMap(String id, Map<String, dynamic> data) {
    return PotModel(
      docId: id,
      slotIndex: data['slotIndex'] as int?,
      moisture: (data['moisture'] as num?)?.toDouble() ?? 0,
      temperature: (data['temperature'] as num?)?.toDouble() ?? 0,
      humidity: (data['humidity'] as num?)?.toDouble() ?? 0,
      waterLevel: (data['waterLevel'] as num?)?.toDouble() ?? 0,
      pumpStatus: data['pumpStatus'] == true,
      mistStatus: data['mistStatus'] == true,
      isOnline: data['isOnline'] == true,
    );
  }
}

final potsRepositoryProvider = Provider<PotsRepository>((ref) {
  return PotsRepository(FirebaseFirestore.instance);
});

final potsStreamProvider = StreamProvider<List<PotModel>>((ref) {
  return ref.watch(potsRepositoryProvider).watchPots();
});

class ActiveSlotIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setActive(int index) => state = index;
}

final activeSlotIndexProvider =
    NotifierProvider<ActiveSlotIndexNotifier, int>(ActiveSlotIndexNotifier.new);
enum SlotState { locked, empty, connected }

class SlotInfo {
  final SlotState state;
  final PotModel? pot;
  const SlotInfo(this.state, {this.pot});
}

final slotStatusProvider = Provider<List<SlotInfo>>((ref) {
  final unlocked = ref.watch(unlockedSlotStreamProvider).value ?? const <int>[];
  final pots = ref.watch(potsStreamProvider).value ?? const <PotModel>[];

  final usedSlots =
      pots.where((p) => p.slotIndex != null).map((p) => p.slotIndex!).toSet();
  final unclaimed = pots.where((p) => p.slotIndex == null).toList();

  final slotToPot = <int, PotModel>{};
  for (var i = 0; i < WalletConstants.maxSlots; i++) {
    if (!unlocked.contains(i) || usedSlots.contains(i)) continue;
    if (unclaimed.isNotEmpty) {
      slotToPot[i] = unclaimed.removeAt(0);
    }
  }

  return List.generate(WalletConstants.maxSlots, (i) {
    if (usedSlots.contains(i)) {
      return SlotInfo(
          SlotState.connected,
          pot: pots.firstWhere((p) => p.slotIndex == i));
    }
    if (slotToPot.containsKey(i)) {
      return SlotInfo(SlotState.connected, pot: slotToPot[i]);
    }
    if (unlocked.contains(i)) return const SlotInfo(SlotState.empty);
    return const SlotInfo(SlotState.locked);
  });
});

final freeSlotsProvider = Provider<List<int>>((ref) {
  final statuses = ref.watch(slotStatusProvider);
  return [
    for (var i = 0; i < statuses.length; i++)
      if (statuses[i].state == SlotState.empty) i,
  ];
});

class PotsRepository {
  final FirebaseFirestore _firestore;
  PotsRepository(this._firestore);

  Stream<List<PotModel>> watchPots() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value(const []);
    return _firestore
        .collection('pots')
        .where('ownerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      final pots = snapshot.docs
          .map((doc) => PotModel.fromMap(doc.id, doc.data()))
          .toList();
      pots.sort((a, b) => (a.slotIndex ?? 9999).compareTo(b.slotIndex ?? 9999));
      return pots;
    });
  }

  // Đọc trực tiếp từ Firestore — trả ô TRỐNG (đã mở, chưa có ESP).
  Future<List<int>> getFreeSlots() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final unlockedDoc =
        await _firestore.collection('users').doc(user.uid).get();
    final data = unlockedDoc.data() ?? {};
    final raw = data['unlockedSlots'];
    final unlocked = raw is List ? raw.cast<int>() : <int>[];

    final snapshot = await _firestore
        .collection('pots')
        .where('ownerId', isEqualTo: user.uid)
        .get();
    final used = snapshot.docs
        .map((d) => d.data()['slotIndex'] as int?)
        .whereType<int>()
        .toSet();

    return [
      for (var i = 0; i < WalletConstants.maxSlots; i++)
        if (unlocked.contains(i) && !used.contains(i)) i,
    ];
  }


  Future<void> claimFreeSlots() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final unlockedDoc =
        await _firestore.collection('users').doc(user.uid).get();
    final data = unlockedDoc.data() ?? {};
    final raw = data['unlockedSlots'];
    final unlocked = raw is List ? raw.cast<int>() : <int>[];

    final snapshot = await _firestore
        .collection('pots')
        .where('ownerId', isEqualTo: user.uid)
        .get();
    final pots = snapshot.docs
        .map((d) => PotModel.fromMap(d.id, d.data()))
        .toList();
    final used =
        pots.where((p) => p.slotIndex != null).map((p) => p.slotIndex!).toSet();

    for (final pot in pots.where((p) => p.slotIndex == null)) {
      int? target;
      for (var i = 0; i < WalletConstants.maxSlots; i++) {
        if (unlocked.contains(i) && !used.contains(i)) {
          target = i;
          break;
        }
      }
      if (target == null) continue;
      await _firestore
          .collection('pots')
          .doc(pot.docId)
          .update({'slotIndex': target});
      used.add(target);
    }
  }
}