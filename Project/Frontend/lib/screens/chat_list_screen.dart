import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _pinnedCircles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Get user's conversations/chats
      final conversations = await Supabase.instance.client
          .from('conversations')
          .select('''
            id,
            last_message,
            last_message_at,
            unread_count,
            participant1:profiles!conversations_participant1_id_fkey(id, username, full_name, avatar_url),
            participant2:profiles!conversations_participant2_id_fkey(id, username, full_name, avatar_url)
          ''')
          .or('participant1_id.eq.$userId,participant2_id.eq.$userId')
          .order('last_message_at', ascending: false);

      // Get pinned groups/circles
      final pinnedGroups = await Supabase.instance.client
          .from('group_members')
          .select('''
            group_id,
            is_pinned,
            groups (
              id,
              name,
              icon_url
            )
          ''')
          .eq('user_id', userId)
          .eq('is_pinned', true)
          .limit(4);

      if (mounted) {
        setState(() {
          _conversations = List<Map<String, dynamic>>.from(conversations);
          _pinnedCircles = pinnedGroups
              .map<Map<String, dynamic>>(
                (g) => g['groups'] as Map<String, dynamic>,
              )
              .where((g) => g != null)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7ED),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E5631)),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _loadData,
                color: const Color(0xFF1E5631),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
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
                      const Text(
                        'Recent Chats',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E30),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildRecentChats(context),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('New chat coming soon!')),
          );
        },
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
            Text(
              'Colony',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF14471E),
              ),
            ),
          ],
        ),
        Stack(
          children: [
            const Icon(Icons.notifications, color: Color(0xFF2C3E30)),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFF17F36),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '0',
                  style: TextStyle(fontSize: 8, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
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
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E30),
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E6B3B),
          ),
        ),
      ],
    );
  }

  Widget _buildPinnedCircles() {
    return SizedBox(
      height: 120,
      child: _pinnedCircles.isEmpty
          ? _buildEmptyPinnedCircles()
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pinnedCircles.length,
              itemBuilder: (context, index) {
                final group = _pinnedCircles[index];
                return _buildPinnedItem(
                  group['name'] ?? 'Group',
                  group['icon_url'],
                  false,
                );
              },
            ),
    );
  }

  Widget _buildEmptyPinnedCircles() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.push_pin_outlined, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'No pinned circles yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            'Pin your favorite groups here!',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildPinnedItem(String name, String? iconUrl, bool online) {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF17F36), width: 3),
            ),
            child: CircleAvatar(
              backgroundImage: iconUrl != null ? NetworkImage(iconUrl) : null,
              child: iconUrl == null
                  ? const Icon(Icons.group, color: Color(0xFF14471E))
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E30),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChats(BuildContext context) {
    return _conversations.isEmpty
        ? _buildEmptyChats()
        : Column(
            children: _conversations.map((conv) {
              final otherUser = conv['participant1'] ?? conv['participant2'];
              return _buildChatTile(
                context: context,
                name: otherUser['full_name'] ?? 'Unknown',
                username: otherUser['username'] ?? 'user',
                msg: conv['last_message'] ?? 'No messages yet',
                time: _formatTime(conv['last_message_at']),
                avatarUrl: otherUser['avatar_url'],
                unread: conv['unread_count'] ?? 0,
              );
            }).toList(),
          );
  }

  Widget _buildEmptyChats() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No conversations yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a new chat with your neighbors!',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required String name,
    required String username,
    required String msg,
    required String time,
    String? avatarUrl,
    int unread = 0,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatDetailScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(Icons.person, color: Color(0xFF14471E))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E6B3B),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E30),
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@$username',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    msg,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (unread > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFFF17F36),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$unread',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    final dateTime = DateTime.parse(timestamp);
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
