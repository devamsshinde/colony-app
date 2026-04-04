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

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  late PageController _pageController;
  late OnboardingController _onboardingController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _onboardingController = OnboardingController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _onboardingController.dispose();
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_onboardingController.state.currentStep > 0) {
      _onboardingController.previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              // Back button
              if (currentStep > 0)
                GestureDetector(
                  onTap: _goToPreviousPage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: Color(0xFF14471E),
                    ),
                  ),
                )
              else
                const SizedBox(width: 34),
              const SizedBox(width: 16),
              // Progress dots
              Expanded(
                child: Row(
                  children: List.generate(5, (index) {
                    final isActive = index <= currentStep;
                    final isCurrent = index == currentStep;
                    return Expanded(
                      child: Container(
                        height: 6,
                        margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1E5631)
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF1E5631,
                                    ).withOpacity(0.3),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // Step indicator
              Text(
                '${currentStep + 1}/5',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF14471E),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
