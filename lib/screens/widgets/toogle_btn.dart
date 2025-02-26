import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  final String label;
  final ValueChanged<bool>
      onChanged; // Callback with current state (true/false)
  final bool initialState; // Parameter to set initial state

  const ToggleButton({
    Key? key,
    required this.label,
    required this.onChanged,
    this.initialState = false, // Default to false (inactive)
  }) : super(key: key);

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton>
    with SingleTickerProviderStateMixin {
  late bool _isActive;
  late AnimationController _animationController;
  late Animation<Color?> _textColorAnimation;

  @override
  void initState() {
    super.initState();
    _isActive = widget.initialState; // Set initial state from parameter
    _animationController = AnimationController(
      duration:
          const Duration(milliseconds: 200), // Lightweight, fast animation
      vsync: this,
    );
    _textColorAnimation = ColorTween(
      begin: Colors.grey[700], // Low-opacity border color for inactive state
      end: Colors.white, // Full white for active state
    ).animate(_animationController);
    if (_isActive) _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void updateState(bool newState) {
    setState(() {
      _isActive = newState;
    });
    if (_isActive) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    widget.onChanged(_isActive); // Notify parent of state change
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        updateState(!_isActive);
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200), // Smooth, lightweight transition
        constraints: const BoxConstraints(
            minHeight: 30), // Minimum height to ensure visibility
        padding: const EdgeInsets.symmetric(
            vertical: 4, horizontal: 8), // Reduced padding for responsiveness
        decoration: BoxDecoration(
          color: _isActive
              ? Default_Theme.accentColor2
              : Colors.grey[900], // Pink for active, dark grey for inactive
          borderRadius: BorderRadius.circular(
              20), // More rounded corners like in the image
          border: Border.all(
            color: _isActive
                ? Default_Theme.accentColor2
                : Colors.grey[700]!, // Match border color in inactive state
            width: 2,
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown, // Scales text down to fit within the button
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Text(
                widget.label,
                style: TextStyle(
                  color: _textColorAnimation.value!, // Animated text color
                  fontSize: 12, // Default font size, will scale with FittedBox
                  fontWeight: FontWeight.bold, // Bold text for clarity
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
