import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../controllers/onboarding_controller.dart';

class Step2ProfileSetup extends StatefulWidget {
  const Step2ProfileSetup({super.key});

  @override
  State<Step2ProfileSetup> createState() => _Step2ProfileSetupState();
}

class _Step2ProfileSetupState extends State<Step2ProfileSetup> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    final controller = context.read<OnboardingController>();
    _fullNameController.text = controller.state.fullName;
    _usernameController.text = controller.state.username;
    _bioController.text = controller.state.bio;
    _selectedDate = controller.state.dateOfBirth;
    _selectedGender = controller.state.gender;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
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
            'Set up your profile',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF14471E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Let others know who you are',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 32),
          // Avatar upload
          Center(
            child: Consumer<OnboardingController>(
              builder: (context, controller, child) {
                return GestureDetector(
                  onTap: () => _showImageSourceDialog(controller),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E5631), Color(0xFF2E6B3B)],
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
                                  size: 50,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF17F36),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          // Full Name
          _buildTextField(
            controller: _fullNameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Icons.person_outline,
            onChanged: (value) {
              context.read<OnboardingController>().updateFullName(value);
            },
          ),
          const SizedBox(height: 20),
          // Username
          Consumer<OnboardingController>(
            builder: (context, controller, child) {
              return _buildTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Choose a unique username',
                icon: Icons.alternate_email,
                suffixIcon: controller.state.checkingUsername
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : controller.state.usernameAvailable &&
                          _usernameController.text.length >= 3
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : _usernameController.text.length >= 3
                    ? const Icon(Icons.cancel, color: Colors.red)
                    : null,
                onChanged: (value) {
                  controller.updateUsername(value);
                },
              );
            },
          ),
          const SizedBox(height: 20),
          // Bio
          Consumer<OnboardingController>(
            builder: (context, controller, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildTextField(
                    controller: _bioController,
                    label: 'Bio',
                    hint: 'Tell us about yourself',
                    icon: Icons.edit_outlined,
                    maxLines: 3,
                    onChanged: (value) {
                      controller.updateBio(value);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, right: 8),
                    child: Text(
                      '${controller.state.bio.length}/500',
                      style: TextStyle(
                        fontSize: 12,
                        color: controller.state.bio.length > 450
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          // Date of Birth
          GestureDetector(
            onTap: () => _selectDate(context),
            child: AbsorbPointer(
              child: _buildTextField(
                controller: TextEditingController(
                  text: _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : '',
                ),
                label: 'Date of Birth',
                hint: 'Select your date of birth',
                icon: Icons.calendar_today_outlined,
                suffixIcon: const Icon(Icons.arrow_drop_down),
                onChanged: (_) {}, // Not used for date picker
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Gender
          const Text(
            'Gender',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E30),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: ['Male', 'Female', 'Non-binary', 'Prefer not to say'].map(
              (gender) {
                final isSelected = _selectedGender == gender;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedGender = gender);
                    context.read<OnboardingController>().updateGender(gender);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF1E5631)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF1E5631)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      gender,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 40),
          // Continue Button
          Consumer<OnboardingController>(
            builder: (context, controller, child) {
              final isValid = controller.state.isStep2Valid;
              return SizedBox(
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
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C3E30),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey),
            suffixIcon: suffixIcon,
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
              borderSide: const BorderSide(color: Color(0xFF1E5631), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _showImageSourceDialog(OnboardingController controller) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                controller.pickAvatar(ImageSource.camera);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F6E8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Color(0xFF1E5631),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Camera'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                controller.pickAvatar(ImageSource.gallery);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F6E8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: Color(0xFF1E5631),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Gallery'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
          DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 16)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E5631),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2C3E30),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      context.read<OnboardingController>().updateDateOfBirth(picked);
    }
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
