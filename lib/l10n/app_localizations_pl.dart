// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get language => 'Język';

  @override
  String get appTitle => 'Łatwa Forma';

  @override
  String get navToday => 'Dziś';

  @override
  String get navMeals => 'Posiłki';

  @override
  String get navWater => 'Woda';

  @override
  String get navProfile => 'Ja';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get commonDelete => 'Usuń';

  @override
  String get commonClose => 'Zamknij';

  @override
  String get commonRetry => 'Spróbuj ponownie';

  @override
  String get commonWarning => 'Uwaga';

  @override
  String get commonError => 'Błąd';

  @override
  String get commonBack => 'Wstecz';

  @override
  String get commonYes => 'Tak';

  @override
  String get commonNo => 'Nie';

  @override
  String get commonContinue => 'Dalej';

  @override
  String get healthDisclaimer =>
      'Łatwa Forma nie jest urządzeniem medycznym i nie diagnozuje, nie leczy, nie zapobiega ani nie leczy żadnej choroby ani stanu zdrowia. Obliczenia kalorii, makroskładników i porady AI mają charakter orientacyjny. W sprawach zdrowia skonsultuj się z lekarzem lub dietetykiem.';

  @override
  String get onbContinueApple => 'Kontynuuj z Apple';

  @override
  String get onbContinueGoogle => 'Kontynuuj z Google';

  @override
  String get onbContinueWithEmail => 'Kontynuuj z emailem';

  @override
  String get onbStartWithoutAccount => 'Zacznij bez konta';

  @override
  String get onbCreateAccount => 'Załóż konto';

  @override
  String get onbCreateAccountEmail => 'Załóż konto e-mailem';

  @override
  String get onbEnterCodeLink => 'Mam już kod z maila – wpisz go';

  @override
  String get onbAlreadyHaveCode => 'Mam już kod z maila';

  @override
  String get onbLegalPrefix => 'Korzystając z aplikacji, akceptujesz ';

  @override
  String get onbTerms => 'Regulamin';

  @override
  String get onbLegalAnd => ' i ';

  @override
  String get onbPrivacyPolicyAccusative => 'Politykę prywatności';

  @override
  String get onbLegalPeriod => '.';

  @override
  String get onbPrivacyPolicy => 'Polityka prywatności';

  @override
  String get onbContact => 'Kontakt';

  @override
  String get onbFollowUs => 'Śledź nas: ';

  @override
  String onbSocialComingSoon({required String name}) {
    return '$name – wkrótce';
  }

  @override
  String onbCopyrightFull({
    required String company,
    required String nip,
    required String address,
  }) {
    return '© 2026 Łatwa Forma | $company\nNIP $nip · $address';
  }

  @override
  String onbCopyrightShort({required String company, required String nip}) {
    return '© 2026 Łatwa Forma | $company\nNIP $nip';
  }

  @override
  String get onbFeatureCaloriesTitle => 'Kalorie i makro dopasowane do Ciebie';

  @override
  String get onbFeatureCaloriesDesc => 'Dzienny limit i makro pod Twój cel';

  @override
  String get onbFeatureWeightTitle => 'Śledzenie wagi i postępów';

  @override
  String get onbFeatureWeightDesc => 'Waga i zmiany w jednym miejscu';

  @override
  String get onbFeaturePlanTitle => 'Prosty plan do celu';

  @override
  String get onbFeaturePlanDesc => 'Jasna droga do Twojej wagi';

  @override
  String get onbFeatureAiTitle => 'Pomoc AI';

  @override
  String get onbFeatureAiDesc => 'Porady i posiłek ze zdjęcia';

  @override
  String get onbFeatureProductsTitle => 'Baza produktów';

  @override
  String get onbFeatureProductsDesc => 'Szukaj i skanuj kod kreskowy';

  @override
  String get onbBenefitCalories => 'plan kalorii dopasowany do Ciebie';

  @override
  String get onbBenefitWeight => 'śledzenie wagi i postępów';

  @override
  String get onbBenefitPlan => 'prosty plan do celu';

  @override
  String get onbBenefitAi => 'pomoc AI';

  @override
  String get onbLoginOrRegister => 'Zaloguj się lub załóż konto';

  @override
  String get onbLoginOrCreateShort => 'Zaloguj lub załóż konto';

  @override
  String get onbLoginSheetBody =>
      'Masz konto? Zaloguj się. Nowy użytkownik? Załóż konto – Twoje dane będą zapisane.';

  @override
  String get onbFaqTitle => 'FAQ – najczęściej zadawane pytania';

  @override
  String get onbFaqShowLess => 'Pokaż mniej';

  @override
  String onbFaqShowMore({required int count}) {
    return 'Zobacz więcej pytań ($count)';
  }

  @override
  String get onbFaqFreeQ => 'Czy aplikacja jest darmowa?';

  @override
  String get onbFaqFreeA =>
      'Tak. Łatwa Forma jest darmowa do codziennego użytku: śledzenie kalorii, posiłków, wagi, wody i aktywności. Część funkcji (np. analiza AI ze zdjęcia, rozbudowane statystyki) jest dostępna w planie Premium.';

  @override
  String get onbFaqPhotoQ => 'Jak działa licznik kalorii ze zdjęcia?';

  @override
  String get onbFaqPhotoA =>
      'W ekranie dodawania posiłku wybierz „Analiza AI”. Zrób zdjęcie dania lub wybierz je z galerii. Aplikacja wysyła zdjęcie do modelu AI (wizja), który rozpoznaje potrawę i szacuje kalorie oraz makroskładniki (białko, tłuszcze, węglowodany). Możesz je potem poprawić i zapisać. Funkcja wymaga Premium.';

  @override
  String get onbFaqLimitQ => 'Jak aplikacja liczy mój dzienny limit kalorii?';

  @override
  String get onbFaqLimitA =>
      'Na podstawie profilu (wiek, płeć, waga, wzrost, poziom aktywności) obliczamy BMR (wzór Harrisa-Benedicta), a potem TDEE. W zależności od celu (schudnięcie, utrzymanie, przytycie) dostosowujemy limit kalorii i makra.';

  @override
  String get onbFaqNoAccountQ => 'Co to jest „Zacznij bez konta”?';

  @override
  String get onbFaqNoAccountA =>
      'Możesz korzystać z aplikacji bez logowania. Dane są zapisywane lokalnie. Później możesz połączyć je z kontem (Apple, Google lub e-mail), aby mieć backup i synchronizację między urządzeniami.';

  @override
  String get onbFaqStravaQ => 'Czy mogę połączyć Strava lub Garmin?';

  @override
  String get onbFaqStravaA =>
      'Tak, Strava. W ustawieniach (Profil → Integracje) możesz połączyć konto ze Strava. Importowane aktywności są uwzględniane w bilansie kalorii (spalone kcal). Garmin Connect pojawi się po uruchomieniu integracji.';

  @override
  String get onbFaqPremiumQ => 'Co daje Premium?';

  @override
  String get onbFaqPremiumA =>
      'M.in. analiza posiłku ze zdjęcia (AI), rozbudowane statystyki, eksport danych, wyższy limit porad AI. W aplikacji ze sklepu płatności idą przez Google Play / App Store; na stronie latwaforma.pl – przez Stripe.';

  @override
  String get onbFaqGoalQ =>
      'Jak zmienić cel (schudnięcie / utrzymanie / przytycie)?';

  @override
  String get onbFaqGoalA =>
      'W Profilu ustaw wagę docelową. Aplikacja na tej podstawie proponuje cel i dzienny limit; makra można też dostosować ręcznie w ustawieniach profilu.';

  @override
  String get onbFaqAddMealQ => 'Jak dodać posiłek?';

  @override
  String get onbFaqAddMealA =>
      'Z ekranu głównego lub zakładki „Posiłki” wybierz „Dodaj posiłek”. Możesz wpisać dane ręcznie, zeskanować kod kreskowy (Open Food Facts) lub użyć Analizy AI ze zdjęcia (Premium).';

  @override
  String get onbFaqDataQ => 'Gdzie są zapisane moje dane?';

  @override
  String get onbFaqDataA =>
      'Dane są przechowywane na serwerach w Europie (Supabase). Przy „Zacznij bez konta” dane są lokalne do momentu połączenia z kontem.';

  @override
  String get onbFaqDeleteQ => 'Jak usunąć konto i dane?';

  @override
  String get onbFaqDeleteA =>
      'W aplikacji: Profil → Usuń konto. Możesz też złożyć wniosek na latwaforma.pl/usun-konto.html. Po zatwierdzeniu konto i powiązane dane są usuwane (to nie jest zamrożenie konta). Subskrypcję w Google Play / App Store anuluj osobno w sklepie. W razie problemów: contact@latwaforma.pl.';

  @override
  String get onbFaqMedicalQ => 'Czy to aplikacja medyczna?';

  @override
  String get onbFaqMedicalA =>
      'Nie. Łatwa Forma nie jest urządzeniem medycznym i nie diagnozuje, nie leczy ani nie zapobiega chorobom. Obliczenia i porady AI są orientacyjne. W sprawach zdrowia skonsultuj się z lekarzem lub dietetykiem.';

  @override
  String get onbSendingLinkAndCode => 'Wysyłanie linku i kodu...';

  @override
  String get onbSignedIn => 'Zalogowano';

  @override
  String get onbSignedInSuccess => 'Zalogowano pomyślnie!';

  @override
  String get onbSignedInDataSaved =>
      'Zostałeś zalogowany. Twoje dane są zapisane.';

  @override
  String get onbAccountLinked => 'Konto połączone';

  @override
  String get onbEmailLinkedSuccess =>
      'Twój adres e-mail został połączony z kontem. Możesz się teraz logować tym emailem.';

  @override
  String get onbEnterEmailTitle => 'Podaj adres email';

  @override
  String get onbEnterEmailWhichAddress =>
      'Na który adres wysłaliśmy link i kod? Podaj go, a następnie wpiszesz kod.';

  @override
  String get onbEmailAddressLabel => 'Adres email';

  @override
  String get onbEmailAddressLabelAlt => 'Adres e-mail';

  @override
  String get onbEmailAddressHint => 'np. jan@example.com';

  @override
  String get onbCheckInbox => 'Sprawdź skrzynkę';

  @override
  String get onbEnterCodeFromEmailTitle => 'Wpisz kod z maila';

  @override
  String get onbEnterCodeFromEmailLabel => 'Wpisz kod z maila:';

  @override
  String get onbEmailCodeLabel => 'Kod z maila';

  @override
  String get onbEmailCodeHint => 'np. 123456';

  @override
  String onbSentLinkAndCode({required String email}) {
    return 'Wysłaliśmy link i kod na $email. Sprawdź skrzynkę (także folder Spam) – możesz kliknąć link w mailu lub wpisać kod poniżej.';
  }

  @override
  String onbEnterCodeReceived({required String email}) {
    return 'Wpisz poniżej kod, który otrzymałeś na adres $email.';
  }

  @override
  String onbCodeSentTo({required String email}) {
    return 'Kod wysłany na: $email';
  }

  @override
  String onbCodeSentEnterBelow({required String email}) {
    return 'Wysłaliśmy kod na $email. Wpisz go poniżej.';
  }

  @override
  String get onbResend => 'Wyślij ponownie';

  @override
  String get onbSignIn => 'Zaloguj';

  @override
  String get onbConfirmCode => 'Potwierdź kod';

  @override
  String get onbSuccess => 'Sukces';

  @override
  String get onbSendLinkAndCode => 'Wyślij link oraz kod';

  @override
  String get onbEmailSignupBody =>
      'Podaj adres e-mail. Wyślemy link i kod, którymi dokończysz założenie konta.';

  @override
  String get onbEnterEmailRequired => 'Podaj adres e-mail';

  @override
  String get onbIntroTitle => 'Powiedz nam kilka rzeczy o sobie';

  @override
  String get onbIntroBody =>
      'Pokażemy Ci ile jeść każdego dnia,\naby osiągnąć swój cel.';

  @override
  String get onbIntroDuration => 'Zajmie mniej niż minutę';

  @override
  String get onbIntroStart => 'Rozpocznij';

  @override
  String get onbAnonErrorTitle => 'Nie udało się rozpocząć bez konta';

  @override
  String get onbAnonErrorNoConfig =>
      'Aplikacja nie ma połączenia z serwerem (brak konfiguracji w buildzie).';

  @override
  String get onbAnonErrorTimeout =>
      'Serwer nie odpowiedział w czasie. Sprawdź internet lub spróbuj później.';

  @override
  String get onbAnonErrorFailed =>
      'Połączenie z serwerem nie powiodło się. Możesz:';

  @override
  String get onbAnonErrorTipDomain =>
      '• Upewnij się, że jesteś na adresie latwaforma.pl.';

  @override
  String get onbAnonErrorTipRefresh =>
      '• Odśwież stronę (F5) i spróbuj ponownie.';

  @override
  String get onbAnonErrorTipLogin =>
      '• Albo zaloguj się przez Apple, Google albo e-mail – przycisk na górze.';

  @override
  String get onbOpenLatwaForma => 'Otwórz latwaforma.pl';

  @override
  String get onbSplashNoServerConfig =>
      'Brak połączenia z serwerem. Sprawdź konfigurację (.env) i internet.';

  @override
  String get onbSplashNoConnection =>
      'Brak połączenia. Sprawdź internet i spróbuj ponownie.';

  @override
  String get onbSplashLoginFailed =>
      'Nie udało się zalogować. Uzupełnij profil lub spróbuj zalogować się ponownie.';

  @override
  String get onbSplashGoogleFailed =>
      'Logowanie Google nie powiodło się. Zaloguj się ponownie w tej samej karcie.';

  @override
  String get onbSplashAbort => 'Przerwij';

  @override
  String get onbPlanThanks => 'Dziękujemy!';

  @override
  String get onbPlanGotIt => 'Mamy to!';

  @override
  String get onbPlanStepData => 'Dane';

  @override
  String get onbPlanStepCalc => 'Kalkulacja';

  @override
  String get onbPlanStepMacro => 'Makro';

  @override
  String get onbPlanStepDone => 'Gotowe';

  @override
  String get onbPlanStatusAnalyzing => 'Analizujemy Twoje dane…';

  @override
  String get onbPlanStatusCalories => 'Obliczanie kalorii…';

  @override
  String get onbPlanStatusMacro => 'Makro…';

  @override
  String get onbPlanStatusAlmost => 'Prawie gotowe…';

  @override
  String get onbPlanReadyTitle => 'Twój plan jest gotowy!';

  @override
  String get onbPlanWhatDone => 'Co zostało zrobione:';

  @override
  String get onbPlanCaloriesComputed =>
      '• Na podstawie wzrostu, wagi, wieku i poziomu aktywności obliczyliśmy Twoje dzienne zapotrzebowanie kaloryczne.';

  @override
  String onbPlanCaloriesComputedWithValue({required String calories}) {
    return '• Na podstawie wzrostu, wagi, wieku i poziomu aktywności obliczyliśmy Twoje dzienne zapotrzebowanie kaloryczne: $calories kcal.';
  }

  @override
  String onbPlanTargetDate({required String date}) {
    return '• Szacowany termin osiągnięcia celu: $date';
  }

  @override
  String get onbPlanChangeInProfile =>
      'Możesz w każdej chwili zmienić te dane w zakładce Profil (ikona osoby u góry).';

  @override
  String get onbPlanHowToUse => 'Jak korzystać z aplikacji:';

  @override
  String get onbPlanTipMeals =>
      '• Dodawaj posiłki – śledź, co jesz i ile kalorii spożywasz';

  @override
  String get onbPlanTipWater =>
      '• Pij wodę – ustaw przypomnienia w ustawieniach';

  @override
  String get onbPlanTipWeight =>
      '• Wpisuj wagę regularnie – widzisz postępy na wykresie';

  @override
  String get onbPlanTipDashboard =>
      '• Sprawdzaj dashboard – tam widzisz swój dzienny cel i postępy';

  @override
  String get onbPlanMedicalNote =>
      'Łatwa Forma nie jest urządzeniem medycznym i nie diagnozuje, nie leczy ani nie zapobiega chorobom. W sprawach zdrowia skonsultuj się z lekarzem lub dietetykiem.';

  @override
  String get onbPlanStartButton => 'Rozumiem, zaczynam!';

  @override
  String get onbSaveProgressTitle => 'Zapisz postępy';

  @override
  String onbSaveProgressBodyWithMeals({required int count}) {
    return 'Masz już $count posiłków! Zaloguj się, aby nie stracić danych przy reinstalacji aplikacji.';
  }

  @override
  String get onbSaveProgressBodyEmpty =>
      'Załóż konto, żeby Twoje posiłki, aktywności i waga były zapisane w chmurze i dostępne na każdym urządzeniu – nic nie zginie przy reinstalacji.';

  @override
  String get onbChooseLoginMethod => 'Wybierz sposób logowania:';

  @override
  String get onbLater => 'Później';

  @override
  String guestTrialDaysLeft({required int days}) {
    return 'Bez konta: zostało $days dni';
  }

  @override
  String get guestTrialOneDay => 'Bez konta: został 1 dzień';

  @override
  String get guestTrialLastDay =>
      'Bez konta: ostatni dzień. Od jutra nowe wpisy wymagają konta.';

  @override
  String get guestTrialCardBody =>
      'Połącz konto, żeby dane zostały przy zmianie telefonu.';

  @override
  String get guestTrialEndedTitle => 'Okres bez konta minął';

  @override
  String get guestTrialEndedBody =>
      'Możesz przeglądać zapisane posiłki, wodę i wagę. Żeby dodawać dalej, połącz konto — dane zostaną.';

  @override
  String get guestTrialViewOnly => 'Tylko podgląd';

  @override
  String get onbLinkingAccount => 'Łączenie konta...';

  @override
  String get onbAccountSavedSuccess => 'Konto zapisane pomyślnie!';

  @override
  String get onbSaveWithEmailTitle => 'Zapisz z emailem';

  @override
  String get onbEmailAlreadyRegistered => 'E-mail już zarejestrowany';

  @override
  String get onbClickBelowToLogin =>
      'Kliknij poniżej, aby przejść do logowania:';

  @override
  String get onbSignOutAndSignIn => 'Wyloguj i zaloguj się';

  @override
  String get onbGoBackTitle => 'Cofnąć się?';

  @override
  String get onbGoBackBody =>
      'Dane nie zostaną zapisane. Wrócisz do ekranu początkowego.';

  @override
  String get onbGoBackConfirm => 'Tak, cofnij';

  @override
  String get onbBackTooltip => 'Cofnij';

  @override
  String get onbCompleteData => 'Uzupełnij dane';

  @override
  String get onbGenderLabel => 'Płeć *';

  @override
  String get onbGenderFemale => 'Kobieta';

  @override
  String get onbGenderMale => 'Mężczyzna';

  @override
  String get onbAgeLabel => 'Wiek *';

  @override
  String get onbYearsUnit => 'lat';

  @override
  String get onbHeightLabel => 'Wzrost (cm) *';

  @override
  String get onbCurrentWeightLabel => 'Aktualna waga (kg) *';

  @override
  String get onbTargetWeightLabel => 'Waga docelowa (kg) *';

  @override
  String onbWeightDiff({required String diff}) {
    return 'Różnica: $diff kg';
  }

  @override
  String get onbWeightDiffMin =>
      'Różnica między wagami musi wynosić co najmniej 1 kg';

  @override
  String get onbActivityLabel => 'Poziom aktywności *';

  @override
  String get onbActivitySedentary => 'Siedzący';

  @override
  String get onbActivitySedentaryDesc =>
      'Brak aktywności lub minimalna aktywność';

  @override
  String get onbActivityLight => 'Lekka';

  @override
  String get onbActivityLightDesc => 'Ćwiczenia 1-3 razy w tygodniu';

  @override
  String get onbActivityModerate => 'Umiarkowana';

  @override
  String get onbActivityModerateDesc => 'Ćwiczenia 3-5 razy w tygodniu';

  @override
  String get onbActivityIntense => 'Intensywna';

  @override
  String get onbActivityIntenseDesc => 'Ćwiczenia 6-7 razy w tygodniu';

  @override
  String get onbActivityVeryIntense => 'Bardzo intensywna';

  @override
  String get onbActivityVeryIntenseDesc =>
      'Bardzo ciężka praca fizyczna lub treningi 2x dziennie';

  @override
  String get onbSaveAndStart => 'Zapisz i rozpocznij';

  @override
  String get onbGoalLose => 'Chcę schudnąć.';

  @override
  String get onbGoalGain => 'Chcę przybrać na wadze.';

  @override
  String get onbGoalMaintain => 'Chcę utrzymać obecną wagę.';

  @override
  String get onbGoalUnchangedSameWeight =>
      'Cel się nie zmienił. Waga docelowa nie różni się od aktualnej, więc plan jest na utrzymanie wagi.';

  @override
  String get onbErrorCreatingAccount => 'Błąd podczas tworzenia konta.';

  @override
  String get onbErrorNetworkPermission =>
      'Błąd uprawnień sieciowych.\n\nRozwiązanie:\n1. Zatrzymaj aplikację\n2. Uruchom ponownie: flutter run\n3. Jeśli problem nadal występuje, sprawdź czy anonimowa autoryzacja jest włączona w Supabase';

  @override
  String get onbErrorAnonymousDisabled =>
      'Anonimowa autoryzacja nie jest włączona w Supabase.\n\nPrzejdź do: Authentication → Providers → Anonymous → Enable';

  @override
  String get onbErrorInternet =>
      'Błąd połączenia z internetem.\nSprawdź połączenie i spróbuj ponownie.';

  @override
  String get onbErrorInternetShort =>
      'Błąd połączenia z internetem. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get onbErrorSupabaseConfig =>
      'Błąd konfiguracji Supabase.\nSprawdź klucze API w pliku .env';

  @override
  String onbErrorWithDetails({required String details}) {
    return 'Błąd: $details';
  }

  @override
  String get onbErrorSaving => 'Błąd podczas zapisywania';

  @override
  String get onbErrorAuth => 'Błąd autoryzacji. Sprawdź konfigurację Supabase.';

  @override
  String get moreStatisticsTitle => 'Statystyki';

  @override
  String get moreStreaksTooltip => 'Serie';

  @override
  String get moreWeeklySummary => 'Tygodniowe podsumowanie';

  @override
  String get moreShareTooltip => 'Udostępnij';

  @override
  String get moreShareWeeklyStatsFeature =>
      'Udostępnianie tygodniowych statystyk';

  @override
  String get moreShareWeeklySummaryText =>
      '📊 Łatwa Forma – Tygodniowe podsumowanie';

  @override
  String moreShareError({required String error}) {
    return 'Błąd udostępniania: $error';
  }

  @override
  String get moreAvgDailyCalories => 'Średnie dzienne kalorie';

  @override
  String get moreTotalCaloriesWeek => 'Całkowite kalorie (tydzień)';

  @override
  String get moreBurnedCaloriesWeek => 'Spalone kalorie (tydzień)';

  @override
  String get moreWaterWeek => 'Woda (tydzień)';

  @override
  String get moreCaloriesDuringWeek => 'Kalorie w ciągu tygodnia';

  @override
  String get moreMacrosWeek => 'Makro (tydzień)';

  @override
  String get moreProtein => 'Białko';

  @override
  String get moreFat => 'Tłuszcze';

  @override
  String get moreCarbs => 'Węgle';

  @override
  String get moreCarbsFull => 'Węglowodany';

  @override
  String get moreGoalVerification => 'Weryfikacja celu';

  @override
  String get moreGoalVerificationHint =>
      'Wprowadzaj posiłki i wagę codziennie przez tydzień. Aplikacja zweryfikuje Twój cel i zaproponuje poprawki, jeśli Twoje realne zapotrzebowanie różni się od kalkulatora.';

  @override
  String moreProgressDaysWithData({required int days}) {
    return 'Postęp: $days/7 dni z danymi';
  }

  @override
  String get moreBasedOnLast7Days => 'Na podstawie ostatnich 7 dni:';

  @override
  String moreAvgCaloriesPerDayBullet({required String calories}) {
    return '• Średnio: ~$calories kcal/dzień';
  }

  @override
  String get moreWeightStable => 'stała';

  @override
  String moreWeightIncrease({required String kg}) {
    return 'wzrost (+$kg kg)';
  }

  @override
  String moreWeightDecrease({required String kg}) {
    return 'spadek ($kg kg)';
  }

  @override
  String moreWeightBullet({required String change}) {
    return '• Waga: $change';
  }

  @override
  String get moreSaving => 'Zapisywanie…';

  @override
  String get moreApplyCorrectedGoal => 'Wprowadź poprawiony cel';

  @override
  String get moreGoalAligned =>
      'Masz wystarczająco danych. Twój obecny cel jest zgodny z trendem – nie ma potrzeby korekty.';

  @override
  String moreRealTdee({required String calories}) {
    return 'Realne zapotrzebowanie: ~$calories kcal';
  }

  @override
  String moreGoalUpdated({required String calories}) {
    return 'Cel zaktualizowany do ~$calories kcal';
  }

  @override
  String moreErrorWithDetails({required String error}) {
    return 'Błąd: $error';
  }

  @override
  String get moreGoalHistoryReason =>
      'Weryfikacja na podstawie danych z ostatniego tygodnia';

  @override
  String get moreDayMon => 'Pon';

  @override
  String get moreDayTue => 'Wt';

  @override
  String get moreDayWed => 'Śr';

  @override
  String get moreDayThu => 'Czw';

  @override
  String get moreDayFri => 'Pt';

  @override
  String get moreDaySat => 'Sob';

  @override
  String get moreDaySun => 'Nie';

  @override
  String moreSuggestionWeightLossFlat({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'Waga stała przy ~$avg kcal. Twoje realne zapotrzebowanie to ~$real kcal. Chcesz schudnąć? Spróbuj ~$corr kcal.';
  }

  @override
  String moreSuggestionWeightLossDown({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'Chudniesz przy ~$avg kcal. Realne TDEE: ~$real kcal. Sugerowany cel: ~$corr kcal.';
  }

  @override
  String moreSuggestionWeightGainFlat({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'Waga stała przy ~$avg kcal. Twoje realne zapotrzebowanie to ~$real kcal. Chcesz przytyć? Spróbuj ~$corr kcal.';
  }

  @override
  String moreSuggestionWeightGainUp({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'Tyjesz przy ~$avg kcal. Realne TDEE: ~$real kcal. Sugerowany cel: ~$corr kcal.';
  }

  @override
  String moreSuggestionMaintain({
    required String real,
    required String calc,
    required String corr,
  }) {
    return 'Realne zapotrzebowanie: ~$real kcal (kalkulator: $calc kcal). Cel: ~$corr kcal.';
  }

  @override
  String get moreBmiCalculatorTitle => 'Kalkulator BMI';

  @override
  String get moreYourBmi => 'Twoje BMI';

  @override
  String get moreCalculatedBasedOn => 'Obliczono na podstawie:';

  @override
  String moreCurrentWeightBullet({required String weight}) {
    return '• Aktualna waga: $weight kg';
  }

  @override
  String moreHeightBullet({required String height}) {
    return '• Wzrost: $height cm';
  }

  @override
  String moreNormalBmiRangeHint({
    required String minKg,
    required String maxKg,
  }) {
    return 'Aby być w normie (BMI 18,5–24,9), dąż do wagi w przedziale od $minKg do $maxKg kg.';
  }

  @override
  String get moreCompleteProfileForBmi =>
      'Uzupełnij profil (waga i wzrost), aby zobaczyć swoje BMI';

  @override
  String get moreBmiScale => 'Skala BMI';

  @override
  String get moreBmiUnderweight => 'Niedowaga';

  @override
  String get moreBmiNormal => 'Normalna';

  @override
  String get moreBmiOverweight => 'Nadwaga';

  @override
  String get moreBmiObesity1 => 'Otyłość I stopnia';

  @override
  String get moreBmiObesity2 => 'Otyłość II stopnia';

  @override
  String get moreBmiObesity3 => 'Otyłość III stopnia';

  @override
  String get moreBmiFormulaTitle => 'Wzór BMI';

  @override
  String get moreBmiFormula => 'BMI = waga (kg) / wzrost (m)²';

  @override
  String get moreBmiExplanation =>
      'BMI to wskaźnik masy ciała, który pomaga ocenić, czy waga jest odpowiednia do wzrostu.';

  @override
  String get moreExportTitle => 'Eksport danych';

  @override
  String get moreExportDescription =>
      'Wyeksportuj dane do pliku CSV (pełna lista) lub PDF (raport z ostatnich 30 dni). Otworzy się okno udostępniania.';

  @override
  String get moreExporting => 'Eksportowanie...';

  @override
  String get moreExportToCsv => 'Eksportuj do CSV';

  @override
  String get moreExportToPdfPremium => 'Eksportuj do PDF (Premium)';

  @override
  String get moreExportPdfFeature => 'Eksport do PDF';

  @override
  String get moreUserNotLoggedIn => 'Użytkownik nie jest zalogowany';

  @override
  String get moreCsvCopiedClipboard =>
      'Dane skopiowane do schowka. Wklej do Notatnika lub Excela i zapisz jako .csv';

  @override
  String get moreCsvFileReady =>
      'Plik CSV gotowy. Możesz go zapisać lub udostępnić.';

  @override
  String get moreCsvClipboardFallback =>
      'Dane wyeksportowane do schowka (CSV). Wklej je np. do Notatek i zapisz jako plik .csv';

  @override
  String get moreCsvClipboardShort => 'Dane wyeksportowane do schowka (CSV).';

  @override
  String get moreExportFailed =>
      'Nie udało się wyeksportować. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get moreExportShareText => 'Eksport danych Łatwa Forma';

  @override
  String moreExportShareSubject({required String date}) {
    return 'Dane Łatwa Forma - $date';
  }

  @override
  String get morePdfReportShareText => 'Raport Łatwa Forma';

  @override
  String morePdfReportShareSubject({required String date}) {
    return 'Raport Łatwa Forma - $date';
  }

  @override
  String get morePdfDownloaded => 'PDF został pobrany. Sprawdź folder Pobrane.';

  @override
  String get morePdfShareOrDownloadFailed =>
      'Nie udało się udostępnić ani pobrać PDF. Spróbuj w przeglądarce Chrome lub wyeksportuj do CSV.';

  @override
  String get morePdfShareFailed =>
      'Nie udało się udostępnić PDF. Spróbuj wyeksportować do CSV.';

  @override
  String get morePdfFileReady =>
      'Plik PDF gotowy. Możesz go zapisać lub udostępnić.';

  @override
  String morePdfExportFailedWithHint({required String hint}) {
    return 'Eksport PDF nie powiódł się ($hint). Spróbuj do CSV.';
  }

  @override
  String get morePdfExportFailed =>
      'Eksport PDF nie powiódł się. Spróbuj ponownie lub wyeksportuj do CSV.';

  @override
  String get moreCsvSectionProfile => '=== PROFIL ===';

  @override
  String get moreCsvHeaderTypeNameValue => 'Typ,Nazwa,Wartość';

  @override
  String get moreCsvProfile => 'Profil';

  @override
  String get moreCsvGender => 'Płeć';

  @override
  String get moreGenderMale => 'Mężczyzna';

  @override
  String get moreGenderFemale => 'Kobieta';

  @override
  String get moreGenderOther => 'Inna';

  @override
  String get moreCsvAge => 'Wiek';

  @override
  String moreCsvAgeYears({required String age}) {
    return '$age lat';
  }

  @override
  String get moreCsvHeight => 'Wzrost';

  @override
  String get moreCsvCurrentWeight => 'Aktualna waga';

  @override
  String get moreCsvTargetWeight => 'Waga docelowa';

  @override
  String get moreCsvGoal => 'Cel';

  @override
  String get moreGoalWeightLoss => 'Utrata wagi';

  @override
  String get moreGoalWeightGain => 'Przybranie wagi';

  @override
  String get moreGoalMaintain => 'Utrzymanie';

  @override
  String get moreGoalMaintainWeight => 'Utrzymanie wagi';

  @override
  String get moreCsvCalorieGoal => 'Cel kaloryczny';

  @override
  String get moreCsvProteinG => 'Białko (g)';

  @override
  String get moreCsvFatG => 'Tłuszcze (g)';

  @override
  String get moreCsvCarbsG => 'Węglowodany (g)';

  @override
  String get moreCsvTargetDate => 'Szacowany termin osiągnięcia celu';

  @override
  String get moreCsvSectionDiary => '=== DANE DZIENNIKA ===';

  @override
  String get moreCsvGarminNote =>
      '# Dane aktywności mogą obejmować dane z urządzeń Garmin.';

  @override
  String get moreCsvHeaderDiary => 'Typ,Nazwa,Wartość,Data,Źródło danych';

  @override
  String get moreCsvMeal => 'Posiłek';

  @override
  String get moreCsvActivity => 'Aktywność';

  @override
  String get moreCsvWeight => 'Waga';

  @override
  String get morePdfReportTitle => 'Łatwa Forma – Raport';

  @override
  String morePdfPageFooter({
    required String page,
    required String pages,
    required String date,
  }) {
    return 'Strona $page z $pages • Wygenerowano $date';
  }

  @override
  String get morePdfProfileSummary => 'Podsumowanie profilu';

  @override
  String morePdfProfileLine1({
    required String gender,
    required String age,
    required String height,
  }) {
    return 'Płeć: $gender • Wiek: $age lat • Wzrost: $height cm';
  }

  @override
  String morePdfProfileLine2({
    required String weight,
    required String target,
    required String calories,
  }) {
    return 'Waga: $weight kg • Cel: $target kg • Cel kaloryczny: $calories kcal';
  }

  @override
  String get morePdfGoalWeightLoss => 'Cel: Utrata wagi';

  @override
  String get morePdfGoalWeightGain => 'Cel: Przybranie wagi';

  @override
  String get morePdfGoalMaintain => 'Cel: Utrzymanie wagi';

  @override
  String get morePdfNoProfile => 'Brak profilu';

  @override
  String get morePdfMealsLast30 => 'Ostatnie 30 dni – posiłki';

  @override
  String get morePdfNoMeals => 'Brak posiłków';

  @override
  String get morePdfDate => 'Data';

  @override
  String get morePdfName => 'Nazwa';

  @override
  String get morePdfActivitiesLast30 => 'Ostatnie 30 dni – aktywności';

  @override
  String get morePdfNoActivities => 'Brak aktywności';

  @override
  String get morePdfGarminAttribution =>
      'Dane aktywności pochodzą z urządzeń Garmin.';

  @override
  String get morePdfWeightHistory => 'Historia wagi';

  @override
  String get morePdfNoMeasurements => 'Brak pomiarów';

  @override
  String get morePdfWeightKg => 'Waga (kg)';

  @override
  String get moreNotificationsTitle => 'Powiadomienia';

  @override
  String get moreWaterReminders => 'Przypomnienia o wodzie';

  @override
  String get moreMealReminders => 'Przypomnienia o posiłkach';

  @override
  String get moreAdd => 'Dodaj';

  @override
  String get moreMealBreakfast => 'Śniadanie';

  @override
  String get moreMealLunch => 'Obiad';

  @override
  String get moreMealDinner => 'Kolacja';

  @override
  String get moreMealSnack => 'Przekąska';

  @override
  String get moreMealDefault => 'Posiłek';

  @override
  String get moreNewMealReminder => 'Nowe przypomnienie o posiłku';

  @override
  String get moreMealNameLabel => 'Nazwa posiłku';

  @override
  String get moreMealNameHint => 'np. Drugie śniadanie, Podwieczorek';

  @override
  String get moreEditReminder => 'Edytuj przypomnienie';

  @override
  String get moreNotifWaterTitle => 'Pamiętaj o wodzie! 💧';

  @override
  String get moreNotifWaterBody => 'Czas na szklankę wody';

  @override
  String get moreNotifWaterChannel => 'Przypomnienia o wodzie';

  @override
  String get moreNotifWaterChannelDesc => 'Przypomnienia o piciu wody';

  @override
  String moreNotifMealTitle({required String label}) {
    return 'Czas na $label! 🍽️';
  }

  @override
  String get moreNotifMealBody => 'Nie zapomnij zarejestrować posiłku';

  @override
  String get moreNotifMealChannel => 'Przypomnienia o posiłkach';

  @override
  String get moreNotifMealChannelDesc => 'Przypomnienia o rejestracji posiłków';

  @override
  String get moreIntegrationsTitle => 'Integracje';

  @override
  String get moreLoginToFinishStrava =>
      'Zaloguj się, aby dokończyć połączenie ze Strava';

  @override
  String get moreLoginToFinishGarmin =>
      'Zaloguj się, aby dokończyć połączenie z Garmin';

  @override
  String moreStravaConnectedImported({required int count}) {
    return 'Strava połączona. Zaimportowano $count aktywności.';
  }

  @override
  String get moreStravaConnectedNoNew =>
      'Strava połączona. Brak nowych aktywności do importu.';

  @override
  String get moreStravaConnectedSuccess => 'Strava połączona pomyślnie';

  @override
  String get moreStravaSyncFailedLater =>
      'Synchronizacja nie powiodła się. Kliknij „Synchronizuj aktywności” później.';

  @override
  String get moreGarminSessionExpiredRetry =>
      'Sesja wygasła. Spróbuj ponownie połączyć Garmin.';

  @override
  String moreGarminSessionRejected({required String message}) {
    return 'Sesja odrzucona: $message. Wyloguj się, zaloguj ponownie i spróbuj połączyć Garmin.';
  }

  @override
  String get moreGarminSessionExpiredRelogin =>
      'Sesja wygasła. Wyloguj się i zaloguj ponownie do Łatwej Formy, potem kliknij „Połącz z Garmin Connect”.';

  @override
  String get moreConnectedSuccessfully => 'Połączono pomyślnie!';

  @override
  String get moreGarminSessionExpiredShort =>
      'Sesja wygasła. Wyloguj się i zaloguj ponownie, potem połącz Garmin.';

  @override
  String moreGarminError({required String error}) {
    return 'Błąd Garmin: $error';
  }

  @override
  String get moreStravaEnvMissing =>
      'Dodaj STRAVA_CLIENT_ID i STRAVA_CLIENT_SECRET do pliku .env';

  @override
  String get moreGarminEnvMissing =>
      'Dodaj GARMIN_CLIENT_ID do env (po zatwierdzeniu programu).';

  @override
  String get moreLoginAgainForGarmin =>
      'Zaloguj się ponownie, aby uzupełnić dane Garmin.';

  @override
  String moreCouldNotComplete({required String message}) {
    return 'Nie udało się: $message';
  }

  @override
  String get moreGarminNoUserId =>
      'Garmin nie zwrócił User ID. Spróbuj odłączyć i połączyć ponownie.';

  @override
  String get moreGarminReceiveDataSaved =>
      'Dane do odbierania aktywności zapisane. Nowe treningi z Garmin Connect będą się pojawiać w aplikacji.';

  @override
  String moreGarminDisconnectFailed({required String error}) {
    return 'Nie udało się wywołać odłączenia u Garmin: $error';
  }

  @override
  String get moreGarminDisconnectedTitle => 'Garmin Connect odłączony';

  @override
  String get moreGarminDisconnectedBody =>
      'Połączenie z Garmin Connect zostało usunięte. Nowe aktywności nie będą już dodawane automatycznie. Możesz połączyć ponownie w dowolnym momencie.';

  @override
  String get moreStravaDisconnected => 'Strava odłączona';

  @override
  String get moreConnectStravaFirst => 'Najpierw połącz konto Strava';

  @override
  String moreImportedFromStrava({required int count}) {
    return 'Zaimportowano $count aktywności ze Strava';
  }

  @override
  String get moreNoNewActivities => 'Brak nowych aktywności do importu';

  @override
  String moreSyncError({required String error}) {
    return 'Błąd synchronizacji: $error';
  }

  @override
  String get moreStravaImportDesc =>
      'Importuj wszystkie aktywności i spalone kalorie';

  @override
  String get moreConnected => 'Połączona';

  @override
  String get moreSyncing => 'Synchronizuję...';

  @override
  String get moreSyncActivities => 'Synchronizuj aktywności';

  @override
  String get moreDisconnectStrava => 'Odłącz Strava';

  @override
  String get moreConnecting => 'Łączę...';

  @override
  String get moreConnectStrava => 'Połącz ze Strava';

  @override
  String get moreGarminImportDesc =>
      'Aktywności z Garmin dodawane automatycznie po synchronizacji z Garmin Connect';

  @override
  String get moreGarminAutoImportInfo =>
      'Wszystkie nowe aktywności z Garmin Connect są importowane do aplikacji. To Ty decydujesz, którą wliczyć do bilansu.';

  @override
  String get moreGarminNeedUserId =>
      'Żeby aktywności z Garmin pojawiały się w aplikacji, zapisz dane połączenia (ID Garmin).';

  @override
  String get moreSavingShort => 'Zapisuję...';

  @override
  String get moreCompleteActivityReceiveData =>
      'Uzupełnij dane do odbierania aktywności';

  @override
  String get moreDisconnectGarmin => 'Odłącz Garmin';

  @override
  String get moreConnectGarmin => 'Połącz z Garmin Connect';

  @override
  String moreGarminDisconnectErrorStatus({required String status}) {
    return 'Błąd odłączania: $status';
  }

  @override
  String moreErrorStatusCode({required String code}) {
    return 'Błąd $code';
  }

  @override
  String get moreChallengesTitle => 'Cele i wyzwania';

  @override
  String get moreNoChallenges => 'Brak celów i wyzwań';

  @override
  String get moreNoChallengesHint =>
      'Dodaj cel lub wyzwanie, aby śledzić swoje postępy';

  @override
  String moreProgressPercent({required String percent}) {
    return 'Postęp: $percent%';
  }

  @override
  String moreStartDate({required String date}) {
    return 'Start: $date';
  }

  @override
  String moreEndDate({required String date}) {
    return 'Koniec: $date';
  }

  @override
  String get moreDeleteChallengeTitle => 'Usuń wyzwanie';

  @override
  String moreDeleteChallengeConfirm({required String title}) {
    return 'Czy na pewno chcesz usunąć \"$title\"?';
  }

  @override
  String get moreChallengeDeleted => 'Wyzwanie usunięte';

  @override
  String get morePickStartDate => 'Wybierz datę rozpoczęcia';

  @override
  String get morePickEndDate => 'Wybierz datę zakończenia';

  @override
  String get morePick => 'Wybierz';

  @override
  String get moreChallengeAdded => 'Wyzwanie dodane pomyślnie!';

  @override
  String get moreTargetWeightKg => 'Cel wagi (kg)';

  @override
  String get moreCalorieDeficitKcal => 'Deficyt kaloryczny (kcal)';

  @override
  String get moreWaterAmountMl => 'Ilość wody (ml)';

  @override
  String get moreWorkoutCount => 'Liczba treningów';

  @override
  String get moreStreakLengthDays => 'Długość serii (dni)';

  @override
  String get moreTargetValue => 'Wartość docelowa';

  @override
  String get moreAddChallenge => 'Dodaj wyzwanie';

  @override
  String get moreChallengeType => 'Typ wyzwania';

  @override
  String get moreCalorieDeficit => 'Deficyt kaloryczny';

  @override
  String get moreWater => 'Woda';

  @override
  String get moreExercise => 'Ćwiczenia';

  @override
  String get moreStreak => 'Seria';

  @override
  String get moreChallengeTitleLabel => 'Tytuł wyzwania';

  @override
  String get moreChallengeTitleHint => 'np. Schudnij 5 kg';

  @override
  String get moreChallengeTitleRequired => 'Podaj tytuł wyzwania';

  @override
  String get moreDescriptionOptional => 'Opis (opcjonalnie)';

  @override
  String get moreChallengeDescHint => 'Dodatkowe informacje o wyzwaniu';

  @override
  String get moreOptional => 'Opcjonalnie';

  @override
  String get moreStartDateLabel => 'Data rozpoczęcia';

  @override
  String get moreSetEndDate => 'Ustaw datę zakończenia';

  @override
  String get moreEndDateLabel => 'Data zakończenia';

  @override
  String get morePickDate => 'Wybierz datę';

  @override
  String get moreStreaksTitle => 'Serie';

  @override
  String get moreNoStreaks => 'Brak serii';

  @override
  String get moreNoStreaksHint =>
      'Zacznij śledzić swoje nawyki, aby zobaczyć serie';

  @override
  String moreLastTime({required String date}) {
    return 'Ostatni raz: $date';
  }

  @override
  String get moreCurrentStreak => 'Aktualna seria';

  @override
  String get moreLongestStreak => 'Najdłuższa seria';

  @override
  String get moreStreakMeals => 'Posiłki';

  @override
  String get moreStreakActivities => 'Aktywności';

  @override
  String get moreStreakWeight => 'Waga';

  @override
  String get moreAiAdviceTitle => 'Porada AI';

  @override
  String moreAiLimitReachedPremium({required String limit}) {
    return 'Wykorzystałeś dzisiejszy limit ($limit zapytań). Spróbuj jutro.';
  }

  @override
  String moreAiLimitReachedFree({required String limit}) {
    return 'Wykorzystałeś dzisiejszy limit ($limit zapytań). Spróbuj jutro lub przejdź na Premium.';
  }

  @override
  String get moreAiNeedsConnection =>
      'Porada AI wymaga połączenia z aplikacją (Supabase) lub klucza OpenAI w konfiguracji.';

  @override
  String get moreAiNoResponse =>
      'Nie udało się uzyskać odpowiedzi. Spróbuj ponownie.';

  @override
  String moreAiRemainingToday({
    required String remaining,
    required String limit,
  }) {
    return 'Pozostało zapytań dziś: $remaining / $limit';
  }

  @override
  String moreAiRemainingTodayPremium({
    required String remaining,
    required String limit,
  }) {
    return 'Pozostało zapytań dziś: $remaining / $limit (Premium)';
  }

  @override
  String get moreAiIntro =>
      'Zapytaj o poradę w zakresie diety, odżywiania lub aktywności fizycznej. Odpowiedź generuje AI i nie zastępuje konsultacji z lekarzem.';

  @override
  String get moreAiHint => 'np. Ile białka potrzebuję przy treningu siłowym?';

  @override
  String get moreAiAnswer => 'Odpowiedź';

  @override
  String get profErrNetwork =>
      'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.';

  @override
  String get profErrCors =>
      'Błąd połączenia z usługą. Odśwież stronę i spróbuj ponownie.';

  @override
  String get profErrTimeout => 'Przekroczono limit czasu. Spróbuj ponownie.';

  @override
  String get profErrAuth => 'Błąd autoryzacji. Zaloguj się ponownie.';

  @override
  String get profErrNotFound => 'Nie znaleziono zasobu.';

  @override
  String get profErrServer => 'Błąd serwera. Spróbuj później.';

  @override
  String get profErrGeneric => 'Wystąpił błąd. Spróbuj ponownie.';

  @override
  String get profOfflineBanner => 'Brak połączenia z internetem.';

  @override
  String get premFeatureTitle => 'Funkcja Premium';

  @override
  String premFeatureDialog({required String feature}) {
    return '$feature jest dostępna w planie Premium. Czy chcesz dowiedzieć się więcej?';
  }

  @override
  String get premFeatureThis => 'Ta funkcja';

  @override
  String get premSeePremium => 'Zobacz Premium';

  @override
  String premLockedTitle({required String feature}) {
    return '$feature jest w Premium';
  }

  @override
  String get premLockedBody =>
      'Odblokuj nieograniczoną poradę AI, eksport PDF i więcej.';

  @override
  String get premCheckPremium => 'Sprawdź Premium';

  @override
  String get premThanks => 'Dziękujemy!';

  @override
  String get premActivatedBody =>
      'Premium zostało aktywowane.\nCiesz się pełnym dostępem do Łatwa Forma – eksport PDF, porady AI, integracje i więcej.';

  @override
  String get premBackToApp => 'Wróć do aplikacji';

  @override
  String get premCloseTabHint =>
      'Możesz też zamknąć tę kartę, jeśli płatność była w osobnym oknie.';

  @override
  String get premPaymentCancelled => 'Płatność anulowana';

  @override
  String get premCancelBody =>
      'Nic nie zostało pobrane. Możesz wrócić i wybrać plan, kiedy będziesz gotowy.';

  @override
  String get premBackToPlans => 'Wróć do planów Premium';

  @override
  String get premGoToApp => 'Przejdź do aplikacji';

  @override
  String get premTitle => 'Łatwa Forma Premium';

  @override
  String get premHavePremium => 'Masz Premium!';

  @override
  String get premUnlockPotential => 'Odblokuj pełny potencjał';

  @override
  String get premAllFeaturesAvailable =>
      'Wszystkie funkcje premium są dla Ciebie dostępne.';

  @override
  String premValidUntil({required String date}) {
    return 'Ważne do: $date';
  }

  @override
  String get premTrialTitle => 'Okres próbny (24 h)';

  @override
  String premTrialLeft({required int hours, required int minutes}) {
    return 'Pozostało: ${hours}h ${minutes}min. ';
  }

  @override
  String premTrialBody({required String remaining}) {
    return 'Wszystkie funkcje premium są teraz dostępne. ${remaining}Po tym czasie funkcje Premium się wyłączą, dopóki nie wykupisz planu. Okres próbny nie pobiera opłaty i nie zapisuje Cię automatycznie na subskrypcję.';
  }

  @override
  String get premFeatHistoryOtherDays =>
      'Przeglądanie historii innych dni niż dziś';

  @override
  String get premFeatMacrosDash => 'Podgląd makroskładników na dashboardzie';

  @override
  String get premFeatAiAdvice => 'Porada AI (limit 100 dziennie)';

  @override
  String get premFeatAiPhoto => 'Analiza AI posiłku ze zdjęcia';

  @override
  String get premFeatIngredients => 'Dodawanie posiłku ze składników';

  @override
  String get premFeatEatingOut => 'Dodawanie posiłku „na mieście”';

  @override
  String get premFeatQuickActivity => 'Szybkie dodawanie w aktywnościach';

  @override
  String get premFeatShare =>
      'Udostępnianie podsumowania i tygodniowych statystyk';

  @override
  String get premFeatPdf => 'Eksport raportów do PDF';

  @override
  String get premFeatCustomCalories => 'Własny cel kaloryczny w edycji profilu';

  @override
  String get premFeatCustomMacros => 'Własne makroskładniki w edycji profilu';

  @override
  String get premFeatStrava => 'Integracje Strava bez limitów';

  @override
  String get premFeatGoals => 'Zaawansowane cele i wyzwania';

  @override
  String get premChoosePlan => 'Wybierz plan';

  @override
  String get premPlanMonthly => 'Łatwa Forma Premium – miesięcznie';

  @override
  String get premPlanMonthlyPeriod => '1 miesiąc, auto-odnawiane';

  @override
  String get premPlanYearly => 'Łatwa Forma Premium – rocznie';

  @override
  String get premPlanYearlyPeriod => '12 miesięcy, auto-odnawiane';

  @override
  String get premBadgeSave => 'Oszczędzasz ~17%';

  @override
  String get premPlanYearlyOnce => 'Rocznie (jednorazowo)';

  @override
  String get premPlanYearlyOncePeriod => 'za rok';

  @override
  String get premBadgeBlik => 'Tylko BLIK';

  @override
  String get premYearlyOnceSubtitle => 'płatność raz na rok, bez subskrypcji';

  @override
  String get premHaveCode => 'Mam kod';

  @override
  String get premCodeLabel => 'Kod';

  @override
  String get premRedeemTooltip => 'Zrealizuj';

  @override
  String get premOpeningPayment => 'Otwieram płatność…';

  @override
  String get premProcessingPurchase => 'Przetwarzam zakup…';

  @override
  String get premBuy => 'Wykup Premium';

  @override
  String get premRestoring => 'Przywracam…';

  @override
  String get premRestorePurchases => 'Przywróć zakupy';

  @override
  String get premPaymentNoteWeb =>
      'Rocznie (jednorazowo) – tylko BLIK. Subskrypcja – karta, Apple Pay, Google Pay. Subskrypcja odnawia się automatycznie, dopóki jej nie anulujesz.';

  @override
  String get premPaymentNoteMobile =>
      'Płatność przez App Store / Google Play. „Łatwa Forma Premium – miesięcznie” (1 miesiąc) i „Łatwa Forma Premium – rocznie” (12 miesięcy) odnawiają się automatycznie za cenę pokazaną powyżej, aż anulujesz w ustawieniach sklepu. BLIK jest na latwaforma.pl. Podstawowe funkcje działają bez subskrypcji.';

  @override
  String get premAutoActivate =>
      'Po opłaceniu konto Premium aktywuje się automatycznie.';

  @override
  String get premPrivacy => 'Polityka prywatności';

  @override
  String get premTerms => 'Regulamin';

  @override
  String get premEula => 'Terms of Use (EULA)';

  @override
  String get premActivating => 'Aktywuję…';

  @override
  String get premActivateTest => 'Aktywuj Premium (test)';

  @override
  String get premAvailableFeatures => 'Dostępne funkcje:';

  @override
  String get premFeatActiveHistory => 'Historia innych dni';

  @override
  String get premFeatActiveMacros => 'Makro na dashboardzie';

  @override
  String get premFeatActiveAiPhoto => 'Analiza AI posiłku';

  @override
  String get premFeatActiveIngredients => 'Posiłek ze składników';

  @override
  String get premFeatActiveEatingOut => 'Posiłek „na mieście”';

  @override
  String get premFeatActiveQuickActivity => 'Szybkie dodawanie aktywności';

  @override
  String get premFeatActiveShare => 'Udostępnianie podsumowania i statystyk';

  @override
  String get premFeatActivePdf => 'Eksport do PDF';

  @override
  String get premFeatActiveCalories => 'Własny cel kaloryczny';

  @override
  String get premFeatActiveMacrosCustom => 'Własne makroskładniki';

  @override
  String get premFeatActiveStrava => 'Integracje Strava';

  @override
  String get premFeatActiveGoals => 'Zaawansowane cele';

  @override
  String get premOpening => 'Otwieram…';

  @override
  String get premCancelSub => 'Anuluj subskrypcję';

  @override
  String get premManageSub => 'Zarządzaj subskrypcją';

  @override
  String get premCancelNoteWeb =>
      'Możesz anulować subskrypcję. Dostęp do Premium pozostanie do końca opłaconego okresu.';

  @override
  String get premCancelNoteMobile =>
      'Anulowanie w ustawieniach App Store / Google Play. Dostęp Premium do końca opłaconego okresu.';

  @override
  String get premEnterEmail => 'Podaj adres e-mail.';

  @override
  String get premCodeSent => 'Kod wysłany';

  @override
  String premCodeSentBody({required String email}) {
    return 'Wysłaliśmy link i kod na $email. Sprawdź skrzynkę (także folder Spam) – kliknij link w mailu albo wpisz kod poniżej.';
  }

  @override
  String get premSignedIn => 'Zalogowano';

  @override
  String get premSignedInBuy => 'Możesz teraz wykupić Premium.';

  @override
  String get premAccountExistsTitle => 'Konto z tym adresem e-mail istnieje.';

  @override
  String get premAccountExistsBody =>
      'Próbujesz się zalogować na konto powiązane z tym adresem e-mail. Na tym urządzeniu masz inne dane (profil, posiłki itd.).\n\nCo chcesz zrobić?\n\n• Zaktualizować tamto konto – obecnymi danymi z tego urządzenia (profil, posiłki zostaną przeniesione).\n\n• Przywrócić dane konta – zobaczysz dane przypisane do konta z tym e-mailem (obecne dane z urządzenia nie będą użyte).\n\nW obu przypadkach musisz potwierdzić tożsamość – kliknij link w mailu lub wpisz kod weryfikacyjny.';

  @override
  String get premRestoreAccountData => 'Przywróć dane konta';

  @override
  String get premUpdateWithCurrent => 'Zaktualizuj konto tymi danymi';

  @override
  String get premConfirmIdentity => 'Potwierdź tożsamość';

  @override
  String premVerifyEmailSent({required String email}) {
    return 'Wysłaliśmy wiadomość na $email. Możesz kliknąć link weryfikacyjny w mailu albo wpisać kod poniżej (sprawdź też folder Spam).';
  }

  @override
  String get premVerificationCode => 'Kod weryfikacyjny';

  @override
  String get premCodeHint => 'np. 123456';

  @override
  String get premEnterFullCode => 'Wpisz pełny kod z maila (min. 6 znaków).';

  @override
  String premLoggedInMergeError({required String error}) {
    return 'Zalogowano. Błąd przenoszenia danych: $error';
  }

  @override
  String get premVerifyErrorTitle => 'Błąd weryfikacji';

  @override
  String get premVerifyErrorBody =>
      'Kod wygasł lub jest nieprawidłowy. Wyślij ponownie.';

  @override
  String get premConfirm => 'Zatwierdź';

  @override
  String get premConnErrorTitle => 'Błąd połączenia';

  @override
  String get premConnErrorBody =>
      'Nie udało się połączyć z płatnościami. Spróbuj za chwilę lub napisz do nas: contact@latwaforma.pl';

  @override
  String get premLoginToBuy =>
      'Aby wykupić Premium, zaloguj się (Apple, Google albo e-mail z kodem powyżej).';

  @override
  String get premCodeNotForOnce =>
      'Ten kod nie działa przy płatności jednorazowej.';

  @override
  String get premTryLaterContact =>
      'Spróbuj za chwilę ponownie lub napisz do nas: contact@latwaforma.pl';

  @override
  String get premOpenPaymentFailed => 'Nie udało się otworzyć płatności';

  @override
  String get premCannotOpenPaymentPage =>
      'Nie można otworzyć strony płatności.';

  @override
  String get premCheckoutSessionError => 'Błąd tworzenia sesji płatności.';

  @override
  String get premTryLaterContactShort =>
      'Spróbuj za chwilę lub napisz do nas: contact@latwaforma.pl';

  @override
  String get premLoginToUseCode =>
      'Aby użyć kodu, zaloguj się (Apple, Google albo e-mail).';

  @override
  String get premCodeSheetFailed =>
      'Nie udało się otworzyć wpisywania kodu. Spróbuj ponownie.';

  @override
  String get premEnterCode => 'Wpisz kod.';

  @override
  String get premPlayStoreFailed => 'Nie udało się otworzyć Sklepu Play.';

  @override
  String get premLoginToBuyMobile =>
      'Aby wykupić Premium, zaloguj się (Google, Apple lub e-mail z kodem powyżej).';

  @override
  String get premThanksActive =>
      'Dziękujemy! Premium powinno być już aktywne. Jeśli funkcje są jeszcze zablokowane, odczekaj chwilę lub wróć do aplikacji.';

  @override
  String get premPurchasePending =>
      'Zakup zakończony. Status Premium odświeży się za chwilę. Jeśli nie – użyj „Przywróć zakupy”.';

  @override
  String get premInfo => 'Informacja';

  @override
  String get premPurchaseErrorTitle => 'Błąd zakupu';

  @override
  String premPurchaseErrorBody({required String error}) {
    return 'Nie udało się dokończyć zakupu. Sprawdź połączenie i konfigurację sklepu, albo napisz: contact@latwaforma.pl\n\n$error';
  }

  @override
  String get premLoginToRestore => 'Zaloguj się, aby przywrócić zakupy.';

  @override
  String get premRestoredTitle => 'Zakupy przywrócone';

  @override
  String get premNoPurchasesTitle => 'Brak aktywnych zakupów';

  @override
  String get premRestoredBody =>
      'Twoje Premium zostało przywrócone. Jeśli nie widzisz odblokowania, odczekaj chwilę.';

  @override
  String get premNoPurchasesBody =>
      'Nie znaleziono aktywnej subskrypcji powiązanej z tym kontem sklepu.';

  @override
  String premRestoreFailed({required String error}) {
    return 'Nie udało się przywrócić zakupów: $error';
  }

  @override
  String get premSubscription => 'Subskrypcja';

  @override
  String get premManageHint =>
      'Otwórz ustawienia subskrypcji w sklepie Apple / Google, aby anulować lub zarządzać Premium.';

  @override
  String get premSessionExpired => 'Sesja wygasła';

  @override
  String get premLoginAgain => 'Zaloguj się ponownie.';

  @override
  String get premPortalHintWeb =>
      'Odśwież stronę (F5) i spróbuj ponownie. Jeśli problem się powtarza, wyloguj się i zaloguj ponownie.';

  @override
  String get premPortalHintMobile =>
      'Wyloguj się w profilu i zaloguj ponownie, potem spróbuj „Anuluj subskrypcję” jeszcze raz.';

  @override
  String get premCannotOpenPortal => 'Nie można otworzyć portalu.';

  @override
  String get premPortalOpenError => 'Błąd otwierania portalu.';

  @override
  String get premSessionExpiredCancel =>
      'Sesja wygasła. Wyloguj się w profilu i zaloguj ponownie, potem spróbuj „Anuluj subskrypcję” jeszcze raz.';

  @override
  String premErrorWithDetail({required String error}) {
    return 'Błąd: $error';
  }

  @override
  String get premActivatedEnjoy =>
      'Premium aktywowane. Ciesz się pełnym dostępem!';

  @override
  String get premLoginToBuyCard =>
      'Aby wykupić Premium, potrzebne jest konto. Zaloguj się przez Google, Apple albo podaj adres e-mail – wyślemy wiadomość z linkiem weryfikacyjnym i kodem.';

  @override
  String get premSigningIn => 'Logowanie…';

  @override
  String get premContinueGoogle => 'Kontynuuj z Google';

  @override
  String get premContinueApple => 'Kontynuuj z Apple';

  @override
  String get premOrEmail => 'lub e-mail:';

  @override
  String get premEmailLabel => 'Adres e-mail';

  @override
  String get premEmailHint => 'np. jan@example.com';

  @override
  String get premSending => 'Wysyłam…';

  @override
  String get premSendCode => 'Wyślij kod';

  @override
  String get premConfirmIdentityHint =>
      'Potwierdź tożsamość: wpisz poniżej kod z maila albo kliknij link weryfikacyjny w wiadomości (sprawdź też folder Spam).';

  @override
  String get premChecking => 'Sprawdzam…';

  @override
  String get premConfirmAndSignIn => 'Zatwierdź i zaloguj';

  @override
  String get premResendOtherEmail => 'Wyślij kod ponownie na inny adres';

  @override
  String get profTitle => 'Profil';

  @override
  String get profNotifications => 'Powiadomienia';

  @override
  String get profNoProfile => 'Brak profilu';

  @override
  String profErrorWithDetail({required String error}) {
    return 'Błąd: $error';
  }

  @override
  String get profAccountGoogle => 'Konto Google';

  @override
  String get profAccountEmail => 'Konto e-mail';

  @override
  String get profAccountSignedIn => 'Konto zalogowane';

  @override
  String get profSignOutTitle => 'Wyloguj się';

  @override
  String get profSignOutBody =>
      'Czy na pewno chcesz się wylogować? Możesz ponownie zalogować się później.';

  @override
  String get profSignOutConfirm => 'Wyloguj';

  @override
  String get profDeleteAccountTitle => 'Usuń konto';

  @override
  String get profDeleteAccountBody =>
      'Twoje dane zostaną całkowicie usunięte i nie będzie można ich przywrócić. Gdy wrócisz do aplikacji, trzeba będzie uzupełnić profil od nowa.\n\nJeśli masz subskrypcję Premium w Google Play lub App Store, anuluj ją osobno w sklepie – usunięcie konta jej nie kończy.\n\nCzy na pewno chcesz usunąć konto?';

  @override
  String get profAccountDeleted => 'Konto zostało usunięte';

  @override
  String profDeleteUnavailable({required String email}) {
    return 'Usługa usuwania konta jest niedostępna. Skontaktuj się z nami: $email';
  }

  @override
  String get profSessionExpiredRetry =>
      'Sesja wygasła. Zaloguj się ponownie i spróbuj jeszcze raz.';

  @override
  String get profNoPermission => 'Brak uprawnień do wykonania tej operacji.';

  @override
  String get profDeleteFailed =>
      'Nie udało się usunąć konta. Spróbuj ponownie później.';

  @override
  String get profInviteTitle => 'Zaproś znajomego';

  @override
  String get profInviteBody =>
      'Podaj adres e-mail osoby, której chcesz wysłać zaproszenie do Łatwa Forma.';

  @override
  String get profEmailLabel => 'Adres e-mail';

  @override
  String get profEmailHintFriend => 'np. znajomy@example.com';

  @override
  String get profSessionExpiredWebInvite =>
      'Sesja wygasła. Odśwież stronę (F5) i zaloguj się ponownie, potem wyślij zaproszenie.';

  @override
  String get profLoginAgainRetry =>
      'Zaloguj się ponownie i spróbuj jeszcze raz.';

  @override
  String get profInviteSent => 'Zaproszenie wysłane';

  @override
  String get profSessionExpiredWebRetry =>
      'Sesja wygasła. Odśwież stronę (F5) i spróbuj ponownie. Jeśli problem się powtarza, wyloguj się i zaloguj ponownie.';

  @override
  String get profSessionExpiredInviteMobile =>
      'Sesja wygasła. Wyloguj się i zaloguj ponownie, potem wyślij zaproszenie.';

  @override
  String get profInviteAlreadySent =>
      'Na ten adres wysłano już zaproszenie. Sprawdź skrzynkę (w tym spam) lub podaj inny adres.';

  @override
  String get profEmailAlreadyRegistered =>
      'Ten adres e-mail jest już zarejestrowany w Łatwa Forma. Zaproś kogoś innego.';

  @override
  String get profInviteRateLimit =>
      'Zbyt wiele zaproszeń. Poczekaj chwilę i spróbuj ponownie.';

  @override
  String get profEnterValidEmail => 'Podaj prawidłowy adres e-mail.';

  @override
  String get profInviteSendFailed =>
      'Nie udało się wysłać zaproszenia. Spróbuj ponownie.';

  @override
  String get profSessionExpiredWebShort =>
      'Sesja wygasła. Odśwież stronę (F5) i spróbuj ponownie.';

  @override
  String get profSessionExpiredSignOutIn =>
      'Sesja wygasła. Wyloguj się i zaloguj ponownie.';

  @override
  String get profSendInvite => 'Wyślij zaproszenie';

  @override
  String get profInviteSentExclaim => 'Zaproszenie wysłane!';

  @override
  String get profSaveProgress => 'Zapisz postępy';

  @override
  String get profSaveProgressHint =>
      'Zaloguj się przez Apple, Google albo e-mail, aby nie stracić danych';

  @override
  String get profBasicData => 'Dane podstawowe';

  @override
  String get profGender => 'Płeć';

  @override
  String get profAge => 'Wiek';

  @override
  String profAgeYears({required int age}) {
    return '$age lat';
  }

  @override
  String get profHeight => 'Wzrost';

  @override
  String get profCurrentWeight => 'Aktualna waga';

  @override
  String get profTargetWeight => 'Waga docelowa';

  @override
  String get profActivityLevel => 'Poziom aktywności';

  @override
  String get profGoal => 'Cel';

  @override
  String get profCalculations => 'Obliczenia';

  @override
  String get profBmrExplain =>
      'Zapotrzebowanie kaloryczne w spoczynku – ile kalorii spalasz bez aktywności.';

  @override
  String get profTdeeExplain =>
      'Całkowite dzienne zapotrzebowanie – ile kalorii spalasz w ciągu dnia z uwzględnieniem aktywności.';

  @override
  String get profCalorieGoalExplain =>
      'Zalecane dzienne spożycie kalorii do osiągnięcia celu wagowego.';

  @override
  String get profWaterGoal => 'Cel picia wody';

  @override
  String profWaterGoalExplanation({
    required int mlPerKg,
    required String weightKg,
    required int rawMl,
    required int goalMl,
  }) {
    return 'Obliczone z Twojej wagi: $mlPerKg ml na każdy kg ($weightKg kg → ok. $rawMl ml, zaokrąglone do $goalMl ml). Możesz zmienić cel ręcznie.';
  }

  @override
  String get profMacros => 'Makro';

  @override
  String get profProtein => 'Białko';

  @override
  String get profFat => 'Tłuszcze';

  @override
  String get profCarbs => 'Węglowodany';

  @override
  String get profCarbsShort => 'Węgle';

  @override
  String get profTargetDateTitle => 'Termin osiągnięcia celu:';

  @override
  String get profTargetDateHint =>
      'Działaj zgodnie z planem, a ten dzień się nie opóźni.';

  @override
  String get profSpeedUpHint =>
      'Chcesz przyspieszyć cel? Edytuj tempo zmiany wagi w trybie edycji profilu (ikona ołówka u góry).';

  @override
  String get profMaintainNoDateTitle => 'Cel: utrzymanie wagi';

  @override
  String get profMaintainNoDateBody =>
      'Przy utrzymaniu wagi nie ma osobnego terminu „osiągnięcia”. Zmień cel na schudnięcie lub przytycie (oraz wagę docelową) — wtedy powiem Ci, kiedy mniej więcej go osiągniesz.';

  @override
  String get profMaintainNoDateCta => 'Edytuj cel w profilu';

  @override
  String get profAiAdvice => 'Porada AI';

  @override
  String get profAiAdviceHint => 'Zapytaj o dietę, odżywianie i aktywność';

  @override
  String get profBmiTitle => 'Kalkulator BMI';

  @override
  String get profBmiHint => 'Sprawdź swój wskaźnik masy ciała';

  @override
  String profTrialLeft({required int hours, required int minutes}) {
    return 'Pozostało: ${hours}h ${minutes}min';
  }

  @override
  String get profPremiumTitleActive => 'Łatwa Forma Premium';

  @override
  String get profPremiumTitle => 'Subskrypcja Premium';

  @override
  String get profActive => 'Aktywna';

  @override
  String get profPremiumHintActive =>
      'Nieograniczona AI, eksport PDF, integracje';

  @override
  String get profPremiumHint =>
      'Odblokuj pełny potencjał – AI, PDF, integracje';

  @override
  String get profIntegrations => 'Integracje';

  @override
  String get profIntegrationsHint =>
      'Strava – importuj aktywności i spalone kalorie';

  @override
  String get profExport => 'Eksport danych';

  @override
  String get profExportHint => 'Wyeksportuj swoje dane do CSV';

  @override
  String get profInviteHint =>
      'Wyślij zaproszenie e-mailem do aplikacji Łatwa Forma';

  @override
  String get profPrivacy => 'Polityka prywatności';

  @override
  String get profTerms => 'Regulamin';

  @override
  String get profEula => 'Terms of Use (EULA)';

  @override
  String get profDeleteAccountPage => 'Usuń konto (strona)';

  @override
  String get profYourAccount => 'Twoje konto';

  @override
  String get profDeviceData => 'Dane na tym urządzeniu';

  @override
  String get profDeviceDataHint =>
      'Korzystasz bez konta. Możesz usunąć zapisany profil i posiłki z tego urządzenia.';

  @override
  String get profDeleteData => 'Usuń dane';

  @override
  String get profDeleteDataBody =>
      'Profil, posiłki i inne dane z tego urządzenia zostaną trwale usunięte. Nie da się ich przywrócić.\n\nCzy na pewno chcesz usunąć dane?';

  @override
  String get profDataDeleted => 'Dane z urządzenia zostały usunięte.';

  @override
  String get profGenderMale => 'Mężczyzna';

  @override
  String get profGenderFemale => 'Kobieta';

  @override
  String get profGenderOther => 'Inna';

  @override
  String get profActSedentary => 'Siedzący';

  @override
  String get profActLight => 'Lekka';

  @override
  String get profActModerate => 'Umiarkowana';

  @override
  String get profActIntense => 'Intensywna';

  @override
  String get profActVeryIntense => 'Bardzo intensywna';

  @override
  String get profGoalLoss => 'Utrata wagi';

  @override
  String get profGoalGain => 'Przybranie wagi';

  @override
  String get profGoalMaintain => 'Utrzymanie wagi';

  @override
  String get profGenderRequired => 'Płeć *';

  @override
  String get profAgeRequired => 'Wiek *';

  @override
  String get profYearsSuffix => 'lat';

  @override
  String get profHeightRequired => 'Wzrost (cm) *';

  @override
  String get profCurrentWeightRequired => 'Aktualna waga (kg) *';

  @override
  String get profTargetWeightRequired => 'Waga docelowa (kg) *';

  @override
  String get profWeightDiffError =>
      'Różnica między wagami musi wynosić co najmniej 1 kg';

  @override
  String get profActivityRequired => 'Poziom aktywności *';

  @override
  String get profActSedentaryDesc => 'Brak aktywności lub minimalna';

  @override
  String get profActLightDesc => '1-3 treningi / tydzień';

  @override
  String get profActModerateDesc => '3-5 treningów / tydzień';

  @override
  String get profActIntenseDesc => '6-7 treningów / tydzień';

  @override
  String get profActVeryIntenseDesc => '2x dziennie / ciężka praca';

  @override
  String get profWaterGoalMl => 'Cel wody (ml)';

  @override
  String get profWaterGoalHelper =>
      'Możesz zmienić ręcznie. Poniżej wyjaśnienie, skąd bierze się propozycja.';

  @override
  String get profSaveChanges => 'Zapisz zmiany';

  @override
  String get profWantLose => 'Chcę schudnąć.';

  @override
  String get profWantGain => 'Chcę przybrać na wadze.';

  @override
  String get profWantMaintain => 'Chcę utrzymać obecną wagę.';

  @override
  String get profAdjustPlan => 'Dostosuj plan';

  @override
  String get profPlanPremiumOnly =>
      'Własny cel kaloryczny i makroskładniki są dostępne w Premium.';

  @override
  String get profSeePremium => 'Zobacz Premium';

  @override
  String get profWeightRate => 'Tempo zmiany wagi';

  @override
  String profRateKgWeek({required String rate}) {
    return '$rate kg/tydz.';
  }

  @override
  String get profRateZero => '0 kg/tydz.';

  @override
  String get profMaintainRateZero => 'Dla utrzymania wagi tempo = 0';

  @override
  String get profRecommendedRate =>
      'Zalecane tempo: 0,5 kg/tydz. – bezpieczne i zdrowe. Szybsze chudnięcie może być niezdrowe (utrata mięśni, niedobory, zmęczenie).';

  @override
  String profEstTargetDate({required String date}) {
    return 'Szacunkowy termin osiągnięcia celu: $date';
  }

  @override
  String get profMoveSlider => 'Przesuń suwak, aby zobaczyć plan';

  @override
  String get profCustomCalorieGoal => 'Własny cel kaloryczny';

  @override
  String get profGoalKcal => 'Cel (kcal)';

  @override
  String get profLeaveEmptyFromRate => 'Zostaw puste, aby obliczyć z tempa.';

  @override
  String get profCustomMacros => 'Własne makroskładniki';

  @override
  String get profMacrosAutoRecalc =>
      'Kalorie i termin przeliczą się automatycznie.';

  @override
  String profMacroSum({required String kcal}) {
    return 'Suma: $kcal kcal';
  }

  @override
  String profMacroPerGram({required int kcal}) {
    return '1g = $kcal kcal';
  }

  @override
  String get profValuesNotNegative => 'Wartości nie mogą być ujemne.';

  @override
  String profMacroMaxProtein({required String g}) {
    return 'białko max $g g';
  }

  @override
  String profMacroMaxFat({required String g}) {
    return 'tłuszcze max $g g';
  }

  @override
  String profMacroMaxCarbs({required String g}) {
    return 'węglowodany max $g g';
  }

  @override
  String profMacroOverLimit({required String parts}) {
    return '⚠️ Wartości przekraczają zalecane limity dzienne: $parts. Wprowadź realistyczne wartości dla zdrowej diety.';
  }

  @override
  String profMacroCaloriesUnreal({
    required String calories,
    required String max,
  }) {
    return '⚠️ Łączna liczba kalorii ($calories kcal) jest nierealistyczna dla dziennego zapotrzebowania. Zalecane maksimum to ok. $max kcal/dzień.';
  }

  @override
  String profMacroLossSurplus({required String surplus, required String tdee}) {
    return 'Twój cel to chudnięcie (waga docelowa niższa niż obecna), ale wprowadzone makroskładniki dają $surplus kcal powyżej zapotrzebowania (TDEE: $tdee kcal). Zmniejsz kalorie/makroskładniki, aby osiągnąć deficyt.';
  }

  @override
  String profMacroGainDeficit({required String tdee}) {
    return 'Twój cel to przybieranie na wadze (waga docelowa wyższa niż obecna), ale wprowadzone makroskładniki dają deficyt (TDEE: $tdee kcal). Zwiększ kalorie/makroskładniki, aby osiągnąć nadwyżkę.';
  }

  @override
  String profWarnCalAboveTdeeLoss({required String tdee}) {
    return '⚠️ Cel kaloryczny jest wyższy niż TDEE ($tdee kcal). Aby schudnąć, musisz mieć deficyt kaloryczny. Maksymalny bezpieczny deficyt to ~1100 kcal/dzień (ok. 1 kg/tydzień).';
  }

  @override
  String profWarnDeficitHuge({required String deficit}) {
    return '⚠️ Deficyt kaloryczny jest bardzo duży ($deficit kcal/dzień). Zalecany maksymalny deficyt to 1000-1500 kcal/dzień dla bezpiecznej utraty wagi.';
  }

  @override
  String get profWarnDeficitTiny =>
      '⚠️ Deficyt kaloryczny jest bardzo mały. Dla skutecznej utraty wagi zalecany jest deficyt 500-1000 kcal/dzień.';

  @override
  String profWarnCalBelowTdeeGain({required String tdee}) {
    return '⚠️ Cel kaloryczny jest niższy niż TDEE ($tdee kcal). Aby przybrać na wadze, musisz mieć nadwyżkę kaloryczną. Zalecana nadwyżka to 250-500 kcal/dzień (ok. 0.25-0.5 kg/tydzień).';
  }

  @override
  String profWarnSurplusHuge({required String surplus}) {
    return '⚠️ Nadwyżka kaloryczna jest bardzo duża ($surplus kcal/dzień). Zalecana nadwyżka to 250-500 kcal/dzień dla zdrowego przybierania na wadze.';
  }

  @override
  String get profWarnSurplusTiny =>
      '⚠️ Nadwyżka kaloryczna jest bardzo mała. Dla skutecznego przybierania na wadze zalecana jest nadwyżka 250-500 kcal/dzień.';

  @override
  String profWarnMaintainFar({required String tdee}) {
    return '⚠️ Cel kaloryczny różni się znacznie od TDEE ($tdee kcal). Dla utrzymania wagi cel powinien być zbliżony do TDEE (±100-200 kcal).';
  }

  @override
  String profCannotSaveLoss({required String calories, required String tdee}) {
    return 'Nie można zapisać: Cel kaloryczny ($calories kcal) jest wyższy niż TDEE ($tdee kcal). Aby schudnąć, musisz mieć deficyt kaloryczny.';
  }

  @override
  String profCannotSaveGain({required String calories, required String tdee}) {
    return 'Nie można zapisać: Cel kaloryczny ($calories kcal) jest niższy niż TDEE ($tdee kcal). Aby przybrać na wadze, musisz mieć nadwyżkę kaloryczną.';
  }

  @override
  String get profUserNotLoggedIn => 'Użytkownik nie jest zalogowany';

  @override
  String get profGoalHistoryEdit => 'Edycja profilu';

  @override
  String get profUpdatedSuccess =>
      'Profil zaktualizowany pomyślnie! Cel został przeliczony.';

  @override
  String profSaveError({required String error}) {
    return 'Błąd podczas zapisywania: $error';
  }

  @override
  String get profCalorieGoal => 'Cel kaloryczny';

  @override
  String get trackPremium => 'Premium';

  @override
  String get trackStatistics => 'Statystyki';

  @override
  String get trackGoalsAndChallenges => 'Cele i wyzwania';

  @override
  String get trackProfile => 'Profil';

  @override
  String get trackSessionExpired => 'Sesja wygasła. Zaloguj się ponownie.';

  @override
  String get trackLoadDataFailed =>
      'Nie udało się załadować danych. Sprawdź połączenie internetowe i naciśnij „Spróbuj ponownie”.';

  @override
  String trackErrorWithDetails({required String error}) {
    return 'Błąd: $error';
  }

  @override
  String get trackSignIn => 'Zaloguj się';

  @override
  String get trackFeatureEatingOut => 'Posiłek „na mieście”';

  @override
  String trackShareCaloriesText({required String date}) {
    return '📊 Łatwa Forma – Kalorie $date';
  }

  @override
  String trackShareError({required String error}) {
    return 'Błąd udostępniania: $error';
  }

  @override
  String get trackCaloriesOverview => 'Przegląd kalorii';

  @override
  String get trackSelectDate => 'Wybierz datę';

  @override
  String get trackShare => 'Udostępnij';

  @override
  String get trackFeatureShareSummary => 'Udostępnianie podsumowania';

  @override
  String get trackEarlierWeek => 'Wcześniejszy tydzień';

  @override
  String get trackFeatureBrowseHistory => 'Przeglądanie historii innych dni';

  @override
  String get trackLaterWeek => 'Późniejszy tydzień';

  @override
  String trackShowingDataFrom({required String date}) {
    return 'Wyświetlane dane z $date';
  }

  @override
  String get trackConsumed => 'Spożyte';

  @override
  String get trackTodayTarget => 'Cel na dziś';

  @override
  String trackSurplusKcal({required String kcal}) {
    return 'Nadwyżka: $kcal kcal';
  }

  @override
  String get trackProtein => 'Białko';

  @override
  String get trackFat => 'Tłuszcze';

  @override
  String get trackCarbs => 'Węglowodany';

  @override
  String get trackCarbsShort => 'Węgle';

  @override
  String get trackIncludingSaturated => 'w tym nasycone';

  @override
  String get trackIncludingSugars => 'w tym cukry';

  @override
  String get trackFiber => 'błonnik';

  @override
  String get trackFiberLabel => 'Błonnik';

  @override
  String get trackSalt => 'Sól';

  @override
  String get trackFeatureAiMealAnalysis => 'Analiza AI posiłku';

  @override
  String get trackAiPhotoAnalysisTooltip => 'Analiza AI ze zdjęcia';

  @override
  String get trackNoResults => 'Brak wyników';

  @override
  String get trackWater => 'Woda';

  @override
  String get trackWaterMotivation => 'Człowiek nie wielbłąd, pić musi! 💧';

  @override
  String get trackActivitiesToday => 'Aktywności dzisiaj';

  @override
  String trackActivitiesOnDate({required String date}) {
    return 'Aktywności – $date';
  }

  @override
  String get trackNoActivities => 'Brak aktywności';

  @override
  String trackAndMoreCount({required String count}) {
    return '... i $count więcej';
  }

  @override
  String get trackMealsToday => 'Posiłki dzisiaj';

  @override
  String trackMealsOnDate({required String date}) {
    return 'Posiłki – $date';
  }

  @override
  String get trackNoMeals => 'Brak posiłków';

  @override
  String get trackDayMon => 'Pon';

  @override
  String get trackDayTue => 'Wt';

  @override
  String get trackDayWed => 'Śr';

  @override
  String get trackDayThu => 'Czw';

  @override
  String get trackDayFri => 'Pt';

  @override
  String get trackDaySat => 'Sob';

  @override
  String get trackDaySun => 'Nie';

  @override
  String get trackAdd => 'Dodaj';

  @override
  String get trackMeal => 'Posiłek';

  @override
  String get trackEatingOut => 'Jedzenie na mieście';

  @override
  String get trackActivity => 'Aktywność';

  @override
  String get trackWeight => 'Waga';

  @override
  String get trackMeasurements => 'Pomiary';

  @override
  String get trackFavorites => 'Ulubione';

  @override
  String get trackUserNotLoggedIn => 'Użytkownik nie jest zalogowany';

  @override
  String get trackMealSavedAndFavorited =>
      'Posiłek zapisany i dodany do ulubionych!';

  @override
  String get trackMealAddedSuccess => 'Posiłek dodany pomyślnie!';

  @override
  String get trackFeatureIngredientsMeal => 'Posiłek ze składników';

  @override
  String get trackOptionEatingOut => 'Na mieście';

  @override
  String get trackOptionAiAnalysis => 'Analiza AI';

  @override
  String get trackOptionIngredients => 'Składniki';

  @override
  String get trackOptionBarcode => 'Kod kreskowy';

  @override
  String get trackOptionSearchProduct => 'Wyszukaj produkt';

  @override
  String get trackOptionFavorites => 'Ulubione';

  @override
  String get trackEditMeal => 'Edytuj posiłek';

  @override
  String get trackAddMeal => 'Dodaj posiłek';

  @override
  String get trackMealNameOptional => 'Nazwa posiłku (opcjonalnie)';

  @override
  String get trackHintEmptyDefaultName => 'Puste = \"Bez nazwy\"';

  @override
  String get trackDefaultMealName => 'Bez nazwy';

  @override
  String get trackHintCaloriesFromMacros => 'Puste = policzy z makroskładników';

  @override
  String get trackEnterCaloriesOrMacros =>
      'Podaj liczbę kalorii lub uzupełnij makroskładniki';

  @override
  String get trackProteinG => 'Białko (g)';

  @override
  String get trackFatG => 'Tłuszcze (g)';

  @override
  String get trackCarbsG => 'Węglowodany (g)';

  @override
  String get trackFiberG => 'Błonnik (g)';

  @override
  String get trackSaltG => 'Sól (g)';

  @override
  String get trackMealTypeOptional => 'Typ posiłku - opcjonalnie';

  @override
  String get trackBreakfast => 'Śniadanie';

  @override
  String get trackLunch => 'Obiad';

  @override
  String get trackDinner => 'Kolacja';

  @override
  String get trackSnack => 'Przekąska';

  @override
  String get trackAddToFavorites => 'Dodaj do ulubionych';

  @override
  String get trackAddToFavoritesMealSubtitle =>
      'Będziesz mógł szybko dodać ten posiłek później';

  @override
  String get trackUpdateMeal => 'Zaktualizuj posiłek';

  @override
  String get trackSaveMeal => 'Zapisz posiłek';

  @override
  String get trackCalories => 'Kalorie';

  @override
  String get trackCameraUnavailableTitle => 'Kamera niedostępna';

  @override
  String get trackCameraUnavailableBody =>
      'Kamera nie jest dostępna na tym urządzeniu (np. na symulatorze).\n\nUżyj przycisku „Z galerii”, aby wybrać zdjęcie z galerii.';

  @override
  String get trackFromGallery => 'Z galerii';

  @override
  String trackPickImageError({required String error}) {
    return 'Błąd wyboru zdjęcia: $error';
  }

  @override
  String get trackAnalysisFailedOpenAi =>
      'Nie udało się przeanalizować zdjęcia. Sprawdź czy klucz OpenAI API jest ustawiony.';

  @override
  String trackAnalysisError({required String error}) {
    return 'Błąd analizy: $error';
  }

  @override
  String get trackAiPhotoTitle => 'Analiza zdjęcia AI';

  @override
  String get trackTakeMealPhoto => 'Zrób zdjęcie posiłku';

  @override
  String get trackAiPhotoDescription =>
      'AI przeanalizuje zdjęcie i oszacuje wartości odżywcze. Zdjęcie jest wysyłane do dostawcy AI (OpenAI) wyłącznie w tym celu – nie zapisujemy galerii zdjęć. Szacunki są orientacyjne i nie stanowią porady medycznej.';

  @override
  String get trackSimulatorCameraHint =>
      'Na symulatorze kamera nie działa – wybierz zdjęcie z galerii.';

  @override
  String get trackTakePhoto => 'Zrób zdjęcie';

  @override
  String get trackAnalyzingPhoto => 'Analizowanie zdjęcia...';

  @override
  String get trackMayTakeAMoment => 'To może chwilę potrwać';

  @override
  String trackProductNotFound({required String code}) {
    return 'Produkt o kodzie $code nie został znaleziony w bazie produktów.';
  }

  @override
  String trackFetchProductFailed({required String error}) {
    return 'Nie udało się pobrać danych produktu: $error';
  }

  @override
  String get trackBarcodeScannerTitle => 'Skaner kodów kreskowych';

  @override
  String get trackSimulatorEnterCode => 'Na symulatorze wprowadź kod ręcznie';

  @override
  String get trackEnterProductCode => 'Wprowadź kod produktu';

  @override
  String get trackSearchProduct => 'Szukaj produktu';

  @override
  String get trackScannerUnavailable =>
      'Skaner niedostępny - użyj symulatora lub urządzenia fizycznego';

  @override
  String get trackPointAtBarcode => 'Wskaż kod kreskowy produktu';

  @override
  String get trackBarcodePrivacy =>
      'Dane zostaną pobrane z bazy produktów. Kamera służy wyłącznie do odczytu kodu – zdjęcia nie zapisujemy ani nie wysyłamy.';

  @override
  String get trackScanBarcode => 'Skanuj kod kreskowy';

  @override
  String get trackAddProduct => 'Dodaj produkt';

  @override
  String get trackEnterProductWeight => 'Podaj wagę produktu';

  @override
  String get trackNutritionPer100g => 'Wartości odżywcze (na 100g):';

  @override
  String get trackWeightHintExample => 'np. 75.5';

  @override
  String get trackWeightHelper => 'Ile gramów produktu zjadasz?';

  @override
  String get trackEditBeforeSave => 'Edytuj przed zapisem';

  @override
  String trackPer100g({required String label}) {
    return '$label/100g';
  }

  @override
  String get trackWeightG => 'Waga (g)';

  @override
  String get trackSearchProductTitle => 'Wyszukaj produkt';

  @override
  String get trackSearchProductHint => 'Nazwa produktu, np. mleko, nutella…';

  @override
  String get trackEnterProductName => 'Wpisz nazwę produktu';

  @override
  String get trackSearchProductSubtitle =>
      'Korzystamy z bazy Open Food Facts. Wyniki pojawią się po wpisaniu min. kilku liter.';

  @override
  String get trackNoResultsTryBarcode =>
      'Spróbuj innej nazwy lub zeskanuj kod kreskowy produktu.';

  @override
  String get trackBackToDashboard => 'Wróć do dashboardu';

  @override
  String trackMealsDateTitle({required String date}) {
    return 'Posiłki - $date';
  }

  @override
  String get trackFavoriteMealsTooltip => 'Ulubione posiłki';

  @override
  String get trackNoMealsForDay => 'Brak posiłków na ten dzień';

  @override
  String get trackUsePlusToAddMeal => 'Użyj przycisku + aby dodać posiłek';

  @override
  String get trackDeleteMealTitle => 'Usuń posiłek';

  @override
  String trackDeleteMealConfirm({required String name}) {
    return 'Czy na pewno chcesz usunąć \"$name\"?';
  }

  @override
  String get trackMealDeleted => 'Posiłek usunięty';

  @override
  String get trackAddAtLeastOneIngredient =>
      'Dodaj przynajmniej jeden składnik';

  @override
  String get trackMealFromIngredientsTitle => 'Posiłek ze składników';

  @override
  String trackTotalWeightG({required String weight}) {
    return 'Całkowita waga: $weight g';
  }

  @override
  String trackIngredientsCount({required String count}) {
    return 'Składniki ($count)';
  }

  @override
  String get trackAddIngredient => 'Dodaj składnik';

  @override
  String get trackNoIngredients => 'Brak składników';

  @override
  String get trackAddIngredientsHint => 'Dodaj składniki, aby zbudować posiłek';

  @override
  String get trackEditIngredient => 'Edytuj składnik';

  @override
  String get trackIngredientNameOptional => 'Nazwa składnika (opcjonalnie)';

  @override
  String get trackAmountG => 'Ilość (g)';

  @override
  String get trackEnterAmount => 'Podaj ilość';

  @override
  String get trackEnterValidAmount => 'Podaj poprawną ilość';

  @override
  String get trackEnterCaloriesOrFillMacros =>
      'Podaj kalorie lub uzupełnij makroskładniki';

  @override
  String get trackProteinPer100g => 'Białko (g/100g)';

  @override
  String get trackFatPer100g => 'Tłuszcze (g/100g)';

  @override
  String get trackCarbsPer100g => 'Węglowodany (g/100g)';

  @override
  String get trackEatingOutTitle => '🍽️ Jem na mieście';

  @override
  String get trackEatingOutSubtitle => 'Wybierz co jadłeś (szacunki kalorii):';

  @override
  String trackPortionLabel({required String label}) {
    return 'Porcja: $label';
  }

  @override
  String trackSlicesCount({required String count}) {
    return 'Ilość kawałków: $count';
  }

  @override
  String trackSlicesUnit({required String count}) {
    return '$count szt.';
  }

  @override
  String get trackKcalPerSlice => 'kcal na kawałek:';

  @override
  String trackKcalPerPieceLabel({required String kcal}) {
    return '$kcal kcal/szt.';
  }

  @override
  String trackKcalLabel({required String kcal}) {
    return '$kcal kcal';
  }

  @override
  String trackKcalTimesSlices({
    required String kcal,
    required String slices,
    required String total,
  }) {
    return '$kcal × $slices = $total kcal';
  }

  @override
  String get trackSaving => 'Zapisywanie…';

  @override
  String get trackAddToDiary => 'Dodaj do dziennika';

  @override
  String get trackSelectMealAbove => 'Wybierz posiłek powyżej';

  @override
  String get trackEatingOutTip =>
      'Jeśli reszta dnia była lekka – to OK. Nie stresuj się.';

  @override
  String trackMealNameEatingOutSlices({
    required String name,
    required String slices,
  }) {
    return '$name ($slices szt.) (na mieście)';
  }

  @override
  String trackMealNameEatingOut({required String name}) {
    return '$name (na mieście)';
  }

  @override
  String trackAddedEatingOut({
    required String name,
    required String slicesPart,
    required String kcal,
  }) {
    return 'Dodano: $name$slicesPart (~$kcal kcal)';
  }

  @override
  String trackSlicesPart({required String slices}) {
    return ' ($slices szt.)';
  }

  @override
  String get trackEatingOutPizza => 'Pizza';

  @override
  String get trackEatingOutPizzaLabel => '~250–450 kcal / kawałek';

  @override
  String get trackEatingOutKebab => 'Kebab';

  @override
  String get trackEatingOutKebabLabel => '~600–900 kcal';

  @override
  String get trackEatingOutBurger => 'Burger (ogólnie)';

  @override
  String get trackEatingOutBurgerLabel => '~500–800 kcal';

  @override
  String get trackEatingOutChinese => 'Chińczyk';

  @override
  String get trackEatingOutChineseLabel => '~500–900 kcal';

  @override
  String get trackEatingOutMcdCheeseburger => 'McDonald\'s – Cheeseburger';

  @override
  String get trackEatingOutMcdCheeseburgerLabel => '~300 kcal';

  @override
  String get trackEatingOutMcd2ForYou =>
      'McDonald\'s – 2forYou (Cheeseburger + frytki)';

  @override
  String get trackEatingOutMcd2ForYouLabel => '~530 kcal';

  @override
  String get trackEatingOutMcdBigMac => 'McDonald\'s – Big Mac';

  @override
  String get trackEatingOutMcdBigMacLabel => '~590 kcal';

  @override
  String get trackEatingOutMcdMcDouble => 'McDonald\'s – McDouble';

  @override
  String get trackEatingOutMcdMcDoubleLabel => '~400 kcal';

  @override
  String get trackEatingOutMcdSmallFries => 'McDonald\'s – małe frytki';

  @override
  String get trackEatingOutMcdSmallFriesLabel => '~230 kcal';

  @override
  String get trackEatingOutMcdMediumFries => 'McDonald\'s – średnie frytki';

  @override
  String get trackEatingOutMcdMediumFriesLabel => '~340 kcal';

  @override
  String get trackEatingOutKfcDrumstick => 'KFC – udko/nóżka';

  @override
  String get trackEatingOutKfcDrumstickLabel => '~200 kcal / szt.';

  @override
  String get trackEatingOutKfcTenders => 'KFC – Strips / Tenders';

  @override
  String get trackEatingOutKfcTendersLabel => '~400–600 kcal';

  @override
  String get trackEatingOutSubway6 => 'Subway – 6\'\' sub';

  @override
  String get trackEatingOutSubway6Label => '~300–500 kcal';

  @override
  String get trackEatingOutSubwayFootlong => 'Subway – Footlong';

  @override
  String get trackEatingOutSubwayFootlongLabel => '~600–900 kcal';

  @override
  String trackActivitiesDateTitle({required String date}) {
    return 'Aktywności - $date';
  }

  @override
  String get trackNoActivitiesForDay => 'Brak aktywności na ten dzień';

  @override
  String get trackAddFirstActivity => 'Dodaj pierwszą aktywność';

  @override
  String get trackDaySummary => 'Podsumowanie dnia';

  @override
  String get trackBurned => 'Spalone';

  @override
  String get trackTime => 'Czas';

  @override
  String get trackGarminActivitiesNote =>
      'Dane aktywności pochodzą z urządzeń Garmin.';

  @override
  String get trackDeleteActivityTitle => 'Usuń aktywność';

  @override
  String trackDeleteActivityConfirm({required String name}) {
    return 'Czy na pewno chcesz usunąć \"$name\"?';
  }

  @override
  String get trackActivityDeleted => 'Aktywność usunięta';

  @override
  String get trackExcludeFromBalance => 'Nie licz w bilansie (spalone)';

  @override
  String get trackActivityExcludedFromBalance =>
      'Aktywność wyłączona z bilansu';

  @override
  String get trackActivityIncludedInBalance => 'Aktywność wliczana do bilansu';

  @override
  String get trackOtherActivities => 'Pozostałe aktywności.';

  @override
  String get trackActivityTypeOther => 'Inna';

  @override
  String get trackActivityTypeLow => 'Niska';

  @override
  String get trackActivityTypeModerate => 'Umiarkowana';

  @override
  String get trackActivityTypeHigh => 'Wysoka';

  @override
  String get trackActivityTypeVeryHigh => 'Bardzo wysoka';

  @override
  String get trackActivityTypeRun => 'Bieg';

  @override
  String get trackActivityTypeCycling => 'Kolarstwo';

  @override
  String get trackActivityTypeSwim => 'Pływanie';

  @override
  String get trackActivityTypeWalk => 'Chodzenie';

  @override
  String get trackActivityTypeHike => 'Wędrówka';

  @override
  String get trackActivityTypeRow => 'Wioślarstwo';

  @override
  String get trackActivityTypeTennis => 'Tenis';

  @override
  String get trackActivityTypeYoga => 'Joga';

  @override
  String get trackActivityTypeTraining => 'Trening';

  @override
  String get trackFeatureQuickAddActivities =>
      'Szybkie dodawanie w aktywnościach';

  @override
  String get trackActivitySavedAndFavorited =>
      'Aktywność zapisana i dodana do ulubionych!';

  @override
  String get trackActivityAddedSuccess => 'Aktywność dodana pomyślnie!';

  @override
  String get trackEditActivity => 'Edytuj aktywność';

  @override
  String get trackAddActivity => 'Dodaj aktywność';

  @override
  String get trackQuickAdd => 'Szybkie dodawanie';

  @override
  String get trackActivityNameOptional => 'Nazwa aktywności (opcjonalnie)';

  @override
  String get trackHintEmptyDefaultActivityName =>
      'Puste = \"Aktywność bez nazwy\"';

  @override
  String get trackDefaultActivityName => 'Aktywność bez nazwy';

  @override
  String get trackEnterBurnedCalories => 'Podaj liczbę spalonych kalorii';

  @override
  String get trackEnterValidCalories => 'Podaj poprawną liczbę kalorii';

  @override
  String get trackActivityTypeOptional => 'Typ aktywności - opcjonalnie';

  @override
  String get trackAddToFavoritesActivitySubtitle =>
      'Będziesz mógł szybko dodać tę aktywność później';

  @override
  String get trackUpdateActivity => 'Zaktualizuj aktywność';

  @override
  String get trackSaveActivity => 'Zapisz aktywność';

  @override
  String get trackDurationMinutes => 'Czas (min)';

  @override
  String get trackBurnedCalories => 'Spalone kalorie';

  @override
  String trackAddedWaterMl({required String amount}) {
    return 'Dodano $amount ml wody';
  }

  @override
  String trackAddWaterError({required String error}) {
    return 'Błąd podczas dodawania wody: $error';
  }

  @override
  String trackUpdatedAmountMl({required String amount}) {
    return 'Zaktualizowano: $amount ml';
  }

  @override
  String trackUpdateError({required String error}) {
    return 'Błąd podczas aktualizacji: $error';
  }

  @override
  String get trackDeleteEntryTitle => 'Usuń wpis';

  @override
  String trackDeleteWaterConfirm({required String amount}) {
    return 'Czy na pewno chcesz usunąć wpis $amount ml?';
  }

  @override
  String get trackEntryDeleted => 'Wpis usunięty';

  @override
  String trackDeleteError({required String error}) {
    return 'Błąd podczas usuwania: $error';
  }

  @override
  String get trackEditAmount => 'Edytuj ilość';

  @override
  String get trackAmountMl => 'Ilość (ml)';

  @override
  String get trackAmountMlHintRange => '1–5000 ml';

  @override
  String get trackAmountMustBeRange => 'Ilość musi być od 1 do 5000 ml';

  @override
  String get trackAddWater => 'Dodaj wodę';

  @override
  String get trackAmountMlHintExample => 'np. 250';

  @override
  String get trackMaxAmountPerEntry => 'Maksymalna ilość to 5000 ml na wpis';

  @override
  String get trackEnterAmountRange => 'Podaj ilość od 1 do 5000 ml';

  @override
  String get trackDailyWaterGoal => 'Cel dzienny picia wody';

  @override
  String get trackGoalHintExample => 'np. 2000';

  @override
  String get trackGoalMustBeRange => 'Podaj wartość od 500 do 10000 ml';

  @override
  String get trackWaterGoalUpdated => 'Cel wody zaktualizowany';

  @override
  String get trackChangeDailyWaterGoal => 'Zmień cel dzienny picia wody';

  @override
  String get trackEveryDropCounts => 'Każda kropla się liczy!';

  @override
  String get trackCustomAmount => 'Własna';

  @override
  String get trackWaterHistoryHint =>
      'Przegląd – edycja i usuwanie możliwe. Dodawanie tylko na dzisiaj.';

  @override
  String get trackNoEntries => 'Brak wpisów';

  @override
  String get trackEdit => 'Edytuj';

  @override
  String trackAmountMlLabel({required String amount}) {
    return '$amount ml';
  }

  @override
  String get trackDailyGoal => 'Cel dzienny';

  @override
  String get trackEnterWeight => 'Podaj wagę';

  @override
  String get trackEnterValidWeight => 'Podaj poprawną wagę (30-300 kg)';

  @override
  String get trackWeightSaved => 'Waga zapisana pomyślnie!';

  @override
  String get trackWeightMotivation =>
      'Regularne pomiary pomagają trzymać cel. Każdy wpis przybliża Cię do wymarzonej formy!';

  @override
  String get trackPickMeasurementDate => 'Wybierz datę pomiaru';

  @override
  String get trackMeasurementSavedWithDate =>
      'Pomiar zostanie zapisany z wybraną datą';

  @override
  String get trackSaveWeight => 'Zapisz wagę';

  @override
  String get trackDeleteMeasurementTitle => 'Usuń pomiar';

  @override
  String trackDeleteWeightConfirm({required String weight}) {
    return 'Czy na pewno chcesz usunąć pomiar $weight kg?';
  }

  @override
  String get trackMeasurementDeleted => 'Pomiar usunięty';

  @override
  String get trackNoWeightMeasurements => 'Brak pomiarów wagi';

  @override
  String get trackAddFirstMeasurementHint =>
      'Dodaj pierwszy pomiar, aby zobaczyć historię';

  @override
  String get trackNoDataToDisplay => 'Brak danych do wyświetlenia';

  @override
  String get trackWeightKg => 'Waga (kg)';

  @override
  String get trackHistory => 'Historia';

  @override
  String get trackEnterMeasurementValue => 'Podaj wartość pomiaru';

  @override
  String get trackEnterValidPositiveValue =>
      'Podaj poprawną wartość (większą od 0)';

  @override
  String get trackEnterCustomTypeName =>
      'Wpisz nazwę własnego typu pomiaru (np. biceps)';

  @override
  String get trackMeasurementSaved => 'Pomiar zapisany pomyślnie!';

  @override
  String get trackBodyMeasurementsTitle => 'Pomiary ciała';

  @override
  String get trackBodyMeasurementsMotivation =>
      'Śledź wymiary regularnie — każdy pomiar to dowód Twojego postępu i krok do wymarzonej sylwetki!';

  @override
  String get trackMeasurementType => 'Typ pomiaru';

  @override
  String get trackCustomTypeHint => 'np. Biceps, Brzuch';

  @override
  String get trackCustomTypeName => 'Nazwa własnego typu';

  @override
  String get trackValueCm => 'Wartość (cm)';

  @override
  String get trackValueHintExample => 'np. 85.5';

  @override
  String get trackSaveMeasurement => 'Zapisz pomiar';

  @override
  String trackMeasurementHistory({required String label}) {
    return 'Historia pomiarów - $label';
  }

  @override
  String trackDeleteBodyMeasurementConfirm({required String value}) {
    return 'Czy na pewno chcesz usunąć pomiar $value cm?';
  }

  @override
  String get trackNoMeasurements => 'Brak pomiarów';

  @override
  String get trackTypeWaist => 'Talia';

  @override
  String get trackTypeHips => 'Biodra';

  @override
  String get trackTypeChest => 'Klatka piersiowa';

  @override
  String get trackTypeArm => 'Ramię';

  @override
  String get trackTypeThigh => 'Udo';

  @override
  String get trackTypeCustom => 'Własny';

  @override
  String get trackNoFavorites => 'Brak ulubionych';

  @override
  String get trackNoFavoritesSubtitle =>
      'Dodaj posiłki lub aktywności do ulubionych przy ich zapisywaniu';

  @override
  String get trackFavoriteMeals => 'Ulubione posiłki';

  @override
  String get trackNoFavoriteMeals => 'Brak ulubionych posiłków';

  @override
  String get trackFavoriteActivities => 'Ulubione aktywności';

  @override
  String get trackNoFavoriteActivities => 'Brak ulubionych aktywności';

  @override
  String trackAddToMealsOnDate({required String date}) {
    return 'Dodaj do posiłków $date';
  }

  @override
  String get trackAddToTodaysMeals => 'Dodaj do dzisiejszych posiłków';

  @override
  String get trackRemoveFromFavorites => 'Usuń z ulubionych';

  @override
  String trackAddToActivitiesOnDate({required String date}) {
    return 'Dodaj do aktywności $date';
  }

  @override
  String get trackAddToTodaysActivities => 'Dodaj do dzisiejszych aktywności';

  @override
  String trackMealAddedToMealsOnDate({
    required String name,
    required String date,
  }) {
    return '$name dodany do posiłków $date';
  }

  @override
  String trackMealAddedToTodaysMeals({required String name}) {
    return '$name dodany do dzisiejszych posiłków';
  }

  @override
  String trackActivityAddedToActivitiesOnDate({
    required String name,
    required String date,
  }) {
    return '$name dodana do aktywności $date';
  }

  @override
  String trackActivityAddedToTodaysActivities({required String name}) {
    return '$name dodana do dzisiejszych aktywności';
  }

  @override
  String trackRemoveFromFavoritesConfirm({required String name}) {
    return 'Czy na pewno chcesz usunąć \"$name\" z ulubionych?';
  }

  @override
  String get trackRemovedFromFavorites => 'Usunięto z ulubionych';

  @override
  String get trackEditFavoriteMeal => 'Edytuj ulubiony posiłek';

  @override
  String get trackFavoriteMealUpdated => 'Zaktualizowano ulubiony posiłek';

  @override
  String get trackRecalculateFromIngredients => 'Przelicz z składników';

  @override
  String trackMinutesLabel({required String minutes}) {
    return '$minutes min';
  }

  @override
  String get trackCaloriesKcal => 'Kalorie (kcal)';

  @override
  String get trackIncludingSaturatedG => 'w tym nasycone (g)';

  @override
  String get trackIncludingSugarsG => 'w tym cukry (g)';

  @override
  String get trackWeightGOptional => 'Waga (g) - opcjonalnie';

  @override
  String get trackGoalMl => 'Cel (ml)';

  @override
  String get trackWaterTitle => 'Woda';

  @override
  String trackOfGoal({required String current, required String goal}) {
    return '$current / $goal ml';
  }

  @override
  String get trackSearchShort => 'Wyszukaj';

  @override
  String get trackWaterToday => 'Woda – Dzisiaj';

  @override
  String trackWaterOnDate({required String date}) {
    return 'Woda – $date';
  }

  @override
  String get trackHydrationBasics => 'Nawodnienie to podstawa formy.';

  @override
  String get trackSugar => 'Cukry';

  @override
  String get trackSaturatedFat => 'Nasycone';

  @override
  String get trackProduct => 'Produkt';

  @override
  String trackMealMacrosLine({
    required String kcal,
    required String protein,
    required String fat,
    required String carbs,
  }) {
    return '$kcal kcal • B: ${protein}g • T: ${fat}g • W: ${carbs}g';
  }

  @override
  String get trackAnalysisResults => 'Wyniki analizy';

  @override
  String get trackName => 'Nazwa';

  @override
  String get trackProductNotFoundTitle => 'Nie znaleziono produktu';

  @override
  String get trackBarcodeLabel => 'Kod kreskowy';

  @override
  String get trackFetchingProductData => 'Pobieranie danych produktu...';

  @override
  String trackBrand({required String brand}) {
    return 'Marka: $brand';
  }

  @override
  String get trackWeightGRequired => 'Waga (g) *';

  @override
  String get trackYourPortion => 'Twoja porcja:';

  @override
  String get trackMacroAbbrevProtein => 'B';

  @override
  String get trackMacroAbbrevFat => 'T';

  @override
  String get trackMacroAbbrevCarbs => 'W';

  @override
  String trackAddedKcal({required String kcal}) {
    return 'Dodano: $kcal kcal';
  }

  @override
  String get trackCaloriesPer100g => 'Kalorie (kcal/100g)';

  @override
  String get trackDashToday => 'Dzisiaj';

  @override
  String get trackNoDate => 'Brak daty';

  @override
  String get trackEntries => 'Wpisy';

  @override
  String get trackWeightHistory => 'Historia wagi';

  @override
  String get trackMeasurementName => 'Nazwa pomiaru';

  @override
  String get trackChoose => 'Wybierz';

  @override
  String get trackDurationMinutesOptional =>
      'Czas trwania (minuty) - opcjonalnie';

  @override
  String get trackMax5000Helper => 'Maksymalnie 5000 ml na jeden wpis';

  @override
  String get trackRecommendedMin2l => 'Zalecane jest min. 2l';

  @override
  String get trackSummary => 'Podsumowanie';

  @override
  String trackBurnedKcalName({required String kcal}) {
    return 'Spalone $kcal kcal';
  }

  @override
  String get trackMeasurementDate => 'Data pomiaru';

  @override
  String trackKcalBurned({required String kcal}) {
    return '$kcal kcal spalone';
  }

  @override
  String get trackMacrosInPremium => 'Makro – w Premium';

  @override
  String get trackSearchProductEllipsis => 'Szukaj produktu…';

  @override
  String get trackMacros => 'Makro';

  @override
  String get trackRecentMeasurements => 'Ostatnie pomiary';

  @override
  String get authEnterFullCode => 'Wpisz pełny kod z maila.';

  @override
  String get authSignedIn => 'Zalogowano pomyślnie!';

  @override
  String get authCodeExpired =>
      'Kod wygasł lub jest nieprawidłowy. Wyślij ponownie.';

  @override
  String get authEnterEmail => 'Podaj adres email';

  @override
  String get authInvalidEmail => 'Nieprawidłowy format email';

  @override
  String authLinkAndCodeSent({required String email}) {
    return 'Wysłaliśmy link i kod na $email. Sprawdź skrzynkę (także folder Spam) – kliknij link lub wpisz kod w aplikacji.';
  }

  @override
  String get authCouldNotStart => 'Nie udało się rozpocząć logowania.';

  @override
  String get authEmailTaken =>
      'Ten adres e-mail jest już zarejestrowany. Zaloguj się linkiem z maila (sprawdź spam).';

  @override
  String get authAlreadyLinked =>
      'To konto jest już połączone z innym użytkownikiem.';

  @override
  String get authManualLinking =>
      'Łączenie kont wymaga włączenia w Supabase. Włącz \"Manual linking\" w Authentication → Providers.';

  @override
  String get authConnection => 'Błąd połączenia. Sprawdź internet.';

  @override
  String get authTooManyAttempts =>
      'Zbyt dużo prób logowania. Spróbuj za godzinę.';

  @override
  String get authTooManyEmails =>
      'Zbyt wiele wiadomości na ten adres. Sprawdź skrzynkę lub spróbuj za chwilę.';

  @override
  String get authInvalidEmailAddress => 'Nieprawidłowy adres email.';

  @override
  String authGenericError({required String detail}) {
    return 'Błąd: $detail';
  }

  @override
  String premAboutPerMonth({required String amount, required String unit}) {
    return 'ok. $amount $unit / miesięcznie';
  }

  @override
  String get premYearlyPerMonthFallback =>
      'w przeliczeniu ok. 16,25 zł / mies. (płatność raz na rok)';

  @override
  String get moreStreakWater => 'Woda';

  @override
  String get premStoreNotReady =>
      'Zakupy w sklepie nie są jeszcze gotowe. Spróbuj ponownie za chwilę.';

  @override
  String get trackAddToCatalog => 'Dodaj do bazy';

  @override
  String get trackAddToCatalogHint =>
      'Zrób zdjęcie tabeli wartości odżywczych albo wpisz dane z etykiety. Produkt trafi do wspólnej bazy.';

  @override
  String get trackLabelPhoto => 'Zdjęcie etykiety';

  @override
  String get trackReadingLabel => 'Czytam etykietę…';

  @override
  String get trackLabelNotRead =>
      'Nie udało się odczytać tabeli. Wpisz wartości ręcznie.';

  @override
  String get trackEnterNameAndCalories => 'Podaj nazwę i kalorie na 100 g.';

  @override
  String get trackProductSavedCatalog =>
      'Produkt zapisany. Następnym razem skan go znajdzie.';

  @override
  String get trackCatalogNotSaved =>
      'Posiłek możesz dodać, ale wspólna baza nie zapisała produktu.';

  @override
  String get trackBrandOptional => 'Marka (opcjonalnie)';

  @override
  String get trackCopyYesterday => 'Skopiuj wczoraj';

  @override
  String trackCopiedMealsCount({required int count}) {
    return 'Skopiowano posiłki: $count';
  }

  @override
  String get trackNoMealsYesterday =>
      'Wczoraj nie było posiłków do skopiowania.';

  @override
  String get trackCopyConfirmTitle => 'Posiłki już są';

  @override
  String trackCopyConfirmBody({required int count}) {
    return 'Tego dnia masz już $count posiłków. Skopiować wczorajsze jeszcze raz? (powstaną duplikaty)';
  }

  @override
  String get trackCopyAgain => 'Kopiuj ponownie';

  @override
  String get trackCopying => 'Kopiowanie…';

  @override
  String get trackRecentFoods => 'Ostatnio jedzone';

  @override
  String get trackMealIdeasTitle => 'Pasuje na dziś';

  @override
  String trackMealIdeasLeft({required String kcal}) {
    return 'Zostało ok. $kcal kcal';
  }

  @override
  String get trackWaterTipSerious =>
      'Regularne nawodnienie wspiera koncentrację i metabolizm — warto pić przez cały dzień.';

  @override
  String get trackAddFirstMealTitle => 'Dodaj pierwszy posiłek';

  @override
  String get trackAddFirstMealSubtitle =>
      'Zacznij od wpisania tego, co jesz — reszta policzy się sama.';

  @override
  String get trackAddFirstMealCta => 'Dodaj posiłek';

  @override
  String get trackShortcutRecent => 'Ostatnie';

  @override
  String get trackRemainingKcal => 'Zostało do celu';

  @override
  String get trackOverGoalLabel => 'Powyżej celu';

  @override
  String trackGoalVerificationDays({required int days}) {
    return '$days/7 dni z danymi';
  }

  @override
  String get trackCalorieGoalSuccess =>
      'Dobra robota — dziś jesteś w okolicach celu kalorycznego.';

  @override
  String get trackD1ChecklistTitle => 'Pierwszy dzień — checklista';

  @override
  String get trackD1ChecklistMeal => 'Dodaj posiłek';

  @override
  String get trackD1ChecklistWater => 'Zapisz wodę';

  @override
  String get trackD1ChecklistWeight => 'Zapisz wagę';

  @override
  String get trackD1ChecklistDismiss => 'Rozumiem';

  @override
  String get trackPremiumLabel => 'Premium';

  @override
  String trackPercentOfGoal({required String percent}) {
    return '$percent% celu';
  }
}
