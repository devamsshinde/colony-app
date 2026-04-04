import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/onboarding_controller.dart';

class Step4LocationPermission extends StatefulWidget {
  const Step4LocationPermission({super.key});

  @override
  State<Step4LocationPermission> createState() =>
      _Step4LocationPermissionState();
}

class _Step4LocationPermissionState extends State<Step4LocationPermission>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isRequesting = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          // Animated Location Icon
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFF1E5631), Color(0xFF2E6B3B)],
                  center: Alignment.center,
                  radius: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E5631).withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pulse rings
                  ...List.generate(3, (index) {
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.5),
                      duration: Duration(milliseconds: 1500 + (index * 500)),
                      builder: (context, value, child) {
                        return Container(
                          width: 80 + (value * 40),
                          height: 80 + (value * 40),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(
                                0xFF1E5631,
                              ).withOpacity(0.3 - (value * 0.15)),
                              width: 2,
                            ),
                          ),
                        );
                      },
                    );
                  }),
                  const Icon(Icons.location_on, size: 60, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Enable Location',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF14471E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Colony works best when you share your location.\nDiscover nearby neighbors, events, and groups.',
            style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          // Benefits List
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F6E8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildBenefitItem(
                  icon: Icons.people_outline,
                  text: 'Find neighbors nearby',
                ),
                const SizedBox(height: 16),
                _buildBenefitItem(
                  icon: Icons.event_outlined,
                  text: 'Discover local events',
                ),
                const SizedBox(height: 16),
                _buildBenefitItem(
                  icon: Icons.group_outlined,
                  text: 'Join neighborhood groups',
                ),
                const SizedBox(height: 16),
                _buildBenefitItem(
                  icon: Icons.forum_outlined,
                  text: 'Connect with your community',
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Location Status / Button
          Consumer<OnboardingController>(
            builder: (context, controller, child) {
              final hasLocation =
                  controller.state.latitude != null &&
                  controller.state.longitude != null;

              if (hasLocation) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Location Enabled',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E30),
                                  ),
                                ),
                                if (controller.state.locationName != null)
                                  Text(
                                    controller.state.locationName!,
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
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.nextStep();
                          _navigateToNextPage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E5631),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue',
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
                  ],
                );
              }

              // Default - Request location button
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isRequesting
                          ? null
                          : () => _requestLocation(controller),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5631),
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: _isRequesting
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
                                Icon(Icons.location_on, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Enable Location',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      controller.nextStep();
                      _navigateToNextPage();
                    },
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E5631).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1E5631), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E30)),
        ),
      ],
    );
  }

  Future<void> _requestLocation(OnboardingController controller) async {
    setState(() => _isRequesting = true);
    await controller.getCurrentLocation();
    setState(() => _isRequesting = false);
  }

  void _navigateToNextPage() {
    final pageView = context.findAncestorWidgetOfExactType<PageView>();
    if (pageView?.controller != null) {
      pageView!.controller!.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}
