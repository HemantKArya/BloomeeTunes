import 'dart:ui';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/utils/load_image.dart';
import 'package:flutter/material.dart';

/// Bloomee-branded dialog surface.
///
/// Uses the app's dark palette with a subtle frosted-glass look.
/// All app dialogs, alerts, confirmation sheets, and popups should use this
/// as their root surface so the UI feels cohesive.
///
/// ```dart
/// showBloomeeDialog(
///   context: context,
///   title: 'Delete track?',
///   subtitle: 'This cannot be undone.',
///   actions: [
///     BloomeeDialogAction.text('Cancel'),
///     BloomeeDialogAction.filled('Delete', isDestructive: true, onPressed: () {}),
///   ],
/// );
/// ```
class BloomeeDialogAction {
  final String label;
  final VoidCallback? onPressed;
  final bool isDestructive;
  final bool isFilled;

  const BloomeeDialogAction.text(
    this.label, {
    this.onPressed,
    this.isDestructive = false,
  }) : isFilled = false;

  const BloomeeDialogAction.filled(
    this.label, {
    this.onPressed,
    this.isDestructive = false,
  }) : isFilled = true;
}

/// Display the standard Bloomee dialog.
Future<T?> showBloomeeDialog<T>({
  required BuildContext context,
  required String title,
  String? subtitle,
  Widget? body,
  IconData? icon,
  List<BloomeeDialogAction>? actions,
  bool barrierDismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black54,
    builder: (_) => BloomeeDialogSurface(
      title: title,
      subtitle: subtitle,
      body: body,
      icon: icon,
      actions: actions,
    ),
  );
}

// ── Surface Colors ──────────────────────────────────────────────────────────

const _kDialogBg = Color(0xFF12101A);
const _kDialogSurface = Color(0xFF1A1626);
const _kDialogBorder = Color(0xFF2A2438);

/// The dialog surface widget. Can be used directly as a dialog builder return
/// value for dialogs that manage their own state (e.g., Smart Replace).
class BloomeeDialogSurface extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? body;
  final IconData? icon;
  final List<BloomeeDialogAction>? actions;

  const BloomeeDialogSurface({
    super.key,
    required this.title,
    this.subtitle,
    this.body,
    this.icon,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context).size;
    final maxW = mq.width > 560 ? 480.0 : mq.width * 0.9;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            constraints: BoxConstraints(maxWidth: maxW),
            decoration: BoxDecoration(
              color: _kDialogBg.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kDialogBorder, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _header(),
                if (body != null)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: body!,
                    ),
                  ),
                if (actions != null && actions!.isNotEmpty) _actionBar(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Default_Theme.accentColor2.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Default_Theme.accentColor2, size: 20),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Default_Theme.secondoryTextStyleMedium.merge(
                    const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 17,
                      height: 1.3,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color:
                          Default_Theme.primaryColor2.withValues(alpha: 0.62),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (int i = 0; i < actions!.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            _buildAction(context, actions![i]),
          ],
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context, BloomeeDialogAction action) {
    final color = action.isDestructive
        ? const Color(0xFFFF4D6A)
        : Default_Theme.accentColor2;

    if (action.isFilled) {
      return TextButton(
        onPressed: () {
          Navigator.of(context).pop();
          action.onPressed?.call();
        },
        style: TextButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.14),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        child: Text(action.label),
      );
    }

    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
        action.onPressed?.call();
      },
      style: TextButton.styleFrom(
        foregroundColor: Default_Theme.primaryColor2.withValues(alpha: 0.72),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      child: Text(action.label),
    );
  }
}

/// A Bloomee-styled list-tile for use inside dialog bodies.
///
/// Shows a leading thumbnail/icon, title, subtitle, and an optional trailing
/// widget. Used for candidate lists (Smart Replace, search picks, etc.).
class BloomeeDialogTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final IconData? leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;

  const BloomeeDialogTile({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.leadingIcon,
    this.trailing,
    this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: Default_Theme.accentColor2.withValues(alpha: 0.08),
        highlightColor: Default_Theme.accentColor2.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? Default_Theme.accentColor2.withValues(alpha: 0.08)
                : _kDialogSurface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? Default_Theme.accentColor2.withValues(alpha: 0.35)
                  : _kDialogBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              _leading(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Default_Theme.primaryColor1,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: 0.58),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _leading() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 44,
          height: 44,
          child: LoadImageCached(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Default_Theme.accentColor2.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        leadingIcon ?? Icons.music_note_rounded,
        color: Default_Theme.accentColor2.withValues(alpha: 0.7),
        size: 20,
      ),
    );
  }
}

/// A small pill badge (e.g., "Best match", "79%").
class BloomeeDialogBadge extends StatelessWidget {
  final String label;
  final Color? color;

  const BloomeeDialogBadge(this.label, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Default_Theme.accentColor2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
