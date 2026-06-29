import 'package:flutter/material.dart';

class DevicesTab extends StatelessWidget {
  const DevicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connected Devices',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your hardware components and sensors.',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Danh sách các thiết bị
            Expanded(
              child: ListView(
                children: [
                  _buildDeviceCard(
                    icon: Icons.memory,
                    title: 'ESP32 Development Board',
                    subtitle: 'Wi-Fi Module • IP: 192.168.1.45',
                    status: 'Online',
                    statusColor: const Color(0xFF00C896),
                  ),
                  const SizedBox(height: 16),
                  _buildDeviceCard(
                    icon: Icons.developer_board,
                    title: 'Custom Two-Layer PCB',
                    subtitle: 'Main Controller Unit • FW: v1.2',
                    status: 'Online',
                    statusColor: const Color(0xFF00C896),
                  ),
                  const SizedBox(height: 16),
                  _buildDeviceCard(
                    icon: Icons.water_drop,
                    title: 'Water Pump Relay',
                    subtitle: 'GPIO 4 • Auto-mode',
                    status: 'Standby',
                    statusColor: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 16),
                  _buildDeviceCard(
                    icon: Icons.sensors_off,
                    title: 'External Temp Sensor',
                    subtitle: 'I2C Bus • Battery: 5%',
                    status: 'Offline',
                    statusColor: Colors.redAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
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
          
          // information device 
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle, 
                  style: const TextStyle(color: Colors.white54, fontSize: 13)
                ),
              ],
            ),
          ),
          
          //  device status
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