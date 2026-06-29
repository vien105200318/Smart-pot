import 'package:flutter/material.dart';

class CameraTab extends StatelessWidget {
  const CameraTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_outlined, size: 80, color: Color(0xFF00C896)),
          SizedBox(height: 16),
          Text('Camera', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
          Text('Giao diện Livestream đang xây dựng...', style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}