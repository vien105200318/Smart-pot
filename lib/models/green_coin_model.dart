import 'package:cloud_firestore/cloud_firestore.dart';


class GreenCoinModel {
  final String userId;
  final int balance;
  final int totalEarned;
  final DateTime? lastDailyLogin;
  final int streakDays;

  GreenCoinModel({
    required this.userId,
    required this.balance,
    required this.totalEarned,
    this.lastDailyLogin,
    required this.streakDays
  });
  // firestorge function

  factory GreenCoinModel.fromFireStore(DocumentSnapshot doc){
    final data = doc.data() as Map<String, dynamic>? ??{};
    return GreenCoinModel(
      userId: doc.id, 
      balance: data['balance']?? 0, 
      totalEarned: data['totalEarned']?? 0, 
      lastDailyLogin: data['lastDailyLogin'] != null
        ? (data['lastDailyLogin'] as Timestamp).toDate()
        :null,              
      streakDays: data['streakDays']?? 0,
  );
  }
  // corverge to map

  Map<String, dynamic> toMap() {
    return{
      'balance' : balance,
      'totalEarned' : totalEarned,
      'lastDailyLogin' : lastDailyLogin != null
        ? Timestamp.fromDate(lastDailyLogin!)
        : null,

      'streakDays' : streakDays,
    };
  }

  // coppy new value 


  GreenCoinModel copyWith({
    int? balance,
    int? totalEarned,
    DateTime? lastDailyLogin,
    int? streakDays,
  }) {
    return GreenCoinModel(
            userId: userId,
            balance: balance ?? this.balance,
            totalEarned: totalEarned ?? this.totalEarned,
            lastDailyLogin: lastDailyLogin ?? this.lastDailyLogin,
            streakDays: streakDays ?? this.streakDays,
    );
  }
}


/* struct firestrorge affter create:
{
  "balance": 0,
  "totalEarned": 0,
  "lastDailyLogin": null,
  "streakDays": 0
}
*/



