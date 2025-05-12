import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../user_data_provider.dart'; 

class RouteInfoWidget extends StatefulWidget {
  final double distanceKm;
  final String duration;

  const RouteInfoWidget({
    Key? key,
    required this.distanceKm,
    required this.duration,
  }) : super(key: key);

  @override
  State<RouteInfoWidget> createState() => _RouteInfoWidgetState();
}

class _RouteInfoWidgetState extends State<RouteInfoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _getIconPath(String vehicle) {
    switch (vehicle) {
      case 'driving':
        return 'assets/images/icons/car.png';
      case 'walking':
        return 'assets/images/icons/walk.png';
      case 'bicycling':
        return 'assets/images/icons/bike.png';
      default:
        return 'assets/images/icons/car.png'; // Default
    }
  }

  IconData _getIconData(String vehicle) {
    switch (vehicle) {
      case 'driving':
        return Icons.directions_car_rounded;
      case 'walking':
        return Icons.directions_walk_rounded;
      case 'bicycling':
        return Icons.directions_bike_rounded;
      default:
        return Icons.directions_car_rounded; // Default
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedVehicle = Provider.of<UserData>(context).selectedVehicle;
    final iconData = _getIconData(selectedVehicle);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 7,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoColumn(
                    iconData: iconData,
                    label: 'Distance',
                    value: '${widget.distanceKm.toStringAsFixed(2)} km',
                    valueStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const VerticalDivider(width: 2, thickness: 1, color: Colors.grey),
                  _InfoColumn(
                    iconData: Icons.timer_outlined,
                    label: 'Estimated Time',
                    value: widget.duration,
                    valueStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final IconData iconData;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoColumn({
    Key? key,
    required this.iconData,
    required this.label,
    required this.value,
    this.valueStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(iconData, color: Theme.of(context).colorScheme.primary, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueStyle ?? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
