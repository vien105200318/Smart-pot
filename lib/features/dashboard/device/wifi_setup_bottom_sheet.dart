import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

class WifiSetupBottomSheet extends StatefulWidget {
  const WifiSetupBottomSheet({super.key});

  @override
  State<WifiSetupBottomSheet> createState() => _WifiSetupBottomSheetState();
}

class _WifiSetupBottomSheetState extends State<WifiSetupBottomSheet> {
  bool _isLoading = false;
  bool _isSaving = false;
  List<dynamic> _networks = [];
  String? _selectedSSID;
  final TextEditingController _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scanNetworks();
  }

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  Future<void> _scanNetworks() async {
    setState(() => _isLoading = true);
    try {
      final response = await http
          .get(Uri.parse('http://192.168.4.1/scan'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _networks = data['networks'] ?? [];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy chậu cây! Vui lòng kết nối vào WiFi "SmartPot-Setup" trước.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveWiFi() async {
    if (_selectedSSID == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lỗi: Bạn chưa đăng nhập tài khoản!')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final response = await http.post(
        Uri.parse('http://192.168.4.1/save'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'ssid': _selectedSSID,
          'password': _passController.text.trim(),
          'userId': user.uid,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã nạp WiFi thành công! Mạch đang kết nối mạng và kích hoạt...'),
              backgroundColor: Color(0xFF00C896),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi kết nối khi gửi dữ liệu sang thiết bị!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              if (_selectedSSID != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => setState(() {
                    _selectedSSID = null;
                    _passController.clear();
                  }),
                ),
              Text(
                _selectedSSID == null ? 'Select Wi-Fi' : 'Enter Password',
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const Spacer(),
              if (_selectedSSID == null)
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFF00C896)),
                  onPressed: _isLoading ? null : _scanNetworks,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _selectedSSID == null
                ? _buildNetworkList()
                : _buildPasswordForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00C896)),
      );
    }

    if (_networks.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy mạng WiFi nào.\nHãy đảm bảo bạn đã kết nối vào "SmartPot-Setup"',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _networks.length,
      itemBuilder: (context, index) {
        final network = _networks[index];
        final ssid = network['ssid'] ?? 'Unknown';
        final isSecure = network['encryption'] == 'secure';

        return ListTile(
          leading: const Icon(Icons.wifi, color: Colors.white70),
          title: Text(ssid, style: const TextStyle(color: Colors.white)),
          trailing: isSecure
              ? const Icon(Icons.lock_outline, color: Colors.white38, size: 18)
              : null,
          onTap: () {
            setState(() {
              _selectedSSID = ssid;
            });
          },
        );
      },
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connecting to "$_selectedSSID"',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _passController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.lock, color: Colors.white54),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF00C896)),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveWiFi,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C896),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black87,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Connect & Apply',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}