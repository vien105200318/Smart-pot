import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/wallet_constants.dart';
import '../repositories/wallet_repository.dart';


final slotServiceProvider = Provider<SlotService>((ref){
  return SlotService(FirebaseFirestore.instance, ref.watch(walletRepositoryProvider));
});

final unlockedSlotStreamProvider = StreamProvider<List<int>>((ref) {
  final service = ref.watch(slotServiceProvider);
  return service.getUnlockedSlotsStream();
});

class SlotService {
  final FirebaseFirestore _firestore;
  final WalletRepository _walletRepository;


  SlotService(this._firestore, this._walletRepository);

  // ref to list user box

  DocumentReference get _userDoc {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null){
      throw Exception('no login');
    }
    return _firestore.collection('users').doc(user.uid);
  }
  // get list slot open
  Future<List<int>> getUnlockedSlots() async {
    final doc = await _userDoc.get();
    if (!doc.exists) return [];

    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawList = data['unlockedSlots'] as List? ?? [];
    return rawList.cast<int>();
  }

  // stream list slot open
  Stream<List<int>> getUnlockedSlotsStream() async* {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      yield [0];
      return;
    }
    yield* _userDoc.snapshots().map((doc) {
      if (!doc.exists) return [0];
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final raw = data['unlockedSlots'] as List? ?? [0];
      return raw.cast<int>();
    });
  }

  // check coin

  Future<bool> canUnlock() async {
    final balance = await _walletRepository.getBalance();
    return balance >= WalletConstants.slotCost;
  }
    
  // unlock slot

  Future<bool> unlockSlot(int slotIndex) async {
  final balance = await _walletRepository.getBalance();
  if (balance < WalletConstants.slotCost) return false;

  await _userDoc.update({
    'balance': FieldValue.increment(-WalletConstants.slotCost),
    'unlockedSlots': FieldValue.arrayUnion([slotIndex]),
  });
  return true;
  }

}