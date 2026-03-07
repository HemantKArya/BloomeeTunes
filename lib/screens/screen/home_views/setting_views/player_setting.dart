// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
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
              const SettingSectionHeader(label: 'Streaming'),
              SettingCard(
                children: [
                  SettingQualityChipRow(
                    icon: MingCute.cellphone_vibration_line,
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
              const SettingSectionHeader(label: 'Playback'),
              SettingCard(
                children: [
                  SettingToggleTile(
                    icon: MingCute.music_2_line,
                    title: 'Auto Play',
                    subtitle: 'Enqueue similar songs when the queue ends.',
                    value: state.autoPlay,
                    onChanged: (v) =>
                        context.read<SettingsCubit>().setAutoPlay(v),
                  ),
                  const SettingDivider(),
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
                  const SettingDivider(),
                  SettingNavTile(
                    icon: Icons.equalizer_rounded,
                    title: 'Equalizer',
                    subtitle: state.eqEnabled
                        ? 'Enabled — ${state.eqPreset} preset'
                        : '10-band parametric EQ via FFmpeg.',
                    badge: state.eqEnabled ? 'Active' : null,
                    roundBottom: true,
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
              const SettingIconBox(icon: Icons.graphic_eq_rounded),
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
