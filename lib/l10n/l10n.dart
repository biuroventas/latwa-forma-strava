import 'package:flutter/widgets.dart';

import 'package:latwa_forma/l10n/app_localizations.dart';

export 'package:latwa_forma/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
