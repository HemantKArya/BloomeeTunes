import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';

void createPlaylistDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: l10n.createPlaylistDialogBarrierLabel,
    barrierColor: Colors.black.withValues(alpha: 0.85),
    transitionDuration: const Duration(milliseconds: 250), // Slightly faster
    pageBuilder: (context, animation, secondaryAnimation) {
      return const _CreatePlaylistDialog();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);

      // FIX FOR WOBBLING: Using SlideTransition instead of ScaleTransition.
      // This prevents the text engine from re-rasterizing and causing the "heatwave" effect.
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05), // Starts slightly lower and slides up
          end: Offset.zero,
        ).animate(curve),
        child: FadeTransition(
          opacity: curve,
          // RepaintBoundary caches the dialog as an image during animation,
          // guaranteeing 0 jitter or wobbling.
          child: RepaintBoundary(child: child),
        ),
      );
    },
  );
}

class _CreatePlaylistDialog extends StatefulWidget {
  const _CreatePlaylistDialog({Key? key}) : super(key: key);

  @override
  State<_CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<_CreatePlaylistDialog> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();

    _controller.addListener(() {
      setState(() {});
    });

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _isInputValid => _controller.text.trim().length > 2;

  void _submit() {
    if (_isInputValid) {
      context.read<LibraryItemsCubit>().createPlaylist(_controller.text.trim());
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: bottomInset > 0 ? bottomInset / 2.5 : 0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Container(
            decoration: BoxDecoration(
              color: Default_Theme.themeColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Top Accent Line ---
                  Container(
                    height: 6,
                    width: double.infinity,
                    color: Default_Theme.accentColor2,
                  ),

                  // --- Main Content ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 28, 32, 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          l10n.playlistCreateNew,
                          style: Default_Theme.secondoryTextStyleMedium.merge(
                            const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Default_Theme.accentColor2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Input Field
                        TextField(
                          controller: _controller,
                          focusNode: _focusNode,
                          textInputAction: TextInputAction.done,
                          maxLines: 1,
                          maxLength: 35,
                          cursorColor: Default_Theme.accentColor2,
                          cursorWidth: 3,
                          cursorRadius: const Radius.circular(3),
                          style: Default_Theme.secondoryTextStyleMedium.merge(
                            TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: Default_Theme.primaryColor2.withValues(
                                  alpha: 0.9), // Typed text in clear white
                            ),
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: l10n.createPlaylistDialogNameHint,
                            hintStyle:
                                Default_Theme.secondoryTextStyleMedium.merge(
                              TextStyle(
                                fontSize: 32,
                                color: Default_Theme.primaryColor2.withValues(
                                    alpha: 0.2), // Greyed out hint text
                              ),
                            ),
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            border: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          ),
                          onSubmitted: (_) => _submit(),
                        ),

                        // Animated Underline
                        const SizedBox(height: 8),
                        Stack(
                          children: [
                            Container(
                              height: 1.5,
                              width: double.infinity,
                              color: Default_Theme.accentColor2
                                  .withValues(alpha: 0.1),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              height: 1.5,
                              width: _isInputValid
                                  ? MediaQuery.of(context).size.width
                                  : 30,
                              decoration: const BoxDecoration(
                                color: Default_Theme.accentColor2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),

                        // --- Action Buttons ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // FIXED Cancel Button (Greyed-out white, more weight)
                            InkWell(
                              onTap: () => context.pop(),
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                child: Text(
                                  l10n.buttonCancel,
                                  style: Default_Theme.secondoryTextStyleMedium
                                      .merge(
                                    TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight
                                          .w600, // Added more weight so it isn't blurry
                                      color: Default_Theme.primaryColor2
                                          .withValues(
                                              alpha: 0.6), // Greyed-out white
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Outlined Create Button
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _isInputValid ? 1.0 : 0.4,
                              child: InkWell(
                                onTap: _isInputValid ? _submit : null,
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Default_Theme.accentColor2
                                        .withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: Default_Theme.accentColor2,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Text(
                                    l10n.createPlaylistDialogCreate,
                                    style: Default_Theme
                                        .secondoryTextStyleMedium
                                        .merge(
                                      const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Default_Theme.accentColor2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
