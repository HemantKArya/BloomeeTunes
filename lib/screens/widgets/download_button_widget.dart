import 'dart:async';
import 'package:Bloomee/blocs/downloader/cubit/downloader_cubit.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

enum DownloadState { notDownloaded, downloading, downloaded, failed }

class DownloadButtonWidget extends StatefulWidget {
  final MediaItemModel song;
  final double size;
  final Color? color;
  final bool showLabel;

  const DownloadButtonWidget({
    super.key,
    required this.song,
    this.size = 28.0,
    this.color,
    this.showLabel = false,
  });

  @override
  State<DownloadButtonWidget> createState() => _DownloadButtonWidgetState();
}

class _DownloadButtonWidgetState extends State<DownloadButtonWidget>
    with TickerProviderStateMixin {
  DownloadState _downloadState = DownloadState.notDownloaded;
  double _progress = 0.0;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkDownloadStatus();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    _progressTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkDownloadStatus() async {
    print("🔽 DEBUG: Checking download status for: ${widget.song.title}");
    final downloadDB = await BloomeeDBService.getDownloadDB(widget.song);
    if (mounted) {
      setState(() {
        _downloadState = downloadDB != null
            ? DownloadState.downloaded
            : DownloadState.notDownloaded;
      });
      print("🔽 DEBUG: Download status: $_downloadState");
    }
  }

  void _startDownload() {
    print("🔽 DEBUG: Starting download for: ${widget.song.title}");
    setState(() {
      _downloadState = DownloadState.downloading;
      _progress = 0.0;
    });

    // Start pulse animation for downloading state
    _pulseController.repeat(reverse: true);
    context.read<DownloaderCubit>().downloadSong(widget.song);
  }

  Widget _buildDownloadIcon() {
    switch (_downloadState) {
      case DownloadState.notDownloaded:
        return Icon(
          MingCute.download_2_line,
          size: widget.size,
          color: widget.color ?? Default_Theme.primaryColor1,
        );

      case DownloadState.downloading:
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: widget.size,
              height: widget.size,
              child: CircularProgressIndicator(
                value: _progress,
                strokeWidth: 3.0,
                backgroundColor: (widget.color ?? Default_Theme.primaryColor1)
                    .withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.color ?? Default_Theme.primaryColor1,
                ),
              ),
            ),
            // Show only percentage text, no icon
            Text(
              '${(_progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: widget.size * 0.35,
                fontWeight: FontWeight.bold,
                color: widget.color ?? Default_Theme.primaryColor1,
                fontFamily: "Unageo",
              ),
            ),
          ],
        );

      case DownloadState.downloaded:
        return Icon(
          MingCute.check_circle_fill,
          size: widget.size,
          color: Colors.green,
        );

      case DownloadState.failed:
        return Icon(
          MingCute.close_circle_fill,
          size: widget.size,
          color: Colors.red,
        );
    }
  }

  String _getLabel() {
    switch (_downloadState) {
      case DownloadState.notDownloaded:
        return 'Download';
      case DownloadState.downloading:
        return 'Downloading... ${(_progress * 100).toInt()}%';
      case DownloadState.downloaded:
        return 'Downloaded';
      case DownloadState.failed:
        return 'Failed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DownloaderCubit, DownloaderState>(
      listener: (context, state) {
        if (state is DownloadProgress && state.songId == widget.song.id) {
          if (mounted) {
            setState(() {
              _downloadState = DownloadState.downloading;
              _progress = state.progress / 100.0;
            });
          }
        } else if (state is DownloadCompleted &&
            state.songId == widget.song.id) {
          if (mounted) {
            setState(() {
              _downloadState = state.success
                  ? DownloadState.downloaded
                  : DownloadState.failed;
              _progress = state.success ? 1.0 : 0.0;
            });
            _rotationController.stop();
            _rotationController.reset();
            _pulseController.stop();
            _pulseController.reset();
            _progressTimer?.cancel();
          }
        }
      },
      child: GestureDetector(
        onTapDown: (_) => _scaleController.forward(),
        onTapUp: (_) => _scaleController.reverse(),
        onTapCancel: () => _scaleController.reverse(),
        onTap: _downloadState == DownloadState.notDownloaded
            ? _startDownload
            : null,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: widget.showLabel
                ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                : const EdgeInsets.all(8),
            decoration: widget.showLabel
                ? BoxDecoration(
                    color: (widget.color ?? Default_Theme.primaryColor1)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (widget.color ?? Default_Theme.primaryColor1)
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.color ?? Default_Theme.primaryColor1)
                            .withValues(alpha: 0.2),
                        blurRadius:
                            _downloadState == DownloadState.downloading ? 8 : 4,
                        spreadRadius:
                            _downloadState == DownloadState.downloading ? 1 : 0,
                      ),
                    ],
                  )
                : BoxDecoration(
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.color ?? Default_Theme.primaryColor1)
                            .withValues(alpha: 0.3),
                        blurRadius:
                            _downloadState == DownloadState.downloading ? 8 : 4,
                        spreadRadius:
                            _downloadState == DownloadState.downloading ? 1 : 0,
                      ),
                    ],
                  ),
            child: widget.showLabel
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _downloadState == DownloadState.downloading
                          ? ScaleTransition(
                              scale: _pulseAnimation,
                              child: _buildDownloadIcon(),
                            )
                          : _buildDownloadIcon(),
                      const SizedBox(width: 8),
                      Text(
                        _getLabel(),
                        style: TextStyle(
                          color: widget.color ?? Default_Theme.primaryColor1,
                          fontFamily: "Unageo",
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : _downloadState == DownloadState.downloading
                    ? ScaleTransition(
                        scale: _pulseAnimation,
                        child: _buildDownloadIcon(),
                      )
                    : _buildDownloadIcon(),
          ),
        ),
      ),
    );
  }
}
