/// Czas trwania okresu próbnego Premium od pierwszego użycia aplikacji.
const trialDuration = Duration(hours: 24);

const String trialStartPrefKeyPrefix = 'trial_start_';

/// Podstawowe korzystanie bez konta na tym urządzeniu.
const guestTrialDuration = Duration(days: 7);

/// Jeden licznik na telefon — nowe konto anonimowe go nie zeruje.
const String guestTrialStartPrefKey = 'guest_trial_start_device';

const String guestTrialCardDismissedPrefKey = 'guest_trial_card_dismissed';

const String guestTrialLastDayShownPrefKey = 'guest_trial_last_day_shown';
