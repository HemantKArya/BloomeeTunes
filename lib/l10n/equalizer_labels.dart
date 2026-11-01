import 'package:Bloomee/l10n/app_localizations.dart';

/// Translate display names while keeping stored preset identifiers stable.
String equalizerPresetLabel(AppLocalizations l10n, String preset) =>
    switch (preset) {
      'Flat' => l10n.eqPresetFlat,
      'Acoustic' => l10n.eqPresetAcoustic,
      'Bass Boost' => l10n.eqPresetBassBoost,
      'Bass Reducer' => l10n.eqPresetBassReducer,
      'Classical' => l10n.eqPresetClassical,
      'Dance' => l10n.eqPresetDance,
      'Deep' => l10n.eqPresetDeep,
      'EDM' => l10n.eqPresetEDM,
      'Electronic' => l10n.eqPresetElectronic,
      'Hip-Hop' => l10n.eqPresetHipHop,
      'Jazz' => l10n.eqPresetJazz,
      'Latin' => l10n.eqPresetLatin,
      'Live' => l10n.eqPresetLive,
      'Lounge' => l10n.eqPresetLounge,
      'Metal' => l10n.eqPresetMetal,
      'Piano' => l10n.eqPresetPiano,
      'Pop' => l10n.eqPresetPop,
      'R&B' => l10n.eqPresetRB,
      'Rock' => l10n.eqPresetRock,
      'Small Speakers' => l10n.eqPresetSmallSpeakers,
      'Spoken Word' => l10n.eqPresetSpokenWord,
      'Treble Boost' => l10n.eqPresetTrebleBoost,
      'Treble Reducer' => l10n.eqPresetTrebleReducer,
      'Vocal Booster' => l10n.eqPresetVocalBooster,
      'Custom' => l10n.eqPresetCustom,
      _ => preset,
    };
