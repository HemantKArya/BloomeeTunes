import 'dart:async';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class VolumeDragController extends StatefulWidget {
  final Widget child;
  const VolumeDragController({super.key, required this.child});

  @override
  _VolumeDragControllerState createState() => _VolumeDragControllerState();
}

class _VolumeDragControllerState extends State<VolumeDragController> {
  double _volume = 0.5; // Initial volume
  bool _showVolumeController = false;
  Timer? _timer;
  StreamSubscription? _volumeSubscription;

  @override
  void initState() {
    volumeStrm();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _volumeSubscription?.cancel();
    super.dispose();
  }

  void volumeStrm() {
    _volumeSubscription = context
        .read<BloomeePlayerCubit>()
        .bloomeePlayer
        .audioPlayer
        .volumeStream
        .listen((event) {
      setState(() {
        _volume = event;
      });
    });
  }

  void setVolume(double volume) {
    setState(() {
      _volume = volume;
    });
    context
        .read<BloomeePlayerCubit>()
        .bloomeePlayer
        .audioPlayer
        .setVolume(volume);
  }

  void _onDragStart(DragStartDetails details) {
    setState(() {
      _showVolumeController = true;
    });
    _startTimer();
  }

  void _onDragEnd(DragEndDetails details) {
    _startTimer(); // Restart the timer on drag end
  }

  void _updateVolume(DragUpdateDetails details) {
    setState(() {
      _volume = (_volume - details.delta.dy / 200).clamp(0.0, 1.0);
    });
    setVolume(_volume);
    _startTimer(); // Restart the timer on volume change
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _showVolumeController = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          setState(() {
            _showVolumeController = true;
            _volume = (_volume - (event.scrollDelta.dy / 500)).clamp(0.0, 1.0);
          });
          _startTimer();
          setVolume(_volume);
        }
      },
      child: GestureDetector(
        onVerticalDragStart: _onDragStart,
        onVerticalDragUpdate: _updateVolume,
        onVerticalDragEnd: _onDragEnd,
        child: LayoutBuilder(builder: (context, constraints) {
          return Stack(
            children: <Widget>[
              widget.child,
              Positioned(
                right: 20.0,
                bottom: 0,
                top: 0,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedOpacity(
                    opacity: _showVolumeController ? 1.0 : 0.0,
                    // opacity: 1,
                    duration: const Duration(milliseconds: 300),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              (_volume == 0)
                                  ? MingCute.volume_off_fill
                                  : MingCute.volume_fill,
                              color: Default_Theme.primaryColor2,
                            ),
                            RotatedBox(
                              quarterTurns: -1,
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  inactiveTrackColor: Default_Theme
                                      .primaryColor2
                                      .withValues(alpha: 0.3),
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6.0),
                                  overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16.0),
                                  trackShape:
                                      const RoundedRectSliderTrackShape(),
                                  trackHeight: 10.0,
                                ),
                                child: Slider(
                                  value: _volume,
                                  onChanged: (value) {
                                    // update local UI, audio player and keep the
                                    // volume controller visible while interacting
                                    setVolume(value);
                                    _startTimer();
                                  },
                                  onChangeEnd: (value) {
                                    // ensure hide timer restarts when user lifts finger
                                    _startTimer();
                                  },
                                  min: 0.0,
                                  max: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
