import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/dload.dart';
import 'package:Bloomee/utils/imgurl_formator.dart';
import 'package:Bloomee/utils/load_Image.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';

class DownloadingCardWidget extends StatelessWidget {
  final DownloadProgress downloadProgress;
  final VoidCallback? onCancelTap;

  const DownloadingCardWidget({
    Key? key,
    required this.downloadProgress,
    this.onCancelTap,
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
            _buildActionButtons(status),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverArt(BuildContext context, MediaItemModel song,
      DownloadStatus status, double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 55,
            height: 55,
            child: LoadImageCached(
              imageUrl: formatImgURL(
                song.artUri.toString(),
                ImageQuality.low,
              ),
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

  Widget _buildSongInfo(
      MediaItemModel song, DownloadStatus status, double progress) {
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
            status.message ?? song.artist ?? "Unknown Artist",
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

  Widget _buildActionButtons(DownloadStatus status) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _getStatusText(status.state),
          const SizedBox(height: 4),
          Text(
            '${(status.progress * 100).toStringAsFixed(0)}%',
            style: Default_Theme.secondoryTextStyle.copyWith(
              fontSize: 12,
              color: Default_Theme.primaryColor1.withValues(alpha: 0.8),
            ),
          ),
        ],
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
      case DownloadState.fetchingMetadata:
        return const Text(
          "Fetching Metadata",
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        );
      case DownloadState.downloading:
        return const Text(
          "Downloading",
          style: TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        );
      default:
        return const SizedBox.shrink();
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
      default:
        return const SizedBox.shrink(key: ValueKey('default'));
    }
  }
}
