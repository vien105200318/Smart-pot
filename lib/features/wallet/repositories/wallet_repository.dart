import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/green_coin_model.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(FirebaseFirestore.instance);
});

final walletStreamProvider = StreamProvider<GreenCoinModel>((ref) async* {
  final repository = ref.watch(walletRepositoryProvider);
  await repository.ensureWalletDoc();
  yield* repository.getWalletStream();
});


class WalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepository(this._firestore);
// user ID 
String? get _userId => FirebaseAuth.instance.currentUser?.uid;
// referent den document walet cua user

DocumentReference get _walletDoc => _firestore.collection('users').doc(_userId);




// lay string wallet realtime 


Stream<GreenCoinModel> getWalletStream() {
  if (_userId == null) {
    return Stream.value(GreenCoinModel(
      userId: '',
      balance: 0,
      totalEarned: 0,
      streakDays: 0,
    ));
  }
  return _walletDoc.snapshots().map((doc){
    if (doc.exists){
      return GreenCoinModel.fromFireStore(doc);
    }
    return GreenCoinModel(
      userId: '',
      balance: 0,
      totalEarned: 0,
      streakDays: 0,
    );



  });

}

// check balance hien tai


Future<int> getBalance() async {
  if (_userId == null) return 0;
  
  final doc = await _walletDoc.get();
  if (!doc.exists) return 0;

  final data = doc.data() as Map<String, dynamic>? ?? {};
  return data['balance'] ?? 0;
}
// đảm bảo doc ví tồn tại (tạo lần đầu)
Future<void> ensureWalletDoc() async {
  if (_userId == null) return;

  final doc = await _walletDoc.get();
  if (doc.exists) return;

  await _walletDoc.set({
    'balance': 0,
    'totalEarned': 0,
    'streakDays': 0,
    'unlockedSlots': [0], // ô chậu đầu tiên mặc định mở
  });
}

// + coins 


Future<void> addCoins(int amount, {String reason = 'unknown'}) async {
    if (_userId == null) throw Exception('Chưa đăng nhập');
    if (amount <= 0) throw Exception('Số coin phải lớn hơn 0');

    await ensureWalletDoc();

    await _walletDoc.set({
      'balance': FieldValue.increment(amount),
      'totalEarned': FieldValue.increment(amount),
    }, SetOptions(merge: true));
  }
// - coins

Future<bool> spendCoins(int amount, {String reason = 'unknown'}) async {
    if (_userId == null) throw Exception('Chưa đăng nhập');
    if (amount <= 0) throw Exception('Số coin phải lớn hơn 0');

    final currentBalance = await getBalance();
    if (currentBalance < amount) return false;

    await _walletDoc.update({
      'balance': FieldValue.increment(-amount),
    });
    return true;
  }

  //daily login update 
  Future<void> updateDailyLogin({
    required DateTime loginDate,
    required int newStreak,
  }) async {
    if (_userId == null) throw Exception('Chưa đăng nhập');

    await _walletDoc.set({
      'lastDailyLogin': Timestamp.fromDate(loginDate),
      'streakDays': newStreak,
    }, SetOptions(merge: true));
  }

}



