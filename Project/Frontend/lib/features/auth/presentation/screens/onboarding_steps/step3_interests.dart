import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/onboarding_controller.dart';

class Step3Interests extends StatefulWidget {
  const Step3Interests({super.key});

  @override
  State<Step3Interests> createState() => _Step3InterestsState();
}

class _Step3InterestsState extends State<Step3Interests> {
  final _professionController = TextEditingController();

  final List<String> _allInterests = [
    'Technology',
    'Sports',
    'Music',
    'Movies',
    'Books',
    'Travel',
    'Food',
    'Fitness',
    'Art',
    'Photography',
    'Gaming',
    'Fashion',
    'Nature',
    'Cooking',
    'Dancing',
    'Pets',
    'DIY',
    'Gardening',
    'Volunteering',
    'Entrepreneurship',
  ];

  final List<String> _lookingForOptions = [
    'Friends',
    'Networking',
    'Activities',
    'Local Tips',
    'Business',
  ];

  @override
  void initState() {
    super.initState();
    final controller = context.read<OnboardingController>();
    _professionController.text = controller.state.profession;
  }

  @override
  void dispose() {
    _professionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Interests',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF14471E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Select at least 3 interests',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          // Interests Grid
          Consumer<OnboardingController>(
            builder: (context, controller, child) {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _allInterests.map((interest) {
                  final isSelected = controller.state.interests.contains(
                    interest,
                  );
                  return GestureDetector(
                    onTap: () => controller.toggleInterest(interest),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E5631)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1E5631)
                              : Colors.grey.shade300,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1E5631,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        interest,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          // Looking For Section
          const Text(
            'What are you looking for?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2C3E30),
            ),
          ),
          const SizedBox(height: 16),
          Consumer<OnboardingController>(
            builder: (context, controller, child) {
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _lookingForOptions.map((option) {
                  final isSelected = controller.state.lookingFor.contains(
                    option,
                  );
                  return GestureDetector(
                    onTap: () => controller.toggleLookingFor(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFF17F36)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF17F36)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected ? Icons.check : Icons.add,
                            size: 16,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            option,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 32),
          // Profession Field
          const Text(
            'Profession (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E30),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _professionController,
            onChanged: (value) {
              context.read<OnboardingController>().updateProfession(value);
            },
            decoration: InputDecoration(
              hintText: 'e.g., Software Engineer, Teacher',
              prefixIcon: const Icon(Icons.work_outline, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF1E5631),
                  width: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Continue Button
          Consumer<OnboardingController>(
            builder: (context, controller, child) {
              final isValid = controller.state.isStep3Valid;
              return Column(
                children: [
                  if (!isValid && controller.state.interests.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Select at least ${3 - controller.state.interests.length} more interests',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isValid
                          ? () {
                              controller.nextStep();
                              _navigateToNextPage();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5631),
                        disabledBackgroundColor: Colors.grey.shade300,
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
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
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
