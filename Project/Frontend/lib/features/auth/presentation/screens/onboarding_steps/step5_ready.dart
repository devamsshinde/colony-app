import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/onboarding_controller.dart';

class Step5Ready extends StatefulWidget {
  const Step5Ready({super.key});

  @override
  State<Step5Ready> createState() => _Step5ReadyState();
}

class _Step5ReadyState extends State<Step5Ready>
    with SingleTickerProviderStateMixin {
  late AnimationController _confettiController;
  late Animation<double> _scaleAnimation;
  final List<ConfettiParticle> _particles = [];
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _confettiController, curve: Curves.elasticOut),
    );

    // Generate confetti particles
    final random = Random();
    for (int i = 0; i < 50; i++) {
      _particles.add(ConfettiParticle(random: random));
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Trigger animation on first build
    if (!_hasAnimated) {
      _hasAnimated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confettiController.forward();
      });
    }

    return Stack(
      children: [
        // Confetti animation layer
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              painter: ConfettiPainter(
                particles: _particles,
                progress: _confettiController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
        // Main content
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Consumer<OnboardingController>(
            builder: (context, controller, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  // Success Icon with animation
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E5631), Color(0xFF2E6B3B)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1E5631).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: const Text(
                      "You're All Set!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF14471E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your Colony profile is ready.\nStart connecting with your neighborhood!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  // Profile Preview Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Avatar and name
                        Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1E5631),
                                    Color(0xFF2E6B3B),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ClipOval(
                                child: controller.state.avatarFile != null
                                    ? Image.file(
                                        controller.state.avatarFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : controller.state.avatarUrl != null
                                    ? Image.network(
                                        controller.state.avatarUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(
                                        Icons.person,
                                        size: 35,
                                        color: Colors.white,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.state.fullName.isNotEmpty
                                        ? controller.state.fullName
                                        : 'New Neighbor',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2C3E30),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '@${controller.state.username.isNotEmpty ? controller.state.username : "username"}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Bio
                        if (controller.state.bio.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              controller.state.bio,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        // Interests
                        if (controller.state.interests.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: controller.state.interests.take(5).map((
                              interest,
                            ) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F6E8),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  interest,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF1E5631),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Stats preview
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF17F36).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: Icons.people_outline,
                          label: 'Nearby',
                          value: '---',
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        _buildStatItem(
                          icon: Icons.event_outlined,
                          label: 'Events',
                          value: '---',
                        ),
                        Container(
                          height: 30,
                          width: 1,
                          color: Colors.grey.shade300,
                        ),
                        _buildStatItem(
                          icon: Icons.group_outlined,
                          label: 'Groups',
                          value: '---',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Complete Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.state.isLoading
                          ? null
                          : () => _completeOnboarding(controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5631),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: controller.state.isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start Exploring',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, color: Colors.white),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFF17F36), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E30),
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Future<void> _completeOnboarding(OnboardingController controller) async {
    debugPrint('🔄 Starting onboarding completion...');

    final success = await controller.saveOnboardingData();

    debugPrint('📊 Save result: $success, onboardingComplete: ${controller.state.onboardingComplete}');

    if (mounted) {
      if (success) {
        debugPrint('✅ Onboarding saved successfully! Popping to AuthWrapper...');
        // Navigate by popping all routes back to AuthWrapper
        // AuthWrapper will then re-check onboarding status and let user through
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (controller.state.errorMessage != null) {
        debugPrint('❌ Error saving onboarding: ${controller.state.errorMessage}');
        // Show error if save failed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(controller.state.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _completeOnboarding(controller),
            ),
          ),
        );
      }
    }
  }
}

// Confetti particle class
class ConfettiParticle {
  final double x;
  final double y;
  final Color color;
  final double size;
  final double speed;
  final double angle;

  ConfettiParticle({required Random random})
    : x = random.nextDouble(),
      y = random.nextDouble() * 0.5,
      color = [
        const Color(0xFF1E5631),
        const Color(0xFFF17F36),
        Colors.purple,
        Colors.blue,
        Colors.pink,
        Colors.yellow,
      ][random.nextInt(6)],
      size = 4 + random.nextDouble() * 8,
      speed = 0.5 + random.nextDouble() * 0.5,
      angle = random.nextDouble() * 2 * pi;
}

// Custom painter for confetti
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final y = particle.y + (progress * particle.speed * 2);
      final x = particle.x + 0.1 * sin(progress * 2 * pi + particle.angle);

      if (y < 1.0) {
        final paint = Paint()..color = particle.color;
        canvas.drawCircle(
          Offset(x * size.width, y * size.height),
          particle.size,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConfettiPainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}
