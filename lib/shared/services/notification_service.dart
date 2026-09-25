import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:latwa_forma/l10n/app_localizations.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../../core/providers/locale_provider.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // Powiadomienia nie działają na web
    if (kIsWeb) {
      debugPrint('⚠️ Powiadomienia nie są obsługiwane na web');
      return;
    }

    try {
      // Inicjalizuj timezone
      try {
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.getLocation('Europe/Warsaw'));
      } catch (tzError) {
        debugPrint('⚠️ Błąd inicjalizacji timezone: $tzError');
        // Spróbuj użyć domyślnej lokalizacji
        try {
          tz.setLocalLocation(tz.local);
        } catch (e) {
          debugPrint('⚠️ Nie można ustawić lokalizacji timezone: $e');
        }
      }

      // Inicjalizuj Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // Inicjalizuj iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Poproś o uprawnienia na Android
      await _requestPermissions();
    } catch (e) {
      debugPrint('⚠️ Błąd inicjalizacji powiadomień: $e');
      // Nie przerywaj działania aplikacji jeśli powiadomienia nie działają
    }
  }

  static Future<void> _requestPermissions() async {
    try {
      final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();

      final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      debugPrint('⚠️ Błąd podczas żądania uprawnień: $e');
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Można dodać nawigację do odpowiedniego ekranu
    debugPrint('Powiadomienie kliknięte: ${response.payload}');
  }

  static const int _waterReminderIdBase = 1;
  static const int _mealReminderIdBase = 100;

  /// Zaplanuj przypomnienie o wodzie (id: 1-50)
  static Future<void> scheduleWaterReminder({
    required int id,
    required int hour,
    required int minute,
    String? message,
  }) async {
    if (kIsWeb) return;

    final l10n = lookupAppLocalizations(currentAppLocale());
    
    try {
      await _notifications.zonedSchedule(
        _waterReminderIdBase + id,
        l10n.moreNotifWaterTitle,
        message ?? l10n.moreNotifWaterBody,
        _nextInstanceOfTime(hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminder',
            l10n.moreNotifWaterChannel,
            channelDescription: l10n.moreNotifWaterChannelDesc,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('⚠️ Błąd podczas planowania przypomnienia o wodzie: $e');
    }
  }

  /// Zaplanuj przypomnienie o posiłku (id: 0-99, mapowane na 100-199)
  static Future<void> scheduleMealReminder({
    required int id,
    required String label,
    required int hour,
    required int minute,
  }) async {
    if (kIsWeb) return;

    final l10n = lookupAppLocalizations(currentAppLocale());
    
    try {
      await _notifications.zonedSchedule(
        _mealReminderIdBase + id,
        l10n.moreNotifMealTitle(label: label),
        l10n.moreNotifMealBody,
        _nextInstanceOfTime(hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'meal_reminder',
            l10n.moreNotifMealChannel,
            channelDescription: l10n.moreNotifMealChannelDesc,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('⚠️ Błąd podczas planowania przypomnienia o posiłku: $e');
    }
  }

  /// Anuluj pojedyncze przypomnienie o posiłku
  static Future<void> cancelMealReminder(int id) async {
    if (kIsWeb) return;
    try {
      await _notifications.cancel(_mealReminderIdBase + id);
    } catch (e) {
      debugPrint('⚠️ Błąd podczas anulowania przypomnienia o posiłku: $e');
    }
  }

  /// Anuluj pojedyncze przypomnienie o wodzie
  static Future<void> cancelWaterReminder(int id) async {
    if (kIsWeb) return;
    try {
      await _notifications.cancel(_waterReminderIdBase + id);
    } catch (e) {
      debugPrint('⚠️ Błąd podczas anulowania przypomnienia o wodzie: $e');
    }
  }

  /// Anuluj wszystkie przypomnienia o wodzie (używane przy przeładowaniu listy)
  static Future<void> cancelAllWaterReminders() async {
    if (kIsWeb) return;
    try {
      for (var i = 0; i < 50; i++) {
        await _notifications.cancel(_waterReminderIdBase + i);
      }
    } catch (e) {
      debugPrint('⚠️ Błąd podczas anulowania przypomnień o wodzie: $e');
    }
  }

  /// Anuluj wszystkie przypomnienia o posiłkach (używane przy przeładowaniu listy)
  static Future<void> cancelAllMealReminders() async {
    if (kIsWeb) return;
    try {
      for (var i = 0; i < 100; i++) {
        await _notifications.cancel(_mealReminderIdBase + i);
      }
    } catch (e) {
      debugPrint('⚠️ Błąd podczas anulowania przypomnień o posiłkach: $e');
    }
  }

  /// Anuluj wszystkie przypomnienia
  static Future<void> cancelAll() async {
    if (kIsWeb) return;
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('⚠️ Błąd podczas anulowania wszystkich przypomnień: $e');
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    return scheduledDate;
  }
}
