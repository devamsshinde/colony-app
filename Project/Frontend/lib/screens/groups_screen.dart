import 'package:flutter/material.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

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
              const SizedBox(height: 24),
              const Text('Find your hive.',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF2C3E30), letterSpacing: -1)),
              const SizedBox(height: 8),
              const Text('Discover local communities or manage the groups you\'ve nurtured.',
                  style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4)),
              const SizedBox(height: 24),
              _buildTabs(),
              const SizedBox(height: 24),
              _buildGroupCard(
                'TECH',
                const Color(0xFF7DE6ED),
                'Silicon Polder Entrepreneurs',
                '0.8 km',
                'A collective of founders, engineers, and designers building the next generation...',
                true,
                'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&q=80&w=800',
              ),
              const SizedBox(height: 20),
              _buildGroupCard(
                'FITNESS',
                const Color(0xFFF1B7C9),
                'Vondelpark Runners',
                '1.2 km',
                'Daily morning runs through the park followed by coffee at Groot Melkhuis.',
                false,
                'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80&w=800',
                memberCount: '482 Members',
              ),
              const SizedBox(height: 20),
              _buildGroupCard(
                'LIFESTYLE',
                const Color(0xFFA3E9A5),
                'Midnight Book Club',
                '2.5 km',
                'A community for those who prefer the quiet magic of a good book under the city lights.',
                false,
                'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&q=80&w=800',
                memberCount: '124 Members',
              ),
              const SizedBox(height: 20),
              _buildSmallGroupCard('Urban Sketchers', 'Art & Design', '34 members • 0.5 km', 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&q=80&w=200'),
              const SizedBox(height: 12),
              _buildSmallGroupCard('Powerlifting Collective', 'Fitness', '89 members • 3.1 km', 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?auto=format&fit=crop&q=80&w=200'),
              const SizedBox(height: 80), // Padding for FAB
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFFA3E9A5),
        elevation: 2,
        child: const Icon(Icons.add, color: Color(0xFF14471E), size: 30),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.location_on, color: Color(0xFF14471E), size: 18),
            SizedBox(width: 4),
            Text('Amsterdam', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF14471E))),
          ],
        ),
        const Text('Colony', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF14471E), fontStyle: FontStyle.italic)),
        const CircleAvatar(
          radius: 16,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150'),
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
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
            child: const Text('Nearby Groups', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E6B3B), fontSize: 13)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('My Groups', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupCard(String tag, Color tagColor, String title, String distance, String desc, bool primaryAction, String imageUrl, {String? memberCount}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: tagColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30), height: 1.2)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F6E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, size: 10, color: Color(0xFF14471E)),
                          const SizedBox(width: 4),
                          Text(distance, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF14471E))),
                        ],
                      ),
                    ),
                  ],
                ),
                if (memberCount != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(memberCount, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Text(desc, style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4)),
                const SizedBox(height: 20),
                primaryAction ? _buildJoinButtonText() : _buildPrimaryButtonText('View Group'),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildJoinButtonText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOverlapAvatar('https://i.pravatar.cc/100?img=1'),
            _buildOverlapAvatar('https://i.pravatar.cc/100?img=2'),
            _buildOverlapAvatar('https://i.pravatar.cc/100?img=3'),
            Container(
              margin: const EdgeInsets.only(left: 1),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFFA3E9A5), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
              child: const Text('+1.2k', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF14471E))),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A5822),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: const Text('Join Hive', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPrimaryButtonText(String text) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.grey, width: 0.5),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(text, style: const TextStyle(color: Color(0xFF14471E), fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildOverlapAvatar(String url) {
    return Container(
      margin: const EdgeInsets.only(right: 2), // Actually negative margin in real app, simulated flat
      width: 24,
      height: 24,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      child: CircleAvatar(backgroundImage: NetworkImage(url)),
    );
  }
  
  Widget _buildSmallGroupCard(String title, String category, String subtitle, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
                const SizedBox(height: 2),
                Text(category, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2E6B3B))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
