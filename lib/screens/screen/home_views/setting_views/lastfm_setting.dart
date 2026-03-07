import 'dart:developer';

import 'package:Bloomee/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/repository/lastfm/lastfmapi.dart';
import 'package:Bloomee/core/constants/cache_keys.dart';
import 'package:Bloomee/screens/screen/home_views/setting_views/setting_shared_widgets.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          'Last.FM',
          style: const TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ).merge(Default_Theme.secondoryTextStyleMedium),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settingsState) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              // Scrobbling
              const SettingSectionHeader(label: 'Scrobbling'),
              SettingCard(
                children: [
                  SettingToggleTile(
                    icon: FontAwesome.lastfm_brand,
                    title: 'Scrobble Tracks',
                    subtitle: 'Send played tracks to your Last.FM profile.',
                    value: settingsState.lastFMScrobble,
                    onChanged: (value) {
                      context.read<SettingsCubit>().setLastFMScrobble(value);
                      if (value && LastFmAPI.initialized == false) {
                        SnackbarService.showMessage(
                            "First Authenticate Last.FM API.");
                        Future.delayed(const Duration(milliseconds: 500), () {
                          context
                              .read<SettingsCubit>()
                              .setLastFMScrobble(false);
                        });
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Authentication
              const SettingSectionHeader(label: 'Authentication'),
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
                                    ? 'Authenticated as ${lfmState.username}'
                                    : lfmState is LastdotfmFailed
                                        ? 'Authentication failed: ${lfmState.message}'
                                        : 'Not authenticated',
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
                      const SettingInfoText(
                        text:
                            'Steps to authenticate:\n1. Create / open a Last.FM account at last.fm\n2. Generate an API Key at last.fm/api/account/create\n3. Enter your API Key & Secret below\n4. Tap "Start Auth" and approve in the browser\n5. Tap "Get & Save Session Key" to finish',
                      ),
                      const SettingDivider(),
                      SettingTextFieldTile(
                        label: 'API Key',
                        controller: apiKeyController,
                      ),
                      const SettingDivider(),
                      SettingTextFieldTile(
                        label: 'API Secret',
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
                              label: '1. Start Auth',
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
                              label: '2. Get & Save Session Key',
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
                                      "Start Auth first, then approve in browser.");
                                }
                              },
                            ),
                            if (lfmState is LastdotfmIntialized)
                              _AuthButton(
                                label: 'Remove Keys',
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

// ─── Auth Button ─────────────────────────────────────────────────────────────

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
