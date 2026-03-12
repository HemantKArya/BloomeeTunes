import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/custom_switch.dart';
import 'package:flutter/material.dart';

class SettingSectionHeader extends StatelessWidget {
  final String label;
  const SettingSectionHeader({required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: Default_Theme.secondoryTextStyleMedium.copyWith(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class SettingCard extends StatelessWidget {
  final List<Widget> children;
  const SettingCard({required this.children, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor2.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Performance Fix
        children: children,
      ),
    );
  }
}

class SettingDivider extends StatelessWidget {
  const SettingDivider({super.key});
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
      );
}

class SettingIconBox extends StatelessWidget {
  final IconData icon;
  final Color? color;
  const SettingIconBox({required this.icon, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 20,
          color: color ?? Default_Theme.primaryColor2.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

// CONVERTED TO STATEFUL WIDGET FOR INSTANT SWITCH ANIMATION
class SettingToggleTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  State<SettingToggleTile> createState() => _SettingToggleTileState();
}

class _SettingToggleTileState extends State<SettingToggleTile> {
  late bool _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(SettingToggleTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          SettingIconBox(icon: widget.icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Layout Performance Fix
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: Default_Theme.secondoryTextStyleMedium.copyWith(
                    color: Default_Theme.primaryColor2,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: Default_Theme.secondoryTextStyle.copyWith(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          BloomeeSwitch(
            value: _currentValue,
            onChanged: () {
              // Optimistic state update for fluid animation
              final newValue = !_currentValue;
              setState(() => _currentValue = newValue);
              widget.onChanged(newValue);
            },
          ),
        ],
      ),
    );
  }
}

class SettingNavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;
  final bool roundBottom;

  const SettingNavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.roundBottom = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: roundBottom
            ? const BorderRadius.vertical(bottom: Radius.circular(20))
            : BorderRadius.circular(20),
        highlightColor: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        splashColor: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              SettingIconBox(icon: icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Layout Performance Fix
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: Default_Theme.primaryColor2,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Default_Theme.secondoryTextStyle.copyWith(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Default_Theme.accentColor2.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Default_Theme.accentColor2.withValues(alpha: 0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    badge!,
                    style: Default_Theme.secondoryTextStyle.copyWith(
                      color: Default_Theme.accentColor2,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Icon(Icons.chevron_right_rounded,
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.4),
                  size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingRadioTile<T> extends StatelessWidget {
  final String title;
  final String subtitle;
  final T value;
  final T groupValue;
  final ValueChanged<T?> onChanged;

  const SettingRadioTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(20),
        highlightColor: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        splashColor: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? Default_Theme.accentColor2
                        : Default_Theme.primaryColor2.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Default_Theme.accentColor2,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Layout Performance Fix
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: isSelected
                            ? Default_Theme.primaryColor2
                            : Default_Theme.primaryColor2
                                .withValues(alpha: 0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Default_Theme.secondoryTextStyle.copyWith(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.45),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingQualityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SettingQualityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: Default_Theme.accentColor2.withValues(alpha: 0.1),
        highlightColor: Default_Theme.accentColor2.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? Default_Theme.accentColor2.withValues(alpha: 0.15)
                : Default_Theme.primaryColor2.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Default_Theme.accentColor2.withValues(alpha: 0.5)
                  : Default_Theme.primaryColor2.withValues(alpha: 0.05),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: Default_Theme.secondoryTextStyleMedium.copyWith(
              color: isSelected
                  ? Default_Theme.accentColor2
                  : Default_Theme.primaryColor2.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class SettingQualityChipRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const SettingQualityChipRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Layout Performance Fix
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SettingIconBox(icon: icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: Default_Theme.primaryColor2,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Default_Theme.secondoryTextStyle.copyWith(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options
                .map((opt) => SettingQualityChip(
                      label: opt,
                      isSelected: opt == selected,
                      onTap: () => onSelected(opt),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class SettingDestructiveTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingDestructiveTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        highlightColor: Colors.red.withValues(alpha: 0.05),
        splashColor: Colors.red.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.15),
                  ),
                ),
                child: Center(
                  child: Icon(icon,
                      size: 20, color: Colors.red.withValues(alpha: 0.7)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Layout Performance Fix
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: Colors.red.withValues(alpha: 0.85),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Default_Theme.secondoryTextStyle.copyWith(
                        color: Colors.red.withValues(alpha: 0.45),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.red.withValues(alpha: 0.3), size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingInfoText extends StatelessWidget {
  final String text;
  final Color? color;
  const SettingInfoText({required this.text, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        style: Default_Theme.secondoryTextStyle.copyWith(
          color: color ?? Default_Theme.primaryColor2.withValues(alpha: 0.5),
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }
}

class SettingTextFieldTile extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  const SettingTextFieldTile({
    required this.label,
    required this.controller,
    this.keyboardType,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Default_Theme.primaryColor2,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
            fontSize: 13,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
                color: Default_Theme.primaryColor2.withValues(alpha: 0.2)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Default_Theme.accentColor2),
          ),
        ),
      ),
    );
  }
}

class SettingDropdownItem<T> {
  final T value;
  final String label;
  final String? description;
  final IconData? icon;

  const SettingDropdownItem({
    required this.value,
    required this.label,
    this.description,
    this.icon,
  });
}

class SettingDropdownTile<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final T value;
  final List<SettingDropdownItem<T>> items;
  final ValueChanged<T?> onChanged;

  const SettingDropdownTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  String _selectedLabel() {
    for (final item in items) {
      if (item.value == value) return item.label;
    }
    return '';
  }

  void _openSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _DropdownBottomSheet<T>(
        title: title,
        items: items,
        currentValue: value,
        onSelected: (selected) {
          onChanged(selected);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openSelector(context),
        borderRadius: BorderRadius.circular(20),
        highlightColor: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        splashColor: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              SettingIconBox(icon: icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Layout Performance Fix
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: Default_Theme.primaryColor2,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Default_Theme.secondoryTextStyle.copyWith(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: Default_Theme.accentColor2.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Default_Theme.accentColor2.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedLabel(),
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: Default_Theme.accentColor2,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.unfold_more_rounded,
                      color: Default_Theme.accentColor2.withValues(alpha: 0.7),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownBottomSheet<T> extends StatelessWidget {
  final String title;
  final List<SettingDropdownItem<T>> items;
  final T currentValue;
  final ValueChanged<T> onSelected;

  const _DropdownBottomSheet({
    required this.title,
    required this.items,
    required this.currentValue,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Layout Performance Fix
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Default_Theme.primaryColor2.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title.toUpperCase(),
                style: Default_Theme.secondoryTextStyleMedium.copyWith(
                  color: Default_Theme.primaryColor2.withValues(alpha: 0.45),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item.value == currentValue;
                return _DropdownOption<T>(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => onSelected(item.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownOption<T> extends StatelessWidget {
  final SettingDropdownItem<T> item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DropdownOption({
    required this.item,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        highlightColor: Default_Theme.accentColor2.withValues(alpha: 0.06),
        splashColor: Default_Theme.accentColor2.withValues(alpha: 0.08),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? Default_Theme.accentColor2.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? Default_Theme.accentColor2.withValues(alpha: 0.30)
                  : Default_Theme.primaryColor2.withValues(alpha: 0.04),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              if (item.icon != null) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Default_Theme.accentColor2.withValues(alpha: 0.12)
                        : Default_Theme.primaryColor2.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(
                      item.icon,
                      size: 18,
                      color: isSelected
                          ? Default_Theme.accentColor2
                          : Default_Theme.primaryColor2.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Layout Performance Fix
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: isSelected
                            ? Default_Theme.primaryColor2
                            : Default_Theme.primaryColor2
                                .withValues(alpha: 0.7),
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (item.description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.description!,
                        style: Default_Theme.secondoryTextStyle.copyWith(
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: 0.40),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? Default_Theme.accentColor2
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Default_Theme.accentColor2
                        : Default_Theme.primaryColor2.withValues(alpha: 0.20),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
