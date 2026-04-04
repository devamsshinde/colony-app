import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/location_service.dart';

/// A widget that displays the current location at the top of the home screen.
/// Shows a pin icon, location name, and a pulsing green dot when tracking is active.
/// If location is not available, shows "Tap to enable location" with an orange warning.
class LocationHeaderWidget extends StatefulWidget {
  final VoidCallback? onTapWhenDisabled;

  const LocationHeaderWidget({super.key, this.onTapWhenDisabled});

  @override
  State<LocationHeaderWidget> createState() => _LocationHeaderWidgetState();
}

class _LocationHeaderWidgetState extends State<LocationHeaderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  String _previousLocationName = '';

  @override
  void initState() {
    super.initState();

    // Setup pulse animation for the live tracking indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();

    return ValueListenableBuilder<LocationData>(
      valueListenable: locationService.locationNotifier,
      builder: (context, locationData, child) {
        final hasLocation = locationData.hasValidLocation;
        final isTracking = locationData.isTracking;
        final locationName = locationData.locationName;

        // Track previous location for animation
        final locationChanged =
            _previousLocationName != locationName &&
            _previousLocationName.isNotEmpty &&
            locationName != 'Locating...';
        _previousLocationName = locationName;

        return GestureDetector(
          onTap: hasLocation ? null : widget.onTapWhenDisabled,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: hasLocation
                  ? Colors.green.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasLocation
                    ? Colors.green.withOpacity(0.3)
                    : Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Location icon
                Icon(
                  hasLocation ? Icons.location_on : Icons.location_disabled,
                  color: hasLocation ? Colors.green : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),

                // Location name with animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Text(
                    hasLocation ? locationName : 'Tap to enable location',
                    key: ValueKey(locationName),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: hasLocation
                          ? Colors.green.shade800
                          : Colors.orange.shade800,
                    ),
                  ),
                ),

                // Live tracking indicator (pulsing green dot)
                if (isTracking) ...[
                  const SizedBox(width: 10),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green.withOpacity(
                            _pulseAnimation.value,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A simplified version of the location header for use in app bars
class LocationHeaderCompact extends StatelessWidget {
  const LocationHeaderCompact({super.key});

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();

    return ValueListenableBuilder<LocationData>(
      valueListenable: locationService.locationNotifier,
      builder: (context, locationData, child) {
        final hasLocation = locationData.hasValidLocation;
        final locationName = locationData.locationName;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasLocation ? Icons.location_on : Icons.location_disabled,
              color: hasLocation ? Colors.green : Colors.orange,
              size: 16,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                hasLocation ? locationName : 'Location off',
                style: TextStyle(
                  fontSize: 12,
                  color: hasLocation ? Colors.green : Colors.orange,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      },
    );
  }
}
