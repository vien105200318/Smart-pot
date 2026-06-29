import 'package:flutter/material.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_outlined, size: 80, color: Color(0xFF00C896)),
          SizedBox(height: 16),
          Text('History', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          Text('Giao diện biểu đồ thống kê...', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}