import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pot/core/widgets/error_state_widget.dart';
import 'package:smart_pot/l10n/app_localizations.dart';
import 'repositories/sensor_repository.dart';

class DevicesTab extends ConsumerWidget {
  const DevicesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sensorAsyncValue = ref.watch(sensorStreamProvider);
    final lang = AppLocalizations.of(context)!; 

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.connectedDevices,
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              lang.devicesDesc,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16),
            ),
            const SizedBox(height: 24),
      
            Expanded(
              child: sensorAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF00C896))),
                error: (error, stack) {
                  debugPrint('Devices stream lỗi: $error');
                  return ErrorStateWidget(
                    title: 'Không tải được thiết bị',
                    onRetry: () => ref.invalidate(sensorStreamProvider),
                  );
                },
                data: (data) {
                  final bool isOnline = data['isOnline'] ?? false;
                  final bool isWatering = data['pumpStatus'] ?? false;
                  final bool isMisting = data['mistStatus'] ?? false;

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildDeviceCard(
                        context: context,
                        icon: Icons.memory,
                        title: lang.esp32Board,
                        subtitle: 'Wi-Fi Module • IP: 192.168.1.45',
                        status: isOnline ? lang.online : lang.offline,
                        statusColor: isOnline ? const Color(0xFF00C896) : Colors.redAccent,
                        isActive: isOnline,
                      ),
                      const SizedBox(height: 16),

                      _buildDeviceCard(
                        context: context,
                        icon: Icons.water_drop,
                        title: lang.waterPumpRelay,
                        subtitle: 'GPIO 4 • 5V DC Pump',
                        status: isWatering ? lang.watering : (isOnline ? lang.standby : lang.offline),
                        statusColor: isWatering ? Colors.blueAccent : (isOnline ? Colors.orangeAccent : Colors.redAccent),
                        isActive: isWatering,
                      ),
                      const SizedBox(height: 16),

                      _buildDeviceCard(
                        context: context,
                        icon: Icons.cloud,
                        title: lang.mistMaker,
                        subtitle: 'GPIO 5 • 24V Humidifier',
                        status: isMisting ? lang.misting : (isOnline ? lang.standby : lang.offline),
                        statusColor: isMisting ? Colors.purpleAccent : (isOnline ? Colors.orangeAccent : Colors.redAccent),
                        isActive: isMisting,
                      ),
                      const SizedBox(height: 16),

                      _buildDeviceCard(
                        context: context,
                        icon: Icons.sensors,
                        title: lang.envSensors,
                        subtitle: 'DHT11 & Capacitive Soil',
                        status: isOnline ? lang.reading : lang.offline,
                        statusColor: isOnline ? const Color(0xFF00C896) : Colors.redAccent,
                        isActive: isOnline,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required bool isActive,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? statusColor.withOpacity(0.5)
              : colorScheme.outlineVariant,
          width: isActive ? 1.5 : 1.0,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: statusColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ] : [],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: statusColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.circle, color: statusColor, size: 12),
              const SizedBox(height: 4),
              Text(
                status, 
                style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)
              ),
            ],
          )
        ],
      ),
    );
  }
}