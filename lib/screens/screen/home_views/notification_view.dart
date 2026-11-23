import 'package:Bloomee/blocs/notification/notification_cubit.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/check_update_view.dart';
import 'package:Bloomee/screens/widgets/feed_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';

/// The inbox: an available update, then news, new apps, sign-ups and
/// notices from `feed.json`. Opening it marks everything as seen; entries
/// stay until the user dismisses them or they expire.
class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  /// What was new when the inbox opened; it keeps its "New" tag this visit.
  late final Set<String> _newOnOpen;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<NotificationCubit>();
    _newOnOpen = {...cubit.state.newIds};
    cubit.markAllSeen();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<NotificationCubit>();
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.notificationsTitle,
          style: Default_Theme.secondoryTextStyleMedium.copyWith(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          if (cubit.canPreview)
            BlocSelector<NotificationCubit, NotificationState, bool>(
              selector: (s) => s.preview,
              builder: (context, preview) => IconButton(
                tooltip: l10n.feedPreview,
                isSelected: preview,
                onPressed: () => cubit.setPreview(!preview),
                icon: Icon(
                  MingCute.eye_2_fill,
                  color: preview
                      ? Default_Theme.accentColor2
                      : Default_Theme.primaryColor2.withValues(alpha: 0.5),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          final cards = <Widget>[
            if (state.update case final version?)
              FeedCard(
                key: const ValueKey(NotificationState.updateKey),
                style: FeedStyle.update(l10n),
                title: l10n.feedUpdateTitle(version),
                body: l10n.feedUpdateBody,
                actionLabel: l10n.feedUpdateAction,
                external: false,
                onAction: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckUpdateView()),
                ),
                isNew: _newOnOpen.contains(NotificationState.updateKey),
              ),
            for (final item in state.items)
              FeedCard.item(context, item,
                  isNew: _newOnOpen.contains(item.id)),
          ];
          return RefreshIndicator(
            color: Default_Theme.accentColor2,
            backgroundColor: Default_Theme.themeColor,
            onRefresh: () => cubit.refresh(force: true),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: cards.isEmpty
                    ? const _EmptyInbox()
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                        itemCount: cards.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => cards[i],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Scrollable, so pull-to-refresh works on an empty inbox too.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Default_Theme.primaryColor1.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(MingCute.notification_line,
                    size: 28,
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.feedEmpty,
                style: Default_Theme.secondoryTextStyleMedium.copyWith(
                  color: Default_Theme.primaryColor1,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  l10n.feedEmptySubtitle,
                  textAlign: TextAlign.center,
                  style: Default_Theme.secondoryTextStyle.copyWith(
                    color: Default_Theme.primaryColor2.withValues(alpha: 0.55),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
