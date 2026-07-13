import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeNotifier extends Notifier<bool> {
  @override
  bool build() {
    return true; 
  }
  // change theme loop 
  void updateTheme(bool isDark) {
    state = isDark;
  }
}

final themeModeProvider = NotifierProvider<ThemeNotifier, bool>(() {
  return ThemeNotifier();
});