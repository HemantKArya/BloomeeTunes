// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BloomeeSwitch extends StatelessWidget {
  final bool value;
  final VoidCallback onChanged;

  const BloomeeSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value
              ? Default_Theme.accentColor2.withValues(alpha: 0.15)
              : Default_Theme.primaryColor2.withValues(alpha: 0.05),
          border: Border.all(
            color: value
                ? Default_Theme.accentColor2.withValues(alpha: 0.5)
                : Default_Theme.primaryColor2.withValues(alpha: 0.15),
            width: 1.5,
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: value
                  ? Default_Theme.accentColor2
                  : Default_Theme.primaryColor2.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
