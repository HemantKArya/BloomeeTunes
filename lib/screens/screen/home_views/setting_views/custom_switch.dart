// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BloomeeSwitch extends StatefulWidget {
  final bool value;
  final VoidCallback onChanged;

  const BloomeeSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<BloomeeSwitch> createState() => _BloomeeSwitchState();
}

class _BloomeeSwitchState extends State<BloomeeSwitch> {
  late bool _localValue;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant BloomeeSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with external state when the parent rebuilds with a new value.
    if (oldWidget.value != widget.value) {
      _localValue = widget.value;
    }
  }

  void _handleTap() {
    // Optimistically flip for instant animation.
    setState(() {
      _localValue = !_localValue;
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: _localValue
              ? Default_Theme.accentColor2.withValues(alpha: 0.15)
              : Default_Theme.primaryColor2.withValues(alpha: 0.05),
          border: Border.all(
            color: _localValue
                ? Default_Theme.accentColor2.withValues(alpha: 0.5)
                : Default_Theme.primaryColor2.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: _localValue ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: _localValue
                  ? Default_Theme.accentColor2
                  : Default_Theme.primaryColor2.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
