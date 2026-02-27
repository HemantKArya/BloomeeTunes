import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/services/player/player_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A list of EQ presets mapping preset-name → 10-band gain values (dB).
const Map<String, List<double>> _kPresets = {
  'Flat': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  'Bass Boost': [6, 5, 4, 2, 0, 0, 0, 0, 0, 0],
  'Treble Boost': [0, 0, 0, 0, 0, 0, 2, 4, 5, 6],
  'Pop': [-1, 2, 4, 4, 2, 0, -1, -1, 2, 3],
  'Rock': [4, 3, 1, 0, -1, -1, 0, 2, 3, 4],
  'Jazz': [3, 2, 0, 1, -1, -1, 0, 1, 2, 3],
  'Classical': [4, 3, 1, 1, 0, 0, 0, 1, 2, 4],
  'Hip Hop': [4, 3, 0, -1, 1, 0, 1, 0, 2, 3],
  'Electronic': [4, 3, 1, 0, -1, 1, 0, 1, 3, 4],
  'Vocal': [-2, -1, 0, 2, 4, 4, 3, 1, 0, -1],
};

class EqualizerView extends StatefulWidget {
  const EqualizerView({super.key});

  @override
  State<EqualizerView> createState() => _EqualizerViewState();
}

class _EqualizerViewState extends State<EqualizerView>
    with SingleTickerProviderStateMixin {
  late PlayerEngine _engine;
  late SettingsCubit _settingsCubit;
  late List<double> _gains; // local copy to avoid rebuilds per-frame
  String _selectedPreset = 'Flat';
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  static const double _minGain = -12;
  static const double _maxGain = 12;

  @override
  void initState() {
    super.initState();
    _engine = context.read<BloomeePlayerCubit>().bloomeePlayer.engine;
    _settingsCubit = context.read<SettingsCubit>();
    _gains = _engine.equalizerBands.map((b) => b.gain).toList(growable: false);
    _selectedPreset = _settingsCubit.state.eqPreset;
    // If persisted preset doesn't match current gains, detect it
    if (_selectedPreset != _matchingPreset()) {
      _selectedPreset = _matchingPreset();
    }

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    // Persist final gains on exit
    _settingsCubit.setEqBandGains(List<double>.from(_gains));
    _settingsCubit.setEqPreset(_selectedPreset);
    _animCtrl.dispose();
    super.dispose();
  }

  // ─── helpers ──────────────────────────────────────────────────────────────

  void _onBandChanged(int index, double value) {
    setState(() => _gains[index] = value);
    _engine.setEqualizerBandGain(index, value);
    _selectedPreset = _matchingPreset();
  }

  void _applyPreset(String name) {
    final values = _kPresets[name];
    if (values == null) return;
    setState(() {
      _selectedPreset = name;
      for (var i = 0; i < _gains.length && i < values.length; i++) {
        _gains[i] = values[i];
        _engine.setEqualizerBandGain(i, values[i]);
      }
    });
    _settingsCubit.setEqBandGains(List<double>.from(_gains));
    _settingsCubit.setEqPreset(name);
  }

  void _resetEQ() {
    _engine.resetEqualizer();
    setState(() {
      for (var i = 0; i < _gains.length; i++) {
        _gains[i] = 0;
      }
      _selectedPreset = 'Flat';
    });
    _settingsCubit.setEqBandGains(List<double>.from(_gains));
    _settingsCubit.setEqPreset('Flat');
  }

  /// Try to match the current gains to a known preset.
  String _matchingPreset() {
    for (final entry in _kPresets.entries) {
      bool match = true;
      for (var i = 0; i < _gains.length && i < entry.value.length; i++) {
        if ((_gains[i] - entry.value[i]).abs() > 0.5) {
          match = false;
          break;
        }
      }
      if (match) return entry.key;
    }
    return 'Custom';
  }

  String _freqLabel(double hz) {
    if (hz >= 1000) return '${(hz / 1000).toStringAsFixed(0)}k';
    return hz.toStringAsFixed(0);
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bands = _engine.equalizerBands;
    final isEnabled = _engine.equalizerEnabled;

    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Default_Theme.primaryColor1, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Equalizer',
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ).merge(Default_Theme.secondoryTextStyle),
        ),
        actions: [
          // Reset button
          IconButton(
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh_rounded,
                color: Default_Theme.primaryColor2, size: 22),
            onPressed: _resetEQ,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeIn,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // ─── Enable/Disable toggle ─────────────────────────────
              const SizedBox(height: 8),
              _buildEnableRow(isEnabled),

              const SizedBox(height: 20),

              // ─── Preset chips ──────────────────────────────────────
              _buildPresetRow(),

              const SizedBox(height: 24),

              // ─── dB scale labels (left) + Sliders ──────────────────
              Expanded(
                child: AnimatedOpacity(
                  opacity: isEnabled ? 1.0 : 0.35,
                  duration: const Duration(milliseconds: 250),
                  child: IgnorePointer(
                    ignoring: !isEnabled,
                    child: _buildBandSliders(bands),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─── sub-widgets ──────────────────────────────────────────────────────────

  Widget _buildEnableRow(bool isEnabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Default_Theme.primaryColor2.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Equalizer',
            style: const TextStyle(
              color: Default_Theme.primaryColor1,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ).merge(Default_Theme.secondoryTextStyleMedium),
          ),
          Switch.adaptive(
            value: isEnabled,
            onChanged: (val) {
              _engine.setEqualizerEnabled(val);
              _settingsCubit.setEqEnabled(val);
              setState(() {});
            },
            activeColor: Default_Theme.accentColor2,
            inactiveThumbColor:
                Default_Theme.primaryColor2.withValues(alpha: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetRow() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kPresets.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final name = _kPresets.keys.elementAt(index);
          final isActive = name == _selectedPreset;
          return ChoiceChip(
            label: Text(name),
            selected: isActive,
            onSelected: (_) => _applyPreset(name),
            selectedColor: Default_Theme.accentColor2.withValues(alpha: 0.85),
            backgroundColor:
                Default_Theme.primaryColor2.withValues(alpha: 0.08),
            labelStyle: TextStyle(
              color: isActive
                  ? Colors.white
                  : Default_Theme.primaryColor2.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isActive
                    ? Default_Theme.accentColor2
                    : Default_Theme.primaryColor2.withValues(alpha: 0.15),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Widget _buildBandSliders(List<EqualizerBand> bands) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          // dB scale
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _dbLabel('+${_maxGain.toInt()}dB'),
              _dbLabel('0dB'),
              _dbLabel('${_minGain.toInt()}dB'),
            ],
          ),
          const SizedBox(height: 4),
          // Sliders row
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(bands.length, (i) {
                return Expanded(
                  child: _BandSlider(
                    gain: _gains[i],
                    minGain: _minGain,
                    maxGain: _maxGain,
                    freqLabel: _freqLabel(bands[i].centerFrequency),
                    onChanged: (v) => _onBandChanged(i, v),
                  ),
                );
              }),
            ),
          ),
        ],
      );
    });
  }

  Widget _dbLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Default_Theme.primaryColor2.withValues(alpha: 0.45),
        fontSize: 10,
      ),
    );
  }
}

// ─── Individual band slider (vertical) ──────────────────────────────────────

class _BandSlider extends StatelessWidget {
  final double gain;
  final double minGain;
  final double maxGain;
  final String freqLabel;
  final ValueChanged<double> onChanged;

  const _BandSlider({
    required this.gain,
    required this.minGain,
    required this.maxGain,
    required this.freqLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Gain value
        Text(
          '${gain >= 0 ? '+' : ''}${gain.toStringAsFixed(1)}',
          style: TextStyle(
            color: _gainColor(gain),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        // Vertical slider
        Expanded(
          child: RotatedBox(
            quarterTurns: -1,
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Default_Theme.accentColor2,
                inactiveTrackColor:
                    Default_Theme.primaryColor2.withValues(alpha: 0.15),
                thumbColor: Default_Theme.accentColor2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                trackHeight: 3,
                overlayColor:
                    Default_Theme.accentColor2.withValues(alpha: 0.15),
              ),
              child: Slider(
                value: gain,
                min: minGain,
                max: maxGain,
                onChanged: onChanged,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Frequency label
        Text(
          freqLabel,
          style: TextStyle(
            color: Default_Theme.primaryColor2.withValues(alpha: 0.55),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  Color _gainColor(double g) {
    if (g.abs() < 0.5) {
      return Default_Theme.primaryColor2.withValues(alpha: 0.5);
    }
    // Blend from primaryColor1 toward accentColor2 based on magnitude
    final t = (g.abs() / 12).clamp(0.0, 1.0);
    return Color.lerp(
        Default_Theme.primaryColor1, Default_Theme.accentColor2, t)!;
  }
}
