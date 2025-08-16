import 'dart:developer';
import 'package:Bloomee/blocs/global_events/global_events_cubit.dart';
import 'package:Bloomee/screens/screen/common_views/changelog_reader.dart';
import 'package:Bloomee/screens/widgets/gradient_alert_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openURL(String url) async {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

class GlobalEventListener extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  const GlobalEventListener(
      {super.key, required this.child, required this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GlobalEventsCubit, GlobalEventsState>(
      listener: (context, state) {
        final dialogContext = navigatorKey.currentContext ?? context;
        switch (state.runtimeType) {
          case UpdateAvailable:
            final s = state as UpdateAvailable;
            log("Update Available: ${s.message}");
            showDialog(
              context: dialogContext,
              builder: (context) {
                return GradientDialog(
                  "Update Available",
                  content: s.message,
                  presetIndex: 0,
                  actions: [
                    GradientDialogAction('Later',
                        onPressed: () {}, isText: true),
                    GradientDialogAction('Update Now', onPressed: () {
                      openURL(s.downloadUrl);
                    }),
                  ],
                );
              },
            );
            break;
          case AlertDialogState:
            final s = state as AlertDialogState;
            showDialog(
              context: dialogContext,
              builder: (context) {
                return GradientDialog(
                  s.title,
                  content: s.content,
                  presetIndex: 0,
                  actions: [
                    GradientDialogAction('OK', onPressed: () {
                      Navigator.of(context).pop();
                    }),
                  ],
                );
              },
            );
            break;
          case WhatIsNewState:
            final s = state as WhatIsNewState;
            Navigator.of(dialogContext).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ChangelogScreen(
                  changelogText: s.changeLogs,
                  showOlderVersions: false,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  final tween = Tween<Offset>(
                          begin: const Offset(0.0, 1.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOut));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            );
            break;
          default:
            break;
        }
      },
      child: child,
    );
  }
}
