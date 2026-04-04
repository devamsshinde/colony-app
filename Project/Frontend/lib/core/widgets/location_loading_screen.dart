import 'dart:async';
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import 'location_radar_widget.dart';

/// A full-screen loading overlay that shows when fetching initial location.
/// Displays a radar animation with "Finding your colony..." text.
class LocationLoadingScreen extends StatefulWidget {
  /// Called when location is successfully fetched
  final VoidCallback? onLocationFetched;

  /// Called when location fetch fails
  final VoidCallback? onLocationFailed;

  /// Maximum time to wait for location before showing retry
  final Duration timeout;

  /// Whether to auto-dismiss when location is ready
  final bool autoDismiss;

  const LocationLoadingScreen({
    super.key,
    this.onLocationFetched,
    this.onLocationFailed,
    this.timeout = const Duration(seconds: 10),
    this.autoDismiss = true,
  });

  @override
  State<LocationLoadingScreen> createState() => _LocationLoadingScreenState();
}

class _LocationLoadingScreenState extends State<LocationLoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _dotsController;
  late Animation<int> _dotsAnimation;

  final LocationService _locationService = LocationService();

  bool _isLoading = true;
  bool _hasError = false;
  String _statusText = 'Initializing...';
  String _locationDetail = '';

  Timer? _timeoutTimer;
  Timer? _statusTimer;
  int _statusIndex = 0;

  final List<String> _statusMessages = [
    'Checking permissions...',
    'Acquiring satellite signal...',
    'Finding your location...',
    'Resolving address...',
    'Almost there...',
  ];

  @override
  void initState() {
    super.initState();

    // Setup typing dots animation
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _dotsAnimation = StepTween(begin: 0, end: 3).animate(_dotsController);

    // Start location fetching
    _startLocationFetch();

    // Start status message rotation
    _startStatusRotation();

    // Setup timeout
    _timeoutTimer = Timer(widget.timeout, _onTimeout);
  }

  void _startLocationFetch() {
    // Listen to location updates using addListener
    _locationService.locationNotifier.addListener(_onLocationUpdate);

    // Start the async location fetch
    _startLocationFetchAsync();
  }

  void _onLocationUpdate() {
    final data = _locationService.locationNotifier.value;
    if (data.hasValidLocation && mounted) {
      setState(() {
        _isLoading = false;
        _locationDetail = data.locationName;
      });

      if (widget.autoDismiss) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            widget.onLocationFetched?.call();
          }
        });
      }
    }
  }

  Future<void> _startLocationFetchAsync() async {
    // Initialize and start tracking
    final initialized = await _locationService.initialize();
    if (!initialized) {
      setState(() {
        _hasError = true;
        _statusText = 'Location permission denied';
      });
      return;
    }

    setState(() {
      _statusText = 'Getting your location...';
    });

    await _locationService.startTracking();
  }

  void _startStatusRotation() {
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isLoading && mounted) {
        setState(() {
          _statusIndex = (_statusIndex + 1) % _statusMessages.length;
          _statusText = _statusMessages[_statusIndex];
        });
      }
    });
  }

  void _onTimeout() {
    if (_isLoading && mounted) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _statusText = 'Location request timed out';
      });
      widget.onLocationFailed?.call();
    }
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _timeoutTimer?.cancel();
    _statusTimer?.cancel();
    _locationService.locationNotifier.removeListener(_onLocationUpdate);
    super.dispose();
  }

  void _retry() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _statusText = 'Retrying...';
      _locationDetail = '';
    });

    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(widget.timeout, _onTimeout);

    await _locationService.getCurrentPosition();
  }

  void _openSettings() async {
    await _locationService.openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.9),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Radar animation
              if (_isLoading)
                const LocationRadarWidget(size: 200, showNearbyDots: true)
              else if (_hasError)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_disabled,
                    size: 60,
                    color: Colors.orange,
                  ),
                )
              else
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 60,
                    color: Colors.green,
                  ),
                ),

              const SizedBox(height: 40),

              // Main text with typing dots
              AnimatedBuilder(
                animation: _dotsAnimation,
                builder: (context, child) {
                  final dots = '.' * _dotsAnimation.value;
                  return Text(
                    _isLoading ? 'Finding your colony$dots' : _statusText,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),

              const SizedBox(height: 12),

              // Status text
              Text(
                _hasError
                    ? _statusText
                    : (_isLoading ? _statusText : _locationDetail),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Action buttons
              if (_hasError) ...[
                ElevatedButton.icon(
                  onPressed: _retry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: _openSettings,
                  icon: const Icon(Icons.settings, color: Colors.white70),
                  label: const Text(
                    'Open Settings',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],

              // Skip button (optional)
              if (_isLoading) ...[
                const SizedBox(height: 60),
                TextButton(
                  onPressed: () {
                    _timeoutTimer?.cancel();
                    widget.onLocationFetched?.call();
                  },
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A dialog version of the location loading screen
class LocationLoadingDialog extends StatelessWidget {
  final VoidCallback? onDismiss;

  const LocationLoadingDialog({super.key, this.onDismiss});

  static Future<void> show(BuildContext context, {VoidCallback? onDismiss}) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LocationLoadingDialog(onDismiss: onDismiss),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LocationRadarWidget(size: 150, showNearbyDots: true),
            const SizedBox(height: 24),
            const Text(
              'Finding your colony...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we locate you',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
