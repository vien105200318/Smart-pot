import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_pot/features/dashboard/device/wifi_setup_bottom_sheet.dart';
import 'package:smart_pot/core/providers/locale_provider.dart';
import 'package:smart_pot/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:smart_pot/core/utils/image_helper.dart';

class LanguageNotifier extends Notifier<String> {
  @override
  String build() => 'Tiếng Việt';
  
  void setLanguage(String lang) => state = lang;
}

final languageProvider = NotifierProvider<LanguageNotifier, String>(LanguageNotifier.new);

class NotificationNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  
  void setNoti(bool val) => state = val;
}

final notificationProvider = NotifierProvider<NotificationNotifier, bool>(NotificationNotifier.new);

class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}
class _SettingsTabState extends ConsumerState<SettingsTab> {
  Future<void> _updateAvatar() async {
    final File? image = await ImageHelper.pickImageFromGallery();
    
    if (image == null) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final url = await ImageHelper.uploadToCloudinary(image);
      
      if (url != null && currentUser != null) {
        final urlWithTimestamp = '$url?v=${DateTime.now().millisecondsSinceEpoch}';

        // update profile photoURL
        await currentUser.updatePhotoURL(urlWithTimestamp);
        await currentUser.reload();
        
        // update old posts
        final postsQuery = await FirebaseFirestore.instance
            .collection('posts')
            .where('uid', isEqualTo: currentUser.uid)
            .get();
            
        if (postsQuery.docs.isNotEmpty) {
          final batch = FirebaseFirestore.instance.batch();
          for (var doc in postsQuery.docs) {
            batch.update(doc.reference, {'avatar': urlWithTimestamp});
          }
          await batch.commit();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã cập nhật ảnh đại diện mới!'), backgroundColor: Color(0xFF00C896)));
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi tải ảnh lên!'), backgroundColor: Colors.redAccent));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent));
    }
  }
  User? user;
   @override
   void initState() {
     super.initState();
     user = FirebaseAuth.instance.currentUser;
  }

  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final currentUid = user?.uid ?? '';
    final displayName = user?.displayName ?? 'Người dùng Smart Pot';
    final email = user?.email ?? 'Chưa cập nhật email';
    final photoURL = user?.photoURL;
    final currentLocale = ref.watch(localeProvider);
    final lang = AppLocalizations.of(context)!;
    final currentLanguage = ref.watch(languageProvider);
    final isNotiEnabled = ref.watch(notificationProvider);
    
    String getLanguageName(Locale loc){
    if (loc.languageCode == 'vi') return 'Tiếng Việt';
      if (loc.languageCode == 'ja') return '日本語';
      return 'English';
    }

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Settings',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                GestureDetector(
                  onTap: _updateAvatar, 
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: photoURL != null 
                            ? NetworkImage(photoURL) 
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF00C896),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName,
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(email,
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showEditProfileDialog(context, displayName),
                  icon: const Icon(Icons.edit_outlined, color: Colors.white54),
                )
              ],
            ),
            const SizedBox(height: 40),
            const Text('DEVICE CONTROL',
                style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('pots')
                  .where('ownerId', isEqualTo: currentUid)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return const Text('Lỗi tải dữ liệu', style: TextStyle(color: Colors.red));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF00C896)));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.sensors_off, color: Colors.white38, size: 40),
                        const SizedBox(height: 12),
                        const Text('Chưa có thiết bị nào được kết nối', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('Vui lòng vào "Wi-Fi Configuration" để cài đặt.',
                          textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
                      ],
                    ),
                  );
                }

                final deviceDoc = snapshot.data!.docs.first;
                final data = deviceDoc.data() as Map<String, dynamic>;
                final String docId = deviceDoc.id;

                bool isPumpOn = data['pumpStatus'] ?? false;
                bool isMistOn = data['mistStatus'] ?? false;

                return Column(
                  children: [
                    _buildSwitchTile(
                      icon: Icons.water_drop,
                      title: 'Water Pump',
                      subtitle: isPumpOn ? 'Đang bơm nước...' : 'Chạm để bơm thủ công',
                      color: const Color(0xFF00C896),
                      value: isPumpOn,
                      onChanged: (val) => FirebaseFirestore.instance.collection('pots').doc(docId).update({'pumpStatus': val}),
                    ),
                    _buildSwitchTile(
                      icon: Icons.cloudy_snowing,
                      title: 'Mist System',
                      subtitle: isMistOn ? 'Đang phun sương...' : 'Chạm để bật sương',
                      color: Colors.lightBlueAccent,
                      value: isMistOn,
                      onChanged: (val) => FirebaseFirestore.instance.collection('pots').doc(docId).update({'mistStatus': val}),
                    ),
                    const SizedBox(height: 32),
                    const Text('DANGER ZONE', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleUnpairDevice(context, docId),
                        icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                        label: const Text('Unpair Smart Pot', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.redAccent,
                          elevation: 0,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            const Text('GENERAL', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildSwitchTile(
              icon: Icons.notifications_active,
              title: 'Notifications',
              subtitle: isNotiEnabled ? 'Đã bật cảnh báo' : 'Đang tắt',
              color: Colors.blueAccent,
              value: isNotiEnabled,
              onChanged: (val) {
                ref.read(notificationProvider.notifier).setNoti(val);
              },
            ),
            _buildSettingsTile(
              icon: Icons.language,
              title: lang.settings,
              subtitle: getLanguageName(currentLocale),
              color: Colors.orangeAccent,
              onTap: () => _showLanguagePicker(context, ref, currentLocale),
            ),
            const SizedBox(height: 32),
            const Text('DEVICE', style: TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            _buildSettingsTile(
              icon: Icons.wifi,
              title: 'Wi-Fi Configuration',
              subtitle: 'Manage ESP32 network',
              color: const Color(0xFF00C896),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const WifiSetupBottomSheet(), 
                );
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('Log Out', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
  Future<void> _showEditProfileDialog(BuildContext context, String currentName) async {
    final defaultName = currentName == 'Người dùng Smart Pot' ? '' : currentName;
    final TextEditingController nameController = TextEditingController(text: defaultName);
    bool isLoading = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: const Color(0xFF161B22),
            title: const Text('Cập nhật tài khoản', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Tên hiển thị của bạn',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00C896))),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                onPressed: isLoading ? null : () async {
                  final newName = nameController.text.trim();
                  if (newName.isEmpty) return;

                  setStateDialog(() => isLoading = true);
                  
                  try {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    
                    // update profile
                    await currentUser?.updateDisplayName(newName);
                    await currentUser?.reload();
                    // old posts
                    if (currentUser != null) {
                      final postsQuery = await FirebaseFirestore.instance
                          .collection('posts')
                          .where('uid', isEqualTo: currentUser.uid)
                          .get();
                          
                      if (postsQuery.docs.isNotEmpty) {
                        final batch = FirebaseFirestore.instance.batch();
                        for (var doc in postsQuery.docs) {
                          batch.update(doc.reference, {'user': newName});
                        }
                        await batch.commit(); // change all
                      }
                    }
                    
                    if (mounted) {
                      Navigator.pop(ctx); 
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã cập nhật tên của bạn 🌱'), backgroundColor: Color(0xFF00C896))
                      );
                    }
                  } catch (e) {
                    setStateDialog(() => isLoading = false);
                    if (mounted) {
                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C896)),
                child: isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('Lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        }
      ),
    );
  }

void _showLanguagePicker(BuildContext context, WidgetRef ref, Locale currentLocale) {
      final locales = [
      {'code': 'vi', 'name': 'Tiếng Việt'},
      {'code': 'en', 'name': 'English'},
      {'code': 'ja', 'name': '日本語'},
    ];


    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: locales.map((item) {
          final isSelected = currentLocale.languageCode == item['code'];
          return ListTile(
            title: Text(item['name']!, style: TextStyle(color: isSelected ? const Color(0xFF00C896) : Colors.white)),
            onTap: () {
              ref.read(localeProvider.notifier).setLocale(Locale(item['code']!));
              Navigator.pop(ctx);
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _handleUnpairDevice(BuildContext context, String docId) async {
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: const Text('Ngắt kết nối thiết bị', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Bạn muốn chỉ ngắt kết nối để cài lại Wi-Fi, hay muốn xóa sạch toàn bộ lịch sử dữ liệu của chậu cây này khỏi hệ thống?',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 0), 
            child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 1), 
            child: const Text('Giữ Dữ Liệu', style: TextStyle(color: Colors.orangeAccent)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 2), 
            child: const Text('Xóa Sạch', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result == 1) {
      try {
        await FirebaseFirestore.instance.collection('pots').doc(docId).update({
          'ownerId': FieldValue.delete(),
          'pumpStatus': false,
          'mistStatus': false,
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã ngắt kết nối. Dữ liệu vẫn được lưu trữ!'), backgroundColor: Color(0xFF00C896)));
        }
      } catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi ngắt kết nối!'), backgroundColor: Colors.redAccent));
      }
    } 
    else if (result == 2) {
      try {
        showDialog(
          context: context, 
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.redAccent))
        );

        final potRef = FirebaseFirestore.instance.collection('pots').doc(docId);

        final historyDocs = await potRef.collection('history').get();
        for (var doc in historyDocs.docs) {
          await doc.reference.delete();
        }

        final sensorDocs = await potRef.collection('sensor_history').get();
        for (var doc in sensorDocs.docs) {
          await doc.reference.delete();
        }

        await potRef.delete();

        if (context.mounted) Navigator.pop(context); 

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa vĩnh viễn thiết bị và toàn bộ dữ liệu!'), backgroundColor: Color(0xFF00C896)));
        }
      } catch (e) {
        if (context.mounted) Navigator.pop(context);
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lỗi khi xóa dữ liệu!'), backgroundColor: Colors.redAccent));
      }
    }
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required String subtitle, required Color color, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({required IconData icon, required String title, required String subtitle, required Color color, required bool value, required Function(bool) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: value ? color.withOpacity(0.5) : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: value ? color : Colors.white54, fontSize: 13, fontWeight: value ? FontWeight.bold : FontWeight.normal)),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged, activeColor: color, activeTrackColor: color.withOpacity(0.3), inactiveThumbColor: Colors.white54, inactiveTrackColor: Colors.white12),
          ],
        ),
      ),
    );
  }
}