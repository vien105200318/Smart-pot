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

  runApp(const ProviderScope(child: SmartPotApp()));
}

Future<void> setupPushNotifications() async {
  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

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
    final isDarkMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, 
      title: 'Smart Pot',
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.grey[100],
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF00C896),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF161B22),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C896),
        ),
      ),
      locale: locale, 
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}