import 'dart:io';

import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/services/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// Hosts the whole app under the custom desktop title bar.
///
/// It sits above every app state (onboarding, plugin setup, the main app,
/// startup errors), so the window can always be moved and closed. The bar
/// looks the same on Windows, Linux and macOS. Without a custom frame it
/// returns [child] unchanged.
class WindowFrame extends StatefulWidget {
  const WindowFrame({super.key, required this.child});

  final Widget child;

  static const captionHeight = 38.0;

  /// Active [ImmersiveCaption] requests, newest last. The newest one styles
  /// the caption.
  static final _immersive = <_ImmersiveRequest>[];
  static final _immersiveRevision = ValueNotifier<int>(0);
  static bool _notifyScheduled = false;

  /// Changes land after the current frame: the frame rebuilds the whole app
  /// and must not be marked dirty while a requesting subtree is building.
  static void _immersiveChanged() {
    if (_notifyScheduled) return;
    _notifyScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyScheduled = false;
      _immersiveRevision.value++;
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  State<WindowFrame> createState() => _WindowFrameState();
}

class _ImmersiveRequest {
  _ImmersiveRequest(this.scrim);
  double scrim;
}

/// Lets [child]'s screen draw behind the desktop title bar.
///
/// While [enabled] and on the current route, the caption turns transparent
/// and floats over the app. The app then gets the whole window, and the
/// caption height arrives as a top inset in [MediaQuery.paddingOf], so an
/// [AppBar] or a [SafeArea] keeps the screen's content where it was and only
/// backgrounds extend upwards. The window buttons stay legible over a soft
/// top [scrim] (0 = none, 1 = black at the top edge).
///
/// Enable it only for a screen that covers the whole window: everything
/// else in the app gets the same inset while it is active. Without a custom
/// frame (mobile, web, system title bar) it does nothing.
class ImmersiveCaption extends StatefulWidget {
  const ImmersiveCaption({
    super.key,
    this.enabled = true,
    this.scrim = 0.28,
    required this.child,
  });

  final bool enabled;
  final double scrim;
  final Widget child;

  @override
  State<ImmersiveCaption> createState() => _ImmersiveCaptionState();
}

class _ImmersiveCaptionState extends State<ImmersiveCaption> {
  _ImmersiveRequest? _request;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(ImmersiveCaption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_request != null && oldWidget.scrim != widget.scrim) {
      _request!.scrim = widget.scrim;
      WindowFrame._immersiveChanged();
    }
    _sync();
  }

  @override
  void dispose() {
    _release();
    super.dispose();
  }

  /// Covered by a pushed route, the screen gives the caption back.
  void _sync() {
    final wanted = DesktopWindow.isCustomFrame &&
        widget.enabled &&
        (ModalRoute.isCurrentOf(context) ?? true);
    if (wanted && _request == null) {
      _request = _ImmersiveRequest(widget.scrim);
      WindowFrame._immersive.add(_request!);
      WindowFrame._immersiveChanged();
    } else if (!wanted) {
      _release();
    }
  }

  void _release() {
    final request = _request;
    if (request == null) return;
    _request = null;
    WindowFrame._immersive.remove(request);
    WindowFrame._immersiveChanged();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _WindowFrameState extends State<WindowFrame> with WindowListener {
  late final OverlayEntry _entry = OverlayEntry(builder: _buildFrame);

  bool _focused = true;
  bool _maximized = false;
  bool _fullScreen = false;

  /// Bumped when the window is minimised, hidden or restored. The pointer
  /// leaves while the window is away without an exit event, so the buttons
  /// are rebuilt rather than staying highlighted when it comes back.
  int _hoverEpoch = 0;

  @override
  void initState() {
    super.initState();
    if (!DesktopWindow.isCustomFrame) return;
    windowManager.addListener(this);
    WindowFrame._immersiveRevision.addListener(_onImmersiveChanged);
    _syncState();
  }

  void _onImmersiveChanged() => _update(() {});

  @override
  void didUpdateWidget(WindowFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (DesktopWindow.isCustomFrame) _entry.markNeedsBuild();
  }

  @override
  void dispose() {
    if (DesktopWindow.isCustomFrame) {
      windowManager.removeListener(this);
      WindowFrame._immersiveRevision.removeListener(_onImmersiveChanged);
    }
    super.dispose();
  }

  void _update(VoidCallback change) {
    if (!mounted) return;
    change();
    _entry.markNeedsBuild();
  }

  /// Window commands are asynchronous and can also come from the system
  /// (snapping, shortcuts, the taskbar), so state is read back from the
  /// window instead of assumed.
  Future<void> _syncState() async {
    try {
      final state = await Future.wait([
        windowManager.isMaximized(),
        windowManager.isFullScreen(),
        windowManager.isFocused(),
      ]);
      _update(() {
        _maximized = state[0];
        _fullScreen = state[1];
        _focused = state[2];
      });
    } catch (_) {}
  }

  @override
  void onWindowEvent(String eventName) {
    switch (eventName) {
      case 'minimize':
      case 'restore':
      case 'hide':
      case 'show':
        _update(() => _hoverEpoch++);
        _syncState();
      case 'maximize':
      case 'unmaximize':
      case 'enter-full-screen':
      case 'leave-full-screen':
        _syncState();
    }
  }

  @override
  void onWindowFocus() => _update(() => _focused = true);

  @override
  void onWindowBlur() => _update(() => _focused = false);

  void _toggleMaximize() =>
      _maximized ? windowManager.unmaximize() : windowManager.maximize();

  @override
  Widget build(BuildContext context) {
    if (!DesktopWindow.isCustomFrame) return widget.child;
    // Own overlay so caption tooltips work above the app's MaterialApp.
    final frame = Directionality(
      textDirection: TextDirection.ltr,
      child: Overlay(initialEntries: [_entry]),
    );
    if (MediaQuery.maybeOf(context) != null) return frame;
    return MediaQuery.fromView(view: View.of(context), child: frame);
  }

  Widget _buildFrame(BuildContext context) {
    final media = MediaQuery.of(context);
    final captionHeight = _fullScreen ? 0.0 : WindowFrame.captionHeight;
    final immersive =
        captionHeight > 0 ? WindowFrame._immersive.lastOrNull : null;
    // Normally the app sees only the area below the caption. An immersive
    // screen gets the whole window and the caption as a top inset instead.
    // The widget path to the app never changes, so switching only lays it
    // out again.
    final offset = immersive == null ? captionHeight : 0.0;
    final inset = immersive == null ? 0.0 : captionHeight;
    final framed = ColoredBox(
      color: Default_Theme.themeColor,
      child: Stack(
        children: [
          Positioned.fill(
            top: offset,
            child: MediaQuery(
              data: media.copyWith(
                size: Size(
                  media.size.width,
                  (media.size.height - offset).clamp(0, double.infinity),
                ),
                padding: media.padding.copyWith(top: media.padding.top + inset),
                viewPadding: media.viewPadding
                    .copyWith(top: media.viewPadding.top + inset),
              ),
              child: widget.child,
            ),
          ),
          if (captionHeight > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: captionHeight,
              child: _caption(scrim: immersive?.scrim ?? 0),
            ),
        ],
      ),
    );

    if (!Platform.isLinux) return framed;
    // Linux windows without a header bar have no native resize border. The
    // wrapper stays in the tree in every state so the app is never remounted.
    return DragToResizeArea(
      resizeEdgeSize: 6,
      enableResizeEdges: _maximized || _fullScreen ? const [] : null,
      child: framed,
    );
  }

  Widget _caption({required double scrim}) {
    final row = Row(
      children: [
        Expanded(
          child: _CaptionDragArea(
            onDoubleTap: _toggleMaximize,
            onSecondaryTap:
                Platform.isWindows ? windowManager.popUpWindowMenu : null,
            child: _CaptionTitle(focused: _focused),
          ),
        ),
        _CaptionButtons(
          key: ValueKey(_hoverEpoch),
          focused: _focused,
          maximized: _maximized,
          onMinimize: windowManager.minimize,
          onToggleMaximize: _toggleMaximize,
          onClose: windowManager.close,
        ),
      ],
    );
    // Over an immersive screen, a soft shade keeps the title and buttons
    // readable on any artwork. It fades in and out with the mode.
    final caption = TweenAnimationBuilder<double>(
      tween: Tween(end: scrim.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (context, shade, child) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: shade == 0
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: shade),
                    Colors.black.withValues(alpha: shade * 0.45),
                    Colors.black.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.55, 1],
                ),
        ),
        child: child,
      ),
      child: row,
    );

    if (!Platform.isWindows) return caption;
    // Windows keeps native resize borders on the other three sides; the top
    // one is under the caption, so it is provided here.
    return DragToResizeArea(
      resizeEdgeSize: 4,
      enableResizeEdges: _maximized
          ? const []
          : const [ResizeEdge.topLeft, ResizeEdge.top, ResizeEdge.topRight],
      child: caption,
    );
  }
}

/// Empty caption space: drag to move, double-click to maximise or restore,
/// right-click for the system menu (Windows).
class _CaptionDragArea extends StatelessWidget {
  const _CaptionDragArea({
    required this.child,
    required this.onDoubleTap,
    this.onSecondaryTap,
  });

  final Widget child;
  final VoidCallback onDoubleTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanStart: (_) => windowManager.startDragging(),
      onDoubleTap: onDoubleTap,
      onSecondaryTap: onSecondaryTap,
      child: child,
    );
  }
}

class _CaptionTitle extends StatelessWidget {
  const _CaptionTitle({required this.focused});

  final bool focused;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Padding(
      // Centres the logo over the navigation rail's icons.
      padding: const EdgeInsets.only(left: 31),
      child: Row(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: focused ? 1 : 0.5,
            child: Image.asset(
              'assets/icons/BloomeeLogo4.png',
              width: 16,
              height: 16,
              cacheWidth: (16 * dpr).ceil() * 2,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, __, ___) =>
                  const SizedBox.square(dimension: 16),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Bloomee',
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                decoration: TextDecoration.none,
                color: Default_Theme.primaryColor2
                    .withValues(alpha: focused ? 0.75 : 0.38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptionButtons extends StatelessWidget {
  const _CaptionButtons({
    super.key,
    required this.focused,
    required this.maximized,
    required this.onMinimize,
    required this.onToggleMaximize,
    required this.onClose,
  });

  final bool focused;
  final bool maximized;
  final VoidCallback onMinimize;
  final VoidCallback onToggleMaximize;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = DesktopWindow.labels();
    return TooltipTheme(
      data: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 600),
        textStyle: const TextStyle(
          fontSize: 12,
          color: Default_Theme.primaryColor1,
          decoration: TextDecoration.none,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF2A202C),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CaptionButton(
              glyph: _Glyph.minimize,
              label: l10n.windowMinimize,
              focused: focused,
              onPressed: onMinimize,
            ),
            _CaptionButton(
              glyph: maximized ? _Glyph.restore : _Glyph.maximize,
              label: maximized ? l10n.windowRestore : l10n.windowMaximize,
              focused: focused,
              onPressed: onToggleMaximize,
            ),
            _CaptionButton(
              glyph: _Glyph.close,
              label: l10n.windowClose,
              focused: focused,
              destructive: true,
              onPressed: onClose,
            ),
          ],
        ),
      ),
    );
  }
}

/// A round caption button. The hit area is wider than the circle, so the
/// buttons are easy to hit and leave no gaps that would drag the window.
class _CaptionButton extends StatefulWidget {
  const _CaptionButton({
    required this.glyph,
    required this.label,
    required this.focused,
    required this.onPressed,
    this.destructive = false,
  });

  final _Glyph glyph;
  final String label;
  final bool focused;
  final bool destructive;
  final VoidCallback onPressed;

  @override
  State<_CaptionButton> createState() => _CaptionButtonState();
}

class _CaptionButtonState extends State<_CaptionButton> {
  bool _hovered = false;
  bool _pressed = false;

  void _setHovered(bool value) {
    if (_hovered != value) setState(() => _hovered = value);
  }

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.focused || _hovered;
    final danger = widget.destructive && (_hovered || _pressed);

    final Color fill;
    if (danger) {
      fill = _pressed
          ? Color.lerp(Default_Theme.accentColor2, Colors.black, 0.18)!
          : Default_Theme.accentColor2;
    } else {
      final alpha = _pressed ? 0.2 : (_hovered ? 0.13 : (active ? 0.07 : 0.04));
      fill = Colors.white.withValues(alpha: alpha);
    }

    final glyphColor = danger
        ? Colors.white
        : Default_Theme.primaryColor2.withValues(alpha: active ? 0.88 : 0.4);

    return Semantics(
      button: true,
      label: widget.label,
      child: Tooltip(
        message: widget.label,
        excludeFromSemantics: true,
        child: MouseRegion(
          onEnter: (_) => _setHovered(true),
          onExit: (_) {
            _setHovered(false);
            _setPressed(false);
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => _setPressed(true),
            onTapCancel: () => _setPressed(false),
            onTapUp: (_) => _setPressed(false),
            // Fires on release inside the button, like native captions.
            onTap: widget.onPressed,
            child: SizedBox(
              width: 34,
              height: double.infinity,
              child: Center(
                child: AnimatedContainer(
                  duration: Duration(milliseconds: _hovered ? 90 : 160),
                  curve: Curves.easeOut,
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: fill, shape: BoxShape.circle),
                  child: CustomPaint(
                    size: const Size.square(8),
                    painter:
                        _GlyphPainter(glyph: widget.glyph, color: glyphColor),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _Glyph { minimize, maximize, restore, close }

/// Caption glyphs in an 8×8 box with a 1.4px rounded stroke.
class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({required this.glyph, required this.color});

  final _Glyph glyph;
  final Color color;

  static const _stroke = 1.4;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    const h = _stroke / 2;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    switch (glyph) {
      case _Glyph.minimize:
        canvas.drawLine(Offset(h, s / 2), Offset(s - h, s / 2), paint);
      case _Glyph.maximize:
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTRB(h, h, s - h, s - h), const Radius.circular(1.6)),
          paint,
        );
      case _Glyph.restore:
        final inset = s * 0.25;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTRB(h, inset + h, s - inset - h, s - h),
              const Radius.circular(1.2)),
          paint,
        );
        canvas.drawPath(
          Path()
            ..moveTo(inset + h, inset + h)
            ..lineTo(inset + h, h)
            ..lineTo(s - h, h)
            ..lineTo(s - h, s - inset - h)
            ..lineTo(s - inset - h, s - inset - h),
          paint,
        );
      case _Glyph.close:
        canvas.drawLine(const Offset(h, h), Offset(s - h, s - h), paint);
        canvas.drawLine(Offset(s - h, h), Offset(h, s - h), paint);
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter old) =>
      old.glyph != glyph || old.color != color;
}
