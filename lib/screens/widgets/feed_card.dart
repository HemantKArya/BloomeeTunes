import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/services/feed/feed_item.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Icon, colour and label for each kind of entry.
class FeedStyle {
  final IconData icon;
  final Color color;
  final String label;
  const FeedStyle(this.icon, this.color, this.label);

  static const _notice = Color(0xFFFFB547);

  factory FeedStyle.of(FeedKind kind, AppLocalizations l10n) => switch (kind) {
        FeedKind.announcement => FeedStyle(MingCute.news_fill,
            Default_Theme.accentColor1, l10n.feedKindAnnouncement),
        FeedKind.app => FeedStyle(
            MingCute.rocket_fill, Default_Theme.accentColor2, l10n.feedKindApp),
        FeedKind.form => FeedStyle(MingCute.edit_4_fill,
            Default_Theme.accentColor1light, l10n.feedKindForm),
        FeedKind.notice =>
          FeedStyle(MingCute.warning_fill, _notice, l10n.feedKindNotice),
      };

  factory FeedStyle.update(AppLocalizations l10n) => FeedStyle(
      MingCute.download_3_fill,
      Default_Theme.accentColor1,
      l10n.feedKindUpdate);
}

/// Opens an entry's link outside the app and counts the entry as seen.
Future<void> openFeedAction(BuildContext context, FeedItem item) async {
  final cubit = context.read<NotificationCubit>();
  final url = cubit.actionUrl(item);
  if (url == null) return;
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  if (cubit.state.homeCard?.id == item.id) await cubit.closeHomeCard(item);
}

/// One entry in the inbox.
class FeedCard extends StatelessWidget {
  final FeedStyle style;
  final String title;
  final String? body;
  final String? image;
  final String? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// The action opens a page outside the app (browser, store).
  final bool external;
  final VoidCallback? onDismiss;
  final bool isNew;
  final bool urgent;
  final bool draft;

  const FeedCard({
    super.key,
    required this.style,
    required this.title,
    this.body,
    this.image,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.external = true,
    this.onDismiss,
    this.isNew = false,
    this.urgent = false,
    this.draft = false,
  });

  factory FeedCard.item(BuildContext context, FeedItem item,
      {bool isNew = false}) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final cubit = context.read<NotificationCubit>();
    final hasLink = cubit.actionUrl(item) != null;
    return FeedCard(
      key: ValueKey(item.id),
      style: FeedStyle.of(item.kind, l10n),
      title: item.title.resolve(locale),
      body: item.body?.resolve(locale),
      image: item.image,
      icon: item.icon,
      actionLabel:
          hasLink ? item.actionLabel?.resolve(locale) ?? l10n.feedOpen : null,
      onAction: hasLink ? () => openFeedAction(context, item) : null,
      onDismiss: () => cubit.dismiss(item),
      isNew: isNew,
      urgent: item.urgent,
      draft: item.draft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accent = style.color;
    return Container(
      decoration: BoxDecoration(
        color: urgent
            ? accent.withValues(alpha: 0.08)
            : Default_Theme.primaryColor1.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: urgent
              ? accent.withValues(alpha: 0.35)
              : Default_Theme.primaryColor1.withValues(alpha: 0.07),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FeedIcon(style: style, size: 26, url: icon),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style.label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Default_Theme.secondoryTextStyleMedium.copyWith(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    if (isNew) _Tag(l10n.feedNew, Default_Theme.accentColor2),
                    if (draft)
                      _Tag(l10n.feedDraft, Default_Theme.primaryColor2),
                  ],
                ),
              ),
              if (onDismiss != null)
                _SmallIconButton(
                  icon: MingCute.close_line,
                  tooltip: l10n.feedDismiss,
                  onTap: onDismiss!,
                )
              else
                const SizedBox(height: 32),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  title,
                  style: Default_Theme.secondoryTextStyleMedium.copyWith(
                    color: Default_Theme.primaryColor1,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                if (body != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    body!,
                    style: Default_Theme.secondoryTextStyle.copyWith(
                      color: Default_Theme.primaryColor2.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
                if (image != null) ...[
                  const SizedBox(height: 12),
                  _FeedImage(url: image!),
                ],
                if (actionLabel != null && onAction != null) ...[
                  const SizedBox(height: 12),
                  FeedActionButton(
                    label: actionLabel!,
                    color: accent,
                    external: external,
                    onTap: onAction!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The single, compact announcement card on Home.
class HomeFeedCard extends StatelessWidget {
  const HomeFeedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      buildWhen: (a, b) => a.homeCard != b.homeCard,
      builder: (context, state) {
        final item = state.homeCard;
        // Closing a card hands over to the next queued one in place.
        return AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, if (current != null) current],
            ),
            child: item == null
                ? const SizedBox(key: ValueKey(null), width: double.infinity)
                : Padding(
                    key: ValueKey(item.id),
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                    child: _HomeCardBody(item: item),
                  ),
          ),
        );
      },
    );
  }
}

class _HomeCardBody extends StatelessWidget {
  final FeedItem item;
  const _HomeCardBody({required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final cubit = context.read<NotificationCubit>();
    final style = FeedStyle.of(item.kind, l10n);
    final hasLink = cubit.actionUrl(item) != null;
    final body = item.body?.resolve(locale);

    return Container(
      key: ValueKey('home-${item.id}'),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          style.color.withValues(alpha: 0.14),
          Default_Theme.primaryColor1.withValues(alpha: 0.035),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: style.color.withValues(alpha: 0.22)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.image != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 10),
              child: _FeedImage(url: item.image!, aspect: 3),
            ),
          ],
          Row(
            children: [
              FeedIcon(style: style, size: 36, url: item.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.title.resolve(locale),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Default_Theme.secondoryTextStyleMedium.copyWith(
                        color: Default_Theme.primaryColor1,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (body != null)
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Default_Theme.secondoryTextStyle.copyWith(
                          color: Default_Theme.primaryColor2
                              .withValues(alpha: 0.65),
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                  ],
                ),
              ),
              if (hasLink) ...[
                const SizedBox(width: 8),
                FeedActionButton(
                  label: item.actionLabel?.resolve(locale) ?? l10n.feedOpen,
                  color: style.color,
                  onTap: () => openFeedAction(context, item),
                ),
              ],
              _SmallIconButton(
                icon: MingCute.close_line,
                tooltip: l10n.feedDismiss,
                onTap: () => cubit.closeHomeCard(item),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The kind icon, or the entry's own logo when it has one. A logo that
/// cannot load leaves the kind icon in place.
class FeedIcon extends StatelessWidget {
  final FeedStyle style;
  final double size;
  final String? url;
  const FeedIcon(
      {super.key, required this.style, required this.size, this.url});

  Widget _kind() => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: style.color.withValues(alpha: 0.16),
          shape: BoxShape.circle,
        ),
        child: Icon(style.icon, color: style.color, size: size * 0.55),
      );

  @override
  Widget build(BuildContext context) {
    final logo = url;
    if (logo == null) return _kind();
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.24),
      child: CachedNetworkImage(
        imageUrl: logo,
        width: size,
        height: size,
        fit: BoxFit.cover,
        memCacheWidth: (size * 3).round(),
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, __) => _kind(),
        errorWidget: (_, __, ___) => _kind(),
      ),
    );
  }
}

class FeedActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool external;
  final VoidCallback onTap;
  const FeedActionButton({
    super.key,
    required this.label,
    required this.color,
    required this.onTap,
    this.external = true,
  });

  @override
  Widget build(BuildContext context) => Material(
        color: color.withValues(alpha: 0.16),
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 7, 12, 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Default_Theme.secondoryTextStyleMedium.copyWith(
                      color: color,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  external
                      ? MingCute.arrow_right_up_line
                      : MingCute.arrow_right_line,
                  color: color,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      );
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: Default_Theme.secondoryTextStyleMedium.copyWith(
            color: color,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
}

class _SmallIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _SmallIconButton(
      {required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        padding: EdgeInsets.zero,
        iconSize: 16,
        color: Default_Theme.primaryColor2.withValues(alpha: 0.5),
        icon: Icon(icon),
      );
}

class _FeedImage extends StatelessWidget {
  final String url;
  final double aspect;
  const _FeedImage({required this.url, this.aspect = 2});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: url,
          fadeInDuration: const Duration(milliseconds: 180),
          memCacheWidth: 1000,
          imageBuilder: (_, image) => AspectRatio(
            aspectRatio: aspect,
            child: Image(image: image, fit: BoxFit.cover),
          ),
          placeholder: (_, __) => AspectRatio(
            aspectRatio: aspect,
            child: ColoredBox(
                color: Default_Theme.primaryColor1.withValues(alpha: 0.05)),
          ),
          // A broken image simply leaves the card without one.
          errorWidget: (_, __, ___) => const SizedBox.shrink(),
        ),
      );
}
