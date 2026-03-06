// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/custom_switch.dart';
import 'package:Bloomee/screens/screen/player_views/equalizer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class PlayerSettings extends StatelessWidget {
  const PlayerSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Default_Theme.primaryColor1,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          'Audio Player',
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // ─── Streaming Quality ─────────────────────────────────────
              const _SectionHeader(label: 'Streaming'),
              _SettingCard(
                children: [
                  _QualityChipRow(
                    title: 'Streaming Quality',
                    subtitle: 'Global audio bitrate for online playback.',
                    options: const ['Low', 'Medium', 'High'],
                    selected: state.strmQuality,
                    onSelected: (v) =>
                        context.read<SettingsCubit>().setStrmQuality(v),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ─── Playback ──────────────────────────────────────────────
              const _SectionHeader(label: 'Playback'),
              _SettingCard(
                children: [
                  _ToggleTile(
                    icon: MingCute.music_2_line,
                    title: 'Auto Play',
                    subtitle: 'Enqueue similar songs when the queue ends.',
                    value: state.autoPlay,
                    onChanged: (v) =>
                        context.read<SettingsCubit>().setAutoPlay(v),
                  ),
                  const _Divider(),
                  _CrossfadeSlider(
                    value: state.crossfadeDuration,
                    onChanged: (v) {
                      context.read<SettingsCubit>().setCrossfadeDuration(v);
                      context
                          .read<BloomeePlayerCubit>()
                          .bloomeePlayer
                          .setCrossfadeDuration(Duration(seconds: v));
                    },
                  ),
                  const _Divider(),
                  _NavTile(
                    icon: Icons.equalizer_rounded,
                    title: 'Equalizer',
                    subtitle: state.eqEnabled
                        ? 'Enabled — ${state.eqPreset} preset'
                        : '10-band parametric EQ via FFmpeg.',
                    badge: state.eqEnabled ? 'Active' : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EqualizerView()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ).merge(Default_Theme.secondoryTextStyleMedium),
      ),
    );
  }
}

// ─── Card Container ──────────────────────────────────────────────────────────

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

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
        children: children,
      ),
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: Default_Theme.primaryColor2.withValues(alpha: 0.05),
      );
}

// ─── Setting Icon ────────────────────────────────────────────────────────────

class _SettingIcon extends StatelessWidget {
  final IconData icon;
  const _SettingIcon({required this.icon});

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
          color: Default_Theme.primaryColor2.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

// ─── Generic Quality Chip Row ────────────────────────────────────────────────

class _QualityChipRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _QualityChipRow({
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SettingIcon(icon: MingCute.cellphone_vibration_line),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Default_Theme.primaryColor2,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ).merge(Default_Theme.secondoryTextStyleMedium),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ).merge(Default_Theme.secondoryTextStyle),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Custom Chip Wrap
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: options.map((opt) {
              return _CustomQualityChip(
                label: opt,
                isSelected: opt == selected,
                onTap: () => onSelected(opt),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── CUSTOM QUALITY CHIP (Removes blue flash) ────────────────────────────────
// This widget replaces ChoiceChip to ensure exact color control
class _CustomQualityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomQualityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        // Explicitly set splash color to theme (Red/Pink) instead of default Blue
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
            style: TextStyle(
              color: isSelected
                  ? Default_Theme.accentColor2
                  : Default_Theme.primaryColor2.withValues(alpha: 0.7),
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ).merge(Default_Theme.secondoryTextStyleMedium),
          ),
        ),
      ),
    );
  }
}

// ─── Toggle Tile ─────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          _SettingIcon(icon: icon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Default_Theme.primaryColor2,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ).merge(Default_Theme.secondoryTextStyleMedium),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ).merge(Default_Theme.secondoryTextStyle),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          BloomeeSwitch(
            value: value,
            onChanged: () => onChanged(!value),
          ),
        ],
      ),
    );
  }
}

// ─── Nav Tile ────────────────────────────────────────────────────────────────

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        highlightColor: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        splashColor: Default_Theme.primaryColor2.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              _SettingIcon(icon: icon),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Default_Theme.primaryColor2,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ).merge(Default_Theme.secondoryTextStyleMedium),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ).merge(Default_Theme.secondoryTextStyle),
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
                    style: const TextStyle(
                      color: Default_Theme.accentColor2,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ).merge(Default_Theme.secondoryTextStyle),
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

// ─── Crossfade Slider ────────────────────────────────────────────────────────

class _CrossfadeSlider extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _CrossfadeSlider({required this.value, required this.onChanged});

  @override
  State<_CrossfadeSlider> createState() => _CrossfadeSliderState();
}

class _CrossfadeSliderState extends State<_CrossfadeSlider> {
  late double _localValue;

  @override
  void initState() {
    super.initState();
    _localValue = widget.value.toDouble();
  }

  @override
  void didUpdateWidget(_CrossfadeSlider old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _localValue = widget.value.toDouble();
    }
  }

  String get _description {
    if (_localValue == 0) return 'Tracks switch instantly';
    return '${_localValue.toInt()}s blend between tracks';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SettingIcon(icon: Icons.graphic_eq_rounded),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crossfade',
                      style: const TextStyle(
                        color: Default_Theme.primaryColor2,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ).merge(Default_Theme.secondoryTextStyleMedium),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _description,
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor2.withValues(alpha: 0.5),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ).merge(Default_Theme.secondoryTextStyle),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _localValue == 0
                    ? Text(
                        'Off',
                        key: const ValueKey('off'),
                        style: TextStyle(
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: 0.4),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ).merge(Default_Theme.secondoryTextStyleMedium),
                      )
                    : Text(
                        '${_localValue.toInt()}s',
                        key: ValueKey(_localValue.toInt()),
                        style: const TextStyle(
                          color: Default_Theme.accentColor2,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ).merge(Default_Theme.secondoryTextStyleMedium),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              activeTrackColor: Default_Theme.accentColor2,
              inactiveTrackColor:
                  Default_Theme.primaryColor2.withValues(alpha: 0.1),
              thumbColor: Default_Theme.accentColor2,
              overlayColor: Default_Theme.accentColor2.withValues(alpha: 0.15),
              tickMarkShape:
                  const RoundSliderTickMarkShape(tickMarkRadius: 2.5),
              activeTickMarkColor:
                  Default_Theme.themeColor.withValues(alpha: 0.5),
              inactiveTickMarkColor:
                  Default_Theme.primaryColor2.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: 0,
              max: 12,
              divisions: 6,
              value: _localValue,
              onChanged: (v) => setState(() => _localValue = v),
              onChangeEnd: (v) => widget.onChanged(v.toInt()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [0, 2, 4, 6, 8, 10, 12].map((v) {
                final active = _localValue.toInt() == v;
                return Text(
                  v == 0 ? 'Off' : '${v}s',
                  style: TextStyle(
                    color: active
                        ? Default_Theme.accentColor2
                        : Default_Theme.primaryColor2.withValues(alpha: 0.3),
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ).merge(Default_Theme.secondoryTextStyle),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
