import 'dart:async';
import 'dart:developer';

import 'package:Bloomee/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/services/scrobble/lastfm_api.dart';
import 'package:Bloomee/core/constants/cache_keys.dart';
import 'package:Bloomee/services/scrobble/scrobble_status.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:icons_plus/icons_plus.dart';

class LastDotFM extends StatefulWidget {
  const LastDotFM({super.key});

  @override
  State<LastDotFM> createState() => _LastDotFMState();
}

class _LastDotFMState extends State<LastDotFM> {
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController apiSecretController = TextEditingController();
  bool authBtnClicked = false;
  String? username;
  bool getBtnVisible = false;
  String? token;

  @override
  void initState() {
    apiKeyController.text = "API Key";
    apiSecretController.text = "Api Secret";
    getKeysFromDB();
    super.initState();
  }

  void authBtnClick() {
    setState(() => authBtnClicked = true);
    Future.delayed(
        const Duration(seconds: 3), () => setState(() => getBtnVisible = true));
    Future.delayed(const Duration(seconds: 7),
        () => setState(() => authBtnClicked = false));
  }

  Future<void> getKeysFromDB() async {
    log("Getting Last.FM Keys from DB", name: "Last.FM");
    final lastdotfmCubit = context.read<LastdotfmCubit>();
    username = await lastdotfmCubit.getApiToken(CacheKeys.lFMUsername);
    final apiKey = await lastdotfmCubit.getApiToken(CacheKeys.lFMApiKey);
    final apiSecret = await lastdotfmCubit.getApiToken(CacheKeys.lFMSecret);
    if (apiKey != null) apiKeyController.text = apiKey;
    if (apiSecret != null) apiSecretController.text = apiSecret;
    log("Last.FM Keys from DB: $apiKey, $apiSecret", name: "Last.FM");
    setState(() {});
  }

  @override
  void dispose() {
    apiKeyController.dispose();
    apiSecretController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: Center(
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Default_Theme.primaryColor1,
                size: 24,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: Text(
          l10n.lastfmTitle,
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (prev, curr) => prev.lastFMScrobble != curr.lastFMScrobble,
        builder: (context, settingsState) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: settingsPagePadding(context),
            children: [
              // Scrobbling
              SettingSectionHeader(label: l10n.settingsScrobbling),
              SettingCard(
                children: [
                  SettingToggleTile(
                    icon: FontAwesome.lastfm_brand,
                    title: l10n.lastfmScrobbleTracks,
                    subtitle: l10n.lastfmScrobbleTracksSubtitle,
                    value: settingsState.lastFMScrobble,
                    onChanged: (value) {
                      final settings = context.read<SettingsCubit>();
                      settings.setLastFMScrobble(value);
                      if (value && LastFmAPI.initialized == false) {
                        SnackbarService.showMessage(l10n.lastfmAuthFirst);
                        Future.delayed(const Duration(milliseconds: 500), () {
                          settings.setLastFMScrobble(false);
                        });
                      }
                    },
                  ),
                ],
              ),

              // Live scrobble status (only when signed in)
              BlocBuilder<LastdotfmCubit, LastdotfmState>(
                buildWhen: (p, c) =>
                    (p is LastdotfmIntialized) != (c is LastdotfmIntialized),
                builder: (context, st) {
                  if (st is! LastdotfmIntialized) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SettingSectionHeader(label: l10n.lastfmStatusSection),
                        _ScrobbleStatusCard(
                          enabled: settingsState.lastFMScrobble,
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // Authentication
              SettingSectionHeader(label: l10n.settingsAuthentication),
              BlocBuilder<LastdotfmCubit, LastdotfmState>(
                builder: (context, lfmState) {
                  return SettingCard(
                    children: [
                      // Status indicator
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: lfmState is LastdotfmIntialized
                                    ? Default_Theme.successColor
                                    : Colors.red.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                lfmState is LastdotfmIntialized
                                    ? '${l10n.lastfmAuthenticatedAs}${lfmState.username}'
                                    : lfmState is LastdotfmFailed
                                        ? '${l10n.lastfmAuthFailed} ${lfmState.message}'
                                        : l10n.lastfmNotAuthenticated,
                                style: TextStyle(
                                  color: lfmState is LastdotfmIntialized
                                      ? Default_Theme.successColor
                                      : lfmState is LastdotfmFailed
                                          ? Colors.red.withValues(alpha: 0.8)
                                          : Default_Theme.primaryColor2
                                              .withValues(alpha: 0.5),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ).merge(Default_Theme.secondoryTextStyle),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SettingDivider(),
                      // How-to instructions
                      SettingInfoText(text: l10n.lastfmSteps),
                      const SettingDivider(),
                      SettingTextFieldTile(
                        label: l10n.lastfmApiKey,
                        controller: apiKeyController,
                      ),
                      const SettingDivider(),
                      SettingTextFieldTile(
                        label: l10n.lastfmApiSecret,
                        controller: apiSecretController,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                      const SettingDivider(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _AuthButton(
                              label: l10n.lastfmStartAuth,
                              enabled: lfmState is! LastdotfmIntialized &&
                                  !authBtnClicked,
                              onPressed: () async {
                                authBtnClick();
                                token = await context
                                    .read<LastdotfmCubit>()
                                    .startAuth(
                                      apiKey: apiKeyController.text,
                                      secret: apiSecretController.text,
                                    );
                              },
                            ),
                            _AuthButton(
                              label: l10n.lastfmGetSession,
                              enabled: lfmState is! LastdotfmIntialized &&
                                  getBtnVisible,
                              onPressed: () {
                                if (token != null) {
                                  context
                                      .read<LastdotfmCubit>()
                                      .fetchSessionkey(
                                        apiKey: apiKeyController.text,
                                        secret: apiSecretController.text,
                                        token: token!,
                                      );
                                } else {
                                  SnackbarService.showMessage(
                                      l10n.lastfmStartAuthFirst);
                                }
                              },
                            ),
                            if (lfmState is LastdotfmIntialized)
                              _AuthButton(
                                label: l10n.lastfmRemoveKeys,
                                enabled: true,
                                destructive: true,
                                onPressed: () {
                                  context.read<LastdotfmCubit>().remove();
                                  context
                                      .read<SettingsCubit>()
                                      .setLastFMScrobble(false);
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          );
        },
      ),
    );
  }
}

// --- Scrobble status ---------------------------------------------------------

class _ScrobbleStatusCard extends StatefulWidget {
  final bool enabled;
  const _ScrobbleStatusCard({required this.enabled});

  @override
  State<_ScrobbleStatusCard> createState() => _ScrobbleStatusCardState();
}

class _ScrobbleStatusCardState extends State<_ScrobbleStatusCard> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Keeps the relative time fresh without rebuilding the whole screen.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  String _ago(AppLocalizations l10n, DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return l10n.lastfmJustNow;
    if (d.inHours < 1) return l10n.lastfmMinutesAgo(d.inMinutes);
    if (d.inDays < 1) return l10n.lastfmHoursAgo(d.inHours);
    return l10n.lastfmDaysAgo(d.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<LastdotfmCubit>();
    final muted = Default_Theme.primaryColor2.withValues(alpha: 0.5);

    return ValueListenableBuilder<ScrobbleStatus>(
      valueListenable: cubit.scrobbleStatus,
      builder: (context, s, _) {
        Color tone = Default_Theme.primaryColor2;
        final String title;
        if (!widget.enabled) {
          tone = muted;
          title = l10n.lastfmStatusOff;
        } else if (s.phase == ScrobblePhase.authPaused) {
          tone = Colors.redAccent;
          title = l10n.lastfmStatusAuthPaused;
        } else if (s.phase == ScrobblePhase.retrying) {
          tone = Colors.amber;
          title = l10n.lastfmStatusRetrying;
        } else if (s.phase == ScrobblePhase.sending) {
          title = l10n.lastfmStatusSending;
        } else if (s.pending > 0) {
          title = l10n.lastfmStatusQueued(s.pending);
        } else {
          title = l10n.lastfmStatusSynced;
        }

        final String? detail = switch (s.issue) {
          ScrobbleIssue.network => l10n.lastfmErrorNetwork,
          ScrobbleIssue.auth => l10n.lastfmErrorAuth,
          ScrobbleIssue.rejected => l10n.lastfmErrorRejected(s.rejectedCount),
          null => s.lastTrack,
        };
        final sentAt = s.lastSuccessAt;
        final showActions = s.pending > 0 || s.phase == ScrobblePhase.retrying;

        return SettingCard(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style:
                              Default_Theme.secondoryTextStyleMedium.copyWith(
                            color: tone,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (sentAt != null)
                        Text(
                          '${l10n.lastfmStatLastSent} · ${_ago(l10n, sentAt)}',
                          style: Default_Theme.secondoryTextStyle.copyWith(
                            color: muted.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 6),
                    Padding(
                      padding: EdgeInsets.zero,
                      child: Text(
                        detail,
                        maxLines: s.issue == null ? 1 : 3,
                        overflow: TextOverflow.ellipsis,
                        style: Default_Theme.secondoryTextStyle.copyWith(
                          color: muted,
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showActions) ...[
              const SettingDivider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Row(
                  children: [
                    _TextAction(
                      label: l10n.lastfmSyncNow,
                      color: Default_Theme.accentColor2,
                      onTap: cubit.syncNow,
                    ),
                    _TextAction(
                      label: l10n.lastfmClearQueue,
                      color: muted,
                      onTap: () async {
                        await cubit.clearScrobbleQueue();
                        SnackbarService.showMessage(l10n.lastfmQueueCleared);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TextAction extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _TextAction(
      {required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

// --- Auth Button -------------------------------------------------------------

class _AuthButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool destructive;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = destructive ? Colors.red : Default_Theme.accentColor2;

    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: activeColor,
        disabledBackgroundColor: activeColor.withValues(alpha: 0.3),
        foregroundColor: Default_Theme.primaryColor2,
        disabledForegroundColor:
            Default_Theme.primaryColor2.withValues(alpha: 0.4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
