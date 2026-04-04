import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              _buildSectionHeader('Colony Stories', 'VIEW ALL'),
              const SizedBox(height: 15),
              _buildStoriesList(),
              const SizedBox(height: 30),
              const Text('Nearby Peoples',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
              const SizedBox(height: 15),
              _buildNearbyPeoplesList(),
              const SizedBox(height: 30),
              _buildSectionHeader('Nearby Groups', 'JOIN NEW'),
              const SizedBox(height: 15),
              _buildNearbyGroupsList(),
              const SizedBox(height: 30),
              const Text('Community Highlights',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
              const SizedBox(height: 15),
              _buildCommunityHighlightCard(),
              const SizedBox(height: 20),
            ],
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
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFA3E9A5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on, color: Color(0xFF14471E), size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Colony',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF14471E))),
                Text('PARK STREET, AREA, PATNA',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey)),
              ],
            ),
          ],
        ),
        const Icon(Icons.notifications, color: Color(0xFF14471E)),
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
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
        Text(action, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E6B3B))),
      ],
    );
  }

  Widget _buildStoriesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildAddStoryBtn(),
          const SizedBox(width: 15),
          _buildStoryItem('AaravP01', true),
          const SizedBox(width: 15),
          _buildStoryItem('Priya_S_12', true),
          const SizedBox(width: 15),
          _buildStoryItem('RohanK_98', true),
          const SizedBox(width: 15),
          _buildStoryItem('Sneha', false),
        ],
      ),
    );
  }

  Widget _buildAddStoryBtn() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade400, width: 2, style: BorderStyle.solid),
          ),
          child: const Icon(Icons.add, color: Color(0xFF2E6B3B), size: 30),
        ),
        const SizedBox(height: 8),
        const Text('Add Story', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStoryItem(String name, bool hasUnseen) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: hasUnseen ? const Color(0xFFF17F36) : Colors.grey.shade300, width: 3),
          ),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/150'), // Placeholder
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 12, color: Color(0xFF2C3E30), fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildNearbyPeoplesList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildPeopleCard('AaravP01', 'Software Engineer', '200M'),
          const SizedBox(width: 15),
          _buildPeopleCard('Priya_S_12', 'Graphic Designer', '450M'),
        ],
      ),
    );
  }

  Widget _buildPeopleCard(String name, String role, String distance) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2E4), // Light green tint
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
                backgroundColor: Colors.black,
                backgroundImage: const NetworkImage('https://i.pravatar.cc/150'),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFA3E9A5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(distance, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF14471E))),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
          Text(role, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.waving_hand, size: 16, color: Colors.white),
              label: const Text('Wave', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E6B3B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(vertical: 10),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyGroupsList() {
    return Column(
      children: [
        _buildGroupTile('Morning Runners Club', 'Rahul: Tomorrow\'s run at 6 AM?', '12:45', 3, const Color(0xFFF19B36), Icons.fitness_center),
        const SizedBox(height: 12),
        _buildGroupTile('Park Street Readers', 'Sana: Just finished the first...', '09:12', 0, const Color(0xFFA3E9A5), Icons.book),
      ],
    );
  }

  Widget _buildGroupTile(String title, String subtitle, String time, int unread, Color iconBg, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              if (unread > 0)
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFA53A1B),
                    shape: BoxShape.circle,
                  ),
                  child: Text(unread.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCommunityHighlightCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF382638), // Dark plum base color
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1543269865-cbf427effbad?auto=format&fit=crop&q=80&w=800'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 100),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF19B36),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('EVENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(width: 10),
              const Text('2 DAYS LEFT', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Annual Colony Potluck at Park Street Garden',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
          const SizedBox(height: 12),
          const Text('Bring your favorite homemade dish and join your neighbors for a wonderful afternoon o...',
              style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4)),
        ],
      ),
    );
  }
}
