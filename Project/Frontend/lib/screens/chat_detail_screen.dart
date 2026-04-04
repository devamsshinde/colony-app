import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7ED),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: _buildAppBar(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                children: [
                  _buildDateChip('TODAY'),
                  const SizedBox(height: 30),
                  _buildIncomingMsg(
                    'Hey! I just saw the proposal for the new community garden. It looks incredible. Are we still on for the walkthrough tomorrow morning?',
                    '09:41 AM',
                    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200',
                  ),
                  const SizedBox(height: 20),
                  _buildOutgoingMsg(
                    'Absolutely! I\'ve confirmed the site visit for 8:30 AM. I\'ll bring the updated blueprints and the soil analysis report.',
                    '09:44 AM',
                  ),
                  const SizedBox(height: 20),
                  _buildIncomingImageMsg(
                    'https://images.unsplash.com/photo-1582239454848-0ca91b3511eb?auto=format&fit=crop&q=80&w=800',
                  ),
                  _buildIncomingMsg(
                    'I took this photo of the inspiration site yesterday. This is the exact layout I was thinking for the North quadrant.',
                    '09:45 AM',
                    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200',
                    isSequence: false,
                  ),
                  const SizedBox(height: 20),
                  _buildOutgoingMsg(
                    'That looks perfect. The raised beds will work much better for the drainage issues we identified. See you at the main gate?',
                    '09:48 AM',
                  ),
                  const SizedBox(height: 10),
                  _buildTypingIndicator(),
                ],
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF1E5631)),
              onPressed: () => Navigator.pop(context),
            ),
            Stack(
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&q=80&w=200'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF14471E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF2F7ED), width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Oscar Barnett', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E30))),
                  Text('ONLINE NOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.videocam, color: Color(0xFF4A554A)),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.call, color: Color(0xFF4A554A)),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateChip(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFE6F0E6), borderRadius: BorderRadius.circular(20)),
      child: Text(date, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4A554A))),
    );
  }

  Widget _buildIncomingMsg(String text, String time, String avatarUrl, {bool isSequence = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE2EBE2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  bottomLeft: Radius.circular(0),
                ),
              ),
              child: Text(text, style: const TextStyle(fontSize: 15, color: Color(0xFF2C3E30), height: 1.5)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(radius: 12, backgroundImage: NetworkImage(avatarUrl)),
            const SizedBox(width: 8),
            Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildIncomingImageMsg(String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      alignment: Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(imageUrl, width: 280, height: 200, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildOutgoingMsg(String text, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E6B3B),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.white, height: 1.5)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            const SizedBox(width: 4),
            const Icon(Icons.check_circle, size: 14, color: Color(0xFF14471E)),
          ],
        ),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        const Icon(Icons.more_horiz, color: Colors.grey, size: 20),
        const SizedBox(width: 8),
        const Text('OSCAR IS TYPING...', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFF2F7ED),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFE6F0E6), shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Color(0xFF2C3E30)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
                ],
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Message Oscar...',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.sentiment_satisfied_alt, color: Color(0xFF4A554A)),
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: const Color(0xFF14471E), shape: BoxShape.circle),
            child: const Icon(Icons.send, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}
