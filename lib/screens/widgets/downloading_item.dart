import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/core/models/exported.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/download_types.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

class DownloadingCardWidget extends StatelessWidget {
  final DownloadProgress downloadProgress;

  const DownloadingCardWidget({
    Key? key,
    required this.downloadProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final song = downloadProgress.task.song;
    final status = downloadProgress.status;
    final progress = status.progress;

    return SizedBox(
      height: 70,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          children: [
            _buildCoverArt(context, song, status, progress),
            const SizedBox(width: 10),
            _buildSongInfo(song, status, progress),
            _buildActionButtons(context, downloadProgress),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverArt(BuildContext context, Track song, DownloadStatus status,
      double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 55,
            height: 55,
            child: LoadImageCached(
              imageUrl: song.thumbnail.urlLow ?? song.thumbnail.url,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            value: progress,
            backgroundColor: Default_Theme.primaryColor2.withValues(alpha: 0.2),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Default_Theme.accentColor2),
            strokeWidth: 5,
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: _getStatusIcon(status.state),
        ),
      ],
    );
  }

  Widget _buildSongInfo(Track song, DownloadStatus status, double progress) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            song.title,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Default_Theme.tertiaryTextStyle.merge(
              const TextStyle(
                fontWeight: FontWeight.w600,
                color: Default_Theme.primaryColor1,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status.message ?? song.artists.map((a) => a.name).join(', '),
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            style: Default_Theme.tertiaryTextStyle.merge(
              TextStyle(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, DownloadProgress downloadProgress) {
    final status = downloadProgress.status;
    final cubit = context.read<DownloaderCubit>();

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _getStatusText(status.state),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(status.progress * 100).toStringAsFixed(0)}%',
                style: Default_Theme.secondoryTextStyle.copyWith(
                  fontSize: 12,
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 6),
              ..._buildControls(cubit, downloadProgress),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildControls(
    DownloaderCubit cubit,
    DownloadProgress downloadProgress,
  ) {
    final taskId = downloadProgress.task.taskId;
    final state = downloadProgress.status.state;
    if (taskId.isEmpty) {
      return const [];
    }

    switch (state) {
      case DownloadState.downloading:
      case DownloadState.resolving:
      case DownloadState.fetchingMetadata:
      case DownloadState.retrying:
        return [
          _buildIconButton(
            icon: Icons.pause_circle_outline,
            onTap: () => cubit.pauseDownload(taskId),
          ),
          _buildIconButton(
            icon: Icons.close,
            onTap: () => cubit.cancelDownload(taskId),
          ),
        ];
      case DownloadState.queued:
        return [
          _buildIconButton(
            icon: Icons.close,
            onTap: () => cubit.cancelDownload(taskId),
          ),
        ];
      case DownloadState.paused:
      case DownloadState.failed:
        return [
          _buildIconButton(
            icon: Icons.play_circle_outline,
            onTap: () => cubit.resumeDownload(taskId),
          ),
          _buildIconButton(
            icon: Icons.close,
            onTap: () => cubit.cancelDownload(taskId),
          ),
        ];
      case DownloadState.cancelled:
      case DownloadState.completed:
        return const [];
    }
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        splashRadius: 16,
        iconSize: 18,
        color: Default_Theme.primaryColor1,
        onPressed: onTap,
        icon: Icon(icon),
      ),
    );
  }

  Widget _getStatusText(DownloadState state) {
    switch (state) {
      case DownloadState.completed:
        return const Text(
          "Completed",
          style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold),
        );
      case DownloadState.failed:
        return const Text(
          "Failed",
          style: TextStyle(
              color: Colors.redAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold),
        );
      case DownloadState.queued:
        return const Text(
          "Queued",
          style: TextStyle(
              color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
        );
      case DownloadState.resolving:
        return const Text(
          "Resolving",
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        );
      case DownloadState.fetchingMetadata:
        return const Text(
          "Tagging",
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        );
      case DownloadState.downloading:
        return const Text(
          "Downloading",
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        );
      case DownloadState.paused:
        return const Text(
          "Paused",
          style: TextStyle(
              color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
        );
      case DownloadState.retrying:
        return const Text(
          "Retrying",
          style: TextStyle(
              color: Colors.orangeAccent,
              fontSize: 12,
              fontWeight: FontWeight.bold),
        );
      case DownloadState.cancelled:
        return const Text(
          "Cancelled",
          style: TextStyle(
              color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        );
    }
  }

  Widget _getStatusIcon(DownloadState state) {
    switch (state) {
      case DownloadState.completed:
        return const Icon(
          Icons.check_circle,
          color: Colors.greenAccent,
          key: ValueKey('completed'),
        );
      case DownloadState.failed:
        return const Icon(
          Icons.error,
          color: Colors.redAccent,
          key: ValueKey('failed'),
        );
      case DownloadState.queued:
        return const Icon(
          MingCute.sandglass_line,
          color: Colors.white,
          size: 20,
          key: ValueKey('queued'),
        );
      case DownloadState.resolving:
        return const Icon(
          Icons.link,
          color: Colors.white,
          size: 20,
          key: ValueKey('resolving'),
        );
      case DownloadState.fetchingMetadata:
        return const Icon(
          Icons.info_outline,
          color: Colors.white,
          size: 20,
          key: ValueKey('fetchingMetadata'),
        );
      case DownloadState.downloading:
        return const Icon(
          Icons.arrow_downward,
          color: Colors.white,
          size: 20,
          key: ValueKey('downloading'),
        );
      case DownloadState.paused:
        return const Icon(
          Icons.pause_circle_outline,
          color: Colors.amber,
          size: 20,
          key: ValueKey('paused'),
        );
      case DownloadState.retrying:
        return const Icon(
          Icons.refresh,
          color: Colors.orangeAccent,
          size: 20,
          key: ValueKey('retrying'),
        );
      case DownloadState.cancelled:
        return const Icon(
          Icons.close,
          color: Colors.grey,
          size: 20,
          key: ValueKey('cancelled'),
        );
    }
  }
}
