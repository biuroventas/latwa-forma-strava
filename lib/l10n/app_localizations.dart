import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
    Locale('uk'),
  ];

  /// No description provided for @language.
  ///
  /// In pl, this message translates to:
  /// **'Język'**
  String get language;

  /// No description provided for @appTitle.
  ///
  /// In pl, this message translates to:
  /// **'Łatwa Forma'**
  String get appTitle;

  /// No description provided for @navToday.
  ///
  /// In pl, this message translates to:
  /// **'Dziś'**
  String get navToday;

  /// No description provided for @navMeals.
  ///
  /// In pl, this message translates to:
  /// **'Posiłki'**
  String get navMeals;

  /// No description provided for @navWater.
  ///
  /// In pl, this message translates to:
  /// **'Woda'**
  String get navWater;

  /// No description provided for @navProfile.
  ///
  /// In pl, this message translates to:
  /// **'Ja'**
  String get navProfile;

  /// No description provided for @commonOk.
  ///
  /// In pl, this message translates to:
  /// **'OK'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In pl, this message translates to:
  /// **'Usuń'**
  String get commonDelete;

  /// No description provided for @commonClose.
  ///
  /// In pl, this message translates to:
  /// **'Zamknij'**
  String get commonClose;

  /// No description provided for @commonRetry.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj ponownie'**
  String get commonRetry;

  /// No description provided for @commonWarning.
  ///
  /// In pl, this message translates to:
  /// **'Uwaga'**
  String get commonWarning;

  /// No description provided for @commonError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd'**
  String get commonError;

  /// No description provided for @commonBack.
  ///
  /// In pl, this message translates to:
  /// **'Wstecz'**
  String get commonBack;

  /// No description provided for @commonYes.
  ///
  /// In pl, this message translates to:
  /// **'Tak'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In pl, this message translates to:
  /// **'Nie'**
  String get commonNo;

  /// No description provided for @commonContinue.
  ///
  /// In pl, this message translates to:
  /// **'Dalej'**
  String get commonContinue;

  /// No description provided for @healthDisclaimer.
  ///
  /// In pl, this message translates to:
  /// **'Łatwa Forma nie jest urządzeniem medycznym i nie diagnozuje, nie leczy, nie zapobiega ani nie leczy żadnej choroby ani stanu zdrowia. Obliczenia kalorii, makroskładników i porady AI mają charakter orientacyjny. W sprawach zdrowia skonsultuj się z lekarzem lub dietetykiem.'**
  String get healthDisclaimer;

  /// No description provided for @onbContinueApple.
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj z Apple'**
  String get onbContinueApple;

  /// No description provided for @onbContinueGoogle.
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj z Google'**
  String get onbContinueGoogle;

  /// No description provided for @onbContinueWithEmail.
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj z emailem'**
  String get onbContinueWithEmail;

  /// No description provided for @onbStartWithoutAccount.
  ///
  /// In pl, this message translates to:
  /// **'Zacznij bez konta'**
  String get onbStartWithoutAccount;

  /// No description provided for @onbCreateAccount.
  ///
  /// In pl, this message translates to:
  /// **'Załóż konto'**
  String get onbCreateAccount;

  /// No description provided for @onbCreateAccountEmail.
  ///
  /// In pl, this message translates to:
  /// **'Załóż konto e-mailem'**
  String get onbCreateAccountEmail;

  /// No description provided for @onbEnterCodeLink.
  ///
  /// In pl, this message translates to:
  /// **'Mam już kod z maila – wpisz go'**
  String get onbEnterCodeLink;

  /// No description provided for @onbAlreadyHaveCode.
  ///
  /// In pl, this message translates to:
  /// **'Mam już kod z maila'**
  String get onbAlreadyHaveCode;

  /// No description provided for @onbLegalPrefix.
  ///
  /// In pl, this message translates to:
  /// **'Korzystając z aplikacji, akceptujesz '**
  String get onbLegalPrefix;

  /// No description provided for @onbTerms.
  ///
  /// In pl, this message translates to:
  /// **'Regulamin'**
  String get onbTerms;

  /// No description provided for @onbLegalAnd.
  ///
  /// In pl, this message translates to:
  /// **' i '**
  String get onbLegalAnd;

  /// No description provided for @onbPrivacyPolicyAccusative.
  ///
  /// In pl, this message translates to:
  /// **'Politykę prywatności'**
  String get onbPrivacyPolicyAccusative;

  /// No description provided for @onbLegalPeriod.
  ///
  /// In pl, this message translates to:
  /// **'.'**
  String get onbLegalPeriod;

  /// No description provided for @onbPrivacyPolicy.
  ///
  /// In pl, this message translates to:
  /// **'Polityka prywatności'**
  String get onbPrivacyPolicy;

  /// No description provided for @onbContact.
  ///
  /// In pl, this message translates to:
  /// **'Kontakt'**
  String get onbContact;

  /// No description provided for @onbFollowUs.
  ///
  /// In pl, this message translates to:
  /// **'Śledź nas: '**
  String get onbFollowUs;

  /// No description provided for @onbSocialComingSoon.
  ///
  /// In pl, this message translates to:
  /// **'{name} – wkrótce'**
  String onbSocialComingSoon({required String name});

  /// No description provided for @onbCopyrightFull.
  ///
  /// In pl, this message translates to:
  /// **'© 2026 Łatwa Forma | {company}\nNIP {nip} · {address}'**
  String onbCopyrightFull({
    required String company,
    required String nip,
    required String address,
  });

  /// No description provided for @onbCopyrightShort.
  ///
  /// In pl, this message translates to:
  /// **'© 2026 Łatwa Forma | {company}\nNIP {nip}'**
  String onbCopyrightShort({required String company, required String nip});

  /// No description provided for @onbFeatureCaloriesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kalorie i makro dopasowane do Ciebie'**
  String get onbFeatureCaloriesTitle;

  /// No description provided for @onbFeatureCaloriesDesc.
  ///
  /// In pl, this message translates to:
  /// **'Dzienny limit i makro pod Twój cel'**
  String get onbFeatureCaloriesDesc;

  /// No description provided for @onbFeatureWeightTitle.
  ///
  /// In pl, this message translates to:
  /// **'Śledzenie wagi i postępów'**
  String get onbFeatureWeightTitle;

  /// No description provided for @onbFeatureWeightDesc.
  ///
  /// In pl, this message translates to:
  /// **'Waga i zmiany w jednym miejscu'**
  String get onbFeatureWeightDesc;

  /// No description provided for @onbFeaturePlanTitle.
  ///
  /// In pl, this message translates to:
  /// **'Prosty plan do celu'**
  String get onbFeaturePlanTitle;

  /// No description provided for @onbFeaturePlanDesc.
  ///
  /// In pl, this message translates to:
  /// **'Jasna droga do Twojej wagi'**
  String get onbFeaturePlanDesc;

  /// No description provided for @onbFeatureAiTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pomoc AI'**
  String get onbFeatureAiTitle;

  /// No description provided for @onbFeatureAiDesc.
  ///
  /// In pl, this message translates to:
  /// **'Porady i posiłek ze zdjęcia'**
  String get onbFeatureAiDesc;

  /// No description provided for @onbFeatureProductsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Baza produktów'**
  String get onbFeatureProductsTitle;

  /// No description provided for @onbFeatureProductsDesc.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj i skanuj kod kreskowy'**
  String get onbFeatureProductsDesc;

  /// No description provided for @onbBenefitCalories.
  ///
  /// In pl, this message translates to:
  /// **'plan kalorii dopasowany do Ciebie'**
  String get onbBenefitCalories;

  /// No description provided for @onbBenefitWeight.
  ///
  /// In pl, this message translates to:
  /// **'śledzenie wagi i postępów'**
  String get onbBenefitWeight;

  /// No description provided for @onbBenefitPlan.
  ///
  /// In pl, this message translates to:
  /// **'prosty plan do celu'**
  String get onbBenefitPlan;

  /// No description provided for @onbBenefitAi.
  ///
  /// In pl, this message translates to:
  /// **'pomoc AI'**
  String get onbBenefitAi;

  /// No description provided for @onbLoginOrRegister.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się lub załóż konto'**
  String get onbLoginOrRegister;

  /// No description provided for @onbLoginOrCreateShort.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj lub załóż konto'**
  String get onbLoginOrCreateShort;

  /// No description provided for @onbLoginSheetBody.
  ///
  /// In pl, this message translates to:
  /// **'Masz konto? Zaloguj się. Nowy użytkownik? Załóż konto – Twoje dane będą zapisane.'**
  String get onbLoginSheetBody;

  /// No description provided for @onbFaqTitle.
  ///
  /// In pl, this message translates to:
  /// **'FAQ – najczęściej zadawane pytania'**
  String get onbFaqTitle;

  /// No description provided for @onbFaqShowLess.
  ///
  /// In pl, this message translates to:
  /// **'Pokaż mniej'**
  String get onbFaqShowLess;

  /// No description provided for @onbFaqShowMore.
  ///
  /// In pl, this message translates to:
  /// **'Zobacz więcej pytań ({count})'**
  String onbFaqShowMore({required int count});

  /// No description provided for @onbFaqFreeQ.
  ///
  /// In pl, this message translates to:
  /// **'Czy aplikacja jest darmowa?'**
  String get onbFaqFreeQ;

  /// No description provided for @onbFaqFreeA.
  ///
  /// In pl, this message translates to:
  /// **'Tak. Łatwa Forma jest darmowa do codziennego użytku: śledzenie kalorii, posiłków, wagi, wody i aktywności. Część funkcji (np. analiza AI ze zdjęcia, rozbudowane statystyki) jest dostępna w planie Premium.'**
  String get onbFaqFreeA;

  /// No description provided for @onbFaqPhotoQ.
  ///
  /// In pl, this message translates to:
  /// **'Jak działa licznik kalorii ze zdjęcia?'**
  String get onbFaqPhotoQ;

  /// No description provided for @onbFaqPhotoA.
  ///
  /// In pl, this message translates to:
  /// **'W ekranie dodawania posiłku wybierz „Analiza AI”. Zrób zdjęcie dania lub wybierz je z galerii. Aplikacja wysyła zdjęcie do modelu AI (wizja), który rozpoznaje potrawę i szacuje kalorie oraz makroskładniki (białko, tłuszcze, węglowodany). Możesz je potem poprawić i zapisać. Funkcja wymaga Premium.'**
  String get onbFaqPhotoA;

  /// No description provided for @onbFaqLimitQ.
  ///
  /// In pl, this message translates to:
  /// **'Jak aplikacja liczy mój dzienny limit kalorii?'**
  String get onbFaqLimitQ;

  /// No description provided for @onbFaqLimitA.
  ///
  /// In pl, this message translates to:
  /// **'Na podstawie profilu (wiek, płeć, waga, wzrost, poziom aktywności) obliczamy BMR (wzór Harrisa-Benedicta), a potem TDEE. W zależności od celu (schudnięcie, utrzymanie, przytycie) dostosowujemy limit kalorii i makra.'**
  String get onbFaqLimitA;

  /// No description provided for @onbFaqNoAccountQ.
  ///
  /// In pl, this message translates to:
  /// **'Co to jest „Zacznij bez konta”?'**
  String get onbFaqNoAccountQ;

  /// No description provided for @onbFaqNoAccountA.
  ///
  /// In pl, this message translates to:
  /// **'Możesz korzystać z aplikacji bez logowania. Dane są zapisywane lokalnie. Później możesz połączyć je z kontem (Apple, Google lub e-mail), aby mieć backup i synchronizację między urządzeniami.'**
  String get onbFaqNoAccountA;

  /// No description provided for @onbFaqStravaQ.
  ///
  /// In pl, this message translates to:
  /// **'Czy mogę połączyć Strava lub Garmin?'**
  String get onbFaqStravaQ;

  /// No description provided for @onbFaqStravaA.
  ///
  /// In pl, this message translates to:
  /// **'Tak, Strava. W ustawieniach (Profil → Integracje) możesz połączyć konto ze Strava. Importowane aktywności są uwzględniane w bilansie kalorii (spalone kcal). Garmin Connect pojawi się po uruchomieniu integracji.'**
  String get onbFaqStravaA;

  /// No description provided for @onbFaqPremiumQ.
  ///
  /// In pl, this message translates to:
  /// **'Co daje Premium?'**
  String get onbFaqPremiumQ;

  /// No description provided for @onbFaqPremiumA.
  ///
  /// In pl, this message translates to:
  /// **'M.in. analiza posiłku ze zdjęcia (AI), rozbudowane statystyki, eksport danych, wyższy limit porad AI. W aplikacji ze sklepu płatności idą przez Google Play / App Store; na stronie latwaforma.pl – przez Stripe.'**
  String get onbFaqPremiumA;

  /// No description provided for @onbFaqGoalQ.
  ///
  /// In pl, this message translates to:
  /// **'Jak zmienić cel (schudnięcie / utrzymanie / przytycie)?'**
  String get onbFaqGoalQ;

  /// No description provided for @onbFaqGoalA.
  ///
  /// In pl, this message translates to:
  /// **'W Profilu ustaw wagę docelową. Aplikacja na tej podstawie proponuje cel i dzienny limit; makra można też dostosować ręcznie w ustawieniach profilu.'**
  String get onbFaqGoalA;

  /// No description provided for @onbFaqAddMealQ.
  ///
  /// In pl, this message translates to:
  /// **'Jak dodać posiłek?'**
  String get onbFaqAddMealQ;

  /// No description provided for @onbFaqAddMealA.
  ///
  /// In pl, this message translates to:
  /// **'Z ekranu głównego lub zakładki „Posiłki” wybierz „Dodaj posiłek”. Możesz wpisać dane ręcznie, zeskanować kod kreskowy (Open Food Facts) lub użyć Analizy AI ze zdjęcia (Premium).'**
  String get onbFaqAddMealA;

  /// No description provided for @onbFaqDataQ.
  ///
  /// In pl, this message translates to:
  /// **'Gdzie są zapisane moje dane?'**
  String get onbFaqDataQ;

  /// No description provided for @onbFaqDataA.
  ///
  /// In pl, this message translates to:
  /// **'Dane są przechowywane na serwerach w Europie (Supabase). Przy „Zacznij bez konta” dane są lokalne do momentu połączenia z kontem.'**
  String get onbFaqDataA;

  /// No description provided for @onbFaqDeleteQ.
  ///
  /// In pl, this message translates to:
  /// **'Jak usunąć konto i dane?'**
  String get onbFaqDeleteQ;

  /// No description provided for @onbFaqDeleteA.
  ///
  /// In pl, this message translates to:
  /// **'W aplikacji: Profil → Usuń konto. Możesz też złożyć wniosek na latwaforma.pl/usun-konto.html. Po zatwierdzeniu konto i powiązane dane są usuwane (to nie jest zamrożenie konta). Subskrypcję w Google Play / App Store anuluj osobno w sklepie. W razie problemów: contact@latwaforma.pl.'**
  String get onbFaqDeleteA;

  /// No description provided for @onbFaqMedicalQ.
  ///
  /// In pl, this message translates to:
  /// **'Czy to aplikacja medyczna?'**
  String get onbFaqMedicalQ;

  /// No description provided for @onbFaqMedicalA.
  ///
  /// In pl, this message translates to:
  /// **'Nie. Łatwa Forma nie jest urządzeniem medycznym i nie diagnozuje, nie leczy ani nie zapobiega chorobom. Obliczenia i porady AI są orientacyjne. W sprawach zdrowia skonsultuj się z lekarzem lub dietetykiem.'**
  String get onbFaqMedicalA;

  /// No description provided for @onbSendingLinkAndCode.
  ///
  /// In pl, this message translates to:
  /// **'Wysyłanie linku i kodu...'**
  String get onbSendingLinkAndCode;

  /// No description provided for @onbSignedIn.
  ///
  /// In pl, this message translates to:
  /// **'Zalogowano'**
  String get onbSignedIn;

  /// No description provided for @onbSignedInSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Zalogowano pomyślnie!'**
  String get onbSignedInSuccess;

  /// No description provided for @onbSignedInDataSaved.
  ///
  /// In pl, this message translates to:
  /// **'Zostałeś zalogowany. Twoje dane są zapisane.'**
  String get onbSignedInDataSaved;

  /// No description provided for @onbAccountLinked.
  ///
  /// In pl, this message translates to:
  /// **'Konto połączone'**
  String get onbAccountLinked;

  /// No description provided for @onbEmailLinkedSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Twój adres e-mail został połączony z kontem. Możesz się teraz logować tym emailem.'**
  String get onbEmailLinkedSuccess;

  /// No description provided for @onbEnterEmailTitle.
  ///
  /// In pl, this message translates to:
  /// **'Podaj adres email'**
  String get onbEnterEmailTitle;

  /// No description provided for @onbEnterEmailWhichAddress.
  ///
  /// In pl, this message translates to:
  /// **'Na który adres wysłaliśmy link i kod? Podaj go, a następnie wpiszesz kod.'**
  String get onbEnterEmailWhichAddress;

  /// No description provided for @onbEmailAddressLabel.
  ///
  /// In pl, this message translates to:
  /// **'Adres email'**
  String get onbEmailAddressLabel;

  /// No description provided for @onbEmailAddressLabelAlt.
  ///
  /// In pl, this message translates to:
  /// **'Adres e-mail'**
  String get onbEmailAddressLabelAlt;

  /// No description provided for @onbEmailAddressHint.
  ///
  /// In pl, this message translates to:
  /// **'np. jan@example.com'**
  String get onbEmailAddressHint;

  /// No description provided for @onbCheckInbox.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź skrzynkę'**
  String get onbCheckInbox;

  /// No description provided for @onbEnterCodeFromEmailTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz kod z maila'**
  String get onbEnterCodeFromEmailTitle;

  /// No description provided for @onbEnterCodeFromEmailLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz kod z maila:'**
  String get onbEnterCodeFromEmailLabel;

  /// No description provided for @onbEmailCodeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kod z maila'**
  String get onbEmailCodeLabel;

  /// No description provided for @onbEmailCodeHint.
  ///
  /// In pl, this message translates to:
  /// **'np. 123456'**
  String get onbEmailCodeHint;

  /// No description provided for @onbSentLinkAndCode.
  ///
  /// In pl, this message translates to:
  /// **'Wysłaliśmy link i kod na {email}. Sprawdź skrzynkę (także folder Spam) – możesz kliknąć link w mailu lub wpisać kod poniżej.'**
  String onbSentLinkAndCode({required String email});

  /// No description provided for @onbEnterCodeReceived.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz poniżej kod, który otrzymałeś na adres {email}.'**
  String onbEnterCodeReceived({required String email});

  /// No description provided for @onbCodeSentTo.
  ///
  /// In pl, this message translates to:
  /// **'Kod wysłany na: {email}'**
  String onbCodeSentTo({required String email});

  /// No description provided for @onbCodeSentEnterBelow.
  ///
  /// In pl, this message translates to:
  /// **'Wysłaliśmy kod na {email}. Wpisz go poniżej.'**
  String onbCodeSentEnterBelow({required String email});

  /// No description provided for @onbResend.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij ponownie'**
  String get onbResend;

  /// No description provided for @onbSignIn.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj'**
  String get onbSignIn;

  /// No description provided for @onbConfirmCode.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź kod'**
  String get onbConfirmCode;

  /// No description provided for @onbSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Sukces'**
  String get onbSuccess;

  /// No description provided for @onbSendLinkAndCode.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij link oraz kod'**
  String get onbSendLinkAndCode;

  /// No description provided for @onbEmailSignupBody.
  ///
  /// In pl, this message translates to:
  /// **'Podaj adres e-mail. Wyślemy link i kod, którymi dokończysz założenie konta.'**
  String get onbEmailSignupBody;

  /// No description provided for @onbEnterEmailRequired.
  ///
  /// In pl, this message translates to:
  /// **'Podaj adres e-mail'**
  String get onbEnterEmailRequired;

  /// No description provided for @onbIntroTitle.
  ///
  /// In pl, this message translates to:
  /// **'Powiedz nam kilka rzeczy o sobie'**
  String get onbIntroTitle;

  /// No description provided for @onbIntroBody.
  ///
  /// In pl, this message translates to:
  /// **'Pokażemy Ci ile jeść każdego dnia,\naby osiągnąć swój cel.'**
  String get onbIntroBody;

  /// No description provided for @onbIntroDuration.
  ///
  /// In pl, this message translates to:
  /// **'Zajmie mniej niż minutę'**
  String get onbIntroDuration;

  /// No description provided for @onbIntroStart.
  ///
  /// In pl, this message translates to:
  /// **'Rozpocznij'**
  String get onbIntroStart;

  /// No description provided for @onbAnonErrorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się rozpocząć bez konta'**
  String get onbAnonErrorTitle;

  /// No description provided for @onbAnonErrorNoConfig.
  ///
  /// In pl, this message translates to:
  /// **'Aplikacja nie ma połączenia z serwerem (brak konfiguracji w buildzie).'**
  String get onbAnonErrorNoConfig;

  /// No description provided for @onbAnonErrorTimeout.
  ///
  /// In pl, this message translates to:
  /// **'Serwer nie odpowiedział w czasie. Sprawdź internet lub spróbuj później.'**
  String get onbAnonErrorTimeout;

  /// No description provided for @onbAnonErrorFailed.
  ///
  /// In pl, this message translates to:
  /// **'Połączenie z serwerem nie powiodło się. Możesz:'**
  String get onbAnonErrorFailed;

  /// No description provided for @onbAnonErrorTipDomain.
  ///
  /// In pl, this message translates to:
  /// **'• Upewnij się, że jesteś na adresie latwaforma.pl.'**
  String get onbAnonErrorTipDomain;

  /// No description provided for @onbAnonErrorTipRefresh.
  ///
  /// In pl, this message translates to:
  /// **'• Odśwież stronę (F5) i spróbuj ponownie.'**
  String get onbAnonErrorTipRefresh;

  /// No description provided for @onbAnonErrorTipLogin.
  ///
  /// In pl, this message translates to:
  /// **'• Albo zaloguj się przez Apple, Google albo e-mail – przycisk na górze.'**
  String get onbAnonErrorTipLogin;

  /// No description provided for @onbOpenLatwaForma.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz latwaforma.pl'**
  String get onbOpenLatwaForma;

  /// No description provided for @onbSplashNoServerConfig.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia z serwerem. Sprawdź konfigurację (.env) i internet.'**
  String get onbSplashNoServerConfig;

  /// No description provided for @onbSplashNoConnection.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia. Sprawdź internet i spróbuj ponownie.'**
  String get onbSplashNoConnection;

  /// No description provided for @onbSplashLoginFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się zalogować. Uzupełnij profil lub spróbuj zalogować się ponownie.'**
  String get onbSplashLoginFailed;

  /// No description provided for @onbSplashGoogleFailed.
  ///
  /// In pl, this message translates to:
  /// **'Logowanie Google nie powiodło się. Zaloguj się ponownie w tej samej karcie.'**
  String get onbSplashGoogleFailed;

  /// No description provided for @onbSplashAbort.
  ///
  /// In pl, this message translates to:
  /// **'Przerwij'**
  String get onbSplashAbort;

  /// No description provided for @onbPlanThanks.
  ///
  /// In pl, this message translates to:
  /// **'Dziękujemy!'**
  String get onbPlanThanks;

  /// No description provided for @onbPlanGotIt.
  ///
  /// In pl, this message translates to:
  /// **'Mamy to!'**
  String get onbPlanGotIt;

  /// No description provided for @onbPlanStepData.
  ///
  /// In pl, this message translates to:
  /// **'Dane'**
  String get onbPlanStepData;

  /// No description provided for @onbPlanStepCalc.
  ///
  /// In pl, this message translates to:
  /// **'Kalkulacja'**
  String get onbPlanStepCalc;

  /// No description provided for @onbPlanStepMacro.
  ///
  /// In pl, this message translates to:
  /// **'Makro'**
  String get onbPlanStepMacro;

  /// No description provided for @onbPlanStepDone.
  ///
  /// In pl, this message translates to:
  /// **'Gotowe'**
  String get onbPlanStepDone;

  /// No description provided for @onbPlanStatusAnalyzing.
  ///
  /// In pl, this message translates to:
  /// **'Analizujemy Twoje dane…'**
  String get onbPlanStatusAnalyzing;

  /// No description provided for @onbPlanStatusCalories.
  ///
  /// In pl, this message translates to:
  /// **'Obliczanie kalorii…'**
  String get onbPlanStatusCalories;

  /// No description provided for @onbPlanStatusMacro.
  ///
  /// In pl, this message translates to:
  /// **'Makro…'**
  String get onbPlanStatusMacro;

  /// No description provided for @onbPlanStatusAlmost.
  ///
  /// In pl, this message translates to:
  /// **'Prawie gotowe…'**
  String get onbPlanStatusAlmost;

  /// No description provided for @onbPlanReadyTitle.
  ///
  /// In pl, this message translates to:
  /// **'Twój plan jest gotowy!'**
  String get onbPlanReadyTitle;

  /// No description provided for @onbPlanWhatDone.
  ///
  /// In pl, this message translates to:
  /// **'Co zostało zrobione:'**
  String get onbPlanWhatDone;

  /// No description provided for @onbPlanCaloriesComputed.
  ///
  /// In pl, this message translates to:
  /// **'• Na podstawie wzrostu, wagi, wieku i poziomu aktywności obliczyliśmy Twoje dzienne zapotrzebowanie kaloryczne.'**
  String get onbPlanCaloriesComputed;

  /// No description provided for @onbPlanCaloriesComputedWithValue.
  ///
  /// In pl, this message translates to:
  /// **'• Na podstawie wzrostu, wagi, wieku i poziomu aktywności obliczyliśmy Twoje dzienne zapotrzebowanie kaloryczne: {calories} kcal.'**
  String onbPlanCaloriesComputedWithValue({required String calories});

  /// No description provided for @onbPlanTargetDate.
  ///
  /// In pl, this message translates to:
  /// **'• Szacowany termin osiągnięcia celu: {date}'**
  String onbPlanTargetDate({required String date});

  /// No description provided for @onbPlanChangeInProfile.
  ///
  /// In pl, this message translates to:
  /// **'Możesz w każdej chwili zmienić te dane w zakładce Profil (ikona osoby u góry).'**
  String get onbPlanChangeInProfile;

  /// No description provided for @onbPlanHowToUse.
  ///
  /// In pl, this message translates to:
  /// **'Jak korzystać z aplikacji:'**
  String get onbPlanHowToUse;

  /// No description provided for @onbPlanTipMeals.
  ///
  /// In pl, this message translates to:
  /// **'• Dodawaj posiłki – śledź, co jesz i ile kalorii spożywasz'**
  String get onbPlanTipMeals;

  /// No description provided for @onbPlanTipWater.
  ///
  /// In pl, this message translates to:
  /// **'• Pij wodę – ustaw przypomnienia w ustawieniach'**
  String get onbPlanTipWater;

  /// No description provided for @onbPlanTipWeight.
  ///
  /// In pl, this message translates to:
  /// **'• Wpisuj wagę regularnie – widzisz postępy na wykresie'**
  String get onbPlanTipWeight;

  /// No description provided for @onbPlanTipDashboard.
  ///
  /// In pl, this message translates to:
  /// **'• Sprawdzaj dashboard – tam widzisz swój dzienny cel i postępy'**
  String get onbPlanTipDashboard;

  /// No description provided for @onbPlanMedicalNote.
  ///
  /// In pl, this message translates to:
  /// **'Łatwa Forma nie jest urządzeniem medycznym i nie diagnozuje, nie leczy ani nie zapobiega chorobom. W sprawach zdrowia skonsultuj się z lekarzem lub dietetykiem.'**
  String get onbPlanMedicalNote;

  /// No description provided for @onbPlanStartButton.
  ///
  /// In pl, this message translates to:
  /// **'Rozumiem, zaczynam!'**
  String get onbPlanStartButton;

  /// No description provided for @onbSaveProgressTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz postępy'**
  String get onbSaveProgressTitle;

  /// No description provided for @onbSaveProgressBodyWithMeals.
  ///
  /// In pl, this message translates to:
  /// **'Masz już {count} posiłków! Zaloguj się, aby nie stracić danych przy reinstalacji aplikacji.'**
  String onbSaveProgressBodyWithMeals({required int count});

  /// No description provided for @onbSaveProgressBodyEmpty.
  ///
  /// In pl, this message translates to:
  /// **'Załóż konto, żeby Twoje posiłki, aktywności i waga były zapisane w chmurze i dostępne na każdym urządzeniu – nic nie zginie przy reinstalacji.'**
  String get onbSaveProgressBodyEmpty;

  /// No description provided for @onbChooseLoginMethod.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz sposób logowania:'**
  String get onbChooseLoginMethod;

  /// No description provided for @onbLater.
  ///
  /// In pl, this message translates to:
  /// **'Później'**
  String get onbLater;

  /// No description provided for @guestTrialDaysLeft.
  ///
  /// In pl, this message translates to:
  /// **'Bez konta: zostało {days} dni'**
  String guestTrialDaysLeft({required int days});

  /// No description provided for @guestTrialOneDay.
  ///
  /// In pl, this message translates to:
  /// **'Bez konta: został 1 dzień'**
  String get guestTrialOneDay;

  /// No description provided for @guestTrialLastDay.
  ///
  /// In pl, this message translates to:
  /// **'Bez konta: ostatni dzień. Od jutra nowe wpisy wymagają konta.'**
  String get guestTrialLastDay;

  /// No description provided for @guestTrialCardBody.
  ///
  /// In pl, this message translates to:
  /// **'Połącz konto, żeby dane zostały przy zmianie telefonu.'**
  String get guestTrialCardBody;

  /// No description provided for @guestTrialEndedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Okres bez konta minął'**
  String get guestTrialEndedTitle;

  /// No description provided for @guestTrialEndedBody.
  ///
  /// In pl, this message translates to:
  /// **'Możesz przeglądać zapisane posiłki, wodę i wagę. Żeby dodawać dalej, połącz konto — dane zostaną.'**
  String get guestTrialEndedBody;

  /// No description provided for @guestTrialViewOnly.
  ///
  /// In pl, this message translates to:
  /// **'Tylko podgląd'**
  String get guestTrialViewOnly;

  /// No description provided for @onbLinkingAccount.
  ///
  /// In pl, this message translates to:
  /// **'Łączenie konta...'**
  String get onbLinkingAccount;

  /// No description provided for @onbAccountSavedSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Konto zapisane pomyślnie!'**
  String get onbAccountSavedSuccess;

  /// No description provided for @onbSaveWithEmailTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz z emailem'**
  String get onbSaveWithEmailTitle;

  /// No description provided for @onbEmailAlreadyRegistered.
  ///
  /// In pl, this message translates to:
  /// **'E-mail już zarejestrowany'**
  String get onbEmailAlreadyRegistered;

  /// No description provided for @onbClickBelowToLogin.
  ///
  /// In pl, this message translates to:
  /// **'Kliknij poniżej, aby przejść do logowania:'**
  String get onbClickBelowToLogin;

  /// No description provided for @onbSignOutAndSignIn.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj i zaloguj się'**
  String get onbSignOutAndSignIn;

  /// No description provided for @onbGoBackTitle.
  ///
  /// In pl, this message translates to:
  /// **'Cofnąć się?'**
  String get onbGoBackTitle;

  /// No description provided for @onbGoBackBody.
  ///
  /// In pl, this message translates to:
  /// **'Dane nie zostaną zapisane. Wrócisz do ekranu początkowego.'**
  String get onbGoBackBody;

  /// No description provided for @onbGoBackConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Tak, cofnij'**
  String get onbGoBackConfirm;

  /// No description provided for @onbBackTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Cofnij'**
  String get onbBackTooltip;

  /// No description provided for @onbCompleteData.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij dane'**
  String get onbCompleteData;

  /// No description provided for @onbGenderLabel.
  ///
  /// In pl, this message translates to:
  /// **'Płeć *'**
  String get onbGenderLabel;

  /// No description provided for @onbGenderFemale.
  ///
  /// In pl, this message translates to:
  /// **'Kobieta'**
  String get onbGenderFemale;

  /// No description provided for @onbGenderMale.
  ///
  /// In pl, this message translates to:
  /// **'Mężczyzna'**
  String get onbGenderMale;

  /// No description provided for @onbAgeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wiek *'**
  String get onbAgeLabel;

  /// No description provided for @onbYearsUnit.
  ///
  /// In pl, this message translates to:
  /// **'lat'**
  String get onbYearsUnit;

  /// No description provided for @onbHeightLabel.
  ///
  /// In pl, this message translates to:
  /// **'Wzrost (cm) *'**
  String get onbHeightLabel;

  /// No description provided for @onbCurrentWeightLabel.
  ///
  /// In pl, this message translates to:
  /// **'Aktualna waga (kg) *'**
  String get onbCurrentWeightLabel;

  /// No description provided for @onbTargetWeightLabel.
  ///
  /// In pl, this message translates to:
  /// **'Waga docelowa (kg) *'**
  String get onbTargetWeightLabel;

  /// No description provided for @onbWeightDiff.
  ///
  /// In pl, this message translates to:
  /// **'Różnica: {diff} kg'**
  String onbWeightDiff({required String diff});

  /// No description provided for @onbWeightDiffMin.
  ///
  /// In pl, this message translates to:
  /// **'Różnica między wagami musi wynosić co najmniej 1 kg'**
  String get onbWeightDiffMin;

  /// No description provided for @onbActivityLabel.
  ///
  /// In pl, this message translates to:
  /// **'Poziom aktywności *'**
  String get onbActivityLabel;

  /// No description provided for @onbActivitySedentary.
  ///
  /// In pl, this message translates to:
  /// **'Siedzący'**
  String get onbActivitySedentary;

  /// No description provided for @onbActivitySedentaryDesc.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywności lub minimalna aktywność'**
  String get onbActivitySedentaryDesc;

  /// No description provided for @onbActivityLight.
  ///
  /// In pl, this message translates to:
  /// **'Lekka'**
  String get onbActivityLight;

  /// No description provided for @onbActivityLightDesc.
  ///
  /// In pl, this message translates to:
  /// **'Ćwiczenia 1-3 razy w tygodniu'**
  String get onbActivityLightDesc;

  /// No description provided for @onbActivityModerate.
  ///
  /// In pl, this message translates to:
  /// **'Umiarkowana'**
  String get onbActivityModerate;

  /// No description provided for @onbActivityModerateDesc.
  ///
  /// In pl, this message translates to:
  /// **'Ćwiczenia 3-5 razy w tygodniu'**
  String get onbActivityModerateDesc;

  /// No description provided for @onbActivityIntense.
  ///
  /// In pl, this message translates to:
  /// **'Intensywna'**
  String get onbActivityIntense;

  /// No description provided for @onbActivityIntenseDesc.
  ///
  /// In pl, this message translates to:
  /// **'Ćwiczenia 6-7 razy w tygodniu'**
  String get onbActivityIntenseDesc;

  /// No description provided for @onbActivityVeryIntense.
  ///
  /// In pl, this message translates to:
  /// **'Bardzo intensywna'**
  String get onbActivityVeryIntense;

  /// No description provided for @onbActivityVeryIntenseDesc.
  ///
  /// In pl, this message translates to:
  /// **'Bardzo ciężka praca fizyczna lub treningi 2x dziennie'**
  String get onbActivityVeryIntenseDesc;

  /// No description provided for @onbSaveAndStart.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz i rozpocznij'**
  String get onbSaveAndStart;

  /// No description provided for @onbGoalLose.
  ///
  /// In pl, this message translates to:
  /// **'Chcę schudnąć.'**
  String get onbGoalLose;

  /// No description provided for @onbGoalGain.
  ///
  /// In pl, this message translates to:
  /// **'Chcę przybrać na wadze.'**
  String get onbGoalGain;

  /// No description provided for @onbGoalMaintain.
  ///
  /// In pl, this message translates to:
  /// **'Chcę utrzymać obecną wagę.'**
  String get onbGoalMaintain;

  /// No description provided for @onbGoalUnchangedSameWeight.
  ///
  /// In pl, this message translates to:
  /// **'Cel się nie zmienił. Waga docelowa nie różni się od aktualnej, więc plan jest na utrzymanie wagi.'**
  String get onbGoalUnchangedSameWeight;

  /// No description provided for @onbErrorCreatingAccount.
  ///
  /// In pl, this message translates to:
  /// **'Błąd podczas tworzenia konta.'**
  String get onbErrorCreatingAccount;

  /// No description provided for @onbErrorNetworkPermission.
  ///
  /// In pl, this message translates to:
  /// **'Błąd uprawnień sieciowych.\n\nRozwiązanie:\n1. Zatrzymaj aplikację\n2. Uruchom ponownie: flutter run\n3. Jeśli problem nadal występuje, sprawdź czy anonimowa autoryzacja jest włączona w Supabase'**
  String get onbErrorNetworkPermission;

  /// No description provided for @onbErrorAnonymousDisabled.
  ///
  /// In pl, this message translates to:
  /// **'Anonimowa autoryzacja nie jest włączona w Supabase.\n\nPrzejdź do: Authentication → Providers → Anonymous → Enable'**
  String get onbErrorAnonymousDisabled;

  /// No description provided for @onbErrorInternet.
  ///
  /// In pl, this message translates to:
  /// **'Błąd połączenia z internetem.\nSprawdź połączenie i spróbuj ponownie.'**
  String get onbErrorInternet;

  /// No description provided for @onbErrorInternetShort.
  ///
  /// In pl, this message translates to:
  /// **'Błąd połączenia z internetem. Sprawdź połączenie i spróbuj ponownie.'**
  String get onbErrorInternetShort;

  /// No description provided for @onbErrorSupabaseConfig.
  ///
  /// In pl, this message translates to:
  /// **'Błąd konfiguracji Supabase.\nSprawdź klucze API w pliku .env'**
  String get onbErrorSupabaseConfig;

  /// No description provided for @onbErrorWithDetails.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {details}'**
  String onbErrorWithDetails({required String details});

  /// No description provided for @onbErrorSaving.
  ///
  /// In pl, this message translates to:
  /// **'Błąd podczas zapisywania'**
  String get onbErrorSaving;

  /// No description provided for @onbErrorAuth.
  ///
  /// In pl, this message translates to:
  /// **'Błąd autoryzacji. Sprawdź konfigurację Supabase.'**
  String get onbErrorAuth;

  /// No description provided for @moreStatisticsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki'**
  String get moreStatisticsTitle;

  /// No description provided for @moreStreaksTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Serie'**
  String get moreStreaksTooltip;

  /// No description provided for @moreWeeklySummary.
  ///
  /// In pl, this message translates to:
  /// **'Tygodniowe podsumowanie'**
  String get moreWeeklySummary;

  /// No description provided for @moreShareTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij'**
  String get moreShareTooltip;

  /// No description provided for @moreShareWeeklyStatsFeature.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnianie tygodniowych statystyk'**
  String get moreShareWeeklyStatsFeature;

  /// No description provided for @moreShareWeeklySummaryText.
  ///
  /// In pl, this message translates to:
  /// **'📊 Łatwa Forma – Tygodniowe podsumowanie'**
  String get moreShareWeeklySummaryText;

  /// No description provided for @moreShareError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd udostępniania: {error}'**
  String moreShareError({required String error});

  /// No description provided for @moreAvgDailyCalories.
  ///
  /// In pl, this message translates to:
  /// **'Średnie dzienne kalorie'**
  String get moreAvgDailyCalories;

  /// No description provided for @moreTotalCaloriesWeek.
  ///
  /// In pl, this message translates to:
  /// **'Całkowite kalorie (tydzień)'**
  String get moreTotalCaloriesWeek;

  /// No description provided for @moreBurnedCaloriesWeek.
  ///
  /// In pl, this message translates to:
  /// **'Spalone kalorie (tydzień)'**
  String get moreBurnedCaloriesWeek;

  /// No description provided for @moreWaterWeek.
  ///
  /// In pl, this message translates to:
  /// **'Woda (tydzień)'**
  String get moreWaterWeek;

  /// No description provided for @moreCaloriesDuringWeek.
  ///
  /// In pl, this message translates to:
  /// **'Kalorie w ciągu tygodnia'**
  String get moreCaloriesDuringWeek;

  /// No description provided for @moreMacrosWeek.
  ///
  /// In pl, this message translates to:
  /// **'Makro (tydzień)'**
  String get moreMacrosWeek;

  /// No description provided for @moreProtein.
  ///
  /// In pl, this message translates to:
  /// **'Białko'**
  String get moreProtein;

  /// No description provided for @moreFat.
  ///
  /// In pl, this message translates to:
  /// **'Tłuszcze'**
  String get moreFat;

  /// No description provided for @moreCarbs.
  ///
  /// In pl, this message translates to:
  /// **'Węgle'**
  String get moreCarbs;

  /// No description provided for @moreCarbsFull.
  ///
  /// In pl, this message translates to:
  /// **'Węglowodany'**
  String get moreCarbsFull;

  /// No description provided for @moreGoalVerification.
  ///
  /// In pl, this message translates to:
  /// **'Weryfikacja celu'**
  String get moreGoalVerification;

  /// No description provided for @moreGoalVerificationHint.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadzaj posiłki i wagę codziennie przez tydzień. Aplikacja zweryfikuje Twój cel i zaproponuje poprawki, jeśli Twoje realne zapotrzebowanie różni się od kalkulatora.'**
  String get moreGoalVerificationHint;

  /// No description provided for @moreProgressDaysWithData.
  ///
  /// In pl, this message translates to:
  /// **'Postęp: {days}/7 dni z danymi'**
  String moreProgressDaysWithData({required int days});

  /// No description provided for @moreBasedOnLast7Days.
  ///
  /// In pl, this message translates to:
  /// **'Na podstawie ostatnich 7 dni:'**
  String get moreBasedOnLast7Days;

  /// No description provided for @moreAvgCaloriesPerDayBullet.
  ///
  /// In pl, this message translates to:
  /// **'• Średnio: ~{calories} kcal/dzień'**
  String moreAvgCaloriesPerDayBullet({required String calories});

  /// No description provided for @moreWeightStable.
  ///
  /// In pl, this message translates to:
  /// **'stała'**
  String get moreWeightStable;

  /// No description provided for @moreWeightIncrease.
  ///
  /// In pl, this message translates to:
  /// **'wzrost (+{kg} kg)'**
  String moreWeightIncrease({required String kg});

  /// No description provided for @moreWeightDecrease.
  ///
  /// In pl, this message translates to:
  /// **'spadek ({kg} kg)'**
  String moreWeightDecrease({required String kg});

  /// No description provided for @moreWeightBullet.
  ///
  /// In pl, this message translates to:
  /// **'• Waga: {change}'**
  String moreWeightBullet({required String change});

  /// No description provided for @moreSaving.
  ///
  /// In pl, this message translates to:
  /// **'Zapisywanie…'**
  String get moreSaving;

  /// No description provided for @moreApplyCorrectedGoal.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź poprawiony cel'**
  String get moreApplyCorrectedGoal;

  /// No description provided for @moreGoalAligned.
  ///
  /// In pl, this message translates to:
  /// **'Masz wystarczająco danych. Twój obecny cel jest zgodny z trendem – nie ma potrzeby korekty.'**
  String get moreGoalAligned;

  /// No description provided for @moreRealTdee.
  ///
  /// In pl, this message translates to:
  /// **'Realne zapotrzebowanie: ~{calories} kcal'**
  String moreRealTdee({required String calories});

  /// No description provided for @moreGoalUpdated.
  ///
  /// In pl, this message translates to:
  /// **'Cel zaktualizowany do ~{calories} kcal'**
  String moreGoalUpdated({required String calories});

  /// No description provided for @moreErrorWithDetails.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String moreErrorWithDetails({required String error});

  /// No description provided for @moreGoalHistoryReason.
  ///
  /// In pl, this message translates to:
  /// **'Weryfikacja na podstawie danych z ostatniego tygodnia'**
  String get moreGoalHistoryReason;

  /// No description provided for @moreDayMon.
  ///
  /// In pl, this message translates to:
  /// **'Pon'**
  String get moreDayMon;

  /// No description provided for @moreDayTue.
  ///
  /// In pl, this message translates to:
  /// **'Wt'**
  String get moreDayTue;

  /// No description provided for @moreDayWed.
  ///
  /// In pl, this message translates to:
  /// **'Śr'**
  String get moreDayWed;

  /// No description provided for @moreDayThu.
  ///
  /// In pl, this message translates to:
  /// **'Czw'**
  String get moreDayThu;

  /// No description provided for @moreDayFri.
  ///
  /// In pl, this message translates to:
  /// **'Pt'**
  String get moreDayFri;

  /// No description provided for @moreDaySat.
  ///
  /// In pl, this message translates to:
  /// **'Sob'**
  String get moreDaySat;

  /// No description provided for @moreDaySun.
  ///
  /// In pl, this message translates to:
  /// **'Nie'**
  String get moreDaySun;

  /// No description provided for @moreSuggestionWeightLossFlat.
  ///
  /// In pl, this message translates to:
  /// **'Waga stała przy ~{avg} kcal. Twoje realne zapotrzebowanie to ~{real} kcal. Chcesz schudnąć? Spróbuj ~{corr} kcal.'**
  String moreSuggestionWeightLossFlat({
    required String avg,
    required String real,
    required String corr,
  });

  /// No description provided for @moreSuggestionWeightLossDown.
  ///
  /// In pl, this message translates to:
  /// **'Chudniesz przy ~{avg} kcal. Realne TDEE: ~{real} kcal. Sugerowany cel: ~{corr} kcal.'**
  String moreSuggestionWeightLossDown({
    required String avg,
    required String real,
    required String corr,
  });

  /// No description provided for @moreSuggestionWeightGainFlat.
  ///
  /// In pl, this message translates to:
  /// **'Waga stała przy ~{avg} kcal. Twoje realne zapotrzebowanie to ~{real} kcal. Chcesz przytyć? Spróbuj ~{corr} kcal.'**
  String moreSuggestionWeightGainFlat({
    required String avg,
    required String real,
    required String corr,
  });

  /// No description provided for @moreSuggestionWeightGainUp.
  ///
  /// In pl, this message translates to:
  /// **'Tyjesz przy ~{avg} kcal. Realne TDEE: ~{real} kcal. Sugerowany cel: ~{corr} kcal.'**
  String moreSuggestionWeightGainUp({
    required String avg,
    required String real,
    required String corr,
  });

  /// No description provided for @moreSuggestionMaintain.
  ///
  /// In pl, this message translates to:
  /// **'Realne zapotrzebowanie: ~{real} kcal (kalkulator: {calc} kcal). Cel: ~{corr} kcal.'**
  String moreSuggestionMaintain({
    required String real,
    required String calc,
    required String corr,
  });

  /// No description provided for @moreBmiCalculatorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kalkulator BMI'**
  String get moreBmiCalculatorTitle;

  /// No description provided for @moreYourBmi.
  ///
  /// In pl, this message translates to:
  /// **'Twoje BMI'**
  String get moreYourBmi;

  /// No description provided for @moreCalculatedBasedOn.
  ///
  /// In pl, this message translates to:
  /// **'Obliczono na podstawie:'**
  String get moreCalculatedBasedOn;

  /// No description provided for @moreCurrentWeightBullet.
  ///
  /// In pl, this message translates to:
  /// **'• Aktualna waga: {weight} kg'**
  String moreCurrentWeightBullet({required String weight});

  /// No description provided for @moreHeightBullet.
  ///
  /// In pl, this message translates to:
  /// **'• Wzrost: {height} cm'**
  String moreHeightBullet({required String height});

  /// No description provided for @moreNormalBmiRangeHint.
  ///
  /// In pl, this message translates to:
  /// **'Aby być w normie (BMI 18,5–24,9), dąż do wagi w przedziale od {minKg} do {maxKg} kg.'**
  String moreNormalBmiRangeHint({required String minKg, required String maxKg});

  /// No description provided for @moreCompleteProfileForBmi.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij profil (waga i wzrost), aby zobaczyć swoje BMI'**
  String get moreCompleteProfileForBmi;

  /// No description provided for @moreBmiScale.
  ///
  /// In pl, this message translates to:
  /// **'Skala BMI'**
  String get moreBmiScale;

  /// No description provided for @moreBmiUnderweight.
  ///
  /// In pl, this message translates to:
  /// **'Niedowaga'**
  String get moreBmiUnderweight;

  /// No description provided for @moreBmiNormal.
  ///
  /// In pl, this message translates to:
  /// **'Normalna'**
  String get moreBmiNormal;

  /// No description provided for @moreBmiOverweight.
  ///
  /// In pl, this message translates to:
  /// **'Nadwaga'**
  String get moreBmiOverweight;

  /// No description provided for @moreBmiObesity1.
  ///
  /// In pl, this message translates to:
  /// **'Otyłość I stopnia'**
  String get moreBmiObesity1;

  /// No description provided for @moreBmiObesity2.
  ///
  /// In pl, this message translates to:
  /// **'Otyłość II stopnia'**
  String get moreBmiObesity2;

  /// No description provided for @moreBmiObesity3.
  ///
  /// In pl, this message translates to:
  /// **'Otyłość III stopnia'**
  String get moreBmiObesity3;

  /// No description provided for @moreBmiFormulaTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wzór BMI'**
  String get moreBmiFormulaTitle;

  /// No description provided for @moreBmiFormula.
  ///
  /// In pl, this message translates to:
  /// **'BMI = waga (kg) / wzrost (m)²'**
  String get moreBmiFormula;

  /// No description provided for @moreBmiExplanation.
  ///
  /// In pl, this message translates to:
  /// **'BMI to wskaźnik masy ciała, który pomaga ocenić, czy waga jest odpowiednia do wzrostu.'**
  String get moreBmiExplanation;

  /// No description provided for @moreExportTitle.
  ///
  /// In pl, this message translates to:
  /// **'Eksport danych'**
  String get moreExportTitle;

  /// No description provided for @moreExportDescription.
  ///
  /// In pl, this message translates to:
  /// **'Wyeksportuj dane do pliku CSV (pełna lista) lub PDF (raport z ostatnich 30 dni). Otworzy się okno udostępniania.'**
  String get moreExportDescription;

  /// No description provided for @moreExporting.
  ///
  /// In pl, this message translates to:
  /// **'Eksportowanie...'**
  String get moreExporting;

  /// No description provided for @moreExportToCsv.
  ///
  /// In pl, this message translates to:
  /// **'Eksportuj do CSV'**
  String get moreExportToCsv;

  /// No description provided for @moreExportToPdfPremium.
  ///
  /// In pl, this message translates to:
  /// **'Eksportuj do PDF (Premium)'**
  String get moreExportToPdfPremium;

  /// No description provided for @moreExportPdfFeature.
  ///
  /// In pl, this message translates to:
  /// **'Eksport do PDF'**
  String get moreExportPdfFeature;

  /// No description provided for @moreUserNotLoggedIn.
  ///
  /// In pl, this message translates to:
  /// **'Użytkownik nie jest zalogowany'**
  String get moreUserNotLoggedIn;

  /// No description provided for @moreCsvCopiedClipboard.
  ///
  /// In pl, this message translates to:
  /// **'Dane skopiowane do schowka. Wklej do Notatnika lub Excela i zapisz jako .csv'**
  String get moreCsvCopiedClipboard;

  /// No description provided for @moreCsvFileReady.
  ///
  /// In pl, this message translates to:
  /// **'Plik CSV gotowy. Możesz go zapisać lub udostępnić.'**
  String get moreCsvFileReady;

  /// No description provided for @moreCsvClipboardFallback.
  ///
  /// In pl, this message translates to:
  /// **'Dane wyeksportowane do schowka (CSV). Wklej je np. do Notatek i zapisz jako plik .csv'**
  String get moreCsvClipboardFallback;

  /// No description provided for @moreCsvClipboardShort.
  ///
  /// In pl, this message translates to:
  /// **'Dane wyeksportowane do schowka (CSV).'**
  String get moreCsvClipboardShort;

  /// No description provided for @moreExportFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wyeksportować. Sprawdź połączenie i spróbuj ponownie.'**
  String get moreExportFailed;

  /// No description provided for @moreExportShareText.
  ///
  /// In pl, this message translates to:
  /// **'Eksport danych Łatwa Forma'**
  String get moreExportShareText;

  /// No description provided for @moreExportShareSubject.
  ///
  /// In pl, this message translates to:
  /// **'Dane Łatwa Forma - {date}'**
  String moreExportShareSubject({required String date});

  /// No description provided for @morePdfReportShareText.
  ///
  /// In pl, this message translates to:
  /// **'Raport Łatwa Forma'**
  String get morePdfReportShareText;

  /// No description provided for @morePdfReportShareSubject.
  ///
  /// In pl, this message translates to:
  /// **'Raport Łatwa Forma - {date}'**
  String morePdfReportShareSubject({required String date});

  /// No description provided for @morePdfDownloaded.
  ///
  /// In pl, this message translates to:
  /// **'PDF został pobrany. Sprawdź folder Pobrane.'**
  String get morePdfDownloaded;

  /// No description provided for @morePdfShareOrDownloadFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się udostępnić ani pobrać PDF. Spróbuj w przeglądarce Chrome lub wyeksportuj do CSV.'**
  String get morePdfShareOrDownloadFailed;

  /// No description provided for @morePdfShareFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się udostępnić PDF. Spróbuj wyeksportować do CSV.'**
  String get morePdfShareFailed;

  /// No description provided for @morePdfFileReady.
  ///
  /// In pl, this message translates to:
  /// **'Plik PDF gotowy. Możesz go zapisać lub udostępnić.'**
  String get morePdfFileReady;

  /// No description provided for @morePdfExportFailedWithHint.
  ///
  /// In pl, this message translates to:
  /// **'Eksport PDF nie powiódł się ({hint}). Spróbuj do CSV.'**
  String morePdfExportFailedWithHint({required String hint});

  /// No description provided for @morePdfExportFailed.
  ///
  /// In pl, this message translates to:
  /// **'Eksport PDF nie powiódł się. Spróbuj ponownie lub wyeksportuj do CSV.'**
  String get morePdfExportFailed;

  /// No description provided for @moreCsvSectionProfile.
  ///
  /// In pl, this message translates to:
  /// **'=== PROFIL ==='**
  String get moreCsvSectionProfile;

  /// No description provided for @moreCsvHeaderTypeNameValue.
  ///
  /// In pl, this message translates to:
  /// **'Typ,Nazwa,Wartość'**
  String get moreCsvHeaderTypeNameValue;

  /// No description provided for @moreCsvProfile.
  ///
  /// In pl, this message translates to:
  /// **'Profil'**
  String get moreCsvProfile;

  /// No description provided for @moreCsvGender.
  ///
  /// In pl, this message translates to:
  /// **'Płeć'**
  String get moreCsvGender;

  /// No description provided for @moreGenderMale.
  ///
  /// In pl, this message translates to:
  /// **'Mężczyzna'**
  String get moreGenderMale;

  /// No description provided for @moreGenderFemale.
  ///
  /// In pl, this message translates to:
  /// **'Kobieta'**
  String get moreGenderFemale;

  /// No description provided for @moreGenderOther.
  ///
  /// In pl, this message translates to:
  /// **'Inna'**
  String get moreGenderOther;

  /// No description provided for @moreCsvAge.
  ///
  /// In pl, this message translates to:
  /// **'Wiek'**
  String get moreCsvAge;

  /// No description provided for @moreCsvAgeYears.
  ///
  /// In pl, this message translates to:
  /// **'{age} lat'**
  String moreCsvAgeYears({required String age});

  /// No description provided for @moreCsvHeight.
  ///
  /// In pl, this message translates to:
  /// **'Wzrost'**
  String get moreCsvHeight;

  /// No description provided for @moreCsvCurrentWeight.
  ///
  /// In pl, this message translates to:
  /// **'Aktualna waga'**
  String get moreCsvCurrentWeight;

  /// No description provided for @moreCsvTargetWeight.
  ///
  /// In pl, this message translates to:
  /// **'Waga docelowa'**
  String get moreCsvTargetWeight;

  /// No description provided for @moreCsvGoal.
  ///
  /// In pl, this message translates to:
  /// **'Cel'**
  String get moreCsvGoal;

  /// No description provided for @moreGoalWeightLoss.
  ///
  /// In pl, this message translates to:
  /// **'Utrata wagi'**
  String get moreGoalWeightLoss;

  /// No description provided for @moreGoalWeightGain.
  ///
  /// In pl, this message translates to:
  /// **'Przybranie wagi'**
  String get moreGoalWeightGain;

  /// No description provided for @moreGoalMaintain.
  ///
  /// In pl, this message translates to:
  /// **'Utrzymanie'**
  String get moreGoalMaintain;

  /// No description provided for @moreGoalMaintainWeight.
  ///
  /// In pl, this message translates to:
  /// **'Utrzymanie wagi'**
  String get moreGoalMaintainWeight;

  /// No description provided for @moreCsvCalorieGoal.
  ///
  /// In pl, this message translates to:
  /// **'Cel kaloryczny'**
  String get moreCsvCalorieGoal;

  /// No description provided for @moreCsvProteinG.
  ///
  /// In pl, this message translates to:
  /// **'Białko (g)'**
  String get moreCsvProteinG;

  /// No description provided for @moreCsvFatG.
  ///
  /// In pl, this message translates to:
  /// **'Tłuszcze (g)'**
  String get moreCsvFatG;

  /// No description provided for @moreCsvCarbsG.
  ///
  /// In pl, this message translates to:
  /// **'Węglowodany (g)'**
  String get moreCsvCarbsG;

  /// No description provided for @moreCsvTargetDate.
  ///
  /// In pl, this message translates to:
  /// **'Szacowany termin osiągnięcia celu'**
  String get moreCsvTargetDate;

  /// No description provided for @moreCsvSectionDiary.
  ///
  /// In pl, this message translates to:
  /// **'=== DANE DZIENNIKA ==='**
  String get moreCsvSectionDiary;

  /// No description provided for @moreCsvGarminNote.
  ///
  /// In pl, this message translates to:
  /// **'# Dane aktywności mogą obejmować dane z urządzeń Garmin.'**
  String get moreCsvGarminNote;

  /// No description provided for @moreCsvHeaderDiary.
  ///
  /// In pl, this message translates to:
  /// **'Typ,Nazwa,Wartość,Data,Źródło danych'**
  String get moreCsvHeaderDiary;

  /// No description provided for @moreCsvMeal.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek'**
  String get moreCsvMeal;

  /// No description provided for @moreCsvActivity.
  ///
  /// In pl, this message translates to:
  /// **'Aktywność'**
  String get moreCsvActivity;

  /// No description provided for @moreCsvWeight.
  ///
  /// In pl, this message translates to:
  /// **'Waga'**
  String get moreCsvWeight;

  /// No description provided for @morePdfReportTitle.
  ///
  /// In pl, this message translates to:
  /// **'Łatwa Forma – Raport'**
  String get morePdfReportTitle;

  /// No description provided for @morePdfPageFooter.
  ///
  /// In pl, this message translates to:
  /// **'Strona {page} z {pages} • Wygenerowano {date}'**
  String morePdfPageFooter({
    required String page,
    required String pages,
    required String date,
  });

  /// No description provided for @morePdfProfileSummary.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie profilu'**
  String get morePdfProfileSummary;

  /// No description provided for @morePdfProfileLine1.
  ///
  /// In pl, this message translates to:
  /// **'Płeć: {gender} • Wiek: {age} lat • Wzrost: {height} cm'**
  String morePdfProfileLine1({
    required String gender,
    required String age,
    required String height,
  });

  /// No description provided for @morePdfProfileLine2.
  ///
  /// In pl, this message translates to:
  /// **'Waga: {weight} kg • Cel: {target} kg • Cel kaloryczny: {calories} kcal'**
  String morePdfProfileLine2({
    required String weight,
    required String target,
    required String calories,
  });

  /// No description provided for @morePdfGoalWeightLoss.
  ///
  /// In pl, this message translates to:
  /// **'Cel: Utrata wagi'**
  String get morePdfGoalWeightLoss;

  /// No description provided for @morePdfGoalWeightGain.
  ///
  /// In pl, this message translates to:
  /// **'Cel: Przybranie wagi'**
  String get morePdfGoalWeightGain;

  /// No description provided for @morePdfGoalMaintain.
  ///
  /// In pl, this message translates to:
  /// **'Cel: Utrzymanie wagi'**
  String get morePdfGoalMaintain;

  /// No description provided for @morePdfNoProfile.
  ///
  /// In pl, this message translates to:
  /// **'Brak profilu'**
  String get morePdfNoProfile;

  /// No description provided for @morePdfMealsLast30.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnie 30 dni – posiłki'**
  String get morePdfMealsLast30;

  /// No description provided for @morePdfNoMeals.
  ///
  /// In pl, this message translates to:
  /// **'Brak posiłków'**
  String get morePdfNoMeals;

  /// No description provided for @morePdfDate.
  ///
  /// In pl, this message translates to:
  /// **'Data'**
  String get morePdfDate;

  /// No description provided for @morePdfName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get morePdfName;

  /// No description provided for @morePdfActivitiesLast30.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnie 30 dni – aktywności'**
  String get morePdfActivitiesLast30;

  /// No description provided for @morePdfNoActivities.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywności'**
  String get morePdfNoActivities;

  /// No description provided for @morePdfGarminAttribution.
  ///
  /// In pl, this message translates to:
  /// **'Dane aktywności pochodzą z urządzeń Garmin.'**
  String get morePdfGarminAttribution;

  /// No description provided for @morePdfWeightHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia wagi'**
  String get morePdfWeightHistory;

  /// No description provided for @morePdfNoMeasurements.
  ///
  /// In pl, this message translates to:
  /// **'Brak pomiarów'**
  String get morePdfNoMeasurements;

  /// No description provided for @morePdfWeightKg.
  ///
  /// In pl, this message translates to:
  /// **'Waga (kg)'**
  String get morePdfWeightKg;

  /// No description provided for @moreNotificationsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia'**
  String get moreNotificationsTitle;

  /// No description provided for @moreWaterReminders.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia o wodzie'**
  String get moreWaterReminders;

  /// No description provided for @moreMealReminders.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia o posiłkach'**
  String get moreMealReminders;

  /// No description provided for @moreAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj'**
  String get moreAdd;

  /// No description provided for @moreMealBreakfast.
  ///
  /// In pl, this message translates to:
  /// **'Śniadanie'**
  String get moreMealBreakfast;

  /// No description provided for @moreMealLunch.
  ///
  /// In pl, this message translates to:
  /// **'Obiad'**
  String get moreMealLunch;

  /// No description provided for @moreMealDinner.
  ///
  /// In pl, this message translates to:
  /// **'Kolacja'**
  String get moreMealDinner;

  /// No description provided for @moreMealSnack.
  ///
  /// In pl, this message translates to:
  /// **'Przekąska'**
  String get moreMealSnack;

  /// No description provided for @moreMealDefault.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek'**
  String get moreMealDefault;

  /// No description provided for @moreNewMealReminder.
  ///
  /// In pl, this message translates to:
  /// **'Nowe przypomnienie o posiłku'**
  String get moreNewMealReminder;

  /// No description provided for @moreMealNameLabel.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa posiłku'**
  String get moreMealNameLabel;

  /// No description provided for @moreMealNameHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Drugie śniadanie, Podwieczorek'**
  String get moreMealNameHint;

  /// No description provided for @moreEditReminder.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj przypomnienie'**
  String get moreEditReminder;

  /// No description provided for @moreNotifWaterTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pamiętaj o wodzie! 💧'**
  String get moreNotifWaterTitle;

  /// No description provided for @moreNotifWaterBody.
  ///
  /// In pl, this message translates to:
  /// **'Czas na szklankę wody'**
  String get moreNotifWaterBody;

  /// No description provided for @moreNotifWaterChannel.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia o wodzie'**
  String get moreNotifWaterChannel;

  /// No description provided for @moreNotifWaterChannelDesc.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia o piciu wody'**
  String get moreNotifWaterChannelDesc;

  /// No description provided for @moreNotifMealTitle.
  ///
  /// In pl, this message translates to:
  /// **'Czas na {label}! 🍽️'**
  String moreNotifMealTitle({required String label});

  /// No description provided for @moreNotifMealBody.
  ///
  /// In pl, this message translates to:
  /// **'Nie zapomnij zarejestrować posiłku'**
  String get moreNotifMealBody;

  /// No description provided for @moreNotifMealChannel.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia o posiłkach'**
  String get moreNotifMealChannel;

  /// No description provided for @moreNotifMealChannelDesc.
  ///
  /// In pl, this message translates to:
  /// **'Przypomnienia o rejestracji posiłków'**
  String get moreNotifMealChannelDesc;

  /// No description provided for @moreIntegrationsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Integracje'**
  String get moreIntegrationsTitle;

  /// No description provided for @moreLoginToFinishStrava.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się, aby dokończyć połączenie ze Strava'**
  String get moreLoginToFinishStrava;

  /// No description provided for @moreLoginToFinishGarmin.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się, aby dokończyć połączenie z Garmin'**
  String get moreLoginToFinishGarmin;

  /// No description provided for @moreStravaConnectedImported.
  ///
  /// In pl, this message translates to:
  /// **'Strava połączona. Zaimportowano {count} aktywności.'**
  String moreStravaConnectedImported({required int count});

  /// No description provided for @moreStravaConnectedNoNew.
  ///
  /// In pl, this message translates to:
  /// **'Strava połączona. Brak nowych aktywności do importu.'**
  String get moreStravaConnectedNoNew;

  /// No description provided for @moreStravaConnectedSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Strava połączona pomyślnie'**
  String get moreStravaConnectedSuccess;

  /// No description provided for @moreStravaSyncFailedLater.
  ///
  /// In pl, this message translates to:
  /// **'Synchronizacja nie powiodła się. Kliknij „Synchronizuj aktywności” później.'**
  String get moreStravaSyncFailedLater;

  /// No description provided for @moreGarminSessionExpiredRetry.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Spróbuj ponownie połączyć Garmin.'**
  String get moreGarminSessionExpiredRetry;

  /// No description provided for @moreGarminSessionRejected.
  ///
  /// In pl, this message translates to:
  /// **'Sesja odrzucona: {message}. Wyloguj się, zaloguj ponownie i spróbuj połączyć Garmin.'**
  String moreGarminSessionRejected({required String message});

  /// No description provided for @moreGarminSessionExpiredRelogin.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Wyloguj się i zaloguj ponownie do Łatwej Formy, potem kliknij „Połącz z Garmin Connect”.'**
  String get moreGarminSessionExpiredRelogin;

  /// No description provided for @moreConnectedSuccessfully.
  ///
  /// In pl, this message translates to:
  /// **'Połączono pomyślnie!'**
  String get moreConnectedSuccessfully;

  /// No description provided for @moreGarminSessionExpiredShort.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Wyloguj się i zaloguj ponownie, potem połącz Garmin.'**
  String get moreGarminSessionExpiredShort;

  /// No description provided for @moreGarminError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd Garmin: {error}'**
  String moreGarminError({required String error});

  /// No description provided for @moreStravaEnvMissing.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj STRAVA_CLIENT_ID i STRAVA_CLIENT_SECRET do pliku .env'**
  String get moreStravaEnvMissing;

  /// No description provided for @moreGarminEnvMissing.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj GARMIN_CLIENT_ID do env (po zatwierdzeniu programu).'**
  String get moreGarminEnvMissing;

  /// No description provided for @moreLoginAgainForGarmin.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się ponownie, aby uzupełnić dane Garmin.'**
  String get moreLoginAgainForGarmin;

  /// No description provided for @moreCouldNotComplete.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się: {message}'**
  String moreCouldNotComplete({required String message});

  /// No description provided for @moreGarminNoUserId.
  ///
  /// In pl, this message translates to:
  /// **'Garmin nie zwrócił User ID. Spróbuj odłączyć i połączyć ponownie.'**
  String get moreGarminNoUserId;

  /// No description provided for @moreGarminReceiveDataSaved.
  ///
  /// In pl, this message translates to:
  /// **'Dane do odbierania aktywności zapisane. Nowe treningi z Garmin Connect będą się pojawiać w aplikacji.'**
  String get moreGarminReceiveDataSaved;

  /// No description provided for @moreGarminDisconnectFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wywołać odłączenia u Garmin: {error}'**
  String moreGarminDisconnectFailed({required String error});

  /// No description provided for @moreGarminDisconnectedTitle.
  ///
  /// In pl, this message translates to:
  /// **'Garmin Connect odłączony'**
  String get moreGarminDisconnectedTitle;

  /// No description provided for @moreGarminDisconnectedBody.
  ///
  /// In pl, this message translates to:
  /// **'Połączenie z Garmin Connect zostało usunięte. Nowe aktywności nie będą już dodawane automatycznie. Możesz połączyć ponownie w dowolnym momencie.'**
  String get moreGarminDisconnectedBody;

  /// No description provided for @moreStravaDisconnected.
  ///
  /// In pl, this message translates to:
  /// **'Strava odłączona'**
  String get moreStravaDisconnected;

  /// No description provided for @moreConnectStravaFirst.
  ///
  /// In pl, this message translates to:
  /// **'Najpierw połącz konto Strava'**
  String get moreConnectStravaFirst;

  /// No description provided for @moreImportedFromStrava.
  ///
  /// In pl, this message translates to:
  /// **'Zaimportowano {count} aktywności ze Strava'**
  String moreImportedFromStrava({required int count});

  /// No description provided for @moreNoNewActivities.
  ///
  /// In pl, this message translates to:
  /// **'Brak nowych aktywności do importu'**
  String get moreNoNewActivities;

  /// No description provided for @moreSyncError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd synchronizacji: {error}'**
  String moreSyncError({required String error});

  /// No description provided for @moreStravaImportDesc.
  ///
  /// In pl, this message translates to:
  /// **'Importuj wszystkie aktywności i spalone kalorie'**
  String get moreStravaImportDesc;

  /// No description provided for @moreConnected.
  ///
  /// In pl, this message translates to:
  /// **'Połączona'**
  String get moreConnected;

  /// No description provided for @moreSyncing.
  ///
  /// In pl, this message translates to:
  /// **'Synchronizuję...'**
  String get moreSyncing;

  /// No description provided for @moreSyncActivities.
  ///
  /// In pl, this message translates to:
  /// **'Synchronizuj aktywności'**
  String get moreSyncActivities;

  /// No description provided for @moreDisconnectStrava.
  ///
  /// In pl, this message translates to:
  /// **'Odłącz Strava'**
  String get moreDisconnectStrava;

  /// No description provided for @moreConnecting.
  ///
  /// In pl, this message translates to:
  /// **'Łączę...'**
  String get moreConnecting;

  /// No description provided for @moreConnectStrava.
  ///
  /// In pl, this message translates to:
  /// **'Połącz ze Strava'**
  String get moreConnectStrava;

  /// No description provided for @moreGarminImportDesc.
  ///
  /// In pl, this message translates to:
  /// **'Aktywności z Garmin dodawane automatycznie po synchronizacji z Garmin Connect'**
  String get moreGarminImportDesc;

  /// No description provided for @moreGarminAutoImportInfo.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie nowe aktywności z Garmin Connect są importowane do aplikacji. To Ty decydujesz, którą wliczyć do bilansu.'**
  String get moreGarminAutoImportInfo;

  /// No description provided for @moreGarminNeedUserId.
  ///
  /// In pl, this message translates to:
  /// **'Żeby aktywności z Garmin pojawiały się w aplikacji, zapisz dane połączenia (ID Garmin).'**
  String get moreGarminNeedUserId;

  /// No description provided for @moreSavingShort.
  ///
  /// In pl, this message translates to:
  /// **'Zapisuję...'**
  String get moreSavingShort;

  /// No description provided for @moreCompleteActivityReceiveData.
  ///
  /// In pl, this message translates to:
  /// **'Uzupełnij dane do odbierania aktywności'**
  String get moreCompleteActivityReceiveData;

  /// No description provided for @moreDisconnectGarmin.
  ///
  /// In pl, this message translates to:
  /// **'Odłącz Garmin'**
  String get moreDisconnectGarmin;

  /// No description provided for @moreConnectGarmin.
  ///
  /// In pl, this message translates to:
  /// **'Połącz z Garmin Connect'**
  String get moreConnectGarmin;

  /// No description provided for @moreGarminDisconnectErrorStatus.
  ///
  /// In pl, this message translates to:
  /// **'Błąd odłączania: {status}'**
  String moreGarminDisconnectErrorStatus({required String status});

  /// No description provided for @moreErrorStatusCode.
  ///
  /// In pl, this message translates to:
  /// **'Błąd {code}'**
  String moreErrorStatusCode({required String code});

  /// No description provided for @moreChallengesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Cele i wyzwania'**
  String get moreChallengesTitle;

  /// No description provided for @moreNoChallenges.
  ///
  /// In pl, this message translates to:
  /// **'Brak celów i wyzwań'**
  String get moreNoChallenges;

  /// No description provided for @moreNoChallengesHint.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj cel lub wyzwanie, aby śledzić swoje postępy'**
  String get moreNoChallengesHint;

  /// No description provided for @moreProgressPercent.
  ///
  /// In pl, this message translates to:
  /// **'Postęp: {percent}%'**
  String moreProgressPercent({required String percent});

  /// No description provided for @moreStartDate.
  ///
  /// In pl, this message translates to:
  /// **'Start: {date}'**
  String moreStartDate({required String date});

  /// No description provided for @moreEndDate.
  ///
  /// In pl, this message translates to:
  /// **'Koniec: {date}'**
  String moreEndDate({required String date});

  /// No description provided for @moreDeleteChallengeTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usuń wyzwanie'**
  String get moreDeleteChallengeTitle;

  /// No description provided for @moreDeleteChallengeConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć \"{title}\"?'**
  String moreDeleteChallengeConfirm({required String title});

  /// No description provided for @moreChallengeDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Wyzwanie usunięte'**
  String get moreChallengeDeleted;

  /// No description provided for @morePickStartDate.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz datę rozpoczęcia'**
  String get morePickStartDate;

  /// No description provided for @morePickEndDate.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz datę zakończenia'**
  String get morePickEndDate;

  /// No description provided for @morePick.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz'**
  String get morePick;

  /// No description provided for @moreChallengeAdded.
  ///
  /// In pl, this message translates to:
  /// **'Wyzwanie dodane pomyślnie!'**
  String get moreChallengeAdded;

  /// No description provided for @moreTargetWeightKg.
  ///
  /// In pl, this message translates to:
  /// **'Cel wagi (kg)'**
  String get moreTargetWeightKg;

  /// No description provided for @moreCalorieDeficitKcal.
  ///
  /// In pl, this message translates to:
  /// **'Deficyt kaloryczny (kcal)'**
  String get moreCalorieDeficitKcal;

  /// No description provided for @moreWaterAmountMl.
  ///
  /// In pl, this message translates to:
  /// **'Ilość wody (ml)'**
  String get moreWaterAmountMl;

  /// No description provided for @moreWorkoutCount.
  ///
  /// In pl, this message translates to:
  /// **'Liczba treningów'**
  String get moreWorkoutCount;

  /// No description provided for @moreStreakLengthDays.
  ///
  /// In pl, this message translates to:
  /// **'Długość serii (dni)'**
  String get moreStreakLengthDays;

  /// No description provided for @moreTargetValue.
  ///
  /// In pl, this message translates to:
  /// **'Wartość docelowa'**
  String get moreTargetValue;

  /// No description provided for @moreAddChallenge.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wyzwanie'**
  String get moreAddChallenge;

  /// No description provided for @moreChallengeType.
  ///
  /// In pl, this message translates to:
  /// **'Typ wyzwania'**
  String get moreChallengeType;

  /// No description provided for @moreCalorieDeficit.
  ///
  /// In pl, this message translates to:
  /// **'Deficyt kaloryczny'**
  String get moreCalorieDeficit;

  /// No description provided for @moreWater.
  ///
  /// In pl, this message translates to:
  /// **'Woda'**
  String get moreWater;

  /// No description provided for @moreExercise.
  ///
  /// In pl, this message translates to:
  /// **'Ćwiczenia'**
  String get moreExercise;

  /// No description provided for @moreStreak.
  ///
  /// In pl, this message translates to:
  /// **'Seria'**
  String get moreStreak;

  /// No description provided for @moreChallengeTitleLabel.
  ///
  /// In pl, this message translates to:
  /// **'Tytuł wyzwania'**
  String get moreChallengeTitleLabel;

  /// No description provided for @moreChallengeTitleHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Schudnij 5 kg'**
  String get moreChallengeTitleHint;

  /// No description provided for @moreChallengeTitleRequired.
  ///
  /// In pl, this message translates to:
  /// **'Podaj tytuł wyzwania'**
  String get moreChallengeTitleRequired;

  /// No description provided for @moreDescriptionOptional.
  ///
  /// In pl, this message translates to:
  /// **'Opis (opcjonalnie)'**
  String get moreDescriptionOptional;

  /// No description provided for @moreChallengeDescHint.
  ///
  /// In pl, this message translates to:
  /// **'Dodatkowe informacje o wyzwaniu'**
  String get moreChallengeDescHint;

  /// No description provided for @moreOptional.
  ///
  /// In pl, this message translates to:
  /// **'Opcjonalnie'**
  String get moreOptional;

  /// No description provided for @moreStartDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data rozpoczęcia'**
  String get moreStartDateLabel;

  /// No description provided for @moreSetEndDate.
  ///
  /// In pl, this message translates to:
  /// **'Ustaw datę zakończenia'**
  String get moreSetEndDate;

  /// No description provided for @moreEndDateLabel.
  ///
  /// In pl, this message translates to:
  /// **'Data zakończenia'**
  String get moreEndDateLabel;

  /// No description provided for @morePickDate.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz datę'**
  String get morePickDate;

  /// No description provided for @moreStreaksTitle.
  ///
  /// In pl, this message translates to:
  /// **'Serie'**
  String get moreStreaksTitle;

  /// No description provided for @moreNoStreaks.
  ///
  /// In pl, this message translates to:
  /// **'Brak serii'**
  String get moreNoStreaks;

  /// No description provided for @moreNoStreaksHint.
  ///
  /// In pl, this message translates to:
  /// **'Zacznij śledzić swoje nawyki, aby zobaczyć serie'**
  String get moreNoStreaksHint;

  /// No description provided for @moreLastTime.
  ///
  /// In pl, this message translates to:
  /// **'Ostatni raz: {date}'**
  String moreLastTime({required String date});

  /// No description provided for @moreCurrentStreak.
  ///
  /// In pl, this message translates to:
  /// **'Aktualna seria'**
  String get moreCurrentStreak;

  /// No description provided for @moreLongestStreak.
  ///
  /// In pl, this message translates to:
  /// **'Najdłuższa seria'**
  String get moreLongestStreak;

  /// No description provided for @moreStreakMeals.
  ///
  /// In pl, this message translates to:
  /// **'Posiłki'**
  String get moreStreakMeals;

  /// No description provided for @moreStreakActivities.
  ///
  /// In pl, this message translates to:
  /// **'Aktywności'**
  String get moreStreakActivities;

  /// No description provided for @moreStreakWeight.
  ///
  /// In pl, this message translates to:
  /// **'Waga'**
  String get moreStreakWeight;

  /// No description provided for @moreAiAdviceTitle.
  ///
  /// In pl, this message translates to:
  /// **'Porada AI'**
  String get moreAiAdviceTitle;

  /// No description provided for @moreAiLimitReachedPremium.
  ///
  /// In pl, this message translates to:
  /// **'Wykorzystałeś dzisiejszy limit ({limit} zapytań). Spróbuj jutro.'**
  String moreAiLimitReachedPremium({required String limit});

  /// No description provided for @moreAiLimitReachedFree.
  ///
  /// In pl, this message translates to:
  /// **'Wykorzystałeś dzisiejszy limit ({limit} zapytań). Spróbuj jutro lub przejdź na Premium.'**
  String moreAiLimitReachedFree({required String limit});

  /// No description provided for @moreAiNeedsConnection.
  ///
  /// In pl, this message translates to:
  /// **'Porada AI wymaga połączenia z aplikacją (Supabase) lub klucza OpenAI w konfiguracji.'**
  String get moreAiNeedsConnection;

  /// No description provided for @moreAiNoResponse.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się uzyskać odpowiedzi. Spróbuj ponownie.'**
  String get moreAiNoResponse;

  /// No description provided for @moreAiRemainingToday.
  ///
  /// In pl, this message translates to:
  /// **'Pozostało zapytań dziś: {remaining} / {limit}'**
  String moreAiRemainingToday({
    required String remaining,
    required String limit,
  });

  /// No description provided for @moreAiRemainingTodayPremium.
  ///
  /// In pl, this message translates to:
  /// **'Pozostało zapytań dziś: {remaining} / {limit} (Premium)'**
  String moreAiRemainingTodayPremium({
    required String remaining,
    required String limit,
  });

  /// No description provided for @moreAiIntro.
  ///
  /// In pl, this message translates to:
  /// **'Zapytaj o poradę w zakresie diety, odżywiania lub aktywności fizycznej. Odpowiedź generuje AI i nie zastępuje konsultacji z lekarzem.'**
  String get moreAiIntro;

  /// No description provided for @moreAiHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Ile białka potrzebuję przy treningu siłowym?'**
  String get moreAiHint;

  /// No description provided for @moreAiAnswer.
  ///
  /// In pl, this message translates to:
  /// **'Odpowiedź'**
  String get moreAiAnswer;

  /// No description provided for @profErrNetwork.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia z internetem. Sprawdź sieć i spróbuj ponownie.'**
  String get profErrNetwork;

  /// No description provided for @profErrCors.
  ///
  /// In pl, this message translates to:
  /// **'Błąd połączenia z usługą. Odśwież stronę i spróbuj ponownie.'**
  String get profErrCors;

  /// No description provided for @profErrTimeout.
  ///
  /// In pl, this message translates to:
  /// **'Przekroczono limit czasu. Spróbuj ponownie.'**
  String get profErrTimeout;

  /// No description provided for @profErrAuth.
  ///
  /// In pl, this message translates to:
  /// **'Błąd autoryzacji. Zaloguj się ponownie.'**
  String get profErrAuth;

  /// No description provided for @profErrNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono zasobu.'**
  String get profErrNotFound;

  /// No description provided for @profErrServer.
  ///
  /// In pl, this message translates to:
  /// **'Błąd serwera. Spróbuj później.'**
  String get profErrServer;

  /// No description provided for @profErrGeneric.
  ///
  /// In pl, this message translates to:
  /// **'Wystąpił błąd. Spróbuj ponownie.'**
  String get profErrGeneric;

  /// No description provided for @profOfflineBanner.
  ///
  /// In pl, this message translates to:
  /// **'Brak połączenia z internetem.'**
  String get profOfflineBanner;

  /// No description provided for @premFeatureTitle.
  ///
  /// In pl, this message translates to:
  /// **'Funkcja Premium'**
  String get premFeatureTitle;

  /// No description provided for @premFeatureDialog.
  ///
  /// In pl, this message translates to:
  /// **'{feature} jest dostępna w planie Premium. Czy chcesz dowiedzieć się więcej?'**
  String premFeatureDialog({required String feature});

  /// No description provided for @premFeatureThis.
  ///
  /// In pl, this message translates to:
  /// **'Ta funkcja'**
  String get premFeatureThis;

  /// No description provided for @premSeePremium.
  ///
  /// In pl, this message translates to:
  /// **'Zobacz Premium'**
  String get premSeePremium;

  /// No description provided for @premLockedTitle.
  ///
  /// In pl, this message translates to:
  /// **'{feature} jest w Premium'**
  String premLockedTitle({required String feature});

  /// No description provided for @premLockedBody.
  ///
  /// In pl, this message translates to:
  /// **'Odblokuj nieograniczoną poradę AI, eksport PDF i więcej.'**
  String get premLockedBody;

  /// No description provided for @premCheckPremium.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź Premium'**
  String get premCheckPremium;

  /// No description provided for @premThanks.
  ///
  /// In pl, this message translates to:
  /// **'Dziękujemy!'**
  String get premThanks;

  /// No description provided for @premActivatedBody.
  ///
  /// In pl, this message translates to:
  /// **'Premium zostało aktywowane.\nCiesz się pełnym dostępem do Łatwa Forma – eksport PDF, porady AI, integracje i więcej.'**
  String get premActivatedBody;

  /// No description provided for @premBackToApp.
  ///
  /// In pl, this message translates to:
  /// **'Wróć do aplikacji'**
  String get premBackToApp;

  /// No description provided for @premCloseTabHint.
  ///
  /// In pl, this message translates to:
  /// **'Możesz też zamknąć tę kartę, jeśli płatność była w osobnym oknie.'**
  String get premCloseTabHint;

  /// No description provided for @premPaymentCancelled.
  ///
  /// In pl, this message translates to:
  /// **'Płatność anulowana'**
  String get premPaymentCancelled;

  /// No description provided for @premCancelBody.
  ///
  /// In pl, this message translates to:
  /// **'Nic nie zostało pobrane. Możesz wrócić i wybrać plan, kiedy będziesz gotowy.'**
  String get premCancelBody;

  /// No description provided for @premBackToPlans.
  ///
  /// In pl, this message translates to:
  /// **'Wróć do planów Premium'**
  String get premBackToPlans;

  /// No description provided for @premGoToApp.
  ///
  /// In pl, this message translates to:
  /// **'Przejdź do aplikacji'**
  String get premGoToApp;

  /// No description provided for @premTitle.
  ///
  /// In pl, this message translates to:
  /// **'Łatwa Forma Premium'**
  String get premTitle;

  /// No description provided for @premHavePremium.
  ///
  /// In pl, this message translates to:
  /// **'Masz Premium!'**
  String get premHavePremium;

  /// No description provided for @premUnlockPotential.
  ///
  /// In pl, this message translates to:
  /// **'Odblokuj pełny potencjał'**
  String get premUnlockPotential;

  /// No description provided for @premAllFeaturesAvailable.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie funkcje premium są dla Ciebie dostępne.'**
  String get premAllFeaturesAvailable;

  /// No description provided for @premValidUntil.
  ///
  /// In pl, this message translates to:
  /// **'Ważne do: {date}'**
  String premValidUntil({required String date});

  /// No description provided for @premTrialTitle.
  ///
  /// In pl, this message translates to:
  /// **'Okres próbny (24 h)'**
  String get premTrialTitle;

  /// No description provided for @premTrialLeft.
  ///
  /// In pl, this message translates to:
  /// **'Pozostało: {hours}h {minutes}min. '**
  String premTrialLeft({required int hours, required int minutes});

  /// No description provided for @premTrialBody.
  ///
  /// In pl, this message translates to:
  /// **'Wszystkie funkcje premium są teraz dostępne. {remaining}Po tym czasie funkcje Premium się wyłączą, dopóki nie wykupisz planu. Okres próbny nie pobiera opłaty i nie zapisuje Cię automatycznie na subskrypcję.'**
  String premTrialBody({required String remaining});

  /// No description provided for @premFeatHistoryOtherDays.
  ///
  /// In pl, this message translates to:
  /// **'Przeglądanie historii innych dni niż dziś'**
  String get premFeatHistoryOtherDays;

  /// No description provided for @premFeatMacrosDash.
  ///
  /// In pl, this message translates to:
  /// **'Podgląd makroskładników na dashboardzie'**
  String get premFeatMacrosDash;

  /// No description provided for @premFeatAiAdvice.
  ///
  /// In pl, this message translates to:
  /// **'Porada AI (limit 100 dziennie)'**
  String get premFeatAiAdvice;

  /// No description provided for @premFeatAiPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Analiza AI posiłku ze zdjęcia'**
  String get premFeatAiPhoto;

  /// No description provided for @premFeatIngredients.
  ///
  /// In pl, this message translates to:
  /// **'Dodawanie posiłku ze składników'**
  String get premFeatIngredients;

  /// No description provided for @premFeatEatingOut.
  ///
  /// In pl, this message translates to:
  /// **'Dodawanie posiłku „na mieście”'**
  String get premFeatEatingOut;

  /// No description provided for @premFeatQuickActivity.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie dodawanie w aktywnościach'**
  String get premFeatQuickActivity;

  /// No description provided for @premFeatShare.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnianie podsumowania i tygodniowych statystyk'**
  String get premFeatShare;

  /// No description provided for @premFeatPdf.
  ///
  /// In pl, this message translates to:
  /// **'Eksport raportów do PDF'**
  String get premFeatPdf;

  /// No description provided for @premFeatCustomCalories.
  ///
  /// In pl, this message translates to:
  /// **'Własny cel kaloryczny w edycji profilu'**
  String get premFeatCustomCalories;

  /// No description provided for @premFeatCustomMacros.
  ///
  /// In pl, this message translates to:
  /// **'Własne makroskładniki w edycji profilu'**
  String get premFeatCustomMacros;

  /// No description provided for @premFeatStrava.
  ///
  /// In pl, this message translates to:
  /// **'Integracje Strava bez limitów'**
  String get premFeatStrava;

  /// No description provided for @premFeatGoals.
  ///
  /// In pl, this message translates to:
  /// **'Zaawansowane cele i wyzwania'**
  String get premFeatGoals;

  /// No description provided for @premChoosePlan.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz plan'**
  String get premChoosePlan;

  /// No description provided for @premPlanMonthly.
  ///
  /// In pl, this message translates to:
  /// **'Łatwa Forma Premium – miesięcznie'**
  String get premPlanMonthly;

  /// No description provided for @premPlanMonthlyPeriod.
  ///
  /// In pl, this message translates to:
  /// **'1 miesiąc, auto-odnawiane'**
  String get premPlanMonthlyPeriod;

  /// No description provided for @premPlanYearly.
  ///
  /// In pl, this message translates to:
  /// **'Łatwa Forma Premium – rocznie'**
  String get premPlanYearly;

  /// No description provided for @premPlanYearlyPeriod.
  ///
  /// In pl, this message translates to:
  /// **'12 miesięcy, auto-odnawiane'**
  String get premPlanYearlyPeriod;

  /// No description provided for @premBadgeSave.
  ///
  /// In pl, this message translates to:
  /// **'Oszczędzasz ~17%'**
  String get premBadgeSave;

  /// No description provided for @premPlanYearlyOnce.
  ///
  /// In pl, this message translates to:
  /// **'Rocznie (jednorazowo)'**
  String get premPlanYearlyOnce;

  /// No description provided for @premPlanYearlyOncePeriod.
  ///
  /// In pl, this message translates to:
  /// **'za rok'**
  String get premPlanYearlyOncePeriod;

  /// No description provided for @premBadgeBlik.
  ///
  /// In pl, this message translates to:
  /// **'Tylko BLIK'**
  String get premBadgeBlik;

  /// No description provided for @premYearlyOnceSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'płatność raz na rok, bez subskrypcji'**
  String get premYearlyOnceSubtitle;

  /// No description provided for @premHaveCode.
  ///
  /// In pl, this message translates to:
  /// **'Mam kod'**
  String get premHaveCode;

  /// No description provided for @premCodeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kod'**
  String get premCodeLabel;

  /// No description provided for @premRedeemTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Zrealizuj'**
  String get premRedeemTooltip;

  /// No description provided for @premOpeningPayment.
  ///
  /// In pl, this message translates to:
  /// **'Otwieram płatność…'**
  String get premOpeningPayment;

  /// No description provided for @premProcessingPurchase.
  ///
  /// In pl, this message translates to:
  /// **'Przetwarzam zakup…'**
  String get premProcessingPurchase;

  /// No description provided for @premBuy.
  ///
  /// In pl, this message translates to:
  /// **'Wykup Premium'**
  String get premBuy;

  /// No description provided for @premRestoring.
  ///
  /// In pl, this message translates to:
  /// **'Przywracam…'**
  String get premRestoring;

  /// No description provided for @premRestorePurchases.
  ///
  /// In pl, this message translates to:
  /// **'Przywróć zakupy'**
  String get premRestorePurchases;

  /// No description provided for @premPaymentNoteWeb.
  ///
  /// In pl, this message translates to:
  /// **'Rocznie (jednorazowo) – tylko BLIK. Subskrypcja – karta, Apple Pay, Google Pay. Subskrypcja odnawia się automatycznie, dopóki jej nie anulujesz.'**
  String get premPaymentNoteWeb;

  /// No description provided for @premPaymentNoteMobile.
  ///
  /// In pl, this message translates to:
  /// **'Płatność przez App Store / Google Play. „Łatwa Forma Premium – miesięcznie” (1 miesiąc) i „Łatwa Forma Premium – rocznie” (12 miesięcy) odnawiają się automatycznie za cenę pokazaną powyżej, aż anulujesz w ustawieniach sklepu. BLIK jest na latwaforma.pl. Podstawowe funkcje działają bez subskrypcji.'**
  String get premPaymentNoteMobile;

  /// No description provided for @premAutoActivate.
  ///
  /// In pl, this message translates to:
  /// **'Po opłaceniu konto Premium aktywuje się automatycznie.'**
  String get premAutoActivate;

  /// No description provided for @premPrivacy.
  ///
  /// In pl, this message translates to:
  /// **'Polityka prywatności'**
  String get premPrivacy;

  /// No description provided for @premTerms.
  ///
  /// In pl, this message translates to:
  /// **'Regulamin'**
  String get premTerms;

  /// No description provided for @premEula.
  ///
  /// In pl, this message translates to:
  /// **'Terms of Use (EULA)'**
  String get premEula;

  /// No description provided for @premActivating.
  ///
  /// In pl, this message translates to:
  /// **'Aktywuję…'**
  String get premActivating;

  /// No description provided for @premActivateTest.
  ///
  /// In pl, this message translates to:
  /// **'Aktywuj Premium (test)'**
  String get premActivateTest;

  /// No description provided for @premAvailableFeatures.
  ///
  /// In pl, this message translates to:
  /// **'Dostępne funkcje:'**
  String get premAvailableFeatures;

  /// No description provided for @premFeatActiveHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia innych dni'**
  String get premFeatActiveHistory;

  /// No description provided for @premFeatActiveMacros.
  ///
  /// In pl, this message translates to:
  /// **'Makro na dashboardzie'**
  String get premFeatActiveMacros;

  /// No description provided for @premFeatActiveAiPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Analiza AI posiłku'**
  String get premFeatActiveAiPhoto;

  /// No description provided for @premFeatActiveIngredients.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek ze składników'**
  String get premFeatActiveIngredients;

  /// No description provided for @premFeatActiveEatingOut.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek „na mieście”'**
  String get premFeatActiveEatingOut;

  /// No description provided for @premFeatActiveQuickActivity.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie dodawanie aktywności'**
  String get premFeatActiveQuickActivity;

  /// No description provided for @premFeatActiveShare.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnianie podsumowania i statystyk'**
  String get premFeatActiveShare;

  /// No description provided for @premFeatActivePdf.
  ///
  /// In pl, this message translates to:
  /// **'Eksport do PDF'**
  String get premFeatActivePdf;

  /// No description provided for @premFeatActiveCalories.
  ///
  /// In pl, this message translates to:
  /// **'Własny cel kaloryczny'**
  String get premFeatActiveCalories;

  /// No description provided for @premFeatActiveMacrosCustom.
  ///
  /// In pl, this message translates to:
  /// **'Własne makroskładniki'**
  String get premFeatActiveMacrosCustom;

  /// No description provided for @premFeatActiveStrava.
  ///
  /// In pl, this message translates to:
  /// **'Integracje Strava'**
  String get premFeatActiveStrava;

  /// No description provided for @premFeatActiveGoals.
  ///
  /// In pl, this message translates to:
  /// **'Zaawansowane cele'**
  String get premFeatActiveGoals;

  /// No description provided for @premOpening.
  ///
  /// In pl, this message translates to:
  /// **'Otwieram…'**
  String get premOpening;

  /// No description provided for @premCancelSub.
  ///
  /// In pl, this message translates to:
  /// **'Anuluj subskrypcję'**
  String get premCancelSub;

  /// No description provided for @premManageSub.
  ///
  /// In pl, this message translates to:
  /// **'Zarządzaj subskrypcją'**
  String get premManageSub;

  /// No description provided for @premCancelNoteWeb.
  ///
  /// In pl, this message translates to:
  /// **'Możesz anulować subskrypcję. Dostęp do Premium pozostanie do końca opłaconego okresu.'**
  String get premCancelNoteWeb;

  /// No description provided for @premCancelNoteMobile.
  ///
  /// In pl, this message translates to:
  /// **'Anulowanie w ustawieniach App Store / Google Play. Dostęp Premium do końca opłaconego okresu.'**
  String get premCancelNoteMobile;

  /// No description provided for @premEnterEmail.
  ///
  /// In pl, this message translates to:
  /// **'Podaj adres e-mail.'**
  String get premEnterEmail;

  /// No description provided for @premCodeSent.
  ///
  /// In pl, this message translates to:
  /// **'Kod wysłany'**
  String get premCodeSent;

  /// No description provided for @premCodeSentBody.
  ///
  /// In pl, this message translates to:
  /// **'Wysłaliśmy link i kod na {email}. Sprawdź skrzynkę (także folder Spam) – kliknij link w mailu albo wpisz kod poniżej.'**
  String premCodeSentBody({required String email});

  /// No description provided for @premSignedIn.
  ///
  /// In pl, this message translates to:
  /// **'Zalogowano'**
  String get premSignedIn;

  /// No description provided for @premSignedInBuy.
  ///
  /// In pl, this message translates to:
  /// **'Możesz teraz wykupić Premium.'**
  String get premSignedInBuy;

  /// No description provided for @premAccountExistsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Konto z tym adresem e-mail istnieje.'**
  String get premAccountExistsTitle;

  /// No description provided for @premAccountExistsBody.
  ///
  /// In pl, this message translates to:
  /// **'Próbujesz się zalogować na konto powiązane z tym adresem e-mail. Na tym urządzeniu masz inne dane (profil, posiłki itd.).\n\nCo chcesz zrobić?\n\n• Zaktualizować tamto konto – obecnymi danymi z tego urządzenia (profil, posiłki zostaną przeniesione).\n\n• Przywrócić dane konta – zobaczysz dane przypisane do konta z tym e-mailem (obecne dane z urządzenia nie będą użyte).\n\nW obu przypadkach musisz potwierdzić tożsamość – kliknij link w mailu lub wpisz kod weryfikacyjny.'**
  String get premAccountExistsBody;

  /// No description provided for @premRestoreAccountData.
  ///
  /// In pl, this message translates to:
  /// **'Przywróć dane konta'**
  String get premRestoreAccountData;

  /// No description provided for @premUpdateWithCurrent.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizuj konto tymi danymi'**
  String get premUpdateWithCurrent;

  /// No description provided for @premConfirmIdentity.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź tożsamość'**
  String get premConfirmIdentity;

  /// No description provided for @premVerifyEmailSent.
  ///
  /// In pl, this message translates to:
  /// **'Wysłaliśmy wiadomość na {email}. Możesz kliknąć link weryfikacyjny w mailu albo wpisać kod poniżej (sprawdź też folder Spam).'**
  String premVerifyEmailSent({required String email});

  /// No description provided for @premVerificationCode.
  ///
  /// In pl, this message translates to:
  /// **'Kod weryfikacyjny'**
  String get premVerificationCode;

  /// No description provided for @premCodeHint.
  ///
  /// In pl, this message translates to:
  /// **'np. 123456'**
  String get premCodeHint;

  /// No description provided for @premEnterFullCode.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz pełny kod z maila (min. 6 znaków).'**
  String get premEnterFullCode;

  /// No description provided for @premLoggedInMergeError.
  ///
  /// In pl, this message translates to:
  /// **'Zalogowano. Błąd przenoszenia danych: {error}'**
  String premLoggedInMergeError({required String error});

  /// No description provided for @premVerifyErrorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Błąd weryfikacji'**
  String get premVerifyErrorTitle;

  /// No description provided for @premVerifyErrorBody.
  ///
  /// In pl, this message translates to:
  /// **'Kod wygasł lub jest nieprawidłowy. Wyślij ponownie.'**
  String get premVerifyErrorBody;

  /// No description provided for @premConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdź'**
  String get premConfirm;

  /// No description provided for @premConnErrorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Błąd połączenia'**
  String get premConnErrorTitle;

  /// No description provided for @premConnErrorBody.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się połączyć z płatnościami. Spróbuj za chwilę lub napisz do nas: contact@latwaforma.pl'**
  String get premConnErrorBody;

  /// No description provided for @premLoginToBuy.
  ///
  /// In pl, this message translates to:
  /// **'Aby wykupić Premium, zaloguj się (Apple, Google albo e-mail z kodem powyżej).'**
  String get premLoginToBuy;

  /// No description provided for @premCodeNotForOnce.
  ///
  /// In pl, this message translates to:
  /// **'Ten kod nie działa przy płatności jednorazowej.'**
  String get premCodeNotForOnce;

  /// No description provided for @premTryLaterContact.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj za chwilę ponownie lub napisz do nas: contact@latwaforma.pl'**
  String get premTryLaterContact;

  /// No description provided for @premOpenPaymentFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się otworzyć płatności'**
  String get premOpenPaymentFailed;

  /// No description provided for @premCannotOpenPaymentPage.
  ///
  /// In pl, this message translates to:
  /// **'Nie można otworzyć strony płatności.'**
  String get premCannotOpenPaymentPage;

  /// No description provided for @premCheckoutSessionError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd tworzenia sesji płatności.'**
  String get premCheckoutSessionError;

  /// No description provided for @premTryLaterContactShort.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj za chwilę lub napisz do nas: contact@latwaforma.pl'**
  String get premTryLaterContactShort;

  /// No description provided for @premLoginToUseCode.
  ///
  /// In pl, this message translates to:
  /// **'Aby użyć kodu, zaloguj się (Apple, Google albo e-mail).'**
  String get premLoginToUseCode;

  /// No description provided for @premCodeSheetFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się otworzyć wpisywania kodu. Spróbuj ponownie.'**
  String get premCodeSheetFailed;

  /// No description provided for @premEnterCode.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz kod.'**
  String get premEnterCode;

  /// No description provided for @premPlayStoreFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się otworzyć Sklepu Play.'**
  String get premPlayStoreFailed;

  /// No description provided for @premLoginToBuyMobile.
  ///
  /// In pl, this message translates to:
  /// **'Aby wykupić Premium, zaloguj się (Google, Apple lub e-mail z kodem powyżej).'**
  String get premLoginToBuyMobile;

  /// No description provided for @premThanksActive.
  ///
  /// In pl, this message translates to:
  /// **'Dziękujemy! Premium powinno być już aktywne. Jeśli funkcje są jeszcze zablokowane, odczekaj chwilę lub wróć do aplikacji.'**
  String get premThanksActive;

  /// No description provided for @premPurchasePending.
  ///
  /// In pl, this message translates to:
  /// **'Zakup zakończony. Status Premium odświeży się za chwilę. Jeśli nie – użyj „Przywróć zakupy”.'**
  String get premPurchasePending;

  /// No description provided for @premInfo.
  ///
  /// In pl, this message translates to:
  /// **'Informacja'**
  String get premInfo;

  /// No description provided for @premPurchaseErrorTitle.
  ///
  /// In pl, this message translates to:
  /// **'Błąd zakupu'**
  String get premPurchaseErrorTitle;

  /// No description provided for @premPurchaseErrorBody.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się dokończyć zakupu. Sprawdź połączenie i konfigurację sklepu, albo napisz: contact@latwaforma.pl\n\n{error}'**
  String premPurchaseErrorBody({required String error});

  /// No description provided for @premLoginToRestore.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się, aby przywrócić zakupy.'**
  String get premLoginToRestore;

  /// No description provided for @premRestoredTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zakupy przywrócone'**
  String get premRestoredTitle;

  /// No description provided for @premNoPurchasesTitle.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywnych zakupów'**
  String get premNoPurchasesTitle;

  /// No description provided for @premRestoredBody.
  ///
  /// In pl, this message translates to:
  /// **'Twoje Premium zostało przywrócone. Jeśli nie widzisz odblokowania, odczekaj chwilę.'**
  String get premRestoredBody;

  /// No description provided for @premNoPurchasesBody.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono aktywnej subskrypcji powiązanej z tym kontem sklepu.'**
  String get premNoPurchasesBody;

  /// No description provided for @premRestoreFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się przywrócić zakupów: {error}'**
  String premRestoreFailed({required String error});

  /// No description provided for @premSubscription.
  ///
  /// In pl, this message translates to:
  /// **'Subskrypcja'**
  String get premSubscription;

  /// No description provided for @premManageHint.
  ///
  /// In pl, this message translates to:
  /// **'Otwórz ustawienia subskrypcji w sklepie Apple / Google, aby anulować lub zarządzać Premium.'**
  String get premManageHint;

  /// No description provided for @premSessionExpired.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła'**
  String get premSessionExpired;

  /// No description provided for @premLoginAgain.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się ponownie.'**
  String get premLoginAgain;

  /// No description provided for @premPortalHintWeb.
  ///
  /// In pl, this message translates to:
  /// **'Odśwież stronę (F5) i spróbuj ponownie. Jeśli problem się powtarza, wyloguj się i zaloguj ponownie.'**
  String get premPortalHintWeb;

  /// No description provided for @premPortalHintMobile.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj się w profilu i zaloguj ponownie, potem spróbuj „Anuluj subskrypcję” jeszcze raz.'**
  String get premPortalHintMobile;

  /// No description provided for @premCannotOpenPortal.
  ///
  /// In pl, this message translates to:
  /// **'Nie można otworzyć portalu.'**
  String get premCannotOpenPortal;

  /// No description provided for @premPortalOpenError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd otwierania portalu.'**
  String get premPortalOpenError;

  /// No description provided for @premSessionExpiredCancel.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Wyloguj się w profilu i zaloguj ponownie, potem spróbuj „Anuluj subskrypcję” jeszcze raz.'**
  String get premSessionExpiredCancel;

  /// No description provided for @premErrorWithDetail.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String premErrorWithDetail({required String error});

  /// No description provided for @premActivatedEnjoy.
  ///
  /// In pl, this message translates to:
  /// **'Premium aktywowane. Ciesz się pełnym dostępem!'**
  String get premActivatedEnjoy;

  /// No description provided for @premLoginToBuyCard.
  ///
  /// In pl, this message translates to:
  /// **'Aby wykupić Premium, potrzebne jest konto. Zaloguj się przez Google, Apple albo podaj adres e-mail – wyślemy wiadomość z linkiem weryfikacyjnym i kodem.'**
  String get premLoginToBuyCard;

  /// No description provided for @premSigningIn.
  ///
  /// In pl, this message translates to:
  /// **'Logowanie…'**
  String get premSigningIn;

  /// No description provided for @premContinueGoogle.
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj z Google'**
  String get premContinueGoogle;

  /// No description provided for @premContinueApple.
  ///
  /// In pl, this message translates to:
  /// **'Kontynuuj z Apple'**
  String get premContinueApple;

  /// No description provided for @premOrEmail.
  ///
  /// In pl, this message translates to:
  /// **'lub e-mail:'**
  String get premOrEmail;

  /// No description provided for @premEmailLabel.
  ///
  /// In pl, this message translates to:
  /// **'Adres e-mail'**
  String get premEmailLabel;

  /// No description provided for @premEmailHint.
  ///
  /// In pl, this message translates to:
  /// **'np. jan@example.com'**
  String get premEmailHint;

  /// No description provided for @premSending.
  ///
  /// In pl, this message translates to:
  /// **'Wysyłam…'**
  String get premSending;

  /// No description provided for @premSendCode.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij kod'**
  String get premSendCode;

  /// No description provided for @premConfirmIdentityHint.
  ///
  /// In pl, this message translates to:
  /// **'Potwierdź tożsamość: wpisz poniżej kod z maila albo kliknij link weryfikacyjny w wiadomości (sprawdź też folder Spam).'**
  String get premConfirmIdentityHint;

  /// No description provided for @premChecking.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdzam…'**
  String get premChecking;

  /// No description provided for @premConfirmAndSignIn.
  ///
  /// In pl, this message translates to:
  /// **'Zatwierdź i zaloguj'**
  String get premConfirmAndSignIn;

  /// No description provided for @premResendOtherEmail.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij kod ponownie na inny adres'**
  String get premResendOtherEmail;

  /// No description provided for @profTitle.
  ///
  /// In pl, this message translates to:
  /// **'Profil'**
  String get profTitle;

  /// No description provided for @profNotifications.
  ///
  /// In pl, this message translates to:
  /// **'Powiadomienia'**
  String get profNotifications;

  /// No description provided for @profNoProfile.
  ///
  /// In pl, this message translates to:
  /// **'Brak profilu'**
  String get profNoProfile;

  /// No description provided for @profErrorWithDetail.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String profErrorWithDetail({required String error});

  /// No description provided for @profAccountGoogle.
  ///
  /// In pl, this message translates to:
  /// **'Konto Google'**
  String get profAccountGoogle;

  /// No description provided for @profAccountEmail.
  ///
  /// In pl, this message translates to:
  /// **'Konto e-mail'**
  String get profAccountEmail;

  /// No description provided for @profAccountSignedIn.
  ///
  /// In pl, this message translates to:
  /// **'Konto zalogowane'**
  String get profAccountSignedIn;

  /// No description provided for @profSignOutTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj się'**
  String get profSignOutTitle;

  /// No description provided for @profSignOutBody.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz się wylogować? Możesz ponownie zalogować się później.'**
  String get profSignOutBody;

  /// No description provided for @profSignOutConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Wyloguj'**
  String get profSignOutConfirm;

  /// No description provided for @profDeleteAccountTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usuń konto'**
  String get profDeleteAccountTitle;

  /// No description provided for @profDeleteAccountBody.
  ///
  /// In pl, this message translates to:
  /// **'Twoje dane zostaną całkowicie usunięte i nie będzie można ich przywrócić. Gdy wrócisz do aplikacji, trzeba będzie uzupełnić profil od nowa.\n\nJeśli masz subskrypcję Premium w Google Play lub App Store, anuluj ją osobno w sklepie – usunięcie konta jej nie kończy.\n\nCzy na pewno chcesz usunąć konto?'**
  String get profDeleteAccountBody;

  /// No description provided for @profAccountDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Konto zostało usunięte'**
  String get profAccountDeleted;

  /// No description provided for @profDeleteUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Usługa usuwania konta jest niedostępna. Skontaktuj się z nami: {email}'**
  String profDeleteUnavailable({required String email});

  /// No description provided for @profSessionExpiredRetry.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Zaloguj się ponownie i spróbuj jeszcze raz.'**
  String get profSessionExpiredRetry;

  /// No description provided for @profNoPermission.
  ///
  /// In pl, this message translates to:
  /// **'Brak uprawnień do wykonania tej operacji.'**
  String get profNoPermission;

  /// No description provided for @profDeleteFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się usunąć konta. Spróbuj ponownie później.'**
  String get profDeleteFailed;

  /// No description provided for @profInviteTitle.
  ///
  /// In pl, this message translates to:
  /// **'Zaproś znajomego'**
  String get profInviteTitle;

  /// No description provided for @profInviteBody.
  ///
  /// In pl, this message translates to:
  /// **'Podaj adres e-mail osoby, której chcesz wysłać zaproszenie do Łatwa Forma.'**
  String get profInviteBody;

  /// No description provided for @profEmailLabel.
  ///
  /// In pl, this message translates to:
  /// **'Adres e-mail'**
  String get profEmailLabel;

  /// No description provided for @profEmailHintFriend.
  ///
  /// In pl, this message translates to:
  /// **'np. znajomy@example.com'**
  String get profEmailHintFriend;

  /// No description provided for @profSessionExpiredWebInvite.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Odśwież stronę (F5) i zaloguj się ponownie, potem wyślij zaproszenie.'**
  String get profSessionExpiredWebInvite;

  /// No description provided for @profLoginAgainRetry.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się ponownie i spróbuj jeszcze raz.'**
  String get profLoginAgainRetry;

  /// No description provided for @profInviteSent.
  ///
  /// In pl, this message translates to:
  /// **'Zaproszenie wysłane'**
  String get profInviteSent;

  /// No description provided for @profSessionExpiredWebRetry.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Odśwież stronę (F5) i spróbuj ponownie. Jeśli problem się powtarza, wyloguj się i zaloguj ponownie.'**
  String get profSessionExpiredWebRetry;

  /// No description provided for @profSessionExpiredInviteMobile.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Wyloguj się i zaloguj ponownie, potem wyślij zaproszenie.'**
  String get profSessionExpiredInviteMobile;

  /// No description provided for @profInviteAlreadySent.
  ///
  /// In pl, this message translates to:
  /// **'Na ten adres wysłano już zaproszenie. Sprawdź skrzynkę (w tym spam) lub podaj inny adres.'**
  String get profInviteAlreadySent;

  /// No description provided for @profEmailAlreadyRegistered.
  ///
  /// In pl, this message translates to:
  /// **'Ten adres e-mail jest już zarejestrowany w Łatwa Forma. Zaproś kogoś innego.'**
  String get profEmailAlreadyRegistered;

  /// No description provided for @profInviteRateLimit.
  ///
  /// In pl, this message translates to:
  /// **'Zbyt wiele zaproszeń. Poczekaj chwilę i spróbuj ponownie.'**
  String get profInviteRateLimit;

  /// No description provided for @profEnterValidEmail.
  ///
  /// In pl, this message translates to:
  /// **'Podaj prawidłowy adres e-mail.'**
  String get profEnterValidEmail;

  /// No description provided for @profInviteSendFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się wysłać zaproszenia. Spróbuj ponownie.'**
  String get profInviteSendFailed;

  /// No description provided for @profSessionExpiredWebShort.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Odśwież stronę (F5) i spróbuj ponownie.'**
  String get profSessionExpiredWebShort;

  /// No description provided for @profSessionExpiredSignOutIn.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Wyloguj się i zaloguj ponownie.'**
  String get profSessionExpiredSignOutIn;

  /// No description provided for @profSendInvite.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij zaproszenie'**
  String get profSendInvite;

  /// No description provided for @profInviteSentExclaim.
  ///
  /// In pl, this message translates to:
  /// **'Zaproszenie wysłane!'**
  String get profInviteSentExclaim;

  /// No description provided for @profSaveProgress.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz postępy'**
  String get profSaveProgress;

  /// No description provided for @profSaveProgressHint.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się przez Apple, Google albo e-mail, aby nie stracić danych'**
  String get profSaveProgressHint;

  /// No description provided for @profBasicData.
  ///
  /// In pl, this message translates to:
  /// **'Dane podstawowe'**
  String get profBasicData;

  /// No description provided for @profGender.
  ///
  /// In pl, this message translates to:
  /// **'Płeć'**
  String get profGender;

  /// No description provided for @profAge.
  ///
  /// In pl, this message translates to:
  /// **'Wiek'**
  String get profAge;

  /// No description provided for @profAgeYears.
  ///
  /// In pl, this message translates to:
  /// **'{age} lat'**
  String profAgeYears({required int age});

  /// No description provided for @profHeight.
  ///
  /// In pl, this message translates to:
  /// **'Wzrost'**
  String get profHeight;

  /// No description provided for @profCurrentWeight.
  ///
  /// In pl, this message translates to:
  /// **'Aktualna waga'**
  String get profCurrentWeight;

  /// No description provided for @profTargetWeight.
  ///
  /// In pl, this message translates to:
  /// **'Waga docelowa'**
  String get profTargetWeight;

  /// No description provided for @profActivityLevel.
  ///
  /// In pl, this message translates to:
  /// **'Poziom aktywności'**
  String get profActivityLevel;

  /// No description provided for @profGoal.
  ///
  /// In pl, this message translates to:
  /// **'Cel'**
  String get profGoal;

  /// No description provided for @profCalculations.
  ///
  /// In pl, this message translates to:
  /// **'Obliczenia'**
  String get profCalculations;

  /// No description provided for @profBmrExplain.
  ///
  /// In pl, this message translates to:
  /// **'Zapotrzebowanie kaloryczne w spoczynku – ile kalorii spalasz bez aktywności.'**
  String get profBmrExplain;

  /// No description provided for @profTdeeExplain.
  ///
  /// In pl, this message translates to:
  /// **'Całkowite dzienne zapotrzebowanie – ile kalorii spalasz w ciągu dnia z uwzględnieniem aktywności.'**
  String get profTdeeExplain;

  /// No description provided for @profCalorieGoalExplain.
  ///
  /// In pl, this message translates to:
  /// **'Zalecane dzienne spożycie kalorii do osiągnięcia celu wagowego.'**
  String get profCalorieGoalExplain;

  /// No description provided for @profWaterGoal.
  ///
  /// In pl, this message translates to:
  /// **'Cel picia wody'**
  String get profWaterGoal;

  /// No description provided for @profWaterGoalExplanation.
  ///
  /// In pl, this message translates to:
  /// **'Obliczone z Twojej wagi: {mlPerKg} ml na każdy kg ({weightKg} kg → ok. {rawMl} ml, zaokrąglone do {goalMl} ml). Możesz zmienić cel ręcznie.'**
  String profWaterGoalExplanation({
    required int mlPerKg,
    required String weightKg,
    required int rawMl,
    required int goalMl,
  });

  /// No description provided for @profMacros.
  ///
  /// In pl, this message translates to:
  /// **'Makro'**
  String get profMacros;

  /// No description provided for @profProtein.
  ///
  /// In pl, this message translates to:
  /// **'Białko'**
  String get profProtein;

  /// No description provided for @profFat.
  ///
  /// In pl, this message translates to:
  /// **'Tłuszcze'**
  String get profFat;

  /// No description provided for @profCarbs.
  ///
  /// In pl, this message translates to:
  /// **'Węglowodany'**
  String get profCarbs;

  /// No description provided for @profCarbsShort.
  ///
  /// In pl, this message translates to:
  /// **'Węgle'**
  String get profCarbsShort;

  /// No description provided for @profTargetDateTitle.
  ///
  /// In pl, this message translates to:
  /// **'Termin osiągnięcia celu:'**
  String get profTargetDateTitle;

  /// No description provided for @profTargetDateHint.
  ///
  /// In pl, this message translates to:
  /// **'Działaj zgodnie z planem, a ten dzień się nie opóźni.'**
  String get profTargetDateHint;

  /// No description provided for @profSpeedUpHint.
  ///
  /// In pl, this message translates to:
  /// **'Chcesz przyspieszyć cel? Edytuj tempo zmiany wagi w trybie edycji profilu (ikona ołówka u góry).'**
  String get profSpeedUpHint;

  /// No description provided for @profMaintainNoDateTitle.
  ///
  /// In pl, this message translates to:
  /// **'Cel: utrzymanie wagi'**
  String get profMaintainNoDateTitle;

  /// No description provided for @profMaintainNoDateBody.
  ///
  /// In pl, this message translates to:
  /// **'Przy utrzymaniu wagi nie ma osobnego terminu „osiągnięcia”. Zmień cel na schudnięcie lub przytycie (oraz wagę docelową) — wtedy powiem Ci, kiedy mniej więcej go osiągniesz.'**
  String get profMaintainNoDateBody;

  /// No description provided for @profMaintainNoDateCta.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj cel w profilu'**
  String get profMaintainNoDateCta;

  /// No description provided for @profAiAdvice.
  ///
  /// In pl, this message translates to:
  /// **'Porada AI'**
  String get profAiAdvice;

  /// No description provided for @profAiAdviceHint.
  ///
  /// In pl, this message translates to:
  /// **'Zapytaj o dietę, odżywianie i aktywność'**
  String get profAiAdviceHint;

  /// No description provided for @profBmiTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kalkulator BMI'**
  String get profBmiTitle;

  /// No description provided for @profBmiHint.
  ///
  /// In pl, this message translates to:
  /// **'Sprawdź swój wskaźnik masy ciała'**
  String get profBmiHint;

  /// No description provided for @profTrialLeft.
  ///
  /// In pl, this message translates to:
  /// **'Pozostało: {hours}h {minutes}min'**
  String profTrialLeft({required int hours, required int minutes});

  /// No description provided for @profPremiumTitleActive.
  ///
  /// In pl, this message translates to:
  /// **'Łatwa Forma Premium'**
  String get profPremiumTitleActive;

  /// No description provided for @profPremiumTitle.
  ///
  /// In pl, this message translates to:
  /// **'Subskrypcja Premium'**
  String get profPremiumTitle;

  /// No description provided for @profActive.
  ///
  /// In pl, this message translates to:
  /// **'Aktywna'**
  String get profActive;

  /// No description provided for @profPremiumHintActive.
  ///
  /// In pl, this message translates to:
  /// **'Nieograniczona AI, eksport PDF, integracje'**
  String get profPremiumHintActive;

  /// No description provided for @profPremiumHint.
  ///
  /// In pl, this message translates to:
  /// **'Odblokuj pełny potencjał – AI, PDF, integracje'**
  String get profPremiumHint;

  /// No description provided for @profIntegrations.
  ///
  /// In pl, this message translates to:
  /// **'Integracje'**
  String get profIntegrations;

  /// No description provided for @profIntegrationsHint.
  ///
  /// In pl, this message translates to:
  /// **'Strava – importuj aktywności i spalone kalorie'**
  String get profIntegrationsHint;

  /// No description provided for @profExport.
  ///
  /// In pl, this message translates to:
  /// **'Eksport danych'**
  String get profExport;

  /// No description provided for @profExportHint.
  ///
  /// In pl, this message translates to:
  /// **'Wyeksportuj swoje dane do CSV'**
  String get profExportHint;

  /// No description provided for @profInviteHint.
  ///
  /// In pl, this message translates to:
  /// **'Wyślij zaproszenie e-mailem do aplikacji Łatwa Forma'**
  String get profInviteHint;

  /// No description provided for @profPrivacy.
  ///
  /// In pl, this message translates to:
  /// **'Polityka prywatności'**
  String get profPrivacy;

  /// No description provided for @profTerms.
  ///
  /// In pl, this message translates to:
  /// **'Regulamin'**
  String get profTerms;

  /// No description provided for @profEula.
  ///
  /// In pl, this message translates to:
  /// **'Terms of Use (EULA)'**
  String get profEula;

  /// No description provided for @profDeleteAccountPage.
  ///
  /// In pl, this message translates to:
  /// **'Usuń konto (strona)'**
  String get profDeleteAccountPage;

  /// No description provided for @profYourAccount.
  ///
  /// In pl, this message translates to:
  /// **'Twoje konto'**
  String get profYourAccount;

  /// No description provided for @profDeviceData.
  ///
  /// In pl, this message translates to:
  /// **'Dane na tym urządzeniu'**
  String get profDeviceData;

  /// No description provided for @profDeviceDataHint.
  ///
  /// In pl, this message translates to:
  /// **'Korzystasz bez konta. Możesz usunąć zapisany profil i posiłki z tego urządzenia.'**
  String get profDeviceDataHint;

  /// No description provided for @profDeleteData.
  ///
  /// In pl, this message translates to:
  /// **'Usuń dane'**
  String get profDeleteData;

  /// No description provided for @profDeleteDataBody.
  ///
  /// In pl, this message translates to:
  /// **'Profil, posiłki i inne dane z tego urządzenia zostaną trwale usunięte. Nie da się ich przywrócić.\n\nCzy na pewno chcesz usunąć dane?'**
  String get profDeleteDataBody;

  /// No description provided for @profDataDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Dane z urządzenia zostały usunięte.'**
  String get profDataDeleted;

  /// No description provided for @profGenderMale.
  ///
  /// In pl, this message translates to:
  /// **'Mężczyzna'**
  String get profGenderMale;

  /// No description provided for @profGenderFemale.
  ///
  /// In pl, this message translates to:
  /// **'Kobieta'**
  String get profGenderFemale;

  /// No description provided for @profGenderOther.
  ///
  /// In pl, this message translates to:
  /// **'Inna'**
  String get profGenderOther;

  /// No description provided for @profActSedentary.
  ///
  /// In pl, this message translates to:
  /// **'Siedzący'**
  String get profActSedentary;

  /// No description provided for @profActLight.
  ///
  /// In pl, this message translates to:
  /// **'Lekka'**
  String get profActLight;

  /// No description provided for @profActModerate.
  ///
  /// In pl, this message translates to:
  /// **'Umiarkowana'**
  String get profActModerate;

  /// No description provided for @profActIntense.
  ///
  /// In pl, this message translates to:
  /// **'Intensywna'**
  String get profActIntense;

  /// No description provided for @profActVeryIntense.
  ///
  /// In pl, this message translates to:
  /// **'Bardzo intensywna'**
  String get profActVeryIntense;

  /// No description provided for @profGoalLoss.
  ///
  /// In pl, this message translates to:
  /// **'Utrata wagi'**
  String get profGoalLoss;

  /// No description provided for @profGoalGain.
  ///
  /// In pl, this message translates to:
  /// **'Przybranie wagi'**
  String get profGoalGain;

  /// No description provided for @profGoalMaintain.
  ///
  /// In pl, this message translates to:
  /// **'Utrzymanie wagi'**
  String get profGoalMaintain;

  /// No description provided for @profGenderRequired.
  ///
  /// In pl, this message translates to:
  /// **'Płeć *'**
  String get profGenderRequired;

  /// No description provided for @profAgeRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wiek *'**
  String get profAgeRequired;

  /// No description provided for @profYearsSuffix.
  ///
  /// In pl, this message translates to:
  /// **'lat'**
  String get profYearsSuffix;

  /// No description provided for @profHeightRequired.
  ///
  /// In pl, this message translates to:
  /// **'Wzrost (cm) *'**
  String get profHeightRequired;

  /// No description provided for @profCurrentWeightRequired.
  ///
  /// In pl, this message translates to:
  /// **'Aktualna waga (kg) *'**
  String get profCurrentWeightRequired;

  /// No description provided for @profTargetWeightRequired.
  ///
  /// In pl, this message translates to:
  /// **'Waga docelowa (kg) *'**
  String get profTargetWeightRequired;

  /// No description provided for @profWeightDiffError.
  ///
  /// In pl, this message translates to:
  /// **'Różnica między wagami musi wynosić co najmniej 1 kg'**
  String get profWeightDiffError;

  /// No description provided for @profActivityRequired.
  ///
  /// In pl, this message translates to:
  /// **'Poziom aktywności *'**
  String get profActivityRequired;

  /// No description provided for @profActSedentaryDesc.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywności lub minimalna'**
  String get profActSedentaryDesc;

  /// No description provided for @profActLightDesc.
  ///
  /// In pl, this message translates to:
  /// **'1-3 treningi / tydzień'**
  String get profActLightDesc;

  /// No description provided for @profActModerateDesc.
  ///
  /// In pl, this message translates to:
  /// **'3-5 treningów / tydzień'**
  String get profActModerateDesc;

  /// No description provided for @profActIntenseDesc.
  ///
  /// In pl, this message translates to:
  /// **'6-7 treningów / tydzień'**
  String get profActIntenseDesc;

  /// No description provided for @profActVeryIntenseDesc.
  ///
  /// In pl, this message translates to:
  /// **'2x dziennie / ciężka praca'**
  String get profActVeryIntenseDesc;

  /// No description provided for @profWaterGoalMl.
  ///
  /// In pl, this message translates to:
  /// **'Cel wody (ml)'**
  String get profWaterGoalMl;

  /// No description provided for @profWaterGoalHelper.
  ///
  /// In pl, this message translates to:
  /// **'Możesz zmienić ręcznie. Poniżej wyjaśnienie, skąd bierze się propozycja.'**
  String get profWaterGoalHelper;

  /// No description provided for @profSaveChanges.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz zmiany'**
  String get profSaveChanges;

  /// No description provided for @profWantLose.
  ///
  /// In pl, this message translates to:
  /// **'Chcę schudnąć.'**
  String get profWantLose;

  /// No description provided for @profWantGain.
  ///
  /// In pl, this message translates to:
  /// **'Chcę przybrać na wadze.'**
  String get profWantGain;

  /// No description provided for @profWantMaintain.
  ///
  /// In pl, this message translates to:
  /// **'Chcę utrzymać obecną wagę.'**
  String get profWantMaintain;

  /// No description provided for @profAdjustPlan.
  ///
  /// In pl, this message translates to:
  /// **'Dostosuj plan'**
  String get profAdjustPlan;

  /// No description provided for @profPlanPremiumOnly.
  ///
  /// In pl, this message translates to:
  /// **'Własny cel kaloryczny i makroskładniki są dostępne w Premium.'**
  String get profPlanPremiumOnly;

  /// No description provided for @profSeePremium.
  ///
  /// In pl, this message translates to:
  /// **'Zobacz Premium'**
  String get profSeePremium;

  /// No description provided for @profWeightRate.
  ///
  /// In pl, this message translates to:
  /// **'Tempo zmiany wagi'**
  String get profWeightRate;

  /// No description provided for @profRateKgWeek.
  ///
  /// In pl, this message translates to:
  /// **'{rate} kg/tydz.'**
  String profRateKgWeek({required String rate});

  /// No description provided for @profRateZero.
  ///
  /// In pl, this message translates to:
  /// **'0 kg/tydz.'**
  String get profRateZero;

  /// No description provided for @profMaintainRateZero.
  ///
  /// In pl, this message translates to:
  /// **'Dla utrzymania wagi tempo = 0'**
  String get profMaintainRateZero;

  /// No description provided for @profRecommendedRate.
  ///
  /// In pl, this message translates to:
  /// **'Zalecane tempo: 0,5 kg/tydz. – bezpieczne i zdrowe. Szybsze chudnięcie może być niezdrowe (utrata mięśni, niedobory, zmęczenie).'**
  String get profRecommendedRate;

  /// No description provided for @profEstTargetDate.
  ///
  /// In pl, this message translates to:
  /// **'Szacunkowy termin osiągnięcia celu: {date}'**
  String profEstTargetDate({required String date});

  /// No description provided for @profMoveSlider.
  ///
  /// In pl, this message translates to:
  /// **'Przesuń suwak, aby zobaczyć plan'**
  String get profMoveSlider;

  /// No description provided for @profCustomCalorieGoal.
  ///
  /// In pl, this message translates to:
  /// **'Własny cel kaloryczny'**
  String get profCustomCalorieGoal;

  /// No description provided for @profGoalKcal.
  ///
  /// In pl, this message translates to:
  /// **'Cel (kcal)'**
  String get profGoalKcal;

  /// No description provided for @profLeaveEmptyFromRate.
  ///
  /// In pl, this message translates to:
  /// **'Zostaw puste, aby obliczyć z tempa.'**
  String get profLeaveEmptyFromRate;

  /// No description provided for @profCustomMacros.
  ///
  /// In pl, this message translates to:
  /// **'Własne makroskładniki'**
  String get profCustomMacros;

  /// No description provided for @profMacrosAutoRecalc.
  ///
  /// In pl, this message translates to:
  /// **'Kalorie i termin przeliczą się automatycznie.'**
  String get profMacrosAutoRecalc;

  /// No description provided for @profMacroSum.
  ///
  /// In pl, this message translates to:
  /// **'Suma: {kcal} kcal'**
  String profMacroSum({required String kcal});

  /// No description provided for @profMacroPerGram.
  ///
  /// In pl, this message translates to:
  /// **'1g = {kcal} kcal'**
  String profMacroPerGram({required int kcal});

  /// No description provided for @profValuesNotNegative.
  ///
  /// In pl, this message translates to:
  /// **'Wartości nie mogą być ujemne.'**
  String get profValuesNotNegative;

  /// No description provided for @profMacroMaxProtein.
  ///
  /// In pl, this message translates to:
  /// **'białko max {g} g'**
  String profMacroMaxProtein({required String g});

  /// No description provided for @profMacroMaxFat.
  ///
  /// In pl, this message translates to:
  /// **'tłuszcze max {g} g'**
  String profMacroMaxFat({required String g});

  /// No description provided for @profMacroMaxCarbs.
  ///
  /// In pl, this message translates to:
  /// **'węglowodany max {g} g'**
  String profMacroMaxCarbs({required String g});

  /// No description provided for @profMacroOverLimit.
  ///
  /// In pl, this message translates to:
  /// **'⚠️ Wartości przekraczają zalecane limity dzienne: {parts}. Wprowadź realistyczne wartości dla zdrowej diety.'**
  String profMacroOverLimit({required String parts});

  /// No description provided for @profMacroCaloriesUnreal.
  ///
  /// In pl, this message translates to:
  /// **'⚠️ Łączna liczba kalorii ({calories} kcal) jest nierealistyczna dla dziennego zapotrzebowania. Zalecane maksimum to ok. {max} kcal/dzień.'**
  String profMacroCaloriesUnreal({
    required String calories,
    required String max,
  });

  /// No description provided for @profMacroLossSurplus.
  ///
  /// In pl, this message translates to:
  /// **'Twój cel to chudnięcie (waga docelowa niższa niż obecna), ale wprowadzone makroskładniki dają {surplus} kcal powyżej zapotrzebowania (TDEE: {tdee} kcal). Zmniejsz kalorie/makroskładniki, aby osiągnąć deficyt.'**
  String profMacroLossSurplus({required String surplus, required String tdee});

  /// No description provided for @profMacroGainDeficit.
  ///
  /// In pl, this message translates to:
  /// **'Twój cel to przybieranie na wadze (waga docelowa wyższa niż obecna), ale wprowadzone makroskładniki dają deficyt (TDEE: {tdee} kcal). Zwiększ kalorie/makroskładniki, aby osiągnąć nadwyżkę.'**
  String profMacroGainDeficit({required String tdee});

  /// No description provided for @profWarnCalAboveTdeeLoss.
  ///
  /// In pl, this message translates to:
  /// **'⚠️ Cel kaloryczny jest wyższy niż TDEE ({tdee} kcal). Aby schudnąć, musisz mieć deficyt kaloryczny. Maksymalny bezpieczny deficyt to ~1100 kcal/dzień (ok. 1 kg/tydzień).'**
  String profWarnCalAboveTdeeLoss({required String tdee});

  /// No description provided for @profWarnDeficitHuge.
  ///
  /// In pl, this message translates to:
  /// **'⚠️ Deficyt kaloryczny jest bardzo duży ({deficit} kcal/dzień). Zalecany maksymalny deficyt to 1000-1500 kcal/dzień dla bezpiecznej utraty wagi.'**
  String profWarnDeficitHuge({required String deficit});

  /// No description provided for @profWarnDeficitTiny.
  ///
  /// In pl, this message translates to:
  /// **'⚠️ Deficyt kaloryczny jest bardzo mały. Dla skutecznej utraty wagi zalecany jest deficyt 500-1000 kcal/dzień.'**
  String get profWarnDeficitTiny;

  /// No description provided for @profWarnCalBelowTdeeGain.
  ///
  /// In pl, this message translates to:
  /// **'⚠️ Cel kaloryczny jest niższy niż TDEE ({tdee} kcal). Aby przybrać na wadze, musisz mieć nadwyżkę kaloryczną. Zalecana nadwyżka to 250-500 kcal/dzień (ok. 0.25-0.5 kg/tydzień).'**
  String profWarnCalBelowTdeeGain({required String tdee});

  /// No description provided for @profWarnSurplusHuge.
  ///
  /// In pl, this message translates to:
  /// **'⚠️ Nadwyżka kaloryczna jest bardzo duża ({surplus} kcal/dzień). Zalecana nadwyżka to 250-500 kcal/dzień dla zdrowego przybierania na wadze.'**
  String profWarnSurplusHuge({required String surplus});

  /// No description provided for @profWarnSurplusTiny.
  ///
  /// In pl, this message translates to:
  /// **'⚠️ Nadwyżka kaloryczna jest bardzo mała. Dla skutecznego przybierania na wadze zalecana jest nadwyżka 250-500 kcal/dzień.'**
  String get profWarnSurplusTiny;

  /// No description provided for @profWarnMaintainFar.
  ///
  /// In pl, this message translates to:
  /// **'⚠️ Cel kaloryczny różni się znacznie od TDEE ({tdee} kcal). Dla utrzymania wagi cel powinien być zbliżony do TDEE (±100-200 kcal).'**
  String profWarnMaintainFar({required String tdee});

  /// No description provided for @profCannotSaveLoss.
  ///
  /// In pl, this message translates to:
  /// **'Nie można zapisać: Cel kaloryczny ({calories} kcal) jest wyższy niż TDEE ({tdee} kcal). Aby schudnąć, musisz mieć deficyt kaloryczny.'**
  String profCannotSaveLoss({required String calories, required String tdee});

  /// No description provided for @profCannotSaveGain.
  ///
  /// In pl, this message translates to:
  /// **'Nie można zapisać: Cel kaloryczny ({calories} kcal) jest niższy niż TDEE ({tdee} kcal). Aby przybrać na wadze, musisz mieć nadwyżkę kaloryczną.'**
  String profCannotSaveGain({required String calories, required String tdee});

  /// No description provided for @profUserNotLoggedIn.
  ///
  /// In pl, this message translates to:
  /// **'Użytkownik nie jest zalogowany'**
  String get profUserNotLoggedIn;

  /// No description provided for @profGoalHistoryEdit.
  ///
  /// In pl, this message translates to:
  /// **'Edycja profilu'**
  String get profGoalHistoryEdit;

  /// No description provided for @profUpdatedSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Profil zaktualizowany pomyślnie! Cel został przeliczony.'**
  String get profUpdatedSuccess;

  /// No description provided for @profSaveError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd podczas zapisywania: {error}'**
  String profSaveError({required String error});

  /// No description provided for @profCalorieGoal.
  ///
  /// In pl, this message translates to:
  /// **'Cel kaloryczny'**
  String get profCalorieGoal;

  /// No description provided for @trackPremium.
  ///
  /// In pl, this message translates to:
  /// **'Premium'**
  String get trackPremium;

  /// No description provided for @trackStatistics.
  ///
  /// In pl, this message translates to:
  /// **'Statystyki'**
  String get trackStatistics;

  /// No description provided for @trackGoalsAndChallenges.
  ///
  /// In pl, this message translates to:
  /// **'Cele i wyzwania'**
  String get trackGoalsAndChallenges;

  /// No description provided for @trackProfile.
  ///
  /// In pl, this message translates to:
  /// **'Profil'**
  String get trackProfile;

  /// No description provided for @trackSessionExpired.
  ///
  /// In pl, this message translates to:
  /// **'Sesja wygasła. Zaloguj się ponownie.'**
  String get trackSessionExpired;

  /// No description provided for @trackLoadDataFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się załadować danych. Sprawdź połączenie internetowe i naciśnij „Spróbuj ponownie”.'**
  String get trackLoadDataFailed;

  /// No description provided for @trackErrorWithDetails.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {error}'**
  String trackErrorWithDetails({required String error});

  /// No description provided for @trackSignIn.
  ///
  /// In pl, this message translates to:
  /// **'Zaloguj się'**
  String get trackSignIn;

  /// No description provided for @trackFeatureEatingOut.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek „na mieście”'**
  String get trackFeatureEatingOut;

  /// No description provided for @trackShareCaloriesText.
  ///
  /// In pl, this message translates to:
  /// **'📊 Łatwa Forma – Kalorie {date}'**
  String trackShareCaloriesText({required String date});

  /// No description provided for @trackShareError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd udostępniania: {error}'**
  String trackShareError({required String error});

  /// No description provided for @trackCaloriesOverview.
  ///
  /// In pl, this message translates to:
  /// **'Przegląd kalorii'**
  String get trackCaloriesOverview;

  /// No description provided for @trackSelectDate.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz datę'**
  String get trackSelectDate;

  /// No description provided for @trackShare.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnij'**
  String get trackShare;

  /// No description provided for @trackFeatureShareSummary.
  ///
  /// In pl, this message translates to:
  /// **'Udostępnianie podsumowania'**
  String get trackFeatureShareSummary;

  /// No description provided for @trackEarlierWeek.
  ///
  /// In pl, this message translates to:
  /// **'Wcześniejszy tydzień'**
  String get trackEarlierWeek;

  /// No description provided for @trackFeatureBrowseHistory.
  ///
  /// In pl, this message translates to:
  /// **'Przeglądanie historii innych dni'**
  String get trackFeatureBrowseHistory;

  /// No description provided for @trackLaterWeek.
  ///
  /// In pl, this message translates to:
  /// **'Późniejszy tydzień'**
  String get trackLaterWeek;

  /// No description provided for @trackShowingDataFrom.
  ///
  /// In pl, this message translates to:
  /// **'Wyświetlane dane z {date}'**
  String trackShowingDataFrom({required String date});

  /// No description provided for @trackConsumed.
  ///
  /// In pl, this message translates to:
  /// **'Spożyte'**
  String get trackConsumed;

  /// No description provided for @trackTodayTarget.
  ///
  /// In pl, this message translates to:
  /// **'Cel na dziś'**
  String get trackTodayTarget;

  /// No description provided for @trackSurplusKcal.
  ///
  /// In pl, this message translates to:
  /// **'Nadwyżka: {kcal} kcal'**
  String trackSurplusKcal({required String kcal});

  /// No description provided for @trackProtein.
  ///
  /// In pl, this message translates to:
  /// **'Białko'**
  String get trackProtein;

  /// No description provided for @trackFat.
  ///
  /// In pl, this message translates to:
  /// **'Tłuszcze'**
  String get trackFat;

  /// No description provided for @trackCarbs.
  ///
  /// In pl, this message translates to:
  /// **'Węglowodany'**
  String get trackCarbs;

  /// No description provided for @trackCarbsShort.
  ///
  /// In pl, this message translates to:
  /// **'Węgle'**
  String get trackCarbsShort;

  /// No description provided for @trackIncludingSaturated.
  ///
  /// In pl, this message translates to:
  /// **'w tym nasycone'**
  String get trackIncludingSaturated;

  /// No description provided for @trackIncludingSugars.
  ///
  /// In pl, this message translates to:
  /// **'w tym cukry'**
  String get trackIncludingSugars;

  /// No description provided for @trackFiber.
  ///
  /// In pl, this message translates to:
  /// **'błonnik'**
  String get trackFiber;

  /// No description provided for @trackFiberLabel.
  ///
  /// In pl, this message translates to:
  /// **'Błonnik'**
  String get trackFiberLabel;

  /// No description provided for @trackSalt.
  ///
  /// In pl, this message translates to:
  /// **'Sól'**
  String get trackSalt;

  /// No description provided for @trackFeatureAiMealAnalysis.
  ///
  /// In pl, this message translates to:
  /// **'Analiza AI posiłku'**
  String get trackFeatureAiMealAnalysis;

  /// No description provided for @trackAiPhotoAnalysisTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Analiza AI ze zdjęcia'**
  String get trackAiPhotoAnalysisTooltip;

  /// No description provided for @trackNoResults.
  ///
  /// In pl, this message translates to:
  /// **'Brak wyników'**
  String get trackNoResults;

  /// No description provided for @trackWater.
  ///
  /// In pl, this message translates to:
  /// **'Woda'**
  String get trackWater;

  /// No description provided for @trackWaterMotivation.
  ///
  /// In pl, this message translates to:
  /// **'Człowiek nie wielbłąd, pić musi! 💧'**
  String get trackWaterMotivation;

  /// No description provided for @trackActivitiesToday.
  ///
  /// In pl, this message translates to:
  /// **'Aktywności dzisiaj'**
  String get trackActivitiesToday;

  /// No description provided for @trackActivitiesOnDate.
  ///
  /// In pl, this message translates to:
  /// **'Aktywności – {date}'**
  String trackActivitiesOnDate({required String date});

  /// No description provided for @trackNoActivities.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywności'**
  String get trackNoActivities;

  /// No description provided for @trackAndMoreCount.
  ///
  /// In pl, this message translates to:
  /// **'... i {count} więcej'**
  String trackAndMoreCount({required String count});

  /// No description provided for @trackMealsToday.
  ///
  /// In pl, this message translates to:
  /// **'Posiłki dzisiaj'**
  String get trackMealsToday;

  /// No description provided for @trackMealsOnDate.
  ///
  /// In pl, this message translates to:
  /// **'Posiłki – {date}'**
  String trackMealsOnDate({required String date});

  /// No description provided for @trackNoMeals.
  ///
  /// In pl, this message translates to:
  /// **'Brak posiłków'**
  String get trackNoMeals;

  /// No description provided for @trackDayMon.
  ///
  /// In pl, this message translates to:
  /// **'Pon'**
  String get trackDayMon;

  /// No description provided for @trackDayTue.
  ///
  /// In pl, this message translates to:
  /// **'Wt'**
  String get trackDayTue;

  /// No description provided for @trackDayWed.
  ///
  /// In pl, this message translates to:
  /// **'Śr'**
  String get trackDayWed;

  /// No description provided for @trackDayThu.
  ///
  /// In pl, this message translates to:
  /// **'Czw'**
  String get trackDayThu;

  /// No description provided for @trackDayFri.
  ///
  /// In pl, this message translates to:
  /// **'Pt'**
  String get trackDayFri;

  /// No description provided for @trackDaySat.
  ///
  /// In pl, this message translates to:
  /// **'Sob'**
  String get trackDaySat;

  /// No description provided for @trackDaySun.
  ///
  /// In pl, this message translates to:
  /// **'Nie'**
  String get trackDaySun;

  /// No description provided for @trackAdd.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj'**
  String get trackAdd;

  /// No description provided for @trackMeal.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek'**
  String get trackMeal;

  /// No description provided for @trackEatingOut.
  ///
  /// In pl, this message translates to:
  /// **'Jedzenie na mieście'**
  String get trackEatingOut;

  /// No description provided for @trackActivity.
  ///
  /// In pl, this message translates to:
  /// **'Aktywność'**
  String get trackActivity;

  /// No description provided for @trackWeight.
  ///
  /// In pl, this message translates to:
  /// **'Waga'**
  String get trackWeight;

  /// No description provided for @trackMeasurements.
  ///
  /// In pl, this message translates to:
  /// **'Pomiary'**
  String get trackMeasurements;

  /// No description provided for @trackFavorites.
  ///
  /// In pl, this message translates to:
  /// **'Ulubione'**
  String get trackFavorites;

  /// No description provided for @trackUserNotLoggedIn.
  ///
  /// In pl, this message translates to:
  /// **'Użytkownik nie jest zalogowany'**
  String get trackUserNotLoggedIn;

  /// No description provided for @trackMealSavedAndFavorited.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek zapisany i dodany do ulubionych!'**
  String get trackMealSavedAndFavorited;

  /// No description provided for @trackMealAddedSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek dodany pomyślnie!'**
  String get trackMealAddedSuccess;

  /// No description provided for @trackFeatureIngredientsMeal.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek ze składników'**
  String get trackFeatureIngredientsMeal;

  /// No description provided for @trackOptionEatingOut.
  ///
  /// In pl, this message translates to:
  /// **'Na mieście'**
  String get trackOptionEatingOut;

  /// No description provided for @trackOptionAiAnalysis.
  ///
  /// In pl, this message translates to:
  /// **'Analiza AI'**
  String get trackOptionAiAnalysis;

  /// No description provided for @trackOptionIngredients.
  ///
  /// In pl, this message translates to:
  /// **'Składniki'**
  String get trackOptionIngredients;

  /// No description provided for @trackOptionBarcode.
  ///
  /// In pl, this message translates to:
  /// **'Kod kreskowy'**
  String get trackOptionBarcode;

  /// No description provided for @trackOptionSearchProduct.
  ///
  /// In pl, this message translates to:
  /// **'Wyszukaj produkt'**
  String get trackOptionSearchProduct;

  /// No description provided for @trackOptionFavorites.
  ///
  /// In pl, this message translates to:
  /// **'Ulubione'**
  String get trackOptionFavorites;

  /// No description provided for @trackEditMeal.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj posiłek'**
  String get trackEditMeal;

  /// No description provided for @trackAddMeal.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj posiłek'**
  String get trackAddMeal;

  /// No description provided for @trackMealNameOptional.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa posiłku (opcjonalnie)'**
  String get trackMealNameOptional;

  /// No description provided for @trackHintEmptyDefaultName.
  ///
  /// In pl, this message translates to:
  /// **'Puste = \"Bez nazwy\"'**
  String get trackHintEmptyDefaultName;

  /// No description provided for @trackDefaultMealName.
  ///
  /// In pl, this message translates to:
  /// **'Bez nazwy'**
  String get trackDefaultMealName;

  /// No description provided for @trackHintCaloriesFromMacros.
  ///
  /// In pl, this message translates to:
  /// **'Puste = policzy z makroskładników'**
  String get trackHintCaloriesFromMacros;

  /// No description provided for @trackEnterCaloriesOrMacros.
  ///
  /// In pl, this message translates to:
  /// **'Podaj liczbę kalorii lub uzupełnij makroskładniki'**
  String get trackEnterCaloriesOrMacros;

  /// No description provided for @trackProteinG.
  ///
  /// In pl, this message translates to:
  /// **'Białko (g)'**
  String get trackProteinG;

  /// No description provided for @trackFatG.
  ///
  /// In pl, this message translates to:
  /// **'Tłuszcze (g)'**
  String get trackFatG;

  /// No description provided for @trackCarbsG.
  ///
  /// In pl, this message translates to:
  /// **'Węglowodany (g)'**
  String get trackCarbsG;

  /// No description provided for @trackFiberG.
  ///
  /// In pl, this message translates to:
  /// **'Błonnik (g)'**
  String get trackFiberG;

  /// No description provided for @trackSaltG.
  ///
  /// In pl, this message translates to:
  /// **'Sól (g)'**
  String get trackSaltG;

  /// No description provided for @trackMealTypeOptional.
  ///
  /// In pl, this message translates to:
  /// **'Typ posiłku - opcjonalnie'**
  String get trackMealTypeOptional;

  /// No description provided for @trackBreakfast.
  ///
  /// In pl, this message translates to:
  /// **'Śniadanie'**
  String get trackBreakfast;

  /// No description provided for @trackLunch.
  ///
  /// In pl, this message translates to:
  /// **'Obiad'**
  String get trackLunch;

  /// No description provided for @trackDinner.
  ///
  /// In pl, this message translates to:
  /// **'Kolacja'**
  String get trackDinner;

  /// No description provided for @trackSnack.
  ///
  /// In pl, this message translates to:
  /// **'Przekąska'**
  String get trackSnack;

  /// No description provided for @trackAddToFavorites.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do ulubionych'**
  String get trackAddToFavorites;

  /// No description provided for @trackAddToFavoritesMealSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Będziesz mógł szybko dodać ten posiłek później'**
  String get trackAddToFavoritesMealSubtitle;

  /// No description provided for @trackUpdateMeal.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizuj posiłek'**
  String get trackUpdateMeal;

  /// No description provided for @trackSaveMeal.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz posiłek'**
  String get trackSaveMeal;

  /// No description provided for @trackCalories.
  ///
  /// In pl, this message translates to:
  /// **'Kalorie'**
  String get trackCalories;

  /// No description provided for @trackCameraUnavailableTitle.
  ///
  /// In pl, this message translates to:
  /// **'Kamera niedostępna'**
  String get trackCameraUnavailableTitle;

  /// No description provided for @trackCameraUnavailableBody.
  ///
  /// In pl, this message translates to:
  /// **'Kamera nie jest dostępna na tym urządzeniu (np. na symulatorze).\n\nUżyj przycisku „Z galerii”, aby wybrać zdjęcie z galerii.'**
  String get trackCameraUnavailableBody;

  /// No description provided for @trackFromGallery.
  ///
  /// In pl, this message translates to:
  /// **'Z galerii'**
  String get trackFromGallery;

  /// No description provided for @trackPickImageError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd wyboru zdjęcia: {error}'**
  String trackPickImageError({required String error});

  /// No description provided for @trackAnalysisFailedOpenAi.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się przeanalizować zdjęcia. Sprawdź czy klucz OpenAI API jest ustawiony.'**
  String get trackAnalysisFailedOpenAi;

  /// No description provided for @trackAnalysisError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd analizy: {error}'**
  String trackAnalysisError({required String error});

  /// No description provided for @trackAiPhotoTitle.
  ///
  /// In pl, this message translates to:
  /// **'Analiza zdjęcia AI'**
  String get trackAiPhotoTitle;

  /// No description provided for @trackTakeMealPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Zrób zdjęcie posiłku'**
  String get trackTakeMealPhoto;

  /// No description provided for @trackAiPhotoDescription.
  ///
  /// In pl, this message translates to:
  /// **'AI przeanalizuje zdjęcie i oszacuje wartości odżywcze. Zdjęcie jest wysyłane do dostawcy AI (OpenAI) wyłącznie w tym celu – nie zapisujemy galerii zdjęć. Szacunki są orientacyjne i nie stanowią porady medycznej.'**
  String get trackAiPhotoDescription;

  /// No description provided for @trackSimulatorCameraHint.
  ///
  /// In pl, this message translates to:
  /// **'Na symulatorze kamera nie działa – wybierz zdjęcie z galerii.'**
  String get trackSimulatorCameraHint;

  /// No description provided for @trackTakePhoto.
  ///
  /// In pl, this message translates to:
  /// **'Zrób zdjęcie'**
  String get trackTakePhoto;

  /// No description provided for @trackAnalyzingPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Analizowanie zdjęcia...'**
  String get trackAnalyzingPhoto;

  /// No description provided for @trackMayTakeAMoment.
  ///
  /// In pl, this message translates to:
  /// **'To może chwilę potrwać'**
  String get trackMayTakeAMoment;

  /// No description provided for @trackProductNotFound.
  ///
  /// In pl, this message translates to:
  /// **'Produkt o kodzie {code} nie został znaleziony w bazie produktów.'**
  String trackProductNotFound({required String code});

  /// No description provided for @trackFetchProductFailed.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się pobrać danych produktu: {error}'**
  String trackFetchProductFailed({required String error});

  /// No description provided for @trackBarcodeScannerTitle.
  ///
  /// In pl, this message translates to:
  /// **'Skaner kodów kreskowych'**
  String get trackBarcodeScannerTitle;

  /// No description provided for @trackSimulatorEnterCode.
  ///
  /// In pl, this message translates to:
  /// **'Na symulatorze wprowadź kod ręcznie'**
  String get trackSimulatorEnterCode;

  /// No description provided for @trackEnterProductCode.
  ///
  /// In pl, this message translates to:
  /// **'Wprowadź kod produktu'**
  String get trackEnterProductCode;

  /// No description provided for @trackSearchProduct.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj produktu'**
  String get trackSearchProduct;

  /// No description provided for @trackScannerUnavailable.
  ///
  /// In pl, this message translates to:
  /// **'Skaner niedostępny - użyj symulatora lub urządzenia fizycznego'**
  String get trackScannerUnavailable;

  /// No description provided for @trackPointAtBarcode.
  ///
  /// In pl, this message translates to:
  /// **'Wskaż kod kreskowy produktu'**
  String get trackPointAtBarcode;

  /// No description provided for @trackBarcodePrivacy.
  ///
  /// In pl, this message translates to:
  /// **'Dane zostaną pobrane z bazy produktów. Kamera służy wyłącznie do odczytu kodu – zdjęcia nie zapisujemy ani nie wysyłamy.'**
  String get trackBarcodePrivacy;

  /// No description provided for @trackScanBarcode.
  ///
  /// In pl, this message translates to:
  /// **'Skanuj kod kreskowy'**
  String get trackScanBarcode;

  /// No description provided for @trackAddProduct.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj produkt'**
  String get trackAddProduct;

  /// No description provided for @trackEnterProductWeight.
  ///
  /// In pl, this message translates to:
  /// **'Podaj wagę produktu'**
  String get trackEnterProductWeight;

  /// No description provided for @trackNutritionPer100g.
  ///
  /// In pl, this message translates to:
  /// **'Wartości odżywcze (na 100g):'**
  String get trackNutritionPer100g;

  /// No description provided for @trackWeightHintExample.
  ///
  /// In pl, this message translates to:
  /// **'np. 75.5'**
  String get trackWeightHintExample;

  /// No description provided for @trackWeightHelper.
  ///
  /// In pl, this message translates to:
  /// **'Ile gramów produktu zjadasz?'**
  String get trackWeightHelper;

  /// No description provided for @trackEditBeforeSave.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj przed zapisem'**
  String get trackEditBeforeSave;

  /// No description provided for @trackPer100g.
  ///
  /// In pl, this message translates to:
  /// **'{label}/100g'**
  String trackPer100g({required String label});

  /// No description provided for @trackWeightG.
  ///
  /// In pl, this message translates to:
  /// **'Waga (g)'**
  String get trackWeightG;

  /// No description provided for @trackSearchProductTitle.
  ///
  /// In pl, this message translates to:
  /// **'Wyszukaj produkt'**
  String get trackSearchProductTitle;

  /// No description provided for @trackSearchProductHint.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa produktu, np. mleko, nutella…'**
  String get trackSearchProductHint;

  /// No description provided for @trackEnterProductName.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz nazwę produktu'**
  String get trackEnterProductName;

  /// No description provided for @trackSearchProductSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Korzystamy z bazy Open Food Facts. Wyniki pojawią się po wpisaniu min. kilku liter.'**
  String get trackSearchProductSubtitle;

  /// No description provided for @trackNoResultsTryBarcode.
  ///
  /// In pl, this message translates to:
  /// **'Spróbuj innej nazwy lub zeskanuj kod kreskowy produktu.'**
  String get trackNoResultsTryBarcode;

  /// No description provided for @trackBackToDashboard.
  ///
  /// In pl, this message translates to:
  /// **'Wróć do dashboardu'**
  String get trackBackToDashboard;

  /// No description provided for @trackMealsDateTitle.
  ///
  /// In pl, this message translates to:
  /// **'Posiłki - {date}'**
  String trackMealsDateTitle({required String date});

  /// No description provided for @trackFavoriteMealsTooltip.
  ///
  /// In pl, this message translates to:
  /// **'Ulubione posiłki'**
  String get trackFavoriteMealsTooltip;

  /// No description provided for @trackNoMealsForDay.
  ///
  /// In pl, this message translates to:
  /// **'Brak posiłków na ten dzień'**
  String get trackNoMealsForDay;

  /// No description provided for @trackUsePlusToAddMeal.
  ///
  /// In pl, this message translates to:
  /// **'Użyj przycisku + aby dodać posiłek'**
  String get trackUsePlusToAddMeal;

  /// No description provided for @trackDeleteMealTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usuń posiłek'**
  String get trackDeleteMealTitle;

  /// No description provided for @trackDeleteMealConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć \"{name}\"?'**
  String trackDeleteMealConfirm({required String name});

  /// No description provided for @trackMealDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek usunięty'**
  String get trackMealDeleted;

  /// No description provided for @trackAddAtLeastOneIngredient.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj przynajmniej jeden składnik'**
  String get trackAddAtLeastOneIngredient;

  /// No description provided for @trackMealFromIngredientsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek ze składników'**
  String get trackMealFromIngredientsTitle;

  /// No description provided for @trackTotalWeightG.
  ///
  /// In pl, this message translates to:
  /// **'Całkowita waga: {weight} g'**
  String trackTotalWeightG({required String weight});

  /// No description provided for @trackIngredientsCount.
  ///
  /// In pl, this message translates to:
  /// **'Składniki ({count})'**
  String trackIngredientsCount({required String count});

  /// No description provided for @trackAddIngredient.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj składnik'**
  String get trackAddIngredient;

  /// No description provided for @trackNoIngredients.
  ///
  /// In pl, this message translates to:
  /// **'Brak składników'**
  String get trackNoIngredients;

  /// No description provided for @trackAddIngredientsHint.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj składniki, aby zbudować posiłek'**
  String get trackAddIngredientsHint;

  /// No description provided for @trackEditIngredient.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj składnik'**
  String get trackEditIngredient;

  /// No description provided for @trackIngredientNameOptional.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa składnika (opcjonalnie)'**
  String get trackIngredientNameOptional;

  /// No description provided for @trackAmountG.
  ///
  /// In pl, this message translates to:
  /// **'Ilość (g)'**
  String get trackAmountG;

  /// No description provided for @trackEnterAmount.
  ///
  /// In pl, this message translates to:
  /// **'Podaj ilość'**
  String get trackEnterAmount;

  /// No description provided for @trackEnterValidAmount.
  ///
  /// In pl, this message translates to:
  /// **'Podaj poprawną ilość'**
  String get trackEnterValidAmount;

  /// No description provided for @trackEnterCaloriesOrFillMacros.
  ///
  /// In pl, this message translates to:
  /// **'Podaj kalorie lub uzupełnij makroskładniki'**
  String get trackEnterCaloriesOrFillMacros;

  /// No description provided for @trackProteinPer100g.
  ///
  /// In pl, this message translates to:
  /// **'Białko (g/100g)'**
  String get trackProteinPer100g;

  /// No description provided for @trackFatPer100g.
  ///
  /// In pl, this message translates to:
  /// **'Tłuszcze (g/100g)'**
  String get trackFatPer100g;

  /// No description provided for @trackCarbsPer100g.
  ///
  /// In pl, this message translates to:
  /// **'Węglowodany (g/100g)'**
  String get trackCarbsPer100g;

  /// No description provided for @trackEatingOutTitle.
  ///
  /// In pl, this message translates to:
  /// **'🍽️ Jem na mieście'**
  String get trackEatingOutTitle;

  /// No description provided for @trackEatingOutSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz co jadłeś (szacunki kalorii):'**
  String get trackEatingOutSubtitle;

  /// No description provided for @trackPortionLabel.
  ///
  /// In pl, this message translates to:
  /// **'Porcja: {label}'**
  String trackPortionLabel({required String label});

  /// No description provided for @trackSlicesCount.
  ///
  /// In pl, this message translates to:
  /// **'Ilość kawałków: {count}'**
  String trackSlicesCount({required String count});

  /// No description provided for @trackSlicesUnit.
  ///
  /// In pl, this message translates to:
  /// **'{count} szt.'**
  String trackSlicesUnit({required String count});

  /// No description provided for @trackKcalPerSlice.
  ///
  /// In pl, this message translates to:
  /// **'kcal na kawałek:'**
  String get trackKcalPerSlice;

  /// No description provided for @trackKcalPerPieceLabel.
  ///
  /// In pl, this message translates to:
  /// **'{kcal} kcal/szt.'**
  String trackKcalPerPieceLabel({required String kcal});

  /// No description provided for @trackKcalLabel.
  ///
  /// In pl, this message translates to:
  /// **'{kcal} kcal'**
  String trackKcalLabel({required String kcal});

  /// No description provided for @trackKcalTimesSlices.
  ///
  /// In pl, this message translates to:
  /// **'{kcal} × {slices} = {total} kcal'**
  String trackKcalTimesSlices({
    required String kcal,
    required String slices,
    required String total,
  });

  /// No description provided for @trackSaving.
  ///
  /// In pl, this message translates to:
  /// **'Zapisywanie…'**
  String get trackSaving;

  /// No description provided for @trackAddToDiary.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do dziennika'**
  String get trackAddToDiary;

  /// No description provided for @trackSelectMealAbove.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz posiłek powyżej'**
  String get trackSelectMealAbove;

  /// No description provided for @trackEatingOutTip.
  ///
  /// In pl, this message translates to:
  /// **'Jeśli reszta dnia była lekka – to OK. Nie stresuj się.'**
  String get trackEatingOutTip;

  /// No description provided for @trackMealNameEatingOutSlices.
  ///
  /// In pl, this message translates to:
  /// **'{name} ({slices} szt.) (na mieście)'**
  String trackMealNameEatingOutSlices({
    required String name,
    required String slices,
  });

  /// No description provided for @trackMealNameEatingOut.
  ///
  /// In pl, this message translates to:
  /// **'{name} (na mieście)'**
  String trackMealNameEatingOut({required String name});

  /// No description provided for @trackAddedEatingOut.
  ///
  /// In pl, this message translates to:
  /// **'Dodano: {name}{slicesPart} (~{kcal} kcal)'**
  String trackAddedEatingOut({
    required String name,
    required String slicesPart,
    required String kcal,
  });

  /// No description provided for @trackSlicesPart.
  ///
  /// In pl, this message translates to:
  /// **' ({slices} szt.)'**
  String trackSlicesPart({required String slices});

  /// No description provided for @trackEatingOutPizza.
  ///
  /// In pl, this message translates to:
  /// **'Pizza'**
  String get trackEatingOutPizza;

  /// No description provided for @trackEatingOutPizzaLabel.
  ///
  /// In pl, this message translates to:
  /// **'~250–450 kcal / kawałek'**
  String get trackEatingOutPizzaLabel;

  /// No description provided for @trackEatingOutKebab.
  ///
  /// In pl, this message translates to:
  /// **'Kebab'**
  String get trackEatingOutKebab;

  /// No description provided for @trackEatingOutKebabLabel.
  ///
  /// In pl, this message translates to:
  /// **'~600–900 kcal'**
  String get trackEatingOutKebabLabel;

  /// No description provided for @trackEatingOutBurger.
  ///
  /// In pl, this message translates to:
  /// **'Burger (ogólnie)'**
  String get trackEatingOutBurger;

  /// No description provided for @trackEatingOutBurgerLabel.
  ///
  /// In pl, this message translates to:
  /// **'~500–800 kcal'**
  String get trackEatingOutBurgerLabel;

  /// No description provided for @trackEatingOutChinese.
  ///
  /// In pl, this message translates to:
  /// **'Chińczyk'**
  String get trackEatingOutChinese;

  /// No description provided for @trackEatingOutChineseLabel.
  ///
  /// In pl, this message translates to:
  /// **'~500–900 kcal'**
  String get trackEatingOutChineseLabel;

  /// No description provided for @trackEatingOutMcdCheeseburger.
  ///
  /// In pl, this message translates to:
  /// **'McDonald\'s – Cheeseburger'**
  String get trackEatingOutMcdCheeseburger;

  /// No description provided for @trackEatingOutMcdCheeseburgerLabel.
  ///
  /// In pl, this message translates to:
  /// **'~300 kcal'**
  String get trackEatingOutMcdCheeseburgerLabel;

  /// No description provided for @trackEatingOutMcd2ForYou.
  ///
  /// In pl, this message translates to:
  /// **'McDonald\'s – 2forYou (Cheeseburger + frytki)'**
  String get trackEatingOutMcd2ForYou;

  /// No description provided for @trackEatingOutMcd2ForYouLabel.
  ///
  /// In pl, this message translates to:
  /// **'~530 kcal'**
  String get trackEatingOutMcd2ForYouLabel;

  /// No description provided for @trackEatingOutMcdBigMac.
  ///
  /// In pl, this message translates to:
  /// **'McDonald\'s – Big Mac'**
  String get trackEatingOutMcdBigMac;

  /// No description provided for @trackEatingOutMcdBigMacLabel.
  ///
  /// In pl, this message translates to:
  /// **'~590 kcal'**
  String get trackEatingOutMcdBigMacLabel;

  /// No description provided for @trackEatingOutMcdMcDouble.
  ///
  /// In pl, this message translates to:
  /// **'McDonald\'s – McDouble'**
  String get trackEatingOutMcdMcDouble;

  /// No description provided for @trackEatingOutMcdMcDoubleLabel.
  ///
  /// In pl, this message translates to:
  /// **'~400 kcal'**
  String get trackEatingOutMcdMcDoubleLabel;

  /// No description provided for @trackEatingOutMcdSmallFries.
  ///
  /// In pl, this message translates to:
  /// **'McDonald\'s – małe frytki'**
  String get trackEatingOutMcdSmallFries;

  /// No description provided for @trackEatingOutMcdSmallFriesLabel.
  ///
  /// In pl, this message translates to:
  /// **'~230 kcal'**
  String get trackEatingOutMcdSmallFriesLabel;

  /// No description provided for @trackEatingOutMcdMediumFries.
  ///
  /// In pl, this message translates to:
  /// **'McDonald\'s – średnie frytki'**
  String get trackEatingOutMcdMediumFries;

  /// No description provided for @trackEatingOutMcdMediumFriesLabel.
  ///
  /// In pl, this message translates to:
  /// **'~340 kcal'**
  String get trackEatingOutMcdMediumFriesLabel;

  /// No description provided for @trackEatingOutKfcDrumstick.
  ///
  /// In pl, this message translates to:
  /// **'KFC – udko/nóżka'**
  String get trackEatingOutKfcDrumstick;

  /// No description provided for @trackEatingOutKfcDrumstickLabel.
  ///
  /// In pl, this message translates to:
  /// **'~200 kcal / szt.'**
  String get trackEatingOutKfcDrumstickLabel;

  /// No description provided for @trackEatingOutKfcTenders.
  ///
  /// In pl, this message translates to:
  /// **'KFC – Strips / Tenders'**
  String get trackEatingOutKfcTenders;

  /// No description provided for @trackEatingOutKfcTendersLabel.
  ///
  /// In pl, this message translates to:
  /// **'~400–600 kcal'**
  String get trackEatingOutKfcTendersLabel;

  /// No description provided for @trackEatingOutSubway6.
  ///
  /// In pl, this message translates to:
  /// **'Subway – 6\'\' sub'**
  String get trackEatingOutSubway6;

  /// No description provided for @trackEatingOutSubway6Label.
  ///
  /// In pl, this message translates to:
  /// **'~300–500 kcal'**
  String get trackEatingOutSubway6Label;

  /// No description provided for @trackEatingOutSubwayFootlong.
  ///
  /// In pl, this message translates to:
  /// **'Subway – Footlong'**
  String get trackEatingOutSubwayFootlong;

  /// No description provided for @trackEatingOutSubwayFootlongLabel.
  ///
  /// In pl, this message translates to:
  /// **'~600–900 kcal'**
  String get trackEatingOutSubwayFootlongLabel;

  /// No description provided for @trackActivitiesDateTitle.
  ///
  /// In pl, this message translates to:
  /// **'Aktywności - {date}'**
  String trackActivitiesDateTitle({required String date});

  /// No description provided for @trackNoActivitiesForDay.
  ///
  /// In pl, this message translates to:
  /// **'Brak aktywności na ten dzień'**
  String get trackNoActivitiesForDay;

  /// No description provided for @trackAddFirstActivity.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszą aktywność'**
  String get trackAddFirstActivity;

  /// No description provided for @trackDaySummary.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie dnia'**
  String get trackDaySummary;

  /// No description provided for @trackBurned.
  ///
  /// In pl, this message translates to:
  /// **'Spalone'**
  String get trackBurned;

  /// No description provided for @trackTime.
  ///
  /// In pl, this message translates to:
  /// **'Czas'**
  String get trackTime;

  /// No description provided for @trackGarminActivitiesNote.
  ///
  /// In pl, this message translates to:
  /// **'Dane aktywności pochodzą z urządzeń Garmin.'**
  String get trackGarminActivitiesNote;

  /// No description provided for @trackDeleteActivityTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usuń aktywność'**
  String get trackDeleteActivityTitle;

  /// No description provided for @trackDeleteActivityConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć \"{name}\"?'**
  String trackDeleteActivityConfirm({required String name});

  /// No description provided for @trackActivityDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Aktywność usunięta'**
  String get trackActivityDeleted;

  /// No description provided for @trackExcludeFromBalance.
  ///
  /// In pl, this message translates to:
  /// **'Nie licz w bilansie (spalone)'**
  String get trackExcludeFromBalance;

  /// No description provided for @trackActivityExcludedFromBalance.
  ///
  /// In pl, this message translates to:
  /// **'Aktywność wyłączona z bilansu'**
  String get trackActivityExcludedFromBalance;

  /// No description provided for @trackActivityIncludedInBalance.
  ///
  /// In pl, this message translates to:
  /// **'Aktywność wliczana do bilansu'**
  String get trackActivityIncludedInBalance;

  /// No description provided for @trackOtherActivities.
  ///
  /// In pl, this message translates to:
  /// **'Pozostałe aktywności.'**
  String get trackOtherActivities;

  /// No description provided for @trackActivityTypeOther.
  ///
  /// In pl, this message translates to:
  /// **'Inna'**
  String get trackActivityTypeOther;

  /// No description provided for @trackActivityTypeLow.
  ///
  /// In pl, this message translates to:
  /// **'Niska'**
  String get trackActivityTypeLow;

  /// No description provided for @trackActivityTypeModerate.
  ///
  /// In pl, this message translates to:
  /// **'Umiarkowana'**
  String get trackActivityTypeModerate;

  /// No description provided for @trackActivityTypeHigh.
  ///
  /// In pl, this message translates to:
  /// **'Wysoka'**
  String get trackActivityTypeHigh;

  /// No description provided for @trackActivityTypeVeryHigh.
  ///
  /// In pl, this message translates to:
  /// **'Bardzo wysoka'**
  String get trackActivityTypeVeryHigh;

  /// No description provided for @trackActivityTypeRun.
  ///
  /// In pl, this message translates to:
  /// **'Bieg'**
  String get trackActivityTypeRun;

  /// No description provided for @trackActivityTypeCycling.
  ///
  /// In pl, this message translates to:
  /// **'Kolarstwo'**
  String get trackActivityTypeCycling;

  /// No description provided for @trackActivityTypeSwim.
  ///
  /// In pl, this message translates to:
  /// **'Pływanie'**
  String get trackActivityTypeSwim;

  /// No description provided for @trackActivityTypeWalk.
  ///
  /// In pl, this message translates to:
  /// **'Chodzenie'**
  String get trackActivityTypeWalk;

  /// No description provided for @trackActivityTypeHike.
  ///
  /// In pl, this message translates to:
  /// **'Wędrówka'**
  String get trackActivityTypeHike;

  /// No description provided for @trackActivityTypeRow.
  ///
  /// In pl, this message translates to:
  /// **'Wioślarstwo'**
  String get trackActivityTypeRow;

  /// No description provided for @trackActivityTypeTennis.
  ///
  /// In pl, this message translates to:
  /// **'Tenis'**
  String get trackActivityTypeTennis;

  /// No description provided for @trackActivityTypeYoga.
  ///
  /// In pl, this message translates to:
  /// **'Joga'**
  String get trackActivityTypeYoga;

  /// No description provided for @trackActivityTypeTraining.
  ///
  /// In pl, this message translates to:
  /// **'Trening'**
  String get trackActivityTypeTraining;

  /// No description provided for @trackFeatureQuickAddActivities.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie dodawanie w aktywnościach'**
  String get trackFeatureQuickAddActivities;

  /// No description provided for @trackActivitySavedAndFavorited.
  ///
  /// In pl, this message translates to:
  /// **'Aktywność zapisana i dodana do ulubionych!'**
  String get trackActivitySavedAndFavorited;

  /// No description provided for @trackActivityAddedSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Aktywność dodana pomyślnie!'**
  String get trackActivityAddedSuccess;

  /// No description provided for @trackEditActivity.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj aktywność'**
  String get trackEditActivity;

  /// No description provided for @trackAddActivity.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj aktywność'**
  String get trackAddActivity;

  /// No description provided for @trackQuickAdd.
  ///
  /// In pl, this message translates to:
  /// **'Szybkie dodawanie'**
  String get trackQuickAdd;

  /// No description provided for @trackActivityNameOptional.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa aktywności (opcjonalnie)'**
  String get trackActivityNameOptional;

  /// No description provided for @trackHintEmptyDefaultActivityName.
  ///
  /// In pl, this message translates to:
  /// **'Puste = \"Aktywność bez nazwy\"'**
  String get trackHintEmptyDefaultActivityName;

  /// No description provided for @trackDefaultActivityName.
  ///
  /// In pl, this message translates to:
  /// **'Aktywność bez nazwy'**
  String get trackDefaultActivityName;

  /// No description provided for @trackEnterBurnedCalories.
  ///
  /// In pl, this message translates to:
  /// **'Podaj liczbę spalonych kalorii'**
  String get trackEnterBurnedCalories;

  /// No description provided for @trackEnterValidCalories.
  ///
  /// In pl, this message translates to:
  /// **'Podaj poprawną liczbę kalorii'**
  String get trackEnterValidCalories;

  /// No description provided for @trackActivityTypeOptional.
  ///
  /// In pl, this message translates to:
  /// **'Typ aktywności - opcjonalnie'**
  String get trackActivityTypeOptional;

  /// No description provided for @trackAddToFavoritesActivitySubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Będziesz mógł szybko dodać tę aktywność później'**
  String get trackAddToFavoritesActivitySubtitle;

  /// No description provided for @trackUpdateActivity.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizuj aktywność'**
  String get trackUpdateActivity;

  /// No description provided for @trackSaveActivity.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz aktywność'**
  String get trackSaveActivity;

  /// No description provided for @trackDurationMinutes.
  ///
  /// In pl, this message translates to:
  /// **'Czas (min)'**
  String get trackDurationMinutes;

  /// No description provided for @trackBurnedCalories.
  ///
  /// In pl, this message translates to:
  /// **'Spalone kalorie'**
  String get trackBurnedCalories;

  /// No description provided for @trackAddedWaterMl.
  ///
  /// In pl, this message translates to:
  /// **'Dodano {amount} ml wody'**
  String trackAddedWaterMl({required String amount});

  /// No description provided for @trackAddWaterError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd podczas dodawania wody: {error}'**
  String trackAddWaterError({required String error});

  /// No description provided for @trackUpdatedAmountMl.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizowano: {amount} ml'**
  String trackUpdatedAmountMl({required String amount});

  /// No description provided for @trackUpdateError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd podczas aktualizacji: {error}'**
  String trackUpdateError({required String error});

  /// No description provided for @trackDeleteEntryTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usuń wpis'**
  String get trackDeleteEntryTitle;

  /// No description provided for @trackDeleteWaterConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć wpis {amount} ml?'**
  String trackDeleteWaterConfirm({required String amount});

  /// No description provided for @trackEntryDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Wpis usunięty'**
  String get trackEntryDeleted;

  /// No description provided for @trackDeleteError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd podczas usuwania: {error}'**
  String trackDeleteError({required String error});

  /// No description provided for @trackEditAmount.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj ilość'**
  String get trackEditAmount;

  /// No description provided for @trackAmountMl.
  ///
  /// In pl, this message translates to:
  /// **'Ilość (ml)'**
  String get trackAmountMl;

  /// No description provided for @trackAmountMlHintRange.
  ///
  /// In pl, this message translates to:
  /// **'1–5000 ml'**
  String get trackAmountMlHintRange;

  /// No description provided for @trackAmountMustBeRange.
  ///
  /// In pl, this message translates to:
  /// **'Ilość musi być od 1 do 5000 ml'**
  String get trackAmountMustBeRange;

  /// No description provided for @trackAddWater.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj wodę'**
  String get trackAddWater;

  /// No description provided for @trackAmountMlHintExample.
  ///
  /// In pl, this message translates to:
  /// **'np. 250'**
  String get trackAmountMlHintExample;

  /// No description provided for @trackMaxAmountPerEntry.
  ///
  /// In pl, this message translates to:
  /// **'Maksymalna ilość to 5000 ml na wpis'**
  String get trackMaxAmountPerEntry;

  /// No description provided for @trackEnterAmountRange.
  ///
  /// In pl, this message translates to:
  /// **'Podaj ilość od 1 do 5000 ml'**
  String get trackEnterAmountRange;

  /// No description provided for @trackDailyWaterGoal.
  ///
  /// In pl, this message translates to:
  /// **'Cel dzienny picia wody'**
  String get trackDailyWaterGoal;

  /// No description provided for @trackGoalHintExample.
  ///
  /// In pl, this message translates to:
  /// **'np. 2000'**
  String get trackGoalHintExample;

  /// No description provided for @trackGoalMustBeRange.
  ///
  /// In pl, this message translates to:
  /// **'Podaj wartość od 500 do 10000 ml'**
  String get trackGoalMustBeRange;

  /// No description provided for @trackWaterGoalUpdated.
  ///
  /// In pl, this message translates to:
  /// **'Cel wody zaktualizowany'**
  String get trackWaterGoalUpdated;

  /// No description provided for @trackChangeDailyWaterGoal.
  ///
  /// In pl, this message translates to:
  /// **'Zmień cel dzienny picia wody'**
  String get trackChangeDailyWaterGoal;

  /// No description provided for @trackEveryDropCounts.
  ///
  /// In pl, this message translates to:
  /// **'Każda kropla się liczy!'**
  String get trackEveryDropCounts;

  /// No description provided for @trackCustomAmount.
  ///
  /// In pl, this message translates to:
  /// **'Własna'**
  String get trackCustomAmount;

  /// No description provided for @trackWaterHistoryHint.
  ///
  /// In pl, this message translates to:
  /// **'Przegląd – edycja i usuwanie możliwe. Dodawanie tylko na dzisiaj.'**
  String get trackWaterHistoryHint;

  /// No description provided for @trackNoEntries.
  ///
  /// In pl, this message translates to:
  /// **'Brak wpisów'**
  String get trackNoEntries;

  /// No description provided for @trackEdit.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj'**
  String get trackEdit;

  /// No description provided for @trackAmountMlLabel.
  ///
  /// In pl, this message translates to:
  /// **'{amount} ml'**
  String trackAmountMlLabel({required String amount});

  /// No description provided for @trackDailyGoal.
  ///
  /// In pl, this message translates to:
  /// **'Cel dzienny'**
  String get trackDailyGoal;

  /// No description provided for @trackEnterWeight.
  ///
  /// In pl, this message translates to:
  /// **'Podaj wagę'**
  String get trackEnterWeight;

  /// No description provided for @trackEnterValidWeight.
  ///
  /// In pl, this message translates to:
  /// **'Podaj poprawną wagę (30-300 kg)'**
  String get trackEnterValidWeight;

  /// No description provided for @trackWeightSaved.
  ///
  /// In pl, this message translates to:
  /// **'Waga zapisana pomyślnie!'**
  String get trackWeightSaved;

  /// No description provided for @trackWeightMotivation.
  ///
  /// In pl, this message translates to:
  /// **'Regularne pomiary pomagają trzymać cel. Każdy wpis przybliża Cię do wymarzonej formy!'**
  String get trackWeightMotivation;

  /// No description provided for @trackPickMeasurementDate.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz datę pomiaru'**
  String get trackPickMeasurementDate;

  /// No description provided for @trackMeasurementSavedWithDate.
  ///
  /// In pl, this message translates to:
  /// **'Pomiar zostanie zapisany z wybraną datą'**
  String get trackMeasurementSavedWithDate;

  /// No description provided for @trackSaveWeight.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz wagę'**
  String get trackSaveWeight;

  /// No description provided for @trackDeleteMeasurementTitle.
  ///
  /// In pl, this message translates to:
  /// **'Usuń pomiar'**
  String get trackDeleteMeasurementTitle;

  /// No description provided for @trackDeleteWeightConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć pomiar {weight} kg?'**
  String trackDeleteWeightConfirm({required String weight});

  /// No description provided for @trackMeasurementDeleted.
  ///
  /// In pl, this message translates to:
  /// **'Pomiar usunięty'**
  String get trackMeasurementDeleted;

  /// No description provided for @trackNoWeightMeasurements.
  ///
  /// In pl, this message translates to:
  /// **'Brak pomiarów wagi'**
  String get trackNoWeightMeasurements;

  /// No description provided for @trackAddFirstMeasurementHint.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy pomiar, aby zobaczyć historię'**
  String get trackAddFirstMeasurementHint;

  /// No description provided for @trackNoDataToDisplay.
  ///
  /// In pl, this message translates to:
  /// **'Brak danych do wyświetlenia'**
  String get trackNoDataToDisplay;

  /// No description provided for @trackWeightKg.
  ///
  /// In pl, this message translates to:
  /// **'Waga (kg)'**
  String get trackWeightKg;

  /// No description provided for @trackHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia'**
  String get trackHistory;

  /// No description provided for @trackEnterMeasurementValue.
  ///
  /// In pl, this message translates to:
  /// **'Podaj wartość pomiaru'**
  String get trackEnterMeasurementValue;

  /// No description provided for @trackEnterValidPositiveValue.
  ///
  /// In pl, this message translates to:
  /// **'Podaj poprawną wartość (większą od 0)'**
  String get trackEnterValidPositiveValue;

  /// No description provided for @trackEnterCustomTypeName.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz nazwę własnego typu pomiaru (np. biceps)'**
  String get trackEnterCustomTypeName;

  /// No description provided for @trackMeasurementSaved.
  ///
  /// In pl, this message translates to:
  /// **'Pomiar zapisany pomyślnie!'**
  String get trackMeasurementSaved;

  /// No description provided for @trackBodyMeasurementsTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pomiary ciała'**
  String get trackBodyMeasurementsTitle;

  /// No description provided for @trackBodyMeasurementsMotivation.
  ///
  /// In pl, this message translates to:
  /// **'Śledź wymiary regularnie — każdy pomiar to dowód Twojego postępu i krok do wymarzonej sylwetki!'**
  String get trackBodyMeasurementsMotivation;

  /// No description provided for @trackMeasurementType.
  ///
  /// In pl, this message translates to:
  /// **'Typ pomiaru'**
  String get trackMeasurementType;

  /// No description provided for @trackCustomTypeHint.
  ///
  /// In pl, this message translates to:
  /// **'np. Biceps, Brzuch'**
  String get trackCustomTypeHint;

  /// No description provided for @trackCustomTypeName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa własnego typu'**
  String get trackCustomTypeName;

  /// No description provided for @trackValueCm.
  ///
  /// In pl, this message translates to:
  /// **'Wartość (cm)'**
  String get trackValueCm;

  /// No description provided for @trackValueHintExample.
  ///
  /// In pl, this message translates to:
  /// **'np. 85.5'**
  String get trackValueHintExample;

  /// No description provided for @trackSaveMeasurement.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz pomiar'**
  String get trackSaveMeasurement;

  /// No description provided for @trackMeasurementHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia pomiarów - {label}'**
  String trackMeasurementHistory({required String label});

  /// No description provided for @trackDeleteBodyMeasurementConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć pomiar {value} cm?'**
  String trackDeleteBodyMeasurementConfirm({required String value});

  /// No description provided for @trackNoMeasurements.
  ///
  /// In pl, this message translates to:
  /// **'Brak pomiarów'**
  String get trackNoMeasurements;

  /// No description provided for @trackTypeWaist.
  ///
  /// In pl, this message translates to:
  /// **'Talia'**
  String get trackTypeWaist;

  /// No description provided for @trackTypeHips.
  ///
  /// In pl, this message translates to:
  /// **'Biodra'**
  String get trackTypeHips;

  /// No description provided for @trackTypeChest.
  ///
  /// In pl, this message translates to:
  /// **'Klatka piersiowa'**
  String get trackTypeChest;

  /// No description provided for @trackTypeArm.
  ///
  /// In pl, this message translates to:
  /// **'Ramię'**
  String get trackTypeArm;

  /// No description provided for @trackTypeThigh.
  ///
  /// In pl, this message translates to:
  /// **'Udo'**
  String get trackTypeThigh;

  /// No description provided for @trackTypeCustom.
  ///
  /// In pl, this message translates to:
  /// **'Własny'**
  String get trackTypeCustom;

  /// No description provided for @trackNoFavorites.
  ///
  /// In pl, this message translates to:
  /// **'Brak ulubionych'**
  String get trackNoFavorites;

  /// No description provided for @trackNoFavoritesSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj posiłki lub aktywności do ulubionych przy ich zapisywaniu'**
  String get trackNoFavoritesSubtitle;

  /// No description provided for @trackFavoriteMeals.
  ///
  /// In pl, this message translates to:
  /// **'Ulubione posiłki'**
  String get trackFavoriteMeals;

  /// No description provided for @trackNoFavoriteMeals.
  ///
  /// In pl, this message translates to:
  /// **'Brak ulubionych posiłków'**
  String get trackNoFavoriteMeals;

  /// No description provided for @trackFavoriteActivities.
  ///
  /// In pl, this message translates to:
  /// **'Ulubione aktywności'**
  String get trackFavoriteActivities;

  /// No description provided for @trackNoFavoriteActivities.
  ///
  /// In pl, this message translates to:
  /// **'Brak ulubionych aktywności'**
  String get trackNoFavoriteActivities;

  /// No description provided for @trackAddToMealsOnDate.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do posiłków {date}'**
  String trackAddToMealsOnDate({required String date});

  /// No description provided for @trackAddToTodaysMeals.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do dzisiejszych posiłków'**
  String get trackAddToTodaysMeals;

  /// No description provided for @trackRemoveFromFavorites.
  ///
  /// In pl, this message translates to:
  /// **'Usuń z ulubionych'**
  String get trackRemoveFromFavorites;

  /// No description provided for @trackAddToActivitiesOnDate.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do aktywności {date}'**
  String trackAddToActivitiesOnDate({required String date});

  /// No description provided for @trackAddToTodaysActivities.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do dzisiejszych aktywności'**
  String get trackAddToTodaysActivities;

  /// No description provided for @trackMealAddedToMealsOnDate.
  ///
  /// In pl, this message translates to:
  /// **'{name} dodany do posiłków {date}'**
  String trackMealAddedToMealsOnDate({
    required String name,
    required String date,
  });

  /// No description provided for @trackMealAddedToTodaysMeals.
  ///
  /// In pl, this message translates to:
  /// **'{name} dodany do dzisiejszych posiłków'**
  String trackMealAddedToTodaysMeals({required String name});

  /// No description provided for @trackActivityAddedToActivitiesOnDate.
  ///
  /// In pl, this message translates to:
  /// **'{name} dodana do aktywności {date}'**
  String trackActivityAddedToActivitiesOnDate({
    required String name,
    required String date,
  });

  /// No description provided for @trackActivityAddedToTodaysActivities.
  ///
  /// In pl, this message translates to:
  /// **'{name} dodana do dzisiejszych aktywności'**
  String trackActivityAddedToTodaysActivities({required String name});

  /// No description provided for @trackRemoveFromFavoritesConfirm.
  ///
  /// In pl, this message translates to:
  /// **'Czy na pewno chcesz usunąć \"{name}\" z ulubionych?'**
  String trackRemoveFromFavoritesConfirm({required String name});

  /// No description provided for @trackRemovedFromFavorites.
  ///
  /// In pl, this message translates to:
  /// **'Usunięto z ulubionych'**
  String get trackRemovedFromFavorites;

  /// No description provided for @trackEditFavoriteMeal.
  ///
  /// In pl, this message translates to:
  /// **'Edytuj ulubiony posiłek'**
  String get trackEditFavoriteMeal;

  /// No description provided for @trackFavoriteMealUpdated.
  ///
  /// In pl, this message translates to:
  /// **'Zaktualizowano ulubiony posiłek'**
  String get trackFavoriteMealUpdated;

  /// No description provided for @trackRecalculateFromIngredients.
  ///
  /// In pl, this message translates to:
  /// **'Przelicz z składników'**
  String get trackRecalculateFromIngredients;

  /// No description provided for @trackMinutesLabel.
  ///
  /// In pl, this message translates to:
  /// **'{minutes} min'**
  String trackMinutesLabel({required String minutes});

  /// No description provided for @trackCaloriesKcal.
  ///
  /// In pl, this message translates to:
  /// **'Kalorie (kcal)'**
  String get trackCaloriesKcal;

  /// No description provided for @trackIncludingSaturatedG.
  ///
  /// In pl, this message translates to:
  /// **'w tym nasycone (g)'**
  String get trackIncludingSaturatedG;

  /// No description provided for @trackIncludingSugarsG.
  ///
  /// In pl, this message translates to:
  /// **'w tym cukry (g)'**
  String get trackIncludingSugarsG;

  /// No description provided for @trackWeightGOptional.
  ///
  /// In pl, this message translates to:
  /// **'Waga (g) - opcjonalnie'**
  String get trackWeightGOptional;

  /// No description provided for @trackGoalMl.
  ///
  /// In pl, this message translates to:
  /// **'Cel (ml)'**
  String get trackGoalMl;

  /// No description provided for @trackWaterTitle.
  ///
  /// In pl, this message translates to:
  /// **'Woda'**
  String get trackWaterTitle;

  /// No description provided for @trackOfGoal.
  ///
  /// In pl, this message translates to:
  /// **'{current} / {goal} ml'**
  String trackOfGoal({required String current, required String goal});

  /// No description provided for @trackSearchShort.
  ///
  /// In pl, this message translates to:
  /// **'Wyszukaj'**
  String get trackSearchShort;

  /// No description provided for @trackWaterToday.
  ///
  /// In pl, this message translates to:
  /// **'Woda – Dzisiaj'**
  String get trackWaterToday;

  /// No description provided for @trackWaterOnDate.
  ///
  /// In pl, this message translates to:
  /// **'Woda – {date}'**
  String trackWaterOnDate({required String date});

  /// No description provided for @trackHydrationBasics.
  ///
  /// In pl, this message translates to:
  /// **'Nawodnienie to podstawa formy.'**
  String get trackHydrationBasics;

  /// No description provided for @trackSugar.
  ///
  /// In pl, this message translates to:
  /// **'Cukry'**
  String get trackSugar;

  /// No description provided for @trackSaturatedFat.
  ///
  /// In pl, this message translates to:
  /// **'Nasycone'**
  String get trackSaturatedFat;

  /// No description provided for @trackProduct.
  ///
  /// In pl, this message translates to:
  /// **'Produkt'**
  String get trackProduct;

  /// No description provided for @trackMealMacrosLine.
  ///
  /// In pl, this message translates to:
  /// **'{kcal} kcal • B: {protein}g • T: {fat}g • W: {carbs}g'**
  String trackMealMacrosLine({
    required String kcal,
    required String protein,
    required String fat,
    required String carbs,
  });

  /// No description provided for @trackAnalysisResults.
  ///
  /// In pl, this message translates to:
  /// **'Wyniki analizy'**
  String get trackAnalysisResults;

  /// No description provided for @trackName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa'**
  String get trackName;

  /// No description provided for @trackProductNotFoundTitle.
  ///
  /// In pl, this message translates to:
  /// **'Nie znaleziono produktu'**
  String get trackProductNotFoundTitle;

  /// No description provided for @trackBarcodeLabel.
  ///
  /// In pl, this message translates to:
  /// **'Kod kreskowy'**
  String get trackBarcodeLabel;

  /// No description provided for @trackFetchingProductData.
  ///
  /// In pl, this message translates to:
  /// **'Pobieranie danych produktu...'**
  String get trackFetchingProductData;

  /// No description provided for @trackBrand.
  ///
  /// In pl, this message translates to:
  /// **'Marka: {brand}'**
  String trackBrand({required String brand});

  /// No description provided for @trackWeightGRequired.
  ///
  /// In pl, this message translates to:
  /// **'Waga (g) *'**
  String get trackWeightGRequired;

  /// No description provided for @trackYourPortion.
  ///
  /// In pl, this message translates to:
  /// **'Twoja porcja:'**
  String get trackYourPortion;

  /// No description provided for @trackMacroAbbrevProtein.
  ///
  /// In pl, this message translates to:
  /// **'B'**
  String get trackMacroAbbrevProtein;

  /// No description provided for @trackMacroAbbrevFat.
  ///
  /// In pl, this message translates to:
  /// **'T'**
  String get trackMacroAbbrevFat;

  /// No description provided for @trackMacroAbbrevCarbs.
  ///
  /// In pl, this message translates to:
  /// **'W'**
  String get trackMacroAbbrevCarbs;

  /// No description provided for @trackAddedKcal.
  ///
  /// In pl, this message translates to:
  /// **'Dodano: {kcal} kcal'**
  String trackAddedKcal({required String kcal});

  /// No description provided for @trackCaloriesPer100g.
  ///
  /// In pl, this message translates to:
  /// **'Kalorie (kcal/100g)'**
  String get trackCaloriesPer100g;

  /// No description provided for @trackDashToday.
  ///
  /// In pl, this message translates to:
  /// **'Dzisiaj'**
  String get trackDashToday;

  /// No description provided for @trackNoDate.
  ///
  /// In pl, this message translates to:
  /// **'Brak daty'**
  String get trackNoDate;

  /// No description provided for @trackEntries.
  ///
  /// In pl, this message translates to:
  /// **'Wpisy'**
  String get trackEntries;

  /// No description provided for @trackWeightHistory.
  ///
  /// In pl, this message translates to:
  /// **'Historia wagi'**
  String get trackWeightHistory;

  /// No description provided for @trackMeasurementName.
  ///
  /// In pl, this message translates to:
  /// **'Nazwa pomiaru'**
  String get trackMeasurementName;

  /// No description provided for @trackChoose.
  ///
  /// In pl, this message translates to:
  /// **'Wybierz'**
  String get trackChoose;

  /// No description provided for @trackDurationMinutesOptional.
  ///
  /// In pl, this message translates to:
  /// **'Czas trwania (minuty) - opcjonalnie'**
  String get trackDurationMinutesOptional;

  /// No description provided for @trackMax5000Helper.
  ///
  /// In pl, this message translates to:
  /// **'Maksymalnie 5000 ml na jeden wpis'**
  String get trackMax5000Helper;

  /// No description provided for @trackRecommendedMin2l.
  ///
  /// In pl, this message translates to:
  /// **'Zalecane jest min. 2l'**
  String get trackRecommendedMin2l;

  /// No description provided for @trackSummary.
  ///
  /// In pl, this message translates to:
  /// **'Podsumowanie'**
  String get trackSummary;

  /// No description provided for @trackBurnedKcalName.
  ///
  /// In pl, this message translates to:
  /// **'Spalone {kcal} kcal'**
  String trackBurnedKcalName({required String kcal});

  /// No description provided for @trackMeasurementDate.
  ///
  /// In pl, this message translates to:
  /// **'Data pomiaru'**
  String get trackMeasurementDate;

  /// No description provided for @trackKcalBurned.
  ///
  /// In pl, this message translates to:
  /// **'{kcal} kcal spalone'**
  String trackKcalBurned({required String kcal});

  /// No description provided for @trackMacrosInPremium.
  ///
  /// In pl, this message translates to:
  /// **'Makro – w Premium'**
  String get trackMacrosInPremium;

  /// No description provided for @trackSearchProductEllipsis.
  ///
  /// In pl, this message translates to:
  /// **'Szukaj produktu…'**
  String get trackSearchProductEllipsis;

  /// No description provided for @trackMacros.
  ///
  /// In pl, this message translates to:
  /// **'Makro'**
  String get trackMacros;

  /// No description provided for @trackRecentMeasurements.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnie pomiary'**
  String get trackRecentMeasurements;

  /// No description provided for @authEnterFullCode.
  ///
  /// In pl, this message translates to:
  /// **'Wpisz pełny kod z maila.'**
  String get authEnterFullCode;

  /// No description provided for @authSignedIn.
  ///
  /// In pl, this message translates to:
  /// **'Zalogowano pomyślnie!'**
  String get authSignedIn;

  /// No description provided for @authCodeExpired.
  ///
  /// In pl, this message translates to:
  /// **'Kod wygasł lub jest nieprawidłowy. Wyślij ponownie.'**
  String get authCodeExpired;

  /// No description provided for @authEnterEmail.
  ///
  /// In pl, this message translates to:
  /// **'Podaj adres email'**
  String get authEnterEmail;

  /// No description provided for @authInvalidEmail.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy format email'**
  String get authInvalidEmail;

  /// No description provided for @authLinkAndCodeSent.
  ///
  /// In pl, this message translates to:
  /// **'Wysłaliśmy link i kod na {email}. Sprawdź skrzynkę (także folder Spam) – kliknij link lub wpisz kod w aplikacji.'**
  String authLinkAndCodeSent({required String email});

  /// No description provided for @authCouldNotStart.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się rozpocząć logowania.'**
  String get authCouldNotStart;

  /// No description provided for @authEmailTaken.
  ///
  /// In pl, this message translates to:
  /// **'Ten adres e-mail jest już zarejestrowany. Zaloguj się linkiem z maila (sprawdź spam).'**
  String get authEmailTaken;

  /// No description provided for @authAlreadyLinked.
  ///
  /// In pl, this message translates to:
  /// **'To konto jest już połączone z innym użytkownikiem.'**
  String get authAlreadyLinked;

  /// No description provided for @authManualLinking.
  ///
  /// In pl, this message translates to:
  /// **'Łączenie kont wymaga włączenia w Supabase. Włącz \"Manual linking\" w Authentication → Providers.'**
  String get authManualLinking;

  /// No description provided for @authConnection.
  ///
  /// In pl, this message translates to:
  /// **'Błąd połączenia. Sprawdź internet.'**
  String get authConnection;

  /// No description provided for @authTooManyAttempts.
  ///
  /// In pl, this message translates to:
  /// **'Zbyt dużo prób logowania. Spróbuj za godzinę.'**
  String get authTooManyAttempts;

  /// No description provided for @authTooManyEmails.
  ///
  /// In pl, this message translates to:
  /// **'Zbyt wiele wiadomości na ten adres. Sprawdź skrzynkę lub spróbuj za chwilę.'**
  String get authTooManyEmails;

  /// No description provided for @authInvalidEmailAddress.
  ///
  /// In pl, this message translates to:
  /// **'Nieprawidłowy adres email.'**
  String get authInvalidEmailAddress;

  /// No description provided for @authGenericError.
  ///
  /// In pl, this message translates to:
  /// **'Błąd: {detail}'**
  String authGenericError({required String detail});

  /// No description provided for @premAboutPerMonth.
  ///
  /// In pl, this message translates to:
  /// **'ok. {amount} {unit} / miesięcznie'**
  String premAboutPerMonth({required String amount, required String unit});

  /// No description provided for @premYearlyPerMonthFallback.
  ///
  /// In pl, this message translates to:
  /// **'w przeliczeniu ok. 16,25 zł / mies. (płatność raz na rok)'**
  String get premYearlyPerMonthFallback;

  /// No description provided for @moreStreakWater.
  ///
  /// In pl, this message translates to:
  /// **'Woda'**
  String get moreStreakWater;

  /// No description provided for @premStoreNotReady.
  ///
  /// In pl, this message translates to:
  /// **'Zakupy w sklepie nie są jeszcze gotowe. Spróbuj ponownie za chwilę.'**
  String get premStoreNotReady;

  /// No description provided for @trackAddToCatalog.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj do bazy'**
  String get trackAddToCatalog;

  /// No description provided for @trackAddToCatalogHint.
  ///
  /// In pl, this message translates to:
  /// **'Zrób zdjęcie tabeli wartości odżywczych albo wpisz dane z etykiety. Produkt trafi do wspólnej bazy.'**
  String get trackAddToCatalogHint;

  /// No description provided for @trackLabelPhoto.
  ///
  /// In pl, this message translates to:
  /// **'Zdjęcie etykiety'**
  String get trackLabelPhoto;

  /// No description provided for @trackReadingLabel.
  ///
  /// In pl, this message translates to:
  /// **'Czytam etykietę…'**
  String get trackReadingLabel;

  /// No description provided for @trackLabelNotRead.
  ///
  /// In pl, this message translates to:
  /// **'Nie udało się odczytać tabeli. Wpisz wartości ręcznie.'**
  String get trackLabelNotRead;

  /// No description provided for @trackEnterNameAndCalories.
  ///
  /// In pl, this message translates to:
  /// **'Podaj nazwę i kalorie na 100 g.'**
  String get trackEnterNameAndCalories;

  /// No description provided for @trackProductSavedCatalog.
  ///
  /// In pl, this message translates to:
  /// **'Produkt zapisany. Następnym razem skan go znajdzie.'**
  String get trackProductSavedCatalog;

  /// No description provided for @trackCatalogNotSaved.
  ///
  /// In pl, this message translates to:
  /// **'Posiłek możesz dodać, ale wspólna baza nie zapisała produktu.'**
  String get trackCatalogNotSaved;

  /// No description provided for @trackBrandOptional.
  ///
  /// In pl, this message translates to:
  /// **'Marka (opcjonalnie)'**
  String get trackBrandOptional;

  /// No description provided for @trackCopyYesterday.
  ///
  /// In pl, this message translates to:
  /// **'Skopiuj wczoraj'**
  String get trackCopyYesterday;

  /// No description provided for @trackCopiedMealsCount.
  ///
  /// In pl, this message translates to:
  /// **'Skopiowano posiłki: {count}'**
  String trackCopiedMealsCount({required int count});

  /// No description provided for @trackNoMealsYesterday.
  ///
  /// In pl, this message translates to:
  /// **'Wczoraj nie było posiłków do skopiowania.'**
  String get trackNoMealsYesterday;

  /// No description provided for @trackCopyConfirmTitle.
  ///
  /// In pl, this message translates to:
  /// **'Posiłki już są'**
  String get trackCopyConfirmTitle;

  /// No description provided for @trackCopyConfirmBody.
  ///
  /// In pl, this message translates to:
  /// **'Tego dnia masz już {count} posiłków. Skopiować wczorajsze jeszcze raz? (powstaną duplikaty)'**
  String trackCopyConfirmBody({required int count});

  /// No description provided for @trackCopyAgain.
  ///
  /// In pl, this message translates to:
  /// **'Kopiuj ponownie'**
  String get trackCopyAgain;

  /// No description provided for @trackCopying.
  ///
  /// In pl, this message translates to:
  /// **'Kopiowanie…'**
  String get trackCopying;

  /// No description provided for @trackRecentFoods.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnio jedzone'**
  String get trackRecentFoods;

  /// No description provided for @trackMealIdeasTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pasuje na dziś'**
  String get trackMealIdeasTitle;

  /// No description provided for @trackMealIdeasLeft.
  ///
  /// In pl, this message translates to:
  /// **'Zostało ok. {kcal} kcal'**
  String trackMealIdeasLeft({required String kcal});

  /// No description provided for @trackWaterTipSerious.
  ///
  /// In pl, this message translates to:
  /// **'Regularne nawodnienie wspiera koncentrację i metabolizm — warto pić przez cały dzień.'**
  String get trackWaterTipSerious;

  /// No description provided for @trackAddFirstMealTitle.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj pierwszy posiłek'**
  String get trackAddFirstMealTitle;

  /// No description provided for @trackAddFirstMealSubtitle.
  ///
  /// In pl, this message translates to:
  /// **'Zacznij od wpisania tego, co jesz — reszta policzy się sama.'**
  String get trackAddFirstMealSubtitle;

  /// No description provided for @trackAddFirstMealCta.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj posiłek'**
  String get trackAddFirstMealCta;

  /// No description provided for @trackShortcutRecent.
  ///
  /// In pl, this message translates to:
  /// **'Ostatnie'**
  String get trackShortcutRecent;

  /// No description provided for @trackRemainingKcal.
  ///
  /// In pl, this message translates to:
  /// **'Zostało do celu'**
  String get trackRemainingKcal;

  /// No description provided for @trackOverGoalLabel.
  ///
  /// In pl, this message translates to:
  /// **'Powyżej celu'**
  String get trackOverGoalLabel;

  /// No description provided for @trackGoalVerificationDays.
  ///
  /// In pl, this message translates to:
  /// **'{days}/7 dni z danymi'**
  String trackGoalVerificationDays({required int days});

  /// No description provided for @trackCalorieGoalSuccess.
  ///
  /// In pl, this message translates to:
  /// **'Dobra robota — dziś jesteś w okolicach celu kalorycznego.'**
  String get trackCalorieGoalSuccess;

  /// No description provided for @trackD1ChecklistTitle.
  ///
  /// In pl, this message translates to:
  /// **'Pierwszy dzień — checklista'**
  String get trackD1ChecklistTitle;

  /// No description provided for @trackD1ChecklistMeal.
  ///
  /// In pl, this message translates to:
  /// **'Dodaj posiłek'**
  String get trackD1ChecklistMeal;

  /// No description provided for @trackD1ChecklistWater.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz wodę'**
  String get trackD1ChecklistWater;

  /// No description provided for @trackD1ChecklistWeight.
  ///
  /// In pl, this message translates to:
  /// **'Zapisz wagę'**
  String get trackD1ChecklistWeight;

  /// No description provided for @trackD1ChecklistDismiss.
  ///
  /// In pl, this message translates to:
  /// **'Rozumiem'**
  String get trackD1ChecklistDismiss;

  /// No description provided for @trackPremiumLabel.
  ///
  /// In pl, this message translates to:
  /// **'Premium'**
  String get trackPremiumLabel;

  /// No description provided for @trackPercentOfGoal.
  ///
  /// In pl, this message translates to:
  /// **'{percent}% celu'**
  String trackPercentOfGoal({required String percent});
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
    case 'uk':
      return AppLocalizationsUk();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
