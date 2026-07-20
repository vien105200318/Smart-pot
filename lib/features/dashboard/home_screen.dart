import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; 
import 'package:smart_pot/features/dashboard/widgets/metric_card.dart';
import 'package:smart_pot/features/dashboard/repositories/sensor_repository.dart'; 
import 'package:smart_pot/l10n/app_localizations.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final sensorAsyncValue = ref.watch(sensorStreamProvider);
    final lang = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // Nền tối
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BANNER LUNA
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
                  child: Text('Lỗi Firebase: $error', style: const TextStyle(color: Colors.redAccent)),
                ),
                data: (sensorData) {
                  final moisture = ((sensorData['moisture'] ?? sensorData['soil_moisture']) as num?)?.toDouble() ?? 0.0;
                  final temperature = (sensorData['temperature'] as num?)?.toDouble() ?? 0.0;
                  final humidity = ((sensorData['humidity'] ?? sensorData['air_humidity']) as num?)?.toDouble() ?? 0.0;
                  final waterLevel = (sensorData['waterLevel'] as num?)?.toDouble() ?? 0.0;

                  final bool isWatering = sensorData['pumpStatus'] ?? false;
                  final bool isMisting = sensorData['mistStatus'] ?? false;
                  final bool isOnline = sensorData['isOnline'] ?? false; 

                  return Column(
                    children: [
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1.3,
                        children: [
                          MetricCard(title: lang.soilMoisture, value: '${moisture.toStringAsFixed(0)}%', icon: Icons.water_drop_outlined, color: const Color(0xFF00C896), progress: moisture / 100.0),
                          MetricCard(title: lang.temperature, value: '${temperature.toStringAsFixed(1)}°C', icon: Icons.thermostat_outlined, color: Colors.orangeAccent, progress: temperature / 50.0),
                          MetricCard(title: lang.airHumidity, value: '${humidity.toStringAsFixed(0)}%', icon: Icons.air_outlined, color: Colors.blueAccent, progress: humidity / 100.0),
                          MetricCard(title: lang.waterTank, value: '${waterLevel.toStringAsFixed(0)}%', icon: Icons.opacity, color: Colors.tealAccent, progress: waterLevel / 100.0),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await ref.read(sensorRepositoryProvider).triggerWaterPump(!isWatering);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đồng bộ: $e'), backgroundColor: Colors.redAccent));
                                    }
                                  }
                                },
                                icon: isWatering
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.water_drop, size: 20),
                                label: Text(
                                  isWatering ? 'Watering...' : lang.waterNow,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isWatering ? Colors.blueAccent : const Color(0xFF00C896),
                                  foregroundColor: isWatering ? Colors.white : Colors.black87,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: isWatering ? 8 : 0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    await ref.read(sensorRepositoryProvider).triggerMister(!isMisting);
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đồng bộ: $e'), backgroundColor: Colors.redAccent));
                                    }
                                  }
                                },
                                icon: isMisting
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Icon(Icons.cloud, size: 20),
                                label: Text(
                                  isMisting ? 'Misting...' : 'Mist Now',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isMisting ? Colors.purpleAccent : Colors.transparent,
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: isMisting ? Colors.purpleAccent : Colors.white24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // TRẠNG THÁI MẠNG
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22), 
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isOnline 
                                ? const Color(0xFF00C896).withOpacity(0.3) 
                                : Colors.redAccent.withOpacity(0.3)
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isOnline ? Icons.wifi : Icons.wifi_off, 
                              color: isOnline ? const Color(0xFF00C896) : Colors.redAccent
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isOnline ? 'Online' : 'Offline', 
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold, 
                                    color: isOnline ? const Color(0xFF00C896) : Colors.redAccent
                                  )
                                ),
                                Text(
                                  isOnline ? 'WiFi: Connected • Sync: Real-time' : 'Device disconnected or sleeping', 
                                  style: const TextStyle(color: Colors.white54, fontSize: 12)
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}