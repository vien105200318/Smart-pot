import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:smart_pot/l10n/app_localizations.dart';
import 'package:smart_pot/features/community/create_post_bottom_sheet.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, 
            backgroundColor: Colors.transparent, 
            builder: (context) => const CreatePostBottomSheet(),
          );
        },
        backgroundColor: const Color(0xFF00C896),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: Text(lang.newPost, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.community,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lang.communityDesc,
                    style: const TextStyle(color: Colors.white54, fontSize: 16),
                  ),
                ],
              ),
            ),
            
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
                    padding: const EdgeInsets.only(bottom: 80), 
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return _buildPostCard(data, lang);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post, AppLocalizations lang) {
    final String user = post['user'] ?? 'Ẩn danh';
    final String avatar = post['avatar'] ?? 'https://i.pravatar.cc/150?img=3'; 
    final String content = post['content'] ?? '';
    final String? image = post['image'];
    final int likes = post['likes'] ?? 0;
    final int comments = post['comments'] ?? 0;

    String timeString = 'Vừa xong';
    if (post['timestamp'] != null) {
      final DateTime time = (post['timestamp'] as Timestamp).toDate();
      timeString = DateFormat('HH:mm - dd/MM').format(time);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border.symmetric(horizontal: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(avatar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(timeString, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white54),
                  onPressed: () {},
                )
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                content,
                style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
              ),
            ),
          const SizedBox(height: 12),

          if (image != null && image.isNotEmpty)
            Image.network(
              image,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),
          
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildActionBtn(Icons.favorite_border, '$likes', Colors.white70),
                const SizedBox(width: 24),
                _buildActionBtn(Icons.chat_bubble_outline, '$comments', Colors.white70),
                const Spacer(),
                _buildActionBtn(Icons.share_outlined, '', Colors.white70),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        if (text.isNotEmpty && text != '0') ...[
          const SizedBox(width: 6),
          Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ]
      ],
    );
  }
}