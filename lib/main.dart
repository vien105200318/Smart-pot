import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pot/core/theme/theme_provider.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'services/notification_service.dart';
import 'package:smart_pot/l10n/app_localizations.dart';
import 'package:smart_pot/core/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_pot/providers/prefs_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await setupPushNotifications();

  final prefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    child: const SmartPotApp(),
  ));
}

Future<void> setupPushNotifications() async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(alert: true, badge: true, sound: true);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    NotificationService.showLocalNotification(
      id: DateTime.now().millisecond,
      title: message.notification?.title ?? "Cảnh báo!",
      body: message.notification?.body ?? "Thiết bị có thay đổi trạng thái.",
    );
  });
}

class SmartPotApp extends ConsumerWidget {
  const SmartPotApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Smart Pot',
      themeMode: themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00C896),
          secondary: Color(0xFF007558),
          surface: Colors.white,
          onSurface: Color(0xFF1A1D21),
          surfaceContainerHighest: Color(0xFFEFF1F4),
          onSurfaceVariant: Color(0xFF57606A),
          outlineVariant: Color(0xFFE3E5E8),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C896),
          secondary: Color(0xFF007558),
          surface: Color(0xFF161B22),
          onSurface: Color(0xFFE6EDF3),
          surfaceContainerHighest: Color(0xFF21262D),
          onSurfaceVariant: Color(0xFF8B949E),
          outlineVariant: Color(0xFF30363D),
        ),
      ),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      routerConfig: ref.watch(goRouterProvider),
    );
  }
}
