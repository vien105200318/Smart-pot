import 'package:flutter/material.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings_outlined, size: 80, color: Color(0xFF00C896)),
          SizedBox(height: 16),
          Text('Settings', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          Text('Giao diện cài đặt và tài khoản...', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}