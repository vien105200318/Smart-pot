import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:smart_pot/features/dashboard/widgets/metric_card.dart';
import 'package:smart_pot/features/dashboard/repositories/sensor_repository.dart'; 

import 'devices_tab.dart';
import 'camera_tab.dart';
import 'history_tab.dart';
import 'settings_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final sensorAsyncValue = ref.watch(sensorStreamProvider);

    final dashboardTab = SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: const DecorationImage(
                  image: AssetImage('assets/images/bg_welcome.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Luna', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                        Chip(
                          label: Text('Healthy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          backgroundColor: Color(0xFF00C896),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                    Text('Monstera Deliciosa', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            sensorAsyncValue.when(
              loading: () => const Center(
                child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: Color(0xFF00C896))),
              ),
              error: (error, stack) => Center(
                child: Text('Lỗi kết nối: $error', style: const TextStyle(color: Colors.redAccent)),
              ),
              data: (sensorData) {
                final moisture = (sensorData['moisture'] as num?)?.toDouble() ?? 0.0;
                final temperature = (sensorData['temperature'] as num?)?.toDouble() ?? 0.0;
                final humidity = (sensorData['humidity'] as num?)?.toDouble() ?? 0.0;
                final waterLevel = (sensorData['waterLevel'] as num?)?.toDouble() ?? 0.0;

                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    MetricCard(title: 'Soil Moisture', value: '${moisture.toStringAsFixed(0)}%', icon: Icons.water_drop_outlined, color: const Color(0xFF00C896), progress: moisture / 100.0),
                    MetricCard(title: 'Temperature', value: '${temperature.toStringAsFixed(1)}°C', icon: Icons.thermostat_outlined, color: Colors.orangeAccent, progress: temperature / 50.0),
                    MetricCard(title: 'Air Humidity', value: '${humidity.toStringAsFixed(0)}%', icon: Icons.air_outlined, color: Colors.blueAccent, progress: humidity / 100.0),
                    MetricCard(title: 'Water Tank', value: '${waterLevel.toStringAsFixed(0)}%', icon: Icons.opacity, color: Colors.tealAccent, progress: waterLevel / 100.0),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C896), foregroundColor: Colors.black87, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('Water Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white24), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('Mist Now', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF161B22), borderRadius: BorderRadius.circular(16)),
              child: const Row(
                children: [
                  Icon(Icons.wifi, color: Color(0xFF00C896)),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Online', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('WiFi: Strong • Sync: Real-time', style: TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          dashboardTab,          // Index 0
          const DevicesTab(),    // Index 1
          const CameraTab(),     // Index 2
          const HistoryTab(),    // Index 3
          const SettingsTab(),   // Index 4
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0D1117),
        selectedItemColor: const Color(0xFF00C896),
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Devices'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam_outlined), label: 'Camera'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
    );
  }
}