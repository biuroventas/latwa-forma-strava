import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const appLocalePrefKey = 'app_locale';

/// Zapisany wybór. Null oznacza język telefonu (ukraiński, angielski albo polski).
Locale? _savedAppLocale;

Future<void> loadSavedAppLocale() async {
  final prefs = await SharedPreferences.getInstance();
  _savedAppLocale = localeFromCode(prefs.getString(appLocalePrefKey));
}

Locale? localeFromCode(String? code) {
  if (code == 'en') return const Locale('en');
  if (code == 'pl') return const Locale('pl');
  if (code == 'uk') return const Locale('uk');
  return null;
}

/// Język telefonu zawężony do ukraińskiego, angielskiego i polskiego.
Locale resolveDeviceLocale(Locale? device) {
  final code = device?.languageCode;
  if (code == 'uk') return const Locale('uk');
  if (code == 'en') return const Locale('en');
  return const Locale('pl');
}

/// Język używany teraz: zapisany wybór albo język telefonu.
Locale currentAppLocale() {
  return _savedAppLocale ??
      resolveDeviceLocale(WidgetsBinding.instance.platformDispatcher.locale);
}

class AppLocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => _savedAppLocale;

  Future<void> choose(String languageCode) async {
    final locale = localeFromCode(languageCode);
    if (locale == null) return;
    _savedAppLocale = locale;
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(appLocalePrefKey, languageCode);
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleController, Locale?>(
  AppLocaleController.new,
);
