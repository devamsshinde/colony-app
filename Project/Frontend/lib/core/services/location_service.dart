import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A singleton service for real-time location tracking in the Colony app.
/// Handles permission requests, continuous location updates, and Supabase sync.
class LocationService {
  // Singleton instance
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Stream subscription for position updates
  StreamSubscription<Position>? _positionStreamSubscription;

  // Current position
  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  // Current location name (reverse geocoded)
  String _currentLocationName = 'Locating...';
  String get currentLocationName => _currentLocationName;

  // ValueNotifier for location updates (UI can listen)
  final ValueNotifier<LocationData> locationNotifier =
      ValueNotifier<LocationData>(
        LocationData(
          latitude: 0,
          longitude: 0,
          locationName: 'Locating...',
          isTracking: false,
          hasPermission: false,
        ),
      );

  // Tracking state
  bool _isTracking = false;
  bool get isTracking => _isTracking;

  // Last geocode time for throttling
  DateTime? _lastGeocodeTime;
  static const Duration _geocodeThrottleDuration = Duration(minutes: 2);

  // Supabase client
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Initialize the location service and check permissions
  Future<bool> initialize() async {
    try {
      // Check if location service is enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        _updateLocationData(
          locationName: 'Location service disabled',
          isTracking: false,
          hasPermission: false,
        );
        return false;
      }

      // Check and request permission
      var permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          _updateLocationData(
            locationName: 'Location permission denied',
            isTracking: false,
            hasPermission: false,
          );
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _updateLocationData(
          locationName: 'Location permission denied forever',
          isTracking: false,
          hasPermission: false,
        );
        return false;
      }

      // Permission granted
      _updateLocationData(hasPermission: true);
      return true;
    } catch (e) {
      debugPrint('LocationService: Initialize error: $e');
      return false;
    }
  }

  /// Start continuous location tracking
  Future<void> startTracking() async {
    if (_isTracking) {
      debugPrint('LocationService: Already tracking');
      return;
    }

    try {
      // Ensure we have permission
      final hasPermission = await initialize();
      if (!hasPermission) {
        debugPrint('LocationService: No permission to start tracking');
        return;
      }

      // Configure location settings
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // Update only when moved 50+ meters
        timeLimit: Duration(seconds: 30),
      );

      // Start position stream
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(_onPositionUpdate, onError: _onPositionError);

      _isTracking = true;
      _updateLocationData(isTracking: true);

      // Get initial position immediately
      await getCurrentPosition();

      debugPrint('LocationService: Started tracking');
    } catch (e) {
      debugPrint('LocationService: Error starting tracking: $e');
      _isTracking = false;
      _updateLocationData(isTracking: false);
    }
  }

  /// Handle position updates from the stream
  Future<void> _onPositionUpdate(Position position) async {
    debugPrint(
      'LocationService: Position update: ${position.latitude}, ${position.longitude}',
    );

    _currentPosition = position;

    // Update location name (with throttling)
    await _updateLocationName(position);

    // Update Supabase profile
    await _updateSupabaseLocation(position);

    // Broadcast update
    _updateLocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      locationName: _currentLocationName,
      isTracking: true,
    );
  }

  /// Handle position stream errors
  void _onPositionError(dynamic error) {
    debugPrint('LocationService: Position stream error: $error');

    if (error is LocationServiceDisabledException) {
      _updateLocationData(
        locationName: 'Location service disabled',
        isTracking: false,
      );
      _isTracking = false;
    }
  }

  /// Update location name with reverse geocoding (throttled)
  Future<void> _updateLocationName(Position position) async {
    // Check throttle
    final now = DateTime.now();
    if (_lastGeocodeTime != null &&
        now.difference(_lastGeocodeTime!) < _geocodeThrottleDuration) {
      return; // Skip geocoding, use cached name
    }

    try {
      final locationName = await getLocationName(
        position.latitude,
        position.longitude,
      );
      _currentLocationName = locationName;
      _lastGeocodeTime = now;
    } catch (e) {
      debugPrint('LocationService: Geocoding error: $e');
      // Keep previous location name or use coordinates
      if (_currentLocationName == 'Locating...') {
        _currentLocationName =
            '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      }
    }
  }

  /// Update Supabase profile with new location
  Future<void> _updateSupabaseLocation(Position position) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('profiles')
          .update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'location_name': _currentLocationName,
            'last_location_update': DateTime.now().toUtc().toIso8601String(),
            'is_online': true,
          })
          .eq('id', userId);

      debugPrint('LocationService: Updated Supabase location');
    } catch (e) {
      debugPrint('LocationService: Supabase update error: $e');
    }
  }

  /// Stop location tracking
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _isTracking = false;
    _updateLocationData(isTracking: false);
    debugPrint('LocationService: Stopped tracking');
  }

  /// Set user offline in Supabase
  Future<void> setUserOffline() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('profiles')
          .update({
            'is_online': false,
            'last_seen': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', userId);

      debugPrint('LocationService: Set user offline');
    } catch (e) {
      debugPrint('LocationService: Error setting user offline: $e');
    }
  }

  /// Set user online in Supabase
  Future<void> setUserOnline() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('profiles')
          .update({'is_online': true})
          .eq('id', userId);

      debugPrint('LocationService: Set user online');
    } catch (e) {
      debugPrint('LocationService: Error setting user online: $e');
    }
  }

  /// Get current position one-time with high accuracy
  Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await initialize();
      if (!hasPermission) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      _currentPosition = position;
      await _updateLocationName(position);
      await _updateSupabaseLocation(position);

      _updateLocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        locationName: _currentLocationName,
      );

      return position;
    } catch (e) {
      debugPrint('LocationService: Error getting current position: $e');
      return null;
    }
  }

  /// Reverse geocode coordinates to get readable location name
  Future<String> getLocationName(double lat, double lng) async {
    try {
      // Use Geolocator's placemark from coordinates (static method)
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) {
        return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      }

      final placemark = placemarks.first;

      // Build location string: "Street, City" or "City, Country"
      final parts = <String>[];

      // Try to get street-level detail
      if (placemark.street != null && placemark.street!.isNotEmpty) {
        // Clean up street name (remove house numbers for privacy)
        final street = placemark.street!
            .replaceAll(RegExp(r'^\d+\s*'), '')
            .trim();
        if (street.isNotEmpty) {
          parts.add(street);
        }
      }

      // Add sub-locality (neighborhood) if available
      if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
        if (parts.isEmpty) {
          parts.add(placemark.subLocality!);
        }
      }

      // Add locality (city)
      if (placemark.locality != null && placemark.locality!.isNotEmpty) {
        parts.add(placemark.locality!);
      } else if (placemark.subAdministrativeArea != null &&
          placemark.subAdministrativeArea!.isNotEmpty) {
        parts.add(placemark.subAdministrativeArea!);
      }

      if (parts.isEmpty) {
        // Fallback to country if nothing else
        if (placemark.country != null) {
          return placemark.country!;
        }
        return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      }

      return parts.take(2).join(', ');
    } catch (e) {
      debugPrint('LocationService: Geocoding error: $e');
      return '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
  }

  /// Calculate distance between two coordinates in meters
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  /// Calculate distance from current position to a point
  double? distanceFromCurrent(double lat, double lng) {
    if (_currentPosition == null) return null;
    return calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      lat,
      lng,
    );
  }

  /// Check current location permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Check if location service is enabled on device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open device location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings for permissions
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Update the location notifier
  void _updateLocationData({
    double? latitude,
    double? longitude,
    String? locationName,
    bool? isTracking,
    bool? hasPermission,
  }) {
    final current = locationNotifier.value;
    locationNotifier.value = LocationData(
      latitude: latitude ?? current.latitude,
      longitude: longitude ?? current.longitude,
      locationName: locationName ?? current.locationName,
      isTracking: isTracking ?? current.isTracking,
      hasPermission: hasPermission ?? current.hasPermission,
    );
  }

  /// Clean up resources
  void dispose() {
    stopTracking();
    locationNotifier.dispose();
    debugPrint('LocationService: Disposed');
  }
}

/// Data class for location information
class LocationData {
  final double latitude;
  final double longitude;
  final String locationName;
  final bool isTracking;
  final bool hasPermission;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.isTracking,
    required this.hasPermission,
  });

  bool get hasValidLocation => latitude != 0 && longitude != 0;

  LocationData copyWith({
    double? latitude,
    double? longitude,
    String? locationName,
    bool? isTracking,
    bool? hasPermission,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      isTracking: isTracking ?? this.isTracking,
      hasPermission: hasPermission ?? this.hasPermission,
    );
  }
}
