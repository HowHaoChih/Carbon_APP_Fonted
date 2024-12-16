import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Extension function to get [l10n] object from [BuildContext].
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Global [l10n] object that is used when [BuildContext] is not available.
// Provide global context here from GlobalKey<NavigatorState>.
// AppLocalizations get l10n => AppLocalizations.of(<context>);