import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smart_pot/l10n/app_localizations.dart';
import 'package:smart_pot/core/utils/image_helper.dart'; 

class CreatePostBottomSheet extends StatefulWidget {
  const CreatePostBottomSheet({super.key});

  @override
  State<CreatePostBottomSheet> createState() => _CreatePostBottomSheetState();
}

class _CreatePostBottomSheetState extends State<CreatePostBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage; 

  Future<void> _pickImage() async {
    final File? image = await ImageHelper.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.reload();
      final freshUser = FirebaseAuth.instance.currentUser;

      String displayName = 'Người chơi hệ cây';
      if (freshUser?.displayName != null && freshUser!.displayName!.isNotEmpty) {
        displayName = freshUser.displayName!;
      } else if (freshUser?.email != null) {
        displayName = freshUser!.email!.split('@')[0]; 
      }
      final photoURL = freshUser?.photoURL ?? 'https://i.pravatar.cc/150?img=11';

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await ImageHelper.uploadToCloudinary(_selectedImage!);
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'uid': freshUser?.uid, 
        'user': displayName,
        'avatar': photoURL,
        'content': content,
        'image': imageUrl, 
        'likes': [], 
        'comments': 0,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đăng bài thành công! 🌱'), backgroundColor: Color(0xFF00C896)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom; 

    return Container(
      margin: EdgeInsets.only(bottom: bottomPadding),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(lang.createPost, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.pop(context),
              )
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: TextField(
              controller: _contentController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: lang.whatsOnYourMind,
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
              onChanged: (val) => setState(() {}), 
            ),
          ),
          const SizedBox(height: 12),

          // Hiển thị ảnh xem trước nếu đã chọn
          if (_selectedImage != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_selectedImage!, height: 120, width: 120, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedImage = null), // Nút xóa ảnh
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          
          if (_selectedImage != null) const SizedBox(height: 16),

          Row(
            children: [
              // Nút thêm ảnh
              IconButton(
                onPressed: _pickImage,
                icon: const Icon(Icons.image, color: Color(0xFF00C896), size: 28),
                tooltip: 'Thêm ảnh',
              ),
              const Spacer(),
              // Nút Đăng
              SizedBox(
                width: 120,
                height: 48,
                child: ElevatedButton(
                  onPressed: ((_contentController.text.trim().isEmpty && _selectedImage == null) || _isLoading) ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C896),
                    disabledBackgroundColor: const Color(0xFF00C896).withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(lang.postBtn, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}