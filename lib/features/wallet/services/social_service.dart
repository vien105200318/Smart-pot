import 'package:share_plus/share_plus.dart';



class SocialService {
  // claim share app
  static const int shareReward = 20;
  // claim whem friend sigin from link aff
  static const int inviteReward = 50;

  Future<bool> shareApp() async {
    final result = await Share.share(
      '🌱 Smart Pot - chăm cây thông minh của bạn! '
      'https://smartpot.example.com?ref=myUserId',
    );
    return result.status == ShareResultStatus.success;
  }
} 

