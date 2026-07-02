import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'services/notification_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Khởi tạo Firebase nếu chưa có
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    }
    
    // Kiểm tra trạng thái
    final doc = await FirebaseFirestore.instance.collection('pots').doc('pot_001').get();
    final isOnline = doc.data()?['isOnline'] ?? true;

    if (isOnline == false) {
      // Cần khởi tạo lại NotificationService trong background task
      await NotificationService.initialize();
      await NotificationService.showLocalNotification(
        id: 999,
        title: "Cảnh báo!",
        body: "Thiết bị ESP32 đã Offline!",
      );
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.initialize();
  
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  
  // Test thử sau 5 giây
  await Workmanager().registerOneOffTask(
    "1", 
    "checkDeviceStatusTask", 
    initialDelay: const Duration(seconds: 5),
  );

  runApp(const ProviderScope(child: SmartPotApp()));
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