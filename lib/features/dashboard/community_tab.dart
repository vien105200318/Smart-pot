import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:smart_pot/features/community/create_post_bottom_sheet.dart'; 
import 'package:smart_pot/core/utils/image_helper.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0B191E),
              Color(0xFF071215),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    const Icon(Icons.eco, color: Color(0xFF00C896), size: 32),
                    const SizedBox(width: 8),
                    const Text(
                      'GreenVibe',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5),
                    ),
                    const Spacer(),
                    const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                    const SizedBox(width: 16),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFF00C896),
                      backgroundImage: currentUser?.photoURL != null ? NetworkImage(currentUser!.photoURL!) : null,
                      child: currentUser?.photoURL == null ? const Icon(Icons.person, size: 16, color: Colors.white) : null,
                    ),
                  ],
                ),
              ),
              _buildFeaturedStories(),
              const SizedBox(height: 16),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts') 
                      .orderBy('timestamp', descending: true) 
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFF00C896)));
                    }
                    
                    if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
                    }

                    final docs = snapshot.data?.docs ?? [];
                    
                    if (docs.isEmpty) {
                      return const Center(child: Text('Chưa có bài viết nào, hãy là người đầu tiên chia sẻ!', style: TextStyle(color: Colors.white54)));
                    }

                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10).copyWith(bottom: 100), 
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final docId = docs[index].id; 
                        return _buildGlassPostCard(context, docId, data, currentUid);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF00C896).withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, 
                    backgroundColor: Colors.transparent, 
                    builder: (context) => const CreatePostBottomSheet(),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                splashColor: const Color(0xFF00C896).withOpacity(0.3),
                highlightColor: Colors.transparent,
                child: const Icon(
                  Icons.add,
                  color: Color(0xFF00C896),
                  size: 32,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeaturedStories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Featured Stories', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
              Text('WATCH ALL', style: TextStyle(color: Color(0xFF00C896), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('stories')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF00C896)));
              }

              final docs = snapshot.data?.docs ?? [];

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: docs.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return _buildAddStoryButton(context);

                  final data = docs[index - 1].data() as Map<String, dynamic>;
                  final String avatar = data['avatar'] ?? data['img'] ?? '';
                  final String user = data['user'] ?? 'User';

                  return StoryBubble(avatarUrl: avatar, username: user);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGlassPostCard(BuildContext context, String docId, Map<String, dynamic> post, String currentUid) {
    final String postUid = post['uid'] ?? '';
    final String user = post['user'] ?? 'Ẩn danh';
    final String avatar = post['avatar'] ?? 'https://i.pravatar.cc/150?img=3'; 
    final String content = post['content'] ?? '';
    final String? image = post['image'];
    
    final List<dynamic> likesArray = post['likes'] is List ? post['likes'] : [];
    final int likesCount = likesArray.length;
    final bool isLikedByMe = likesArray.contains(currentUid);
    final int comments = post['comments'] ?? 0;

    String locationOrTime = 'Vừa xong';
    if (post['timestamp'] != null) {
      final DateTime time = (post['timestamp'] as Timestamp).toDate();
      locationOrTime = DateFormat('HH:mm - dd/MM').format(time);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF00C896).withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF00C896).withOpacity(0.5), width: 1.5),
                          image: DecorationImage(image: NetworkImage(avatar), fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, color: Colors.white54, size: 12),
                              const SizedBox(width: 4),
                              Text(locationOrTime, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00C896).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF00C896).withOpacity(0.5)),
                      ),
                      child: const Text('VIBE: 9.8', style: TextStyle(color: Color(0xFF00C896), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    if (postUid == currentUid) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => _showPostOptions(context, docId),
                        child: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                      )
                    ]
                  ],
                ),
                const SizedBox(height: 16),
                if (image != null && image.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      image,
                      width: double.infinity,
                      height: 280,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 16),
                if (content.isNotEmpty)
                  Text(
                    content,
                    style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4, fontWeight: FontWeight.w500),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildActionBtn(
                      icon: isLikedByMe ? Icons.favorite : Icons.favorite_border, 
                      text: '$likesCount', 
                      color: isLikedByMe ? const Color(0xFF00C896) : Colors.white70,
                      onTap: () => _toggleLike(docId, currentUid, isLikedByMe),
                    ),
                    const SizedBox(width: 24),
                    _buildActionBtn(
                      icon: Icons.chat_bubble_outline, 
                      text: '$comments', 
                      color: Colors.white70,
                      onTap: () {},
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn({required IconData icon, required String text, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          if (text.isNotEmpty && text != '0') ...[
            const SizedBox(width: 6),
            Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
          ]
        ],
      ),
    );
  }

  Widget _buildAddStoryButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: () => _handleCreateStory(context),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2)),
              child: const CircleAvatar(radius: 28, backgroundColor: Color(0xFF071215), child: Icon(Icons.add, color: Color(0xFF00C896))),
            ),
            const SizedBox(height: 8),
            const Text("Story", style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCreateStory(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đăng Story!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    try {
      final File? image = await ImageHelper.pickImageFromGallery();
      if (image == null) return;

      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator(color: Color(0xFF00C896))),
        );
      }

      final url = await ImageHelper.uploadToCloudinary(image);
      
      if (context.mounted) Navigator.pop(context); 

      if (url != null) {
        await FirebaseFirestore.instance.collection('stories').add({
          'uid': currentUser.uid,
          'user': currentUser.displayName ?? 'Người dùng Smart Pot',
          'avatar': currentUser.photoURL ?? '',
          'img': url,
          'timestamp': FieldValue.serverTimestamp(),
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã đăng Story mới thành công! 🌱'), backgroundColor: Color(0xFF00C896)),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lỗi tải ảnh lên server!'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _toggleLike(String docId, String uid, bool isLiked) async {
    if (uid.isEmpty) return;
    final docRef = FirebaseFirestore.instance.collection('posts').doc(docId);
    if (isLiked) {
      await docRef.update({'likes': FieldValue.arrayRemove([uid])});
    } else {
      await docRef.update({'likes': FieldValue.arrayUnion([uid])});
    }
  }

  void _showPostOptions(BuildContext context, String docId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
            title: const Text('Xóa bài viết', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance.collection('posts').doc(docId).delete();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa bài viết!'), backgroundColor: Color(0xFF00C896)));
              }
            },
          ),
        ],
      ),
    );
  }
}

class StoryBubble extends StatelessWidget {
  final String avatarUrl;
  final String username;

  const StoryBubble({super.key, required this.avatarUrl, required this.username});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle, 
              gradient: LinearGradient(colors: [Color(0xFF00C896), Colors.blueAccent])
            ),
            child: CircleAvatar(
              radius: 28, 
              backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            username.split(' ').first, 
            style: const TextStyle(color: Colors.white, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}