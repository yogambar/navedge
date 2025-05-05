import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class PinButton extends StatefulWidget {
  final IconData iconData;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;

  const PinButton({
    super.key,
    required this.iconData,
    this.onPressed,
    this.tooltip,
    this.backgroundColor,
    this.iconColor,
    this.size,
  });

  @override
  State<PinButton> createState() => _PinButtonState();
}

class _PinButtonState extends State<PinButton> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor =
        widget.backgroundColor ?? Theme.of(context).colorScheme.primary;
    final Color effectiveIconColor =
        widget.iconColor ?? Colors.white;
    final double effectiveSize = widget.size ?? 56.0; // Standard FAB size

    return FadeIn(
      duration: const Duration(milliseconds: 400),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.05)
            .animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)),
        child: Tooltip(
          message: widget.tooltip ?? 'Set Pin',
          waitDuration: const Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: effectiveBackgroundColor.withOpacity(0.6),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
              borderRadius: BorderRadius.circular(effectiveSize),
            ),
            child: FloatingActionButton(
              heroTag: null, // avoid hero conflict
              backgroundColor: effectiveBackgroundColor,
              foregroundColor: effectiveIconColor,
              onPressed: widget.onPressed,
              elevation: 6,
              highlightElevation: 10,
              mini: true,
              child: Icon(
                widget.iconData,
                size: effectiveSize * 0.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

