import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7ED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 30),
              _buildSectionHeader('Pinned Circles', 'EDIT'),
              const SizedBox(height: 20),
              _buildPinnedCircles(),
              const SizedBox(height: 30),
              const Text('Recent Chats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
              const SizedBox(height: 15),
              _buildRecentChats(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF1E5631),
        elevation: 2,
        child: const Icon(Icons.edit_square, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.location_on, color: Color(0xFF14471E), size: 20),
            SizedBox(width: 8),
            Text('Colony', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF14471E))),
          ],
        ),
        const Icon(Icons.notifications, color: Color(0xFF2C3E30)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search conversations...',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
        Text(action, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E6B3B))),
      ],
    );
  }

  Widget _buildPinnedCircles() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPinnedItem('Gardeners', 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200', true),
          const SizedBox(width: 20),
          _buildPinnedItem('Art Club', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200', false),
          const SizedBox(width: 20),
          _buildPinnedItem('Design', 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=200', false),
          const SizedBox(width: 20),
          _buildPinnedItem('Music', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200', false),
        ],
      ),
    );
  }

  Widget _buildPinnedItem(String name, String img, bool online) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF17F36), width: 3),
              ),
              child: CircleAvatar(backgroundImage: NetworkImage(img)),
            ),
            if (online)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E6B3B),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF2F7ED), width: 3),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
      ],
    );
  }

  Widget _buildRecentChats(BuildContext context) {
    return Column(
      children: [
        _buildChatTile(
          context: context,
          name: 'Maya Harrison',
          msg: 'The project layout look...',
          time: '12:45 PM',
          img: 'https://images.unsplash.com/photo-1531123897727-8f129e1bf98c?auto=format&fit=crop&q=80&w=200',
          isActive: true,
          statusColor: const Color(0xFFF17F36),
          onlineDot: true,
        ),
        _buildChatTile(
          context: context,
          name: 'Julian Thorne',
          msg: 'See you at the sanctuary at 6:00...',
          time: 'YESTERDAY',
          img: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&q=80&w=200',
        ),
        _buildChatTile(
          context: context,
          name: 'The Collective',
          msg: 'Sarah: Just uploaded...',
          time: 'OCT 24',
          isGroup: true,
          unread: 3,
        ),
        _buildChatTile(
          context: context,
          name: 'Lena Rivers',
          msg: 'That coffee spot was a great rec...',
          time: 'OCT 22',
          img: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&q=80&w=200',
        ),
        _buildChatTile(
          context: context,
          name: 'Thomas Vance',
          msg: 'The draft for the new sanctuar...',
          time: 'OCT 20',
          img: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&q=80&w=200',
        ),
      ],
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required String name,
    required String msg,
    required String time,
    String? img,
    bool isGroup = false,
    bool isActive = false,
    int unread = 0,
    Color? statusColor,
    bool onlineDot = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatDetailScreen()));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE6F3E6) : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: isGroup ? const Color(0xFFA3E9A5) : Colors.grey.shade300,
                  backgroundImage: img != null ? NetworkImage(img) : null,
                  child: isGroup ? const Text('TC', style: TextStyle(color: Color(0xFF14471E), fontWeight: FontWeight.bold)) : null,
                ),
                if (statusColor != null)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: isActive ? const Color(0xFFE6F3E6) : const Color(0xFFF2F7ED), width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
                      Text(time, style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(msg, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      if (onlineDot)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(color: Color(0xFF2E6B3B), shape: BoxShape.circle),
                        ),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(color: Color(0xFF1E5631), shape: BoxShape.circle),
                          child: Text(unread.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
