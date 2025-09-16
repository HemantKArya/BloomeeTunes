// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:Bloomee/theme_data/default.dart';
import 'package:icons_plus/icons_plus.dart';

class PlayPauseButton extends StatefulWidget {
  final double size;
  final VoidCallback? onPlay;
  final VoidCallback? onPause;
  final bool isPlaying;
  const PlayPauseButton({
    Key? key,
    this.size = 60,
    this.onPlay,
    this.onPause,
    this.isPlaying = false,
  }) : super(key: key);
  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  late bool _isPlaying;
  late Color _currentColor;
  void _togglePlayPause() {
    setState(() {
      _isPlaying ? widget.onPause!() : widget.onPlay!();
      _isPlaying = !_isPlaying;
      _currentColor =
          _isPlaying ? Default_Theme.accentColor1 : Default_Theme.accentColor2;
    });
  }

  @override
  Widget build(BuildContext context) {
    double size = widget.size;
    _isPlaying = widget.isPlaying;
    _currentColor =
        _isPlaying ? Default_Theme.accentColor1 : Default_Theme.accentColor2;
    return GestureDetector(
      onTap: _togglePlayPause,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(color: _currentColor, spreadRadius: 1, blurRadius: 20)
            ],
            shape: BoxShape.circle,
            color: _currentColor,
          ),
          width: size,
          height: size,
          child: _isPlaying
              ? Icon(
                  FontAwesome.pause_solid,
                  size: widget.size * 0.5,
                  color: Default_Theme.primaryColor1,
                )
              : Icon(
                  MingCute.play_fill,
                  size: widget.size * 0.5,
                  color: Default_Theme.primaryColor1,
                ),
        ),
      ),
    );
  }
}
