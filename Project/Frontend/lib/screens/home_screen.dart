import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _nearbyPeople = [];
  List<Map<String, dynamic>> _nearbyGroups = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
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

      // Get nearby people (other users)
      final people = await Supabase.instance.client
          .from('profiles')
          .select('id, username, full_name, avatar_url')
          .neq('id', userId)
          .limit(10);

      // Get user's groups
      final groups = await Supabase.instance.client
          .from('group_members')
          .select('''
            group_id,
            groups (
              id,
              name,
              description,
              icon_url,
              member_count
            )
          ''')
          .eq('user_id', userId)
          .limit(5);

      if (mounted) {
        setState(() {
          _currentUser = userData;
          _nearbyPeople = List<Map<String, dynamic>>.from(people);
          _nearbyGroups = groups
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
                      _buildSectionHeader('Colony Stories', 'VIEW ALL'),
                      const SizedBox(height: 15),
                      _buildStoriesList(),
                      const SizedBox(height: 30),
                      const Text(
                        'Nearby People',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E30),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildNearbyPeopleList(),
                      const SizedBox(height: 30),
                      _buildSectionHeader('Your Groups', 'JOIN NEW'),
                      const SizedBox(height: 15),
                      _buildGroupsList(),
                      const SizedBox(height: 30),
                      const Text(
                        'Community Highlights',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E30),
                        ),
                      ),
                      const SizedBox(height: 15),
                      _buildCommunityHighlightCard(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final userName = _currentUser?['full_name'] ?? 'User';
    final avatarUrl = _currentUser?['avatar_url'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFA3E9A5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFF14471E),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Colony',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF14471E),
                  ),
                ),
                Text(
                  'Welcome, $userName',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Stack(
              children: [
                const Icon(Icons.notifications, color: Color(0xFF14471E)),
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
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? const Icon(Icons.person, color: Color(0xFF14471E))
                  : null,
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search neighbors, groups or events...',
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

  Widget _buildStoriesList() {
    return SizedBox(
      height: 100,
      child: _stories.isEmpty
          ? _buildEmptyState(
              'No stories yet',
              'Be the first to share!',
              Icons.add_circle_outline,
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _stories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildAddStoryBtn();
                final story = _stories[index - 1];
                return _buildStoryItem(story['username'] ?? 'User', false);
              },
            ),
    );
  }

  Widget _buildAddStoryBtn() {
    return GestureDetector(
      onTap: () {
        // TODO: Add story functionality
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Add story coming soon!')));
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2,
                style: BorderStyle.solid,
              ),
            ),
            child: const Icon(Icons.add, color: Color(0xFF2E6B3B), size: 30),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add Story',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryItem(String name, bool hasUnseen) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: hasUnseen
                    ? const Color(0xFFF17F36)
                    : Colors.grey.shade300,
                width: 3,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              child: Text(
                name[0].toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF14471E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2C3E30),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPeopleList() {
    return SizedBox(
      height: 180,
      child: _nearbyPeople.isEmpty
          ? _buildEmptyState(
              'No nearby people',
              'Invite friends to join!',
              Icons.people_outline,
            )
          : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _nearbyPeople.length,
              itemBuilder: (context, index) {
                final person = _nearbyPeople[index];
                return _buildPeopleCard(
                  person['username'] ?? 'Unknown',
                  person['full_name'] ?? 'User',
                  person['avatar_url'],
                );
              },
            ),
    );
  }

  Widget _buildPeopleCard(String username, String fullName, String? avatarUrl) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2E4),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl == null
                    ? const Icon(Icons.person, color: Color(0xFF14471E))
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFA3E9A5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Nearby',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF14471E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            username,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E30),
            ),
          ),
          Text(
            fullName,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Wave feature coming soon!')),
                );
              },
              icon: const Icon(
                Icons.waving_hand,
                size: 16,
                color: Colors.white,
              ),
              label: const Text(
                'Wave',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E6B3B),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsList() {
    return _nearbyGroups.isEmpty
        ? _buildEmptyState(
            'No groups yet',
            'Create or join a group!',
            Icons.group_add_outlined,
          )
        : Column(
            children: _nearbyGroups.map((group) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildGroupTile(
                  group['name'] ?? 'Unnamed Group',
                  group['description'] ?? 'No description',
                  group['member_count'] ?? 0,
                  group['icon_url'],
                ),
              );
            }).toList(),
          );
  }

  Widget _buildGroupTile(
    String title,
    String description,
    int memberCount,
    String? iconUrl,
  ) {
    return Container(
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
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFA3E9A5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: iconUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(iconUrl, fit: BoxFit.cover),
                  )
                : const Icon(Icons.group, color: Color(0xFF14471E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E30),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$memberCount',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E6B3B),
                ),
              ),
              const Text(
                'members',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityHighlightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E5631), Color(0xFF2E6B3B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to Colony!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect with your neighbors, join local groups, and build a stronger community together.',
            style: TextStyle(fontSize: 14, color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Explore feature coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Explore Community',
              style: TextStyle(
                color: Color(0xFF1E5631),
                fontWeight: FontWeight.bold,
              ),
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
          Icon(icon, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
