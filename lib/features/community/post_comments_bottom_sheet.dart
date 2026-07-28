import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PostCommentsBottomSheet extends StatefulWidget {
  final String postId;

  const PostCommentsBottomSheet({super.key, required this.postId});

  @override
  State<PostCommentsBottomSheet> createState() => _PostCommentsBottomSheetState();
}

class _PostCommentsBottomSheetState extends State<PostCommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSending = false;

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để bình luận!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
      final commentsRef = postRef.collection('comments');

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(commentsRef.doc(), {
          'uid': currentUser.uid,
          'user': currentUser.displayName ?? 'Người dùng Smart Pot',
          'avatar': currentUser.photoURL ?? '',
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
        });

        transaction.update(postRef, {
          'comments': FieldValue.increment(1),
        });
      });

      _commentController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi bình luận: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: EdgeInsets.only(bottom: bottomInset),
          decoration: BoxDecoration(
            color: const Color(0xFF161B22).withOpacity(0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Bình luận',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.white12, height: 1),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C896)));
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('Chưa có bình luận nào. Hãy là người đầu tiên!', style: TextStyle(color: Colors.white54)),
                      );
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final user = data['user'] ?? 'Ẩn danh';
                        final avatar = data['avatar'] ?? '';
                        final text = data['text'] ?? '';
                        
                        String timeStr = 'Vừa xong';
                        if (data['timestamp'] != null) {
                          final DateTime time = (data['timestamp'] as Timestamp).toDate();
                          timeStr = DateFormat('HH:mm - dd/MM').format(time);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: const Color(0xFF00C896).withOpacity(0.2),
                                backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                                child: avatar.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 18) : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(user, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                          Text(timeStr, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.3)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D1117),
                  border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Thêm bình luận...',
                          hintStyle: const TextStyle(color: Colors.white38),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF00C896),
                      child: IconButton(
                        icon: _isSending
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.black87, strokeWidth: 2))
                            : const Icon(Icons.send, color: Colors.black87, size: 20),
                        onPressed: _isSending ? null : _sendComment,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}