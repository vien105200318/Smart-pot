import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundColor: Color(0xFF00C896),
                  child: Icon(Icons.person, size: 40, color: Colors.black87),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nguyễn Văn Viên',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('vien.nguyen@smartpot.com',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14)),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, color: Colors.white54),
                )
              ],
            ),
            const SizedBox(height: 40),
            const Text('DEVICE CONTROL',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 16),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pots')
                  .doc('pot_001')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Lỗi tải dữ liệu',
                      style: TextStyle(color: Colors.red));
                }

                bool isPumpOn = false;
                bool isMistOn = false;

                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  isPumpOn = data['pumpStatus'] ?? false;
                  isMistOn = data['mistStatus'] ?? false;
                }

                return Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.water_drop,
                      title: 'Water Pump',
                      subtitle: isPumpOn
                          ? 'Đang bơm nước...'
                          : 'Chạm để bơm thủ công',
                      color: const Color(0xFF00C896),
                      value: isPumpOn,
                      onChanged: (val) {
                        FirebaseFirestore.instance
                            .collection('pots')
                            .doc('pot_001')
                            .update({'pumpStatus': val});
                      },
                    ),
                    _buildSwitchTile(
                      icon: Icons.cloudy_snowing,
                      title: 'Mist System',
                      subtitle: isMistOn
                          ? 'Đang phun sương...'
                          : 'Chạm để bật sương',
                      color: Colors.lightBlueAccent,
                      value: isMistOn,
                      onChanged: (val) {
                        FirebaseFirestore.instance
                            .collection('pots')
                            .doc('pot_001')
                            .update({'mistStatus': val});
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('GENERAL',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildSettingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'On for all devices',
                color: Colors.blueAccent),
            _buildSettingsTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English',
                color: Colors.orangeAccent),
            _buildSettingsTile(
                icon: Icons.dark_mode_outlined,
                title: 'Appearance',
                subtitle: 'Dark Mode',
                color: Colors.purpleAccent),
            const SizedBox(height: 32),
            const Text('DEVICE',
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildSettingsTile(
                icon: Icons.wifi,
                title: 'Wi-Fi Configuration',
                subtitle: 'Manage ESP32 network',
                color: const Color(0xFF00C896)),
            _buildSettingsTile(
                icon: Icons.system_update,
                title: 'Firmware Update',
                subtitle: 'v1.2 (Up to date)',
                color: Colors.tealAccent),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();

                    if (context.mounted) {
                      context.go('/welcome');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi đăng xuất: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Log Out',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white38),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
      {required IconData icon,
      required String title,
      required String subtitle,
      required Color color,
      required bool value,
      required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: value
                  ? color.withOpacity(0.5)
                  : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: value ? color : Colors.white54,
                          fontSize: 13,
                          fontWeight:
                              value ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: color,
              activeTrackColor: color.withOpacity(0.3),
              inactiveThumbColor: Colors.white54,
              inactiveTrackColor: Colors.white12,
            ),
          ],
        ),
      ),
    );
  }
}