import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'services/notification_service.dart';


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

  final settings = await messaging.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    await messaging.subscribeToTopic('all_users');
  }

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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false, 
      title: 'Smart Pot',
      routerConfig: ref.watch(goRouterProvider),
    );
  }
}