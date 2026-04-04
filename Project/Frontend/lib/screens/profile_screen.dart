import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7ED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
              _buildMutualConnections(),
              const SizedBox(height: 30),
              _buildVisualJournalHeader(),
              const SizedBox(height: 15),
              _buildVisualJournalPhotos(),
              const SizedBox(height: 80), // Padding for bottom nav
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

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFF17F36), Color(0xFF2E6B3B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFF2F7ED), shape: BoxShape.circle),
                padding: const EdgeInsets.all(3),
                child: const CircleAvatar(
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200'),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF14471E),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF2F7ED), width: 3),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Vikram Singh', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2C3E30))),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.location_on, color: Colors.grey, size: 14),
            SizedBox(width: 4),
            Text('Patna, India', style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
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
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A5822),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: const Text('Edit Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFE2EBE2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.settings, color: Color(0xFF4A554A), size: 24),
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
          _buildStatItem('1.2k', 'FRIENDS'),
          _buildDivider(),
          _buildStatItem('24', 'GROUPS'),
          _buildDivider(),
          _buildStatItem('148', 'POSTS'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF14471E))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade400,
    );
  }

  Widget _buildMutualConnections() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Mutual Connections', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
            Text('SEE ALL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2E6B3B))),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOverlapAvatar('https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=200'),
                _buildOverlapAvatar('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200'),
                _buildOverlapAvatar('https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&q=80&w=200'),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFA3E9A5), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                  child: const Text('+12', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF14471E))),
                ),
              ],
            ),
            const SizedBox(width: 12),
            const Text('Ananya and 12 others', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF4A554A))),
          ],
        ),
      ],
    );
  }

  Widget _buildOverlapAvatar(String url) {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      width: 32,
      height: 32,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      child: CircleAvatar(backgroundImage: NetworkImage(url)),
    );
  }

  Widget _buildVisualJournalHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Visual Journal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: const Color(0xFFA3E9A5), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.grid_view, size: 16, color: Color(0xFF14471E)),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.view_list, size: 20, color: Colors.grey),
          ],
        ),
      ],
    );
  }

  Widget _buildVisualJournalPhotos() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildPhotoCard('https://images.unsplash.com/photo-1448375240586-882707db888b?auto=format&fit=crop&q=80&w=400', 250),
              const SizedBox(height: 10),
              _buildPhotoCard('https://images.unsplash.com/photo-1610701596007-11502861dcfa?auto=format&fit=crop&q=80&w=400', 120),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildPhotoCard('https://images.unsplash.com/photo-1542157585-ef208ce1b4b5?auto=format&fit=crop&q=80&w=400', 120),
              const SizedBox(height: 10),
              _buildPhotoCard('https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=400', 250),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoCard(String url, double height) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: DecorationImage(
          image: NetworkImage(url),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
