import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _nearbyGroups = [];
  List<Map<String, dynamic>> _myGroups = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Get current user profile
      final userData = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // Get user's groups
      final myGroups = await Supabase.instance.client
          .from('group_members')
          .select('''
            group_id,
            role,
            groups (
              id,
              name,
              description,
              icon_url,
              member_count,
              category
            )
          ''')
          .eq('user_id', userId);

      // Get nearby/public groups
      final nearbyGroups = await Supabase.instance.client
          .from('groups')
          .select(
            'id, name, description, icon_url, member_count, category, is_public',
          )
          .eq('is_public', true)
          .limit(10);

      if (mounted) {
        setState(() {
          _currentUser = userData;
          _myGroups = myGroups
              .map<Map<String, dynamic>>(
                (g) => g['groups'] as Map<String, dynamic>,
              )
              .where((g) => g != null)
              .toList();
          _nearbyGroups = List<Map<String, dynamic>>.from(nearbyGroups);
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
                      const SizedBox(height: 24),
                      const Text(
                        'Find your hive.',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2C3E30),
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Discover local communities or manage the groups you\'ve nurtured.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildTabs(),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 600, // Fixed height for tab content
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildNearbyGroupsList(),
                            _buildMyGroupsList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80), // Padding for FAB
                    ],
                  ),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Create group coming soon!')),
          );
        },
        backgroundColor: const Color(0xFFA3E9A5),
        elevation: 2,
        child: const Icon(Icons.add, color: Color(0xFF14471E), size: 30),
      ),
    );
  }

  Widget _buildHeader() {
    final avatarUrl = _currentUser?['avatar_url'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.location_on, color: Color(0xFF14471E), size: 18),
            SizedBox(width: 4),
            Text(
              'Colony',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Color(0xFF14471E),
              ),
            ),
          ],
        ),
        const Text(
          'Groups',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: Color(0xFF14471E),
            fontStyle: FontStyle.italic,
          ),
        ),
        CircleAvatar(
          radius: 16,
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null
              ? const Icon(Icons.person, size: 16, color: Color(0xFF14471E))
              : null,
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF2E6B3B),
        unselectedLabelColor: Colors.grey,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        tabs: const [
          Tab(text: 'Nearby Groups'),
          Tab(text: 'My Groups'),
        ],
      ),
    );
  }

  Widget _buildNearbyGroupsList() {
    return _nearbyGroups.isEmpty
        ? _buildEmptyState(
            'No nearby groups',
            'Be the first to create one!',
            Icons.explore_outlined,
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _nearbyGroups.length,
            itemBuilder: (context, index) {
              final group = _nearbyGroups[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildGroupCard(
                  group['category'] ?? 'GENERAL',
                  _getCategoryColor(group['category']),
                  group['name'] ?? 'Unnamed Group',
                  group['description'] ?? 'No description',
                  group['member_count'] ?? 0,
                  group['icon_url'],
                ),
              );
            },
          );
  }

  Widget _buildMyGroupsList() {
    return _myGroups.isEmpty
        ? _buildEmptyState(
            'No groups joined yet',
            'Discover and join groups nearby!',
            Icons.group_add_outlined,
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _myGroups.length,
            itemBuilder: (context, index) {
              final group = _myGroups[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildGroupCard(
                  group['category'] ?? 'GENERAL',
                  _getCategoryColor(group['category']),
                  group['name'] ?? 'Unnamed Group',
                  group['description'] ?? 'No description',
                  group['member_count'] ?? 0,
                  group['icon_url'],
                ),
              );
            },
          );
  }

  Color _getCategoryColor(String? category) {
    switch (category?.toUpperCase()) {
      case 'TECH':
        return const Color(0xFF7DE6ED);
      case 'FITNESS':
        return const Color(0xFFF1B7C9);
      case 'LIFESTYLE':
        return const Color(0xFFA3E9A5);
      case 'ART':
        return const Color(0xFFF1B7C9);
      case 'MUSIC':
        return const Color(0xFFE6C2A3);
      case 'SPORTS':
        return const Color(0xFFA3D4E6);
      default:
        return const Color(0xFFE8E8E8);
    }
  }

  Widget _buildGroupCard(
    String tag,
    Color tagColor,
    String title,
    String description,
    int memberCount,
    String? iconUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            width: double.infinity,
            color: tagColor.withOpacity(0.3),
            child: iconUrl != null
                ? Image.network(iconUrl, fit: BoxFit.cover)
                : Center(child: Icon(Icons.group, size: 50, color: tagColor)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E30),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E30),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$memberCount members',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Join $title coming soon!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5631),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Join',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
