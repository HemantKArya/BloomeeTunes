import 'package:Bloomee/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// An open failure must be visible without silently replacing or clearing data.
class StartupFailureApp extends StatelessWidget {
  final String details;
  const StartupFailureApp({super.key, required this.details});

  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData.dark(),
        home: Builder(builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
              body: SafeArea(
                  child: Center(
                      child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.backupStartupFailed,
                          style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 16),
                      Text(l10n.backupStartupFailedDetails),
                      const SizedBox(height: 16),
                      SelectableText(details),
                    ])),
          ))));
        }),
      );
}
