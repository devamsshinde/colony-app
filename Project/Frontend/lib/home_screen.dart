import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/data/auth_repository.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final primaryDark = const Color(0xFF1B5A27);
    final bgColor1 = const Color(0xFFEEF9E9);
    final bgColor2 = const Color(0xFFE2F3D9);

    // Get user display name from user metadata or email
    final displayName =
        user.userMetadata?['full_name'] ??
        user.email?.split('@').first ??
        'User';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: primaryDark),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: primaryDark),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgColor1, bgColor2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome header
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: primaryDark.withOpacity(0.8),
                  ),
                ),
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: primaryDark,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Stats card - Real data will be loaded from Supabase
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Colony',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: primaryDark,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: primaryDark.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Active',
                              style: TextStyle(
                                color: primaryDark,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Real stats will be loaded from database
                      FutureBuilder<Map<String, int>>(
                        future: _loadColonyStats(),
                        builder: (context, snapshot) {
                          final stats =
                              snapshot.data ??
                              {'members': 0, 'events': 0, 'tasks': 0};
                          return Row(
                            children: [
                              _buildStat(
                                'Members',
                                stats['members'].toString(),
                                Icons.people_outline,
                              ),
                              const SizedBox(width: 24),
                              _buildStat(
                                'Events',
                                stats['events'].toString(),
                                Icons.event_note_outlined,
                              ),
                              const SizedBox(width: 24),
                              _buildStat(
                                'Tasks',
                                stats['tasks'].toString(),
                                Icons.task_alt_outlined,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Quick actions title
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: primaryDark,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.add_circle_outline,
                        label: 'Create Event',
                        color: primaryDark,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.chat_bubble_outline,
                        label: 'Community Chat',
                        color: const Color(0xFF4A90E2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        color: const Color(0xFFF5A623),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        color: const Color(0xFF7B68EE),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Logout button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      await AuthRepository().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushReplacementNamed('/login');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 5,
                      shadowColor: primaryDark.withOpacity(0.2),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Load colony statistics from Supabase
  /// Returns a map with 'members', 'events', and 'tasks' counts
  Future<Map<String, int>> _loadColonyStats() async {
    try {
      final supabase = Supabase.instance.client;

      // Get current user's colony_id from profile
      final profile = await supabase
          .from('profiles')
          .select('colony_id')
          .eq('id', user.id)
          .single();

      final colonyId = profile['colony_id'];

      if (colonyId == null) {
        return {'members': 0, 'events': 0, 'tasks': 0};
      }

      // Count members in the colony
      final membersCount = await supabase
          .from('colony_members')
          .select('id')
          .eq('colony_id', colonyId)
          .count();

      // Count active events
      final eventsCount = await supabase
          .from('events')
          .select('id')
          .eq('colony_id', colonyId)
          .gte('end_time', DateTime.now().toIso8601String())
          .count();

      // Count pending tasks
      final tasksCount = await supabase
          .from('tasks')
          .select('id')
          .eq('colony_id', colonyId)
          .eq('status', 'pending')
          .count();

      return {
        'members': membersCount.count,
        'events': eventsCount.count,
        'tasks': tasksCount.count,
      };
    } catch (e) {
      // Return zeros if there's an error (e.g., user not in a colony yet)
      return {'members': 0, 'events': 0, 'tasks': 0};
    }
  }

  Widget _buildStat(String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF5F6E60)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5F6E60),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E2F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
