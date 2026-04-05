import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

/// State class for onboarding data
class OnboardingState {
  final int currentStep;
  final File? avatarFile;
  final String? avatarUrl;
  final String fullName;
  final String username;
  final String bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final List<String> interests;
  final List<String> lookingFor;
  final String profession;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final bool isLoading;
  final String? errorMessage;
  final bool usernameAvailable;
  final bool checkingUsername;
  final bool locationEnabled;
  final bool onboardingComplete;

  const OnboardingState({
    this.currentStep = 0,
    this.avatarFile,
    this.avatarUrl,
    this.fullName = '',
    this.username = '',
    this.bio = '',
    this.dateOfBirth,
    this.gender,
    this.interests = const [],
    this.lookingFor = const [],
    this.profession = '',
    this.latitude,
    this.longitude,
    this.locationName,
    this.isLoading = false,
    this.errorMessage,
    this.usernameAvailable = false,
    this.checkingUsername = false,
    this.locationEnabled = false,
    this.onboardingComplete = false,
  });

  OnboardingState copyWith({
    int? currentStep,
    File? avatarFile,
    String? avatarUrl,
    String? fullName,
    String? username,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    List<String>? interests,
    List<String>? lookingFor,
    String? profession,
    double? latitude,
    double? longitude,
    String? locationName,
    bool? isLoading,
    String? errorMessage,
    bool? usernameAvailable,
    bool? checkingUsername,
    bool? locationEnabled,
    bool? onboardingComplete,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      avatarFile: avatarFile ?? this.avatarFile,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
      lookingFor: lookingFor ?? this.lookingFor,
      profession: profession ?? this.profession,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      usernameAvailable: usernameAvailable ?? this.usernameAvailable,
      checkingUsername: checkingUsername ?? this.checkingUsername,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  // Validation methods
  bool get isStep1Valid => true; // Welcome step always valid

  bool get isStep2Valid {
    return fullName.trim().length >= 2 &&
        username.trim().length >= 3 &&
        usernameAvailable &&
        dateOfBirth != null &&
        _isAtLeast16YearsOld(dateOfBirth!) &&
        gender != null;
  }

  bool get isStep3Valid {
    return interests.length >= 3;
  }

  bool get isStep4Valid {
    return latitude != null && longitude != null;
  }

  bool get isStep5Valid => true; // Ready step always valid

  bool _isAtLeast16YearsOld(DateTime dob) {
    final now = DateTime.now();
    final age = now.year - dob.year;
    if (age > 16) return true;
    if (age == 16) {
      return now.month > dob.month ||
          (now.month == dob.month && now.day >= dob.day);
    }
    return false;
  }

  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }
}

/// Controller for managing onboarding flow using ChangeNotifier
class OnboardingController extends ChangeNotifier {
  OnboardingState _state = const OnboardingState();

  OnboardingState get state => _state;

  OnboardingController() {
    _initializeFromCurrentUser();
  }

  Future<void> _initializeFromCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        _state = _state.copyWith(
          fullName: profile['full_name'] ?? '',
          username: profile['username'] ?? '',
          bio: profile['bio'] ?? '',
          avatarUrl: profile['avatar_url'],
          locationName: profile['location_name'], // Fixed: was 'location'
        );
        notifyListeners();
      } catch (e) {
        // Profile doesn't exist yet, that's fine
      }
    }
  }

  // Navigation
  void goToStep(int step) {
    _state = _state.copyWith(currentStep: step);
    notifyListeners();
  }

  void nextStep() {
    if (_state.currentStep < 4) {
      _state = _state.copyWith(currentStep: _state.currentStep + 1);
      notifyListeners();
    }
  }

  void previousStep() {
    if (_state.currentStep > 0) {
      _state = _state.copyWith(currentStep: _state.currentStep - 1);
      notifyListeners();
    }
  }

  // Step 2: Profile Setup
  Future<void> pickAvatar(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _state = _state.copyWith(avatarFile: File(pickedFile.path));
        notifyListeners();
      }
    } catch (e) {
      _state = _state.copyWith(errorMessage: 'Failed to pick image: $e');
      notifyListeners();
    }
  }

  Future<void> uploadAvatar() async {
    if (_state.avatarFile == null) return;

    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final fileName =
          'avatars/$userId-${DateTime.now().millisecondsSinceEpoch}.jpg';

      await Supabase.instance.client.storage
          .from('avatars')
          .upload(fileName, _state.avatarFile!);

      final avatarUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      _state = _state.copyWith(avatarUrl: avatarUrl, isLoading: false);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to upload avatar: $e',
      );
      notifyListeners();
    }
  }

  void updateFullName(String name) {
    _state = _state.copyWith(fullName: name);
    notifyListeners();
  }

  Future<void> updateUsername(String username) async {
    _state = _state.copyWith(username: username, checkingUsername: true);
    notifyListeners();

    // Debounce username check
    await Future.delayed(const Duration(milliseconds: 500));

    if (_state.username != username) return; // Changed again

    if (username.length < 3) {
      _state = _state.copyWith(
        usernameAvailable: false,
        checkingUsername: false,
      );
      notifyListeners();
      return;
    }

    try {
      final response = await Supabase.instance.client.rpc(
        'check_username_available',
        params: {'p_username': username},
      );

      _state = _state.copyWith(
        usernameAvailable: response == true,
        checkingUsername: false,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        usernameAvailable: false,
        checkingUsername: false,
      );
      notifyListeners();
    }
  }

  void updateBio(String bio) {
    if (bio.length <= 500) {
      _state = _state.copyWith(bio: bio);
      notifyListeners();
    }
  }

  void updateDateOfBirth(DateTime dob) {
    _state = _state.copyWith(dateOfBirth: dob);
    notifyListeners();
  }

  void updateGender(String gender) {
    _state = _state.copyWith(gender: gender);
    notifyListeners();
  }

  // Step 3: Interests
  void toggleInterest(String interest) {
    final interests = List<String>.from(_state.interests);
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
    _state = _state.copyWith(interests: interests);
    notifyListeners();
  }

  void toggleLookingFor(String option) {
    final lookingFor = List<String>.from(_state.lookingFor);
    if (lookingFor.contains(option)) {
      lookingFor.remove(option);
    } else {
      lookingFor.add(option);
    }
    _state = _state.copyWith(lookingFor: lookingFor);
    notifyListeners();
  }

  void updateProfession(String profession) {
    _state = _state.copyWith(profession: profession);
    notifyListeners();
  }

  // Step 4: Location
  Future<bool> requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _state = _state.copyWith(errorMessage: 'Location service is disabled.');
        notifyListeners();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _state = _state.copyWith(errorMessage: 'Location permission denied.');
          notifyListeners();
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _state = _state.copyWith(
          errorMessage:
              'Location permission denied forever. Please enable in settings.',
        );
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      _state = _state.copyWith(
        errorMessage: 'Error checking location permission: $e',
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> getCurrentLocation() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        _state = _state.copyWith(isLoading: false);
        notifyListeners();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      String locationName = 'Location Set';

      _state = _state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: locationName,
        locationEnabled: true,
        isLoading: false,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to get location: $e',
      );
      notifyListeners();
    }
  }

  // Save all data to Supabase
  Future<bool> saveOnboardingData() async {
    _state = _state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      // Upload avatar if selected
      if (_state.avatarFile != null) {
        await uploadAvatar();
      }

      // Update profile
      await Supabase.instance.client.from('profiles').upsert({
        'id': userId,
        'full_name': _state.fullName,
        'username': _state.username,
        'bio': _state.bio,
        'date_of_birth': _state.dateOfBirth?.toIso8601String(),
        'gender': _state.gender,
        'interests': _state.interests,
        'looking_for': _state.lookingFor,
        'profession': _state.profession,
        'latitude': _state.latitude,
        'longitude': _state.longitude,
        'location_name': _state.locationName, // Fixed: was 'location'
        'avatar_url': _state.avatarUrl,
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      });

      _state = _state.copyWith(isLoading: false, onboardingComplete: true);
      notifyListeners();

      return true;
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to save profile: $e',
      );
      notifyListeners();
      return false;
    }
  }

  Future<int> getNearbyUsersCount() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response = await Supabase.instance.client.rpc(
        'get_nearby_users_count',
        params: {'p_user_id': userId, 'p_radius_km': 5.0},
      );
      return response ?? 0;
    } catch (e) {
      return 0;
    }
  }

  void clearError() {
    _state = _state.copyWith(errorMessage: null);
    notifyListeners();
  }
}
