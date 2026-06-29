import 'package:flutter/material.dart';

class DevicesTab extends StatelessWidget {
  const DevicesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.sensors, size: 80, color: Color(0xFF00C896)),
          SizedBox(height: 16),
          Text('Devices', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          Text('Giao diện quản lý thiết bị...', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}