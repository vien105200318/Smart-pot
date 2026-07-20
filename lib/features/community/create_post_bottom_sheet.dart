import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_pot/core/utils/image_helper.dart'; // Đảm bảo ông có file helper này

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
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.trim().isEmpty && _selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      String? imageUrl;
      
      // Upload ảnh lên Cloudinary/Storage trước
      if (_selectedImage != null) {
        imageUrl = await ImageHelper.uploadToCloudinary(_selectedImage!);
      }

      // Lưu vào Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'uid': user?.uid,
        'user': user?.displayName ?? 'Người dùng',
        'content': _contentController.text.trim(),
        'image': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Lỗi đăng bài: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          
          // Input text
          TextField(
            controller: _contentController,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            maxLines: 4,
            decoration: const InputDecoration(hintText: "Bạn đang nghĩ gì về cây của mình?", hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none),
          ),
          
          // Preview ảnh
          if (_selectedImage != null)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)),
              ),
            ),
            
          Row(
            children: [
              IconButton(onPressed: _pickImage, icon: const Icon(Icons.photo_library, color: Color(0xFF00C896), size: 30)),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00C896), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Đăng", style: TextStyle(color: Colors.white)),
              )
            ],
          )
        ],
      ),
    );
  }
}