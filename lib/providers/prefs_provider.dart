import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Phải override trong main()');
});
Future<bool> hasSeenOnboarding(SharedPreferences prefs) async {
  return prefs.getBool('has_seen_onboarding') ?? false;
}
