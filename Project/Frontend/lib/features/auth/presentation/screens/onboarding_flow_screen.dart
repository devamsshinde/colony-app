import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/onboarding_controller.dart';
import 'onboarding_steps/step1_welcome.dart';
import 'onboarding_steps/step2_profile_setup.dart';
import 'onboarding_steps/step3_interests.dart';
import 'onboarding_steps/step4_location_permission.dart';
import 'onboarding_steps/step5_ready.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late OnboardingController _onboardingController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _onboardingController = OnboardingController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _onboardingController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _goToNextPage() {
    final currentState = _onboardingController.state;
    bool canProceed = false;

    switch (currentState.currentStep) {
      case 0:
        canProceed = currentState.isStep1Valid;
        break;
      case 1:
        canProceed = currentState.isStep2Valid;
        break;
      case 2:
        canProceed = currentState.isStep3Valid;
        break;
      case 3:
        canProceed = currentState.isStep4Valid;
        break;
      case 4:
        canProceed = currentState.isStep5Valid;
        break;
    }

    if (canProceed && currentState.currentStep < 4) {
      _onboardingController.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  void _goToPreviousPage() {
    if (_onboardingController.state.currentStep > 0) {
      _onboardingController.previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _onboardingController,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F7ED),
        body: SafeArea(
          child: Column(
            children: [
              _buildProgressBar(),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    _onboardingController.goToStep(index);
                  },
                  children: const [
                    Step1Welcome(),
                    Step2ProfileSetup(),
                    Step3Interests(),
                    Step4LocationPermission(),
                    Step5Ready(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Consumer<OnboardingController>(
      builder: (context, controller, child) {
        final currentStep = controller.state.currentStep;
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Back button
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  width: currentStep > 0 ? 48 : 0,
                  height: 48,
                  child: currentStep > 0
                      ? Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _goToPreviousPage,
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20,
                                color: Color(0xFF14471E),
                              ),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Progress indicators
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          final isActive = index <= currentStep;
                          final isCurrent = index == currentStep;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.fastOutSlowIn,
                            width: (constraints.maxWidth - 32) / 5 - 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF1E5631)
                                  : const Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isCurrent
                                  ? [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF1E5631,
                                        ).withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                // Step counter with pill design
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastOutSlowIn,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1E5631),
                        const Color(0xFF2E7B4A),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1E5631).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.fastOutSlowIn,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      '${currentStep + 1} of 5',
                      key: ValueKey<int>(currentStep),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
