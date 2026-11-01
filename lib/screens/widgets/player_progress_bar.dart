import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/blocs/media_player/bloomee_player_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'gradient_progress_bar.dart';
import 'player_view_activity.dart';

class PlayerProgressBar extends StatelessWidget {
  const PlayerProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<BloomeePlayerCubit>();
    return RepaintBoundary(
      child: StreamBuilder<ProgressBarStreams>(
        stream: PlayerViewActivity.isActive(context)
            ? playerCubit.progressStreams
            : null,
        builder: (context, snapshot) {
          final data = snapshot.data;
          return GradientProgressBar.fromAccentColors(
            progress: data?.position ?? Duration.zero,
            total: data?.duration ?? Duration.zero,
            buffered: data?.buffered ?? Duration.zero,
            onSeek: playerCubit.bloomeePlayer.seek,
            isPlaying: data?.isPlaying ?? false,
            activeAccentColor: Default_Theme.accentColor1,
            inactiveAccentColor: Default_Theme.accentColor2,
            activeGradientStyle: GradientStyle.lightAndBreezy,
            inactiveGradientStyle: GradientStyle.warmAndRich,
            trackHeight: 6.0,
            thumbRadius: 8.0,
            timeLabelPadding: 5,
            timeLabelStyle: Default_Theme.secondoryTextStyle.merge(TextStyle(
              fontSize: 15,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.7),
            )),
            timeLabelLocation: TimeLabelLocation.above,
            inactiveTrackColor:
                Default_Theme.primaryColor2.withValues(alpha: 0.1),
            animationDuration: const Duration(milliseconds: 200),
            animationCurve: Curves.easeOutCubic,
          );
        },
      ),
    );
  }
}
