import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/data/auth_state_notifier.dart';
import '../login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  int _friendsCount = 0;
  int _groupsCount = 0;
  int _postsCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Get user profile
      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      // Get friends count
      final friends = await Supabase.instance.client
          .from('user_friends')
          .select('id')
          .or('user_id.eq.$userId,friend_id.eq.$userId');

      // Get groups count
      final groups = await Supabase.instance.client
          .from('group_members')
          .select('id')
          .eq('user_id', userId);

      // Get posts count
      final posts = await Supabase.instance.client
          .from('posts')
          .select('id')
          .eq('user_id', userId);

      if (mounted) {
        setState(() {
          _userProfile = profile;
          _friendsCount = friends.length;
          _groupsCount = groups.length;
          _postsCount = posts.length;
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

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      final authNotifier = context.read<AuthStateNotifier>();
      await authNotifier.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
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
                onRefresh: _loadProfile,
                color: const Color(0xFF1E5631),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 30),
                      _buildProfileHeader(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                      const SizedBox(height: 30),
                      _buildStatsRow(),
                      const SizedBox(height: 30),
                      _buildSettingsSection(),
                      const SizedBox(height: 30),
                      _buildLogoutButton(),
                      const SizedBox(height: 80), // Padding for bottom nav
                    ],
                  ),
                ),
              ),
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
        IconButton(
          icon: const Icon(Icons.settings, color: Color(0xFF2C3E30)),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings coming soon!')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final fullName = _userProfile?['full_name'] ?? 'User';
    final username = _userProfile?['username'] ?? 'username';
    final avatarUrl = _userProfile?['avatar_url'];
    final location = _userProfile?['location_name'] ?? 'Location not set'; // Fixed: was 'location'

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFF17F36), Color(0xFF2E6B3B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F7ED),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(3),
                child: CircleAvatar(
                  backgroundImage: avatarUrl != null
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Color(0xFF14471E),
                        )
                      : null,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit avatar coming soon!')),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFF14471E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          fullName,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF2C3E30),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '@$username',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, color: Colors.grey, size: 14),
            const SizedBox(width: 4),
            Text(
              location,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit profile coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5822),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Edit Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE2EBE2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.share, color: Color(0xFF4A554A), size: 24),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F6E8),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(_friendsCount.toString(), 'FRIENDS'),
          _buildDivider(),
          _buildStatItem(_groupsCount.toString(), 'GROUPS'),
          _buildDivider(),
          _buildStatItem(_postsCount.toString(), 'POSTS'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E6B3B),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildSettingsItem(Icons.person_outline, 'Account Settings', () {}),
          _buildSettingsDivider(),
          _buildSettingsItem(
            Icons.notifications_outlined,
            'Notifications',
            () {},
          ),
          _buildSettingsDivider(),
          _buildSettingsItem(Icons.lock_outline, 'Privacy', () {}),
          _buildSettingsDivider(),
          _buildSettingsItem(Icons.help_outline, 'Help & Support', () {}),
          _buildSettingsDivider(),
          _buildSettingsItem(Icons.info_outline, 'About', () {}),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E6B3B)),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2C3E30),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: () {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$title coming soon!')));
      },
    );
  }

  Widget _buildSettingsDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(color: Colors.grey.shade200, height: 1),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _handleLogout,
        icon: const Icon(Icons.logout, color: Colors.white),
        label: const Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
