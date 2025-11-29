import 'dart:developer';

import 'package:Bloomee/blocs/lastdotfm/lastdotfm_cubit.dart';
import 'package:Bloomee/blocs/settings_cubit/cubit/settings_cubit.dart';
import 'package:Bloomee/repository/LastFM/lastfmapi.dart';
import 'package:Bloomee/routes_and_consts/global_str_consts.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/bloomee_db_service.dart';
import 'package:flutter/material.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    setState(() {
      authBtnClicked = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        getBtnVisible = true;
      });
    });
    Future.delayed(const Duration(seconds: 7), () {
      setState(() {
        authBtnClicked = false;
      });
    });
  }

  Future<void> getKeysFromDB() async {
    log("Getting Last.FM Keys from DB", name: "Last.FM");
    username =
        await BloomeeDBService.getApiTokenDB(GlobalStrConsts.lFMUsername);
    final apiKey =
        await BloomeeDBService.getApiTokenDB(GlobalStrConsts.lFMApiKey);
    final apiSecret =
        await BloomeeDBService.getApiTokenDB(GlobalStrConsts.lFMSecret);
    if (apiKey != null) {
      apiKeyController.text = apiKey;
    }
    if (apiSecret != null) {
      apiSecretController.text = apiSecret;
    }

    log("Last.FM Keys from DB: $apiKey, $apiSecret", name: "Last.FM");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Last.FM Settings',
          style: const TextStyle(
                  color: Default_Theme.primaryColor1,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)
              .merge(Default_Theme.secondoryTextStyle),
        ),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              SwitchListTile(
                  value: state.lastFMScrobble,
                  subtitle: Text(
                    "Scrobble tracks to Last.FM",
                    style: TextStyle(
                            color: Default_Theme.primaryColor1
                                .withValues(alpha: 0.5),
                            fontSize: 12)
                        .merge(Default_Theme.secondoryTextStyleMedium),
                  ),
                  title: Text(
                    "Scrobble Tracks",
                    style: const TextStyle(
                            color: Default_Theme.primaryColor1, fontSize: 16)
                        .merge(Default_Theme.secondoryTextStyleMedium),
                  ),
                  onChanged: (value) {
                    context.read<SettingsCubit>().setLastFMScrobble(value);
                    if (value && LastFmAPI.initialized == false) {
                      SnackbarService.showMessage(
                          "First Authenticate Last.FM API.");
                      Future.delayed(const Duration(milliseconds: 500), () {
                        context.read<SettingsCubit>().setLastFMScrobble(false);
                      });
                    }
                  }),

              // text box for guiding user to get session key and click buttons
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 8.0, top: 8, bottom: 8),
                child: SelectableText(
                  'To set API Key for Last.FM, \n1. Go to Last.FM create an account there (https://www.last.fm/).\n2. Now generate an API Key and Secret from: https://www.last.fm/api/account/create\n3. Enter the API Key and Secret below and click on \'Start Auth\' to get the session key.\n4. After allowing from browser, click on \'Get and Save Session Key\' to save the session key.',
                  style: TextStyle(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.5),
                          fontSize: 12)
                      .merge(Default_Theme.secondoryTextStyleMedium),
                ),
              ),
              // two text fields for api key and secret and two buttons for start auth and get session key
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 8.0, top: 8, bottom: 8),
                child: TextField(
                  controller: apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    labelStyle: TextStyle(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.5),
                        fontFamily: 'Unageo',
                        fontWeight: FontWeight.w500,
                        fontSize: 12),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.5)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Default_Theme.primaryColor1),
                    ),
                  ),
                  style: const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontFamily: 'Unageo',
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 8.0, top: 8, bottom: 8),
                child: TextField(
                  controller: apiSecretController,
                  keyboardType: TextInputType.visiblePassword,
                  decoration: InputDecoration(
                    labelText: 'API Secret',
                    labelStyle: TextStyle(
                        color:
                            Default_Theme.primaryColor1.withValues(alpha: 0.5),
                        fontFamily: 'Unageo',
                        fontWeight: FontWeight.w500,
                        fontSize: 12),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Default_Theme.primaryColor1
                              .withValues(alpha: 0.5)),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Default_Theme.primaryColor1),
                    ),
                  ),
                  style: const TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontFamily: 'Unageo',
                      fontWeight: FontWeight.w500,
                      fontSize: 16),
                ),
              ),
              // a green info text to show that authentication is successful
              BlocBuilder<LastdotfmCubit, LastdotfmState>(
                builder: (context, state) {
                  if (state is LastdotfmIntialized) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 8.0,
                        top: 16,
                      ),
                      child: Text(
                        'Hi, ${state.username},\nLast.FM API is Authenticated.',
                        style: TextStyle(
                          color:
                              Default_Theme.successColor.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontFamily: 'Unageo',
                        ),
                      ),
                    );
                  } else if (state is LastdotfmFailed) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 16.0,
                        right: 8.0,
                        top: 16,
                      ),
                      child: Text(
                        'Last.FM Authentication Failed.\n${state.message}\nHint: First click Start Auth and Sign-In from browser then click Get & Save Session Key button',
                        style: TextStyle(
                                color: Colors.red.withValues(alpha: 0.7),
                                fontSize: 12)
                            .merge(Default_Theme.secondoryTextStyleMedium),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 8.0, top: 16, bottom: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    BlocBuilder<LastdotfmCubit, LastdotfmState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed:
                              state is! LastdotfmIntialized && !authBtnClicked
                                  ? () async {
                                      authBtnClick();
                                      token = await context
                                          .read<LastdotfmCubit>()
                                          .startAuth(
                                              apiKey: apiKeyController.text,
                                              secret: apiSecretController.text);
                                    }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: Default_Theme.accentColor2
                                .withValues(alpha: 0.5),
                            disabledForegroundColor: Default_Theme.primaryColor2
                                .withValues(alpha: 0.3),
                            backgroundColor: Default_Theme.accentColor2,
                            foregroundColor: Default_Theme.primaryColor2,
                          ),
                          child: const Text('1. Start Auth'),
                        );
                      },
                    ),
                    BlocBuilder<LastdotfmCubit, LastdotfmState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed:
                              state is! LastdotfmIntialized && getBtnVisible
                                  ? () {
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
                                            "Authentication is not started. Click on Start Autentication.");
                                      }
                                    }
                                  : null,
                          style: ElevatedButton.styleFrom(
                            disabledBackgroundColor: Default_Theme.accentColor2
                                .withValues(alpha: 0.5),
                            disabledForegroundColor: Default_Theme.primaryColor2
                                .withValues(alpha: 0.3),
                            backgroundColor: Default_Theme.accentColor2,
                            foregroundColor: Default_Theme.primaryColor2,
                          ),
                          child: const Text('2. Get & Save Session Key'),
                        );
                      },
                    ),
                    // log out button
                    BlocBuilder<LastdotfmCubit, LastdotfmState>(
                      builder: (context, state) {
                        return state is LastdotfmIntialized
                            ? ElevatedButton(
                                onPressed: () {
                                  context.read<LastdotfmCubit>().remove();
                                  context
                                      .read<SettingsCubit>()
                                      .setLastFMScrobble(false);
                                },
                                style: ElevatedButton.styleFrom(
                                  disabledBackgroundColor: Default_Theme
                                      .accentColor2
                                      .withValues(alpha: 0.5),
                                  backgroundColor: Default_Theme.accentColor2,
                                  disabledForegroundColor: Default_Theme
                                      .primaryColor2
                                      .withValues(alpha: 0.3),
                                  foregroundColor: Default_Theme.primaryColor2,
                                ),
                                child: const Text('Remove Keys'),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
