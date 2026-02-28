import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/screen/player_views/equalizer_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class PlayerSettings extends StatelessWidget {
  const PlayerSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Audio Player',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // ─── Streaming Quality ─────────────────────────────────────
              _SectionHeader(label: 'Streaming'),
              _SettingCard(
                children: [
                  _QualityChipRow(
                    title: 'Jiosaavn Quality',
                    subtitle: 'Audio bitrate for online streams.',
                    options: const ['96 kbps', '160 kbps', '320 kbps'],
                    selected: state.strmQuality,
                    onSelected: (v) =>
                        context.read<SettingsCubit>().setStrmQuality(v),
                  ),
                  _Divider(),
                  _QualityChipRow(
                    title: 'YouTube Quality',
                    subtitle: 'Audio quality for YouTube streams.',
                    options: const ['Low', 'High'],
                    selected: state.ytStrmQuality,
                    onSelected: (v) =>
                        context.read<SettingsCubit>().setYtStrmQuality(v),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Playback ──────────────────────────────────────────────
              _SectionHeader(label: 'Playback'),
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
                  _Divider(),
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
                  _Divider(),
                  _NavTile(
                    icon: Icons.equalizer_rounded,
                    title: 'Equalizer',
                    subtitle: state.eqEnabled
                        ? 'Enabled — ${state.eqPreset} preset'
                        : '10-band parametric EQ via FFmpeg.',
                    badge: state.eqEnabled ? 'ON' : null,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EqualizerView()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
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
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Default_Theme.accentColor1,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ).merge(Default_Theme.secondoryTextStyle),
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
        color: Default_Theme.primaryColor1.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Default_Theme.primaryColor1.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ─── Thin Divider ────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Divider(
        height: 1,
        indent: 16,
        endIndent: 16,
        color: Default_Theme.primaryColor1.withValues(alpha: 0.08),
      );
}

// ─── Quality Chip Row ─────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Default_Theme.primaryColor1,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ).merge(Default_Theme.secondoryTextStyle),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
              fontSize: 12,
            ).merge(Default_Theme.secondoryTextStyle),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: options.map((opt) {
              final isSelected = opt == selected;
              return ChoiceChip(
                label: Text(opt),
                selected: isSelected,
                onSelected: (_) => onSelected(opt),
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.black
                      : Default_Theme.primaryColor1.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ).merge(Default_Theme.secondoryTextStyle),
                selectedColor: Default_Theme.accentColor1,
                backgroundColor:
                    Default_Theme.primaryColor1.withValues(alpha: 0.08),
                side: BorderSide(
                  color: isSelected
                      ? Default_Theme.accentColor1
                      : Default_Theme.primaryColor1.withValues(alpha: 0.12),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                showCheckmark: false,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle Tile ───────────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon,
              size: 22,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.7)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Default_Theme.primaryColor1,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ).merge(Default_Theme.secondoryTextStyle),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                    fontSize: 12,
                  ).merge(Default_Theme.secondoryTextStyle),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Default_Theme.accentColor1,
          ),
        ],
      ),
    );
  }
}

// ─── Nav Tile (with optional status badge) ────────────────────────────────────

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
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon,
                size: 22,
                color: Default_Theme.primaryColor1.withValues(alpha: 0.7)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ).merge(Default_Theme.secondoryTextStyle),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Default_Theme.primaryColor1.withValues(alpha: 0.5),
                      fontSize: 12,
                    ).merge(Default_Theme.secondoryTextStyle),
                  ),
                ],
              ),
            ),
            if (badge != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Default_Theme.accentColor1.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Default_Theme.accentColor1.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: Default_Theme.accentColor1,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ).merge(Default_Theme.secondoryTextStyle),
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(Icons.chevron_right_rounded,
                color: Default_Theme.primaryColor2.withValues(alpha: 0.6),
                size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Crossfade Slider ─────────────────────────────────────────────────────────

class _CrossfadeSlider extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _CrossfadeSlider({required this.value, required this.onChanged});

  @override
  State<_CrossfadeSlider> createState() => _CrossfadeSliderState();
}

class _CrossfadeSliderState extends State<_CrossfadeSlider> {
  // Local state allows smooth dragging before committing to the cubit.
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.graphic_eq_rounded,
                  size: 22,
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.7)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crossfade',
                      style: const TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ).merge(Default_Theme.secondoryTextStyle),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _description,
                      style: TextStyle(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.5),
                        fontSize: 12,
                      ).merge(Default_Theme.secondoryTextStyle),
                    ),
                  ],
                ),
              ),
              // Animated live-value pill
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: _localValue == 0
                    ? Text(
                        'Off',
                        key: const ValueKey('off'),
                        style: TextStyle(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.35),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ).merge(Default_Theme.secondoryTextStyle),
                      )
                    : Text(
                        '${_localValue.toInt()}s',
                        key: ValueKey(_localValue.toInt()),
                        style: TextStyle(
                          color: Default_Theme.accentColor1,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ).merge(Default_Theme.secondoryTextStyle),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Default_Theme.accentColor1,
              inactiveTrackColor:
                  Default_Theme.primaryColor1.withValues(alpha: 0.12),
              thumbColor: Default_Theme.accentColor1,
              overlayColor: Default_Theme.accentColor1.withValues(alpha: 0.15),
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2),
              activeTickMarkColor:
                  Default_Theme.accentColor1.withValues(alpha: 0.5),
              inactiveTickMarkColor:
                  Default_Theme.primaryColor1.withValues(alpha: 0.2),
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
          // Step labels in sync with tick marks
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
                        ? Default_Theme.accentColor1
                        : Default_Theme.primaryColor1.withValues(alpha: 0.28),
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w400,
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
