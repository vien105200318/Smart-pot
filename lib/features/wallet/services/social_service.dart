import 'package:share_plus/share_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SocialService {
  static const int shareReward = 20;
  static const int inviteReward = 50;

  Future<bool> shareApp() async {
    final result = await Share.share(
      '🌱 Smart Pot - chăm cây thông minh của bạn! '
      'https://smartpot.example.com?ref=myUserId',
    );
    return result.status == ShareResultStatus.success;
  }

  Future<bool> inviteFriend(String friendEmail) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    try {
      await FirebaseFirestore.instance
          .collection('invitations')
          .doc(friendEmail)
          .set({
        'inviterId': currentUser.uid,
        'inviterEmail': currentUser.email,
        'invitedEmail': friendEmail,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}