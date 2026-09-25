// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get language => 'Мова';

  @override
  String get appTitle => 'Łatwa Forma';

  @override
  String get navToday => 'Сьогодні';

  @override
  String get navMeals => 'Страви';

  @override
  String get navWater => 'Вода';

  @override
  String get navProfile => 'Я';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Скасувати';

  @override
  String get commonSave => 'Зберегти';

  @override
  String get commonDelete => 'Видалити';

  @override
  String get commonClose => 'Закрити';

  @override
  String get commonRetry => 'Спробувати знову';

  @override
  String get commonWarning => 'Увага';

  @override
  String get commonError => 'Помилка';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonYes => 'Так';

  @override
  String get commonNo => 'Ні';

  @override
  String get commonContinue => 'Далі';

  @override
  String get healthDisclaimer =>
      'Łatwa Forma не є медичним пристроєм і не діагностує, не лікує, не запобігає та не виліковує жодної хвороби чи стану здоров’я. Розрахунки калорій, макронутрієнтів і поради ШІ мають орієнтовний характер. У питаннях здоров’я звернися до лікаря або дієтолога.';

  @override
  String get onbContinueApple => 'Продовжити з Apple';

  @override
  String get onbContinueGoogle => 'Продовжити з Google';

  @override
  String get onbContinueWithEmail => 'Продовжити з ел. поштою';

  @override
  String get onbStartWithoutAccount => 'Почати без акаунта';

  @override
  String get onbCreateAccount => 'Створити акаунт';

  @override
  String get onbCreateAccountEmail => 'Створити акаунт через ел. пошту';

  @override
  String get onbEnterCodeLink => 'У мене вже є код із листа — ввести його';

  @override
  String get onbAlreadyHaveCode => 'У мене вже є код із листа';

  @override
  String get onbLegalPrefix => 'Користуючись застосунком, ти приймаєш ';

  @override
  String get onbTerms => 'Умови';

  @override
  String get onbLegalAnd => ' і ';

  @override
  String get onbPrivacyPolicyAccusative => 'Політику конфіденційності';

  @override
  String get onbLegalPeriod => '.';

  @override
  String get onbPrivacyPolicy => 'Політика конфіденційності';

  @override
  String get onbContact => 'Контакт';

  @override
  String get onbFollowUs => 'Стеж за нами: ';

  @override
  String onbSocialComingSoon({required String name}) {
    return '$name — незабаром';
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
  String get onbFeatureCaloriesTitle => 'Калорії та макро під тебе';

  @override
  String get onbFeatureCaloriesDesc => 'Денний ліміт і макро під твою ціль';

  @override
  String get onbFeatureWeightTitle => 'Вага та прогрес';

  @override
  String get onbFeatureWeightDesc => 'Вага і зміни в одному місці';

  @override
  String get onbFeaturePlanTitle => 'Простий план до цілі';

  @override
  String get onbFeaturePlanDesc => 'Зрозумілий шлях до твоєї ваги';

  @override
  String get onbFeatureAiTitle => 'Допомога ШІ';

  @override
  String get onbFeatureAiDesc => 'Поради та страва зі світлини';

  @override
  String get onbFeatureProductsTitle => 'База продуктів';

  @override
  String get onbFeatureProductsDesc => 'Шукай і скануй штрихкод';

  @override
  String get onbBenefitCalories => 'план калорій під тебе';

  @override
  String get onbBenefitWeight => 'відстеження ваги та прогресу';

  @override
  String get onbBenefitPlan => 'простий план до цілі';

  @override
  String get onbBenefitAi => 'допомога ШІ';

  @override
  String get onbLoginOrRegister => 'Увійди або створи акаунт';

  @override
  String get onbLoginOrCreateShort => 'Увійти або створити акаунт';

  @override
  String get onbLoginSheetBody =>
      'Маєш акаунт? Увійди. Новий користувач? Створи акаунт — твої дані буде збережено.';

  @override
  String get onbFaqTitle => 'FAQ — часті запитання';

  @override
  String get onbFaqShowLess => 'Показати менше';

  @override
  String onbFaqShowMore({required int count}) {
    return 'Більше запитань ($count)';
  }

  @override
  String get onbFaqFreeQ => 'Чи застосунок безкоштовний?';

  @override
  String get onbFaqFreeA =>
      'Так. Łatwa Forma безкоштовна для щоденного користування: калорії, страви, вага, вода й активність. Частина функцій (наприклад, аналіз ШІ зі світлини, розширена статистика) доступна в плані Premium.';

  @override
  String get onbFaqPhotoQ => 'Як працює лічильник калорій зі світлини?';

  @override
  String get onbFaqPhotoA =>
      'На екрані додавання страви обери «Аналіз ШІ». Зроби світлину страви або вибери її з галереї. Застосунок надсилає світлину моделі ШІ, яка розпізнає страву й оцінює калорії та макронутрієнти (білки, жири, вуглеводи). Потім їх можна виправити й зберегти. Функція потребує Premium.';

  @override
  String get onbFaqLimitQ => 'Як застосунок рахує мій денний ліміт калорій?';

  @override
  String get onbFaqLimitA =>
      'На основі профілю (вік, стать, вага, зріст, рівень активності) ми рахуємо BMR (формула Гарріса–Бенедикта), а потім TDEE. Залежно від цілі (схуднення, підтримка, набір) підлаштовуємо ліміт калорій і макро.';

  @override
  String get onbFaqNoAccountQ => 'Що таке «Почати без акаунта»?';

  @override
  String get onbFaqNoAccountA =>
      'Можна користуватися застосунком без входу. Дані зберігаються локально. Пізніше їх можна зв’язати з акаунтом (Apple, Google або ел. пошта), щоб мати резервну копію і синхронізацію між пристроями.';

  @override
  String get onbFaqStravaQ => 'Чи можна підключити Strava або Garmin?';

  @override
  String get onbFaqStravaA =>
      'Так, Strava. У налаштуваннях (Профіль → Інтеграції) можна з’єднати акаунт зі Strava. Імпортовані активності враховуються в балансі калорій (спалені kcal). Garmin Connect з’явиться після запуску інтеграції.';

  @override
  String get onbFaqPremiumQ => 'Що дає Premium?';

  @override
  String get onbFaqPremiumA =>
      'Зокрема аналіз страви зі світлини (ШІ), розширену статистику, експорт даних і вищий ліміт порад ШІ. У застосунку з магазину оплата йде через Google Play / App Store; на сайті latwaforma.pl — через Stripe.';

  @override
  String get onbFaqGoalQ => 'Як змінити ціль (схуднення / підтримка / набір)?';

  @override
  String get onbFaqGoalA =>
      'У Профілі вкажи цільову вагу. На цій основі застосунок пропонує ціль і денний ліміт; макро можна також змінити вручну в налаштуваннях профілю.';

  @override
  String get onbFaqAddMealQ => 'Як додати страву?';

  @override
  String get onbFaqAddMealA =>
      'З головного екрана або вкладки «Страви» обери «Додати страву». Можна ввести дані вручну, відсканувати штрихкод (Open Food Facts) або скористатися аналізом ШІ зі світлини (Premium).';

  @override
  String get onbFaqDataQ => 'Де зберігаються мої дані?';

  @override
  String get onbFaqDataA =>
      'Дані зберігаються на серверах у Європі (Supabase). Якщо обрати «Почати без акаунта», дані локальні, доки ти не з’єднаєш їх з акаунтом.';

  @override
  String get onbFaqDeleteQ => 'Як видалити акаунт і дані?';

  @override
  String get onbFaqDeleteA =>
      'У застосунку: Профіль → Видалити акаунт. Можна також подати заявку на latwaforma.pl/usun-konto.html. Після підтвердження акаунт і пов’язані дані видаляються (це не заморожування акаунта). Підписку в Google Play / App Store скасуй окремо в магазині. Якщо є проблема: contact@latwaforma.pl.';

  @override
  String get onbFaqMedicalQ => 'Чи це медичний застосунок?';

  @override
  String get onbFaqMedicalA =>
      'Ні. Łatwa Forma не є медичним пристроєм і не діагностує, не лікує та не запобігає хворобам. Розрахунки й поради ШІ орієнтовні. У питаннях здоров’я звернися до лікаря або дієтолога.';

  @override
  String get onbSendingLinkAndCode => 'Надсилаємо посилання і код...';

  @override
  String get onbSignedIn => 'Вхід виконано';

  @override
  String get onbSignedInSuccess => 'Вхід успішний!';

  @override
  String get onbSignedInDataSaved => 'Ти увійшов. Твої дані збережено.';

  @override
  String get onbAccountLinked => 'Акаунт з’єднано';

  @override
  String get onbEmailLinkedSuccess =>
      'Твою адресу ел. пошти з’єднано з акаунтом. Тепер можна входити цією поштою.';

  @override
  String get onbEnterEmailTitle => 'Вкажи адресу ел. пошти';

  @override
  String get onbEnterEmailWhichAddress =>
      'На яку адресу ми надіслали посилання і код? Вкажи її, а потім введи код.';

  @override
  String get onbEmailAddressLabel => 'Адреса ел. пошти';

  @override
  String get onbEmailAddressLabelAlt => 'Адреса ел. пошти';

  @override
  String get onbEmailAddressHint => 'напр. jan@example.com';

  @override
  String get onbCheckInbox => 'Перевір пошту';

  @override
  String get onbEnterCodeFromEmailTitle => 'Введи код із листа';

  @override
  String get onbEnterCodeFromEmailLabel => 'Введи код із листа:';

  @override
  String get onbEmailCodeLabel => 'Код із листа';

  @override
  String get onbEmailCodeHint => 'напр. 123456';

  @override
  String onbSentLinkAndCode({required String email}) {
    return 'Ми надіслали посилання і код на $email. Перевір пошту (також папку Спам) — можна натиснути посилання в листі або ввести код нижче.';
  }

  @override
  String onbEnterCodeReceived({required String email}) {
    return 'Введи нижче код, який ти отримав на адресу $email.';
  }

  @override
  String onbCodeSentTo({required String email}) {
    return 'Код надіслано на: $email';
  }

  @override
  String onbCodeSentEnterBelow({required String email}) {
    return 'Ми надіслали код на $email. Введи його нижче.';
  }

  @override
  String get onbResend => 'Надіслати знову';

  @override
  String get onbSignIn => 'Увійти';

  @override
  String get onbConfirmCode => 'Підтвердити код';

  @override
  String get onbSuccess => 'Успіх';

  @override
  String get onbSendLinkAndCode => 'Надіслати посилання і код';

  @override
  String get onbEmailSignupBody =>
      'Вкажи адресу ел. пошти. Ми надішлемо посилання і код, якими ти завершиш створення акаунта.';

  @override
  String get onbEnterEmailRequired => 'Вкажи адресу ел. пошти';

  @override
  String get onbIntroTitle => 'Розкажи трохи про себе';

  @override
  String get onbIntroBody =>
      'Покажемо, скільки їсти щодня,\nщоб досягти своєї цілі.';

  @override
  String get onbIntroDuration => 'Займе менше хвилини';

  @override
  String get onbIntroStart => 'Почати';

  @override
  String get onbAnonErrorTitle => 'Не вдалося почати без акаунта';

  @override
  String get onbAnonErrorNoConfig =>
      'Застосунок не має з’єднання з сервером (немає конфігурації у збірці).';

  @override
  String get onbAnonErrorTimeout =>
      'Сервер не відповів вчасно. Перевір інтернет або спробуй пізніше.';

  @override
  String get onbAnonErrorFailed => 'З’єднання з сервером не вдалося. Ти можеш:';

  @override
  String get onbAnonErrorTipDomain =>
      '• Переконайся, що ти на адресі latwaforma.pl.';

  @override
  String get onbAnonErrorTipRefresh => '• Онови сторінку (F5) і спробуй знову.';

  @override
  String get onbAnonErrorTipLogin =>
      '• Або увійди через Apple, Google чи ел. пошту — кнопка вгорі.';

  @override
  String get onbOpenLatwaForma => 'Відкрити latwaforma.pl';

  @override
  String get onbSplashNoServerConfig =>
      'Немає з’єднання з сервером. Перевір конфігурацію (.env) та інтернет.';

  @override
  String get onbSplashNoConnection =>
      'Немає з’єднання. Перевір інтернет і спробуй знову.';

  @override
  String get onbSplashLoginFailed =>
      'Не вдалося увійти. Заповни профіль або спробуй увійти знову.';

  @override
  String get onbSplashGoogleFailed =>
      'Вхід через Google не вдався. Увійди знову в цій самій вкладці.';

  @override
  String get onbSplashAbort => 'Перервати';

  @override
  String get onbPlanThanks => 'Дякуємо!';

  @override
  String get onbPlanGotIt => 'Готово!';

  @override
  String get onbPlanStepData => 'Дані';

  @override
  String get onbPlanStepCalc => 'Розрахунок';

  @override
  String get onbPlanStepMacro => 'Макро';

  @override
  String get onbPlanStepDone => 'Готово';

  @override
  String get onbPlanStatusAnalyzing => 'Аналізуємо твої дані…';

  @override
  String get onbPlanStatusCalories => 'Рахуємо калорії…';

  @override
  String get onbPlanStatusMacro => 'Макро…';

  @override
  String get onbPlanStatusAlmost => 'Майже готово…';

  @override
  String get onbPlanReadyTitle => 'Твій план готовий!';

  @override
  String get onbPlanWhatDone => 'Що зроблено:';

  @override
  String get onbPlanCaloriesComputed =>
      '• На основі зросту, ваги, віку та рівня активності ми розрахували твоє денне споживання калорій.';

  @override
  String onbPlanCaloriesComputedWithValue({required String calories}) {
    return '• На основі зросту, ваги, віку та рівня активності ми розрахували твоє денне споживання калорій: $calories kcal.';
  }

  @override
  String onbPlanTargetDate({required String date}) {
    return '• Орієнтовна дата досягнення цілі: $date';
  }

  @override
  String get onbPlanChangeInProfile =>
      'Ці дані можна будь-коли змінити у вкладці Профіль (іконка людини вгорі).';

  @override
  String get onbPlanHowToUse => 'Як користуватися застосунком:';

  @override
  String get onbPlanTipMeals =>
      '• Додавай страви — стеж, що їси і скільки калорій споживаєш';

  @override
  String get onbPlanTipWater =>
      '• Пий воду — увімкни нагадування в налаштуваннях';

  @override
  String get onbPlanTipWeight =>
      '• Записуй вагу регулярно — прогрес видно на графіку';

  @override
  String get onbPlanTipDashboard =>
      '• Перевіряй головний екран — там денна ціль і прогрес';

  @override
  String get onbPlanMedicalNote =>
      'Łatwa Forma не є медичним пристроєм і не діагностує, не лікує та не запобігає хворобам. У питаннях здоров’я звернися до лікаря або дієтолога.';

  @override
  String get onbPlanStartButton => 'Зрозуміло, починаю!';

  @override
  String get onbSaveProgressTitle => 'Збережи прогрес';

  @override
  String onbSaveProgressBodyWithMeals({required int count}) {
    return 'У тебе вже $count страв! Увійди, щоб не втратити дані після перевстановлення застосунку.';
  }

  @override
  String get onbSaveProgressBodyEmpty =>
      'Створи акаунт, щоб страви, активності та вага зберігалися в хмарі й були доступні на кожному пристрої — нічого не зникне після перевстановлення.';

  @override
  String get onbChooseLoginMethod => 'Обери спосіб входу:';

  @override
  String get onbLater => 'Пізніше';

  @override
  String guestTrialDaysLeft({required int days}) {
    return 'Без облікового запису: залишилось $days дн.';
  }

  @override
  String get guestTrialOneDay => 'Без облікового запису: залишився 1 день';

  @override
  String get guestTrialLastDay =>
      'Без облікового запису: останній день. Від завтра нові записи потребують облікового запису.';

  @override
  String get guestTrialCardBody =>
      'З’єднайте обліковий запис, щоб дані лишилися при зміні телефона.';

  @override
  String get guestTrialEndedTitle => 'Період без облікового запису минув';

  @override
  String get guestTrialEndedBody =>
      'Можна переглядати збережені прийоми їжі, воду і вагу. Щоб додавати далі, з’єднайте обліковий запис — дані залишаться.';

  @override
  String get guestTrialViewOnly => 'Лише перегляд';

  @override
  String get onbLinkingAccount => 'З’єднуємо акаунт...';

  @override
  String get onbAccountSavedSuccess => 'Акаунт успішно збережено!';

  @override
  String get onbSaveWithEmailTitle => 'Зберегти через ел. пошту';

  @override
  String get onbEmailAlreadyRegistered => 'Ел. пошта вже зареєстрована';

  @override
  String get onbClickBelowToLogin => 'Натисни нижче, щоб перейти до входу:';

  @override
  String get onbSignOutAndSignIn => 'Вийти і увійти';

  @override
  String get onbGoBackTitle => 'Повернутися?';

  @override
  String get onbGoBackBody =>
      'Дані не буде збережено. Ти повернешся на початковий екран.';

  @override
  String get onbGoBackConfirm => 'Так, назад';

  @override
  String get onbBackTooltip => 'Назад';

  @override
  String get onbCompleteData => 'Заповни дані';

  @override
  String get onbGenderLabel => 'Стать *';

  @override
  String get onbGenderFemale => 'Жінка';

  @override
  String get onbGenderMale => 'Чоловік';

  @override
  String get onbAgeLabel => 'Вік *';

  @override
  String get onbYearsUnit => 'р.';

  @override
  String get onbHeightLabel => 'Зріст (см) *';

  @override
  String get onbCurrentWeightLabel => 'Поточна вага (кг) *';

  @override
  String get onbTargetWeightLabel => 'Цільова вага (кг) *';

  @override
  String onbWeightDiff({required String diff}) {
    return 'Різниця: $diff кг';
  }

  @override
  String get onbWeightDiffMin => 'Різниця між вагами має бути щонайменше 1 кг';

  @override
  String get onbActivityLabel => 'Рівень активності *';

  @override
  String get onbActivitySedentary => 'Сидячий';

  @override
  String get onbActivitySedentaryDesc =>
      'Немає активності або мінімальна активність';

  @override
  String get onbActivityLight => 'Легка';

  @override
  String get onbActivityLightDesc => 'Тренування 1–3 рази на тиждень';

  @override
  String get onbActivityModerate => 'Помірна';

  @override
  String get onbActivityModerateDesc => 'Тренування 3–5 разів на тиждень';

  @override
  String get onbActivityIntense => 'Інтенсивна';

  @override
  String get onbActivityIntenseDesc => 'Тренування 6–7 разів на тиждень';

  @override
  String get onbActivityVeryIntense => 'Дуже інтенсивна';

  @override
  String get onbActivityVeryIntenseDesc =>
      'Дуже важка фізична робота або тренування двічі на день';

  @override
  String get onbSaveAndStart => 'Зберегти і почати';

  @override
  String get onbGoalLose => 'Хочу схуднути.';

  @override
  String get onbGoalGain => 'Хочу набрати вагу.';

  @override
  String get onbGoalMaintain => 'Хочу зберегти поточну вагу.';

  @override
  String get onbGoalUnchangedSameWeight =>
      'Ціль не змінилась. Цільова вага не відрізняється від поточної, тож план — утримувати вагу.';

  @override
  String get onbErrorCreatingAccount => 'Помилка під час створення акаунта.';

  @override
  String get onbErrorNetworkPermission =>
      'Помилка мережевих дозволів.\n\nРішення:\n1. Зупини застосунок\n2. Запусти знову: flutter run\n3. Якщо проблема лишається, перевір, чи в Supabase увімкнено анонімну авторизацію';

  @override
  String get onbErrorAnonymousDisabled =>
      'Анонімну авторизацію не ввімкнено в Supabase.\n\nПерейди до: Authentication → Providers → Anonymous → Enable';

  @override
  String get onbErrorInternet =>
      'Помилка з’єднання з інтернетом.\nПеревір з’єднання і спробуй знову.';

  @override
  String get onbErrorInternetShort =>
      'Помилка з’єднання з інтернетом. Перевір з’єднання і спробуй знову.';

  @override
  String get onbErrorSupabaseConfig =>
      'Помилка конфігурації Supabase.\nПеревір ключі API у файлі .env';

  @override
  String onbErrorWithDetails({required String details}) {
    return 'Помилка: $details';
  }

  @override
  String get onbErrorSaving => 'Помилка під час збереження';

  @override
  String get onbErrorAuth =>
      'Помилка авторизації. Перевір конфігурацію Supabase.';

  @override
  String get moreStatisticsTitle => 'Статистика';

  @override
  String get moreStreaksTooltip => 'Серії';

  @override
  String get moreWeeklySummary => 'Тижневий підсумок';

  @override
  String get moreShareTooltip => 'Поділитися';

  @override
  String get moreShareWeeklyStatsFeature => 'Надсилання тижневої статистики';

  @override
  String get moreShareWeeklySummaryText => '📊 Łatwa Forma – Тижневий підсумок';

  @override
  String moreShareError({required String error}) {
    return 'Помилка надсилання: $error';
  }

  @override
  String get moreAvgDailyCalories => 'Середні денні калорії';

  @override
  String get moreTotalCaloriesWeek => 'Усього калорій (тиждень)';

  @override
  String get moreBurnedCaloriesWeek => 'Спалені калорії (тиждень)';

  @override
  String get moreWaterWeek => 'Вода (тиждень)';

  @override
  String get moreCaloriesDuringWeek => 'Калорії протягом тижня';

  @override
  String get moreMacrosWeek => 'Макро (тиждень)';

  @override
  String get moreProtein => 'Білки';

  @override
  String get moreFat => 'Жири';

  @override
  String get moreCarbs => 'Вугл.';

  @override
  String get moreCarbsFull => 'Вуглеводи';

  @override
  String get moreGoalVerification => 'Перевірка цілі';

  @override
  String get moreGoalVerificationHint =>
      'Записуй страви і вагу щодня протягом тижня. Застосунок перевірить твою ціль і запропонує правки, якщо реальна потреба відрізняється від калькулятора.';

  @override
  String moreProgressDaysWithData({required int days}) {
    return 'Прогрес: $days/7 днів із даними';
  }

  @override
  String get moreBasedOnLast7Days => 'На основі останніх 7 днів:';

  @override
  String moreAvgCaloriesPerDayBullet({required String calories}) {
    return '• У середньому: ~$calories kcal/день';
  }

  @override
  String get moreWeightStable => 'стабільна';

  @override
  String moreWeightIncrease({required String kg}) {
    return 'зростання (+$kg кг)';
  }

  @override
  String moreWeightDecrease({required String kg}) {
    return 'зниження ($kg кг)';
  }

  @override
  String moreWeightBullet({required String change}) {
    return '• Вага: $change';
  }

  @override
  String get moreSaving => 'Збереження…';

  @override
  String get moreApplyCorrectedGoal => 'Застосувати виправлену ціль';

  @override
  String get moreGoalAligned =>
      'Даних достатньо. Твоя поточна ціль відповідає тренду — корекція не потрібна.';

  @override
  String moreRealTdee({required String calories}) {
    return 'Реальна потреба: ~$calories kcal';
  }

  @override
  String moreGoalUpdated({required String calories}) {
    return 'Ціль оновлено до ~$calories kcal';
  }

  @override
  String moreErrorWithDetails({required String error}) {
    return 'Помилка: $error';
  }

  @override
  String get moreGoalHistoryReason =>
      'Перевірка на основі даних за останній тиждень';

  @override
  String get moreDayMon => 'Пн';

  @override
  String get moreDayTue => 'Вт';

  @override
  String get moreDayWed => 'Ср';

  @override
  String get moreDayThu => 'Чт';

  @override
  String get moreDayFri => 'Пт';

  @override
  String get moreDaySat => 'Сб';

  @override
  String get moreDaySun => 'Нд';

  @override
  String moreSuggestionWeightLossFlat({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'Вага стабільна при ~$avg kcal. Твоя реальна потреба — ~$real kcal. Хочеш схуднути? Спробуй ~$corr kcal.';
  }

  @override
  String moreSuggestionWeightLossDown({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'Ти худнеш при ~$avg kcal. Реальний TDEE: ~$real kcal. Запропонована ціль: ~$corr kcal.';
  }

  @override
  String moreSuggestionWeightGainFlat({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'Вага стабільна при ~$avg kcal. Твоя реальна потреба — ~$real kcal. Хочеш набрати? Спробуй ~$corr kcal.';
  }

  @override
  String moreSuggestionWeightGainUp({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'Ти набираєш при ~$avg kcal. Реальний TDEE: ~$real kcal. Запропонована ціль: ~$corr kcal.';
  }

  @override
  String moreSuggestionMaintain({
    required String real,
    required String calc,
    required String corr,
  }) {
    return 'Реальна потреба: ~$real kcal (калькулятор: $calc kcal). Ціль: ~$corr kcal.';
  }

  @override
  String get moreBmiCalculatorTitle => 'Калькулятор BMI';

  @override
  String get moreYourBmi => 'Твій BMI';

  @override
  String get moreCalculatedBasedOn => 'Розраховано на основі:';

  @override
  String moreCurrentWeightBullet({required String weight}) {
    return '• Поточна вага: $weight кг';
  }

  @override
  String moreHeightBullet({required String height}) {
    return '• Зріст: $height см';
  }

  @override
  String moreNormalBmiRangeHint({
    required String minKg,
    required String maxKg,
  }) {
    return 'Щоб бути в нормі (BMI 18,5–24,9), тримайся ваги від $minKg до $maxKg кг.';
  }

  @override
  String get moreCompleteProfileForBmi =>
      'Заповни профіль (вага і зріст), щоб побачити свій BMI';

  @override
  String get moreBmiScale => 'Шкала BMI';

  @override
  String get moreBmiUnderweight => 'Недостатня вага';

  @override
  String get moreBmiNormal => 'Норма';

  @override
  String get moreBmiOverweight => 'Надмірна вага';

  @override
  String get moreBmiObesity1 => 'Ожиріння I ступеня';

  @override
  String get moreBmiObesity2 => 'Ожиріння II ступеня';

  @override
  String get moreBmiObesity3 => 'Ожиріння III ступеня';

  @override
  String get moreBmiFormulaTitle => 'Формула BMI';

  @override
  String get moreBmiFormula => 'BMI = вага (кг) / зріст (м)²';

  @override
  String get moreBmiExplanation =>
      'BMI — це індекс маси тіла, який допомагає оцінити, чи вага відповідає зросту.';

  @override
  String get moreExportTitle => 'Експорт даних';

  @override
  String get moreExportDescription =>
      'Експортуй дані у файл CSV (повний список) або PDF (звіт за останні 30 днів). Відкриється вікно надсилання.';

  @override
  String get moreExporting => 'Експорт...';

  @override
  String get moreExportToCsv => 'Експортувати в CSV';

  @override
  String get moreExportToPdfPremium => 'Експортувати в PDF (Premium)';

  @override
  String get moreExportPdfFeature => 'Експорт у PDF';

  @override
  String get moreUserNotLoggedIn => 'Користувач не увійшов';

  @override
  String get moreCsvCopiedClipboard =>
      'Дані скопійовано в буфер. Встав у Блокнот або Excel і збережи як .csv';

  @override
  String get moreCsvFileReady =>
      'Файл CSV готовий. Його можна зберегти або надіслати.';

  @override
  String get moreCsvClipboardFallback =>
      'Дані експортовано в буфер (CSV). Встав їх, наприклад, у Нотатки і збережи як файл .csv';

  @override
  String get moreCsvClipboardShort => 'Дані експортовано в буфер (CSV).';

  @override
  String get moreExportFailed =>
      'Не вдалося експортувати. Перевір з’єднання і спробуй знову.';

  @override
  String get moreExportShareText => 'Експорт даних Łatwa Forma';

  @override
  String moreExportShareSubject({required String date}) {
    return 'Дані Łatwa Forma - $date';
  }

  @override
  String get morePdfReportShareText => 'Звіт Łatwa Forma';

  @override
  String morePdfReportShareSubject({required String date}) {
    return 'Звіт Łatwa Forma - $date';
  }

  @override
  String get morePdfDownloaded =>
      'PDF завантажено. Перевір папку Завантаження.';

  @override
  String get morePdfShareOrDownloadFailed =>
      'Не вдалося надіслати чи завантажити PDF. Спробуй у браузері Chrome або експортуй у CSV.';

  @override
  String get morePdfShareFailed =>
      'Не вдалося надіслати PDF. Спробуй експортувати в CSV.';

  @override
  String get morePdfFileReady =>
      'Файл PDF готовий. Його можна зберегти або надіслати.';

  @override
  String morePdfExportFailedWithHint({required String hint}) {
    return 'Експорт PDF не вдався ($hint). Спробуй CSV.';
  }

  @override
  String get morePdfExportFailed =>
      'Експорт PDF не вдався. Спробуй знову або експортуй у CSV.';

  @override
  String get moreCsvSectionProfile => '=== ПРОФІЛЬ ===';

  @override
  String get moreCsvHeaderTypeNameValue => 'Тип,Назва,Значення';

  @override
  String get moreCsvProfile => 'Профіль';

  @override
  String get moreCsvGender => 'Стать';

  @override
  String get moreGenderMale => 'Чоловік';

  @override
  String get moreGenderFemale => 'Жінка';

  @override
  String get moreGenderOther => 'Інша';

  @override
  String get moreCsvAge => 'Вік';

  @override
  String moreCsvAgeYears({required String age}) {
    return '$age р.';
  }

  @override
  String get moreCsvHeight => 'Зріст';

  @override
  String get moreCsvCurrentWeight => 'Поточна вага';

  @override
  String get moreCsvTargetWeight => 'Цільова вага';

  @override
  String get moreCsvGoal => 'Ціль';

  @override
  String get moreGoalWeightLoss => 'Схуднення';

  @override
  String get moreGoalWeightGain => 'Набір ваги';

  @override
  String get moreGoalMaintain => 'Підтримка';

  @override
  String get moreGoalMaintainWeight => 'Підтримка ваги';

  @override
  String get moreCsvCalorieGoal => 'Ціль калорій';

  @override
  String get moreCsvProteinG => 'Білки (г)';

  @override
  String get moreCsvFatG => 'Жири (г)';

  @override
  String get moreCsvCarbsG => 'Вуглеводи (г)';

  @override
  String get moreCsvTargetDate => 'Орієнтовна дата досягнення цілі';

  @override
  String get moreCsvSectionDiary => '=== ДАНІ ЩОДЕННИКА ===';

  @override
  String get moreCsvGarminNote =>
      '# Дані активності можуть містити дані з пристроїв Garmin.';

  @override
  String get moreCsvHeaderDiary => 'Тип,Назва,Значення,Дата,Джерело даних';

  @override
  String get moreCsvMeal => 'Страва';

  @override
  String get moreCsvActivity => 'Активність';

  @override
  String get moreCsvWeight => 'Вага';

  @override
  String get morePdfReportTitle => 'Łatwa Forma – Звіт';

  @override
  String morePdfPageFooter({
    required String page,
    required String pages,
    required String date,
  }) {
    return 'Сторінка $page з $pages • Створено $date';
  }

  @override
  String get morePdfProfileSummary => 'Підсумок профілю';

  @override
  String morePdfProfileLine1({
    required String gender,
    required String age,
    required String height,
  }) {
    return 'Стать: $gender • Вік: $age р. • Зріст: $height см';
  }

  @override
  String morePdfProfileLine2({
    required String weight,
    required String target,
    required String calories,
  }) {
    return 'Вага: $weight кг • Ціль: $target кг • Ціль калорій: $calories kcal';
  }

  @override
  String get morePdfGoalWeightLoss => 'Ціль: схуднення';

  @override
  String get morePdfGoalWeightGain => 'Ціль: набір ваги';

  @override
  String get morePdfGoalMaintain => 'Ціль: підтримка ваги';

  @override
  String get morePdfNoProfile => 'Немає профілю';

  @override
  String get morePdfMealsLast30 => 'Останні 30 днів — страви';

  @override
  String get morePdfNoMeals => 'Немає страв';

  @override
  String get morePdfDate => 'Дата';

  @override
  String get morePdfName => 'Назва';

  @override
  String get morePdfActivitiesLast30 => 'Останні 30 днів — активності';

  @override
  String get morePdfNoActivities => 'Немає активностей';

  @override
  String get morePdfGarminAttribution =>
      'Дані активності походять із пристроїв Garmin.';

  @override
  String get morePdfWeightHistory => 'Історія ваги';

  @override
  String get morePdfNoMeasurements => 'Немає вимірів';

  @override
  String get morePdfWeightKg => 'Вага (кг)';

  @override
  String get moreNotificationsTitle => 'Сповіщення';

  @override
  String get moreWaterReminders => 'Нагадування про воду';

  @override
  String get moreMealReminders => 'Нагадування про страви';

  @override
  String get moreAdd => 'Додати';

  @override
  String get moreMealBreakfast => 'Сніданок';

  @override
  String get moreMealLunch => 'Обід';

  @override
  String get moreMealDinner => 'Вечеря';

  @override
  String get moreMealSnack => 'Перекус';

  @override
  String get moreMealDefault => 'Страва';

  @override
  String get moreNewMealReminder => 'Нове нагадування про страву';

  @override
  String get moreMealNameLabel => 'Назва страви';

  @override
  String get moreMealNameHint => 'напр. Другий сніданок, полуденок';

  @override
  String get moreEditReminder => 'Редагувати нагадування';

  @override
  String get moreNotifWaterTitle => 'Не забудь про воду! 💧';

  @override
  String get moreNotifWaterBody => 'Час на склянку води';

  @override
  String get moreNotifWaterChannel => 'Нагадування про воду';

  @override
  String get moreNotifWaterChannelDesc => 'Нагадування пити воду';

  @override
  String moreNotifMealTitle({required String label}) {
    return 'Час на $label! 🍽️';
  }

  @override
  String get moreNotifMealBody => 'Не забудь записати страву';

  @override
  String get moreNotifMealChannel => 'Нагадування про страви';

  @override
  String get moreNotifMealChannelDesc => 'Нагадування записати страви';

  @override
  String get moreIntegrationsTitle => 'Інтеграції';

  @override
  String get moreLoginToFinishStrava =>
      'Увійди, щоб завершити з’єднання зі Strava';

  @override
  String get moreLoginToFinishGarmin =>
      'Увійди, щоб завершити з’єднання з Garmin';

  @override
  String moreStravaConnectedImported({required int count}) {
    return 'Strava з’єднано. Імпортовано активностей: $count.';
  }

  @override
  String get moreStravaConnectedNoNew =>
      'Strava з’єднано. Немає нових активностей для імпорту.';

  @override
  String get moreStravaConnectedSuccess => 'Strava успішно з’єднано';

  @override
  String get moreStravaSyncFailedLater =>
      'Синхронізація не вдалася. Натисни «Синхронізувати активності» пізніше.';

  @override
  String get moreGarminSessionExpiredRetry =>
      'Сесія закінчилася. Спробуй знову з’єднати Garmin.';

  @override
  String moreGarminSessionRejected({required String message}) {
    return 'Сесію відхилено: $message. Вийди, увійди знову і спробуй з’єднати Garmin.';
  }

  @override
  String get moreGarminSessionExpiredRelogin =>
      'Сесія закінчилася. Вийди і знову увійди в Łatwa Forma, потім натисни «З’єднати з Garmin Connect».';

  @override
  String get moreConnectedSuccessfully => 'Успішно з’єднано!';

  @override
  String get moreGarminSessionExpiredShort =>
      'Сесія закінчилася. Вийди і увійди знову, потім з’єднай Garmin.';

  @override
  String moreGarminError({required String error}) {
    return 'Помилка Garmin: $error';
  }

  @override
  String get moreStravaEnvMissing =>
      'Додай STRAVA_CLIENT_ID і STRAVA_CLIENT_SECRET до файлу .env';

  @override
  String get moreGarminEnvMissing =>
      'Додай GARMIN_CLIENT_ID до env (після схвалення програми).';

  @override
  String get moreLoginAgainForGarmin =>
      'Увійди знову, щоб доповнити дані Garmin.';

  @override
  String moreCouldNotComplete({required String message}) {
    return 'Не вдалося: $message';
  }

  @override
  String get moreGarminNoUserId =>
      'Garmin не повернув User ID. Спробуй від’єднати і з’єднати знову.';

  @override
  String get moreGarminReceiveDataSaved =>
      'Дані для отримання активностей збережено. Нові тренування з Garmin Connect з’являтимуться в застосунку.';

  @override
  String moreGarminDisconnectFailed({required String error}) {
    return 'Не вдалося викликати від’єднання в Garmin: $error';
  }

  @override
  String get moreGarminDisconnectedTitle => 'Garmin Connect від’єднано';

  @override
  String get moreGarminDisconnectedBody =>
      'З’єднання з Garmin Connect видалено. Нові активності більше не додаватимуться автоматично. Можна з’єднати знову будь-коли.';

  @override
  String get moreStravaDisconnected => 'Strava від’єднано';

  @override
  String get moreConnectStravaFirst => 'Спочатку з’єднай акаунт Strava';

  @override
  String moreImportedFromStrava({required int count}) {
    return 'Імпортовано активностей зі Strava: $count';
  }

  @override
  String get moreNoNewActivities => 'Немає нових активностей для імпорту';

  @override
  String moreSyncError({required String error}) {
    return 'Помилка синхронізації: $error';
  }

  @override
  String get moreStravaImportDesc =>
      'Імпортуй усі активності та спалені калорії';

  @override
  String get moreConnected => 'З’єднано';

  @override
  String get moreSyncing => 'Синхронізую...';

  @override
  String get moreSyncActivities => 'Синхронізувати активності';

  @override
  String get moreDisconnectStrava => 'Від’єднати Strava';

  @override
  String get moreConnecting => 'З’єдную...';

  @override
  String get moreConnectStrava => 'З’єднати зі Strava';

  @override
  String get moreGarminImportDesc =>
      'Активності з Garmin додаються автоматично після синхронізації з Garmin Connect';

  @override
  String get moreGarminAutoImportInfo =>
      'Усі нові активності з Garmin Connect імпортуються в застосунок. Ти вирішуєш, яку зарахувати в баланс.';

  @override
  String get moreGarminNeedUserId =>
      'Щоб активності з Garmin з’являлися в застосунку, збережи дані з’єднання (ID Garmin).';

  @override
  String get moreSavingShort => 'Зберігаю...';

  @override
  String get moreCompleteActivityReceiveData =>
      'Доповни дані для отримання активностей';

  @override
  String get moreDisconnectGarmin => 'Від’єднати Garmin';

  @override
  String get moreConnectGarmin => 'З’єднати з Garmin Connect';

  @override
  String moreGarminDisconnectErrorStatus({required String status}) {
    return 'Помилка від’єднання: $status';
  }

  @override
  String moreErrorStatusCode({required String code}) {
    return 'Помилка $code';
  }

  @override
  String get moreChallengesTitle => 'Цілі та виклики';

  @override
  String get moreNoChallenges => 'Немає цілей і викликів';

  @override
  String get moreNoChallengesHint =>
      'Додай ціль або виклик, щоб стежити за прогресом';

  @override
  String moreProgressPercent({required String percent}) {
    return 'Прогрес: $percent%';
  }

  @override
  String moreStartDate({required String date}) {
    return 'Початок: $date';
  }

  @override
  String moreEndDate({required String date}) {
    return 'Кінець: $date';
  }

  @override
  String get moreDeleteChallengeTitle => 'Видалити виклик';

  @override
  String moreDeleteChallengeConfirm({required String title}) {
    return 'Точно видалити «$title»?';
  }

  @override
  String get moreChallengeDeleted => 'Виклик видалено';

  @override
  String get morePickStartDate => 'Обери дату початку';

  @override
  String get morePickEndDate => 'Обери дату завершення';

  @override
  String get morePick => 'Обрати';

  @override
  String get moreChallengeAdded => 'Виклик успішно додано!';

  @override
  String get moreTargetWeightKg => 'Ціль ваги (кг)';

  @override
  String get moreCalorieDeficitKcal => 'Дефіцит калорій (kcal)';

  @override
  String get moreWaterAmountMl => 'Кількість води (мл)';

  @override
  String get moreWorkoutCount => 'Кількість тренувань';

  @override
  String get moreStreakLengthDays => 'Довжина серії (дні)';

  @override
  String get moreTargetValue => 'Цільове значення';

  @override
  String get moreAddChallenge => 'Додати виклик';

  @override
  String get moreChallengeType => 'Тип виклику';

  @override
  String get moreCalorieDeficit => 'Дефіцит калорій';

  @override
  String get moreWater => 'Вода';

  @override
  String get moreExercise => 'Вправи';

  @override
  String get moreStreak => 'Серія';

  @override
  String get moreChallengeTitleLabel => 'Назва виклику';

  @override
  String get moreChallengeTitleHint => 'напр. Схуднути на 5 кг';

  @override
  String get moreChallengeTitleRequired => 'Вкажи назву виклику';

  @override
  String get moreDescriptionOptional => 'Опис (необов’язково)';

  @override
  String get moreChallengeDescHint => 'Додаткова інформація про виклик';

  @override
  String get moreOptional => 'Необов’язково';

  @override
  String get moreStartDateLabel => 'Дата початку';

  @override
  String get moreSetEndDate => 'Встановити дату завершення';

  @override
  String get moreEndDateLabel => 'Дата завершення';

  @override
  String get morePickDate => 'Обери дату';

  @override
  String get moreStreaksTitle => 'Серії';

  @override
  String get moreNoStreaks => 'Немає серій';

  @override
  String get moreNoStreaksHint =>
      'Почни відстежувати звички, щоб побачити серії';

  @override
  String moreLastTime({required String date}) {
    return 'Останній раз: $date';
  }

  @override
  String get moreCurrentStreak => 'Поточна серія';

  @override
  String get moreLongestStreak => 'Найдовша серія';

  @override
  String get moreStreakMeals => 'Страви';

  @override
  String get moreStreakActivities => 'Активності';

  @override
  String get moreStreakWeight => 'Вага';

  @override
  String get moreAiAdviceTitle => 'Порада ШІ';

  @override
  String moreAiLimitReachedPremium({required String limit}) {
    return 'Ти використав сьогоднішній ліміт ($limit запитів). Спробуй завтра.';
  }

  @override
  String moreAiLimitReachedFree({required String limit}) {
    return 'Ти використав сьогоднішній ліміт ($limit запитів). Спробуй завтра або перейди на Premium.';
  }

  @override
  String get moreAiNeedsConnection =>
      'Порада ШІ потребує з’єднання із застосунком (Supabase) або ключа OpenAI в конфігурації.';

  @override
  String get moreAiNoResponse =>
      'Не вдалося отримати відповідь. Спробуй знову.';

  @override
  String moreAiRemainingToday({
    required String remaining,
    required String limit,
  }) {
    return 'Залишилось запитів сьогодні: $remaining / $limit';
  }

  @override
  String moreAiRemainingTodayPremium({
    required String remaining,
    required String limit,
  }) {
    return 'Залишилось запитів сьогодні: $remaining / $limit (Premium)';
  }

  @override
  String get moreAiIntro =>
      'Запитай пораду щодо дієти, харчування або фізичної активності. Відповідь генерує ШІ, і вона не замінює консультацію лікаря.';

  @override
  String get moreAiHint =>
      'напр. Скільки білка мені потрібно при силових тренуваннях?';

  @override
  String get moreAiAnswer => 'Відповідь';

  @override
  String get profErrNetwork =>
      'Немає з’єднання з інтернетом. Перевір мережу і спробуй знову.';

  @override
  String get profErrCors =>
      'Помилка з’єднання з послугою. Онови сторінку і спробуй знову.';

  @override
  String get profErrTimeout => 'Перевищено час очікування. Спробуй знову.';

  @override
  String get profErrAuth => 'Помилка авторизації. Увійди знову.';

  @override
  String get profErrNotFound => 'Ресурс не знайдено.';

  @override
  String get profErrServer => 'Помилка сервера. Спробуй пізніше.';

  @override
  String get profErrGeneric => 'Сталася помилка. Спробуй знову.';

  @override
  String get profOfflineBanner => 'Немає з’єднання з інтернетом.';

  @override
  String get premFeatureTitle => 'Функція Premium';

  @override
  String premFeatureDialog({required String feature}) {
    return '$feature доступна в плані Premium. Хочеш дізнатися більше?';
  }

  @override
  String get premFeatureThis => 'Ця функція';

  @override
  String get premSeePremium => 'Переглянути Premium';

  @override
  String premLockedTitle({required String feature}) {
    return '$feature є в Premium';
  }

  @override
  String get premLockedBody =>
      'Відкрий необмежені поради ШІ, експорт PDF і більше.';

  @override
  String get premCheckPremium => 'Перевірити Premium';

  @override
  String get premThanks => 'Дякуємо!';

  @override
  String get premActivatedBody =>
      'Premium активовано.\nКористуйся повним доступом до Łatwa Forma — експорт PDF, поради ШІ, інтеграції та інше.';

  @override
  String get premBackToApp => 'Повернутися до застосунку';

  @override
  String get premCloseTabHint =>
      'Можна також закрити цю вкладку, якщо оплата була в окремому вікні.';

  @override
  String get premPaymentCancelled => 'Оплату скасовано';

  @override
  String get premCancelBody =>
      'Нічого не списано. Можеш повернутися і обрати план, коли будеш готовий.';

  @override
  String get premBackToPlans => 'Повернутися до планів Premium';

  @override
  String get premGoToApp => 'Перейти до застосунку';

  @override
  String get premTitle => 'Łatwa Forma Premium';

  @override
  String get premHavePremium => 'У тебе Premium!';

  @override
  String get premUnlockPotential => 'Відкрий увесь потенціал';

  @override
  String get premAllFeaturesAvailable =>
      'Усі функції Premium для тебе доступні.';

  @override
  String premValidUntil({required String date}) {
    return 'Діє до: $date';
  }

  @override
  String get premTrialTitle => 'Пробний період (24 год)';

  @override
  String premTrialLeft({required int hours, required int minutes}) {
    return 'Залишилось: $hours год $minutes хв. ';
  }

  @override
  String premTrialBody({required String remaining}) {
    return 'Усі функції Premium зараз доступні. $remainingПісля цього функції Premium вимкнуться, доки ти не придбаєш план. Пробний період нічого не списує і не підписує тебе автоматично.';
  }

  @override
  String get premFeatHistoryOtherDays =>
      'Перегляд історії інших днів, не лише сьогодні';

  @override
  String get premFeatMacrosDash => 'Макронутрієнти на головному екрані';

  @override
  String get premFeatAiAdvice => 'Порада ШІ (ліміт 100 на день)';

  @override
  String get premFeatAiPhoto => 'Аналіз ШІ страви зі світлини';

  @override
  String get premFeatIngredients => 'Додавання страви зі складників';

  @override
  String get premFeatEatingOut => 'Додавання страви «у місті»';

  @override
  String get premFeatQuickActivity => 'Швидке додавання в активностях';

  @override
  String get premFeatShare => 'Надсилання підсумку і тижневої статистики';

  @override
  String get premFeatPdf => 'Експорт звітів у PDF';

  @override
  String get premFeatCustomCalories =>
      'Власна ціль калорій у редагуванні профілю';

  @override
  String get premFeatCustomMacros =>
      'Власні макронутрієнти в редагуванні профілю';

  @override
  String get premFeatStrava => 'Інтеграції Strava без лімітів';

  @override
  String get premFeatGoals => 'Розширені цілі та виклики';

  @override
  String get premChoosePlan => 'Обери план';

  @override
  String get premPlanMonthly => 'Łatwa Forma Premium — щомісяця';

  @override
  String get premPlanMonthlyPeriod => '1 місяць, автопоновлення';

  @override
  String get premPlanYearly => 'Łatwa Forma Premium — щороку';

  @override
  String get premPlanYearlyPeriod => '12 місяців, автопоновлення';

  @override
  String get premBadgeSave => 'Економія ~17%';

  @override
  String get premPlanYearlyOnce => 'На рік (одноразово)';

  @override
  String get premPlanYearlyOncePeriod => 'на рік';

  @override
  String get premBadgeBlik => 'Лише BLIK';

  @override
  String get premYearlyOnceSubtitle => 'оплата раз на рік, без підписки';

  @override
  String get premHaveCode => 'Маю код';

  @override
  String get premCodeLabel => 'Код';

  @override
  String get premRedeemTooltip => 'Застосувати';

  @override
  String get premOpeningPayment => 'Відкриваю оплату…';

  @override
  String get premProcessingPurchase => 'Обробляю покупку…';

  @override
  String get premBuy => 'Придбати Premium';

  @override
  String get premRestoring => 'Відновлюю…';

  @override
  String get premRestorePurchases => 'Відновити покупки';

  @override
  String get premPaymentNoteWeb =>
      'На рік (одноразово) — лише BLIK. Підписка — картка, Apple Pay, Google Pay. Підписка поновлюється автоматично, доки ти її не скасуєш.';

  @override
  String get premPaymentNoteMobile =>
      'Оплата через App Store / Google Play. «Łatwa Forma Premium — щомісяця» (1 місяць) і «Łatwa Forma Premium — щороку» (12 місяців) поновлюються автоматично за ціною, показаною вище, доки ти не скасуєш у налаштуваннях магазину. BLIK є на latwaforma.pl. Базові функції працюють без підписки.';

  @override
  String get premAutoActivate =>
      'Після оплати акаунт Premium активується автоматично.';

  @override
  String get premPrivacy => 'Політика конфіденційності';

  @override
  String get premTerms => 'Умови';

  @override
  String get premEula => 'Terms of Use (EULA)';

  @override
  String get premActivating => 'Активую…';

  @override
  String get premActivateTest => 'Активувати Premium (тест)';

  @override
  String get premAvailableFeatures => 'Доступні функції:';

  @override
  String get premFeatActiveHistory => 'Історія інших днів';

  @override
  String get premFeatActiveMacros => 'Макро на головному екрані';

  @override
  String get premFeatActiveAiPhoto => 'Аналіз ШІ страви';

  @override
  String get premFeatActiveIngredients => 'Страва зі складників';

  @override
  String get premFeatActiveEatingOut => 'Страва «у місті»';

  @override
  String get premFeatActiveQuickActivity => 'Швидке додавання активності';

  @override
  String get premFeatActiveShare => 'Надсилання підсумку і статистики';

  @override
  String get premFeatActivePdf => 'Експорт у PDF';

  @override
  String get premFeatActiveCalories => 'Власна ціль калорій';

  @override
  String get premFeatActiveMacrosCustom => 'Власні макронутрієнти';

  @override
  String get premFeatActiveStrava => 'Інтеграції Strava';

  @override
  String get premFeatActiveGoals => 'Розширені цілі';

  @override
  String get premOpening => 'Відкриваю…';

  @override
  String get premCancelSub => 'Скасувати підписку';

  @override
  String get premManageSub => 'Керувати підпискою';

  @override
  String get premCancelNoteWeb =>
      'Підписку можна скасувати. Доступ до Premium лишиться до кінця оплаченого періоду.';

  @override
  String get premCancelNoteMobile =>
      'Скасування в налаштуваннях App Store / Google Play. Доступ Premium до кінця оплаченого періоду.';

  @override
  String get premEnterEmail => 'Вкажи адресу ел. пошти.';

  @override
  String get premCodeSent => 'Код надіслано';

  @override
  String premCodeSentBody({required String email}) {
    return 'Ми надіслали посилання і код на $email. Перевір пошту (також папку Спам) — натисни посилання в листі або введи код нижче.';
  }

  @override
  String get premSignedIn => 'Вхід виконано';

  @override
  String get premSignedInBuy => 'Тепер можна придбати Premium.';

  @override
  String get premAccountExistsTitle =>
      'Акаунт із цією адресою ел. пошти вже існує.';

  @override
  String get premAccountExistsBody =>
      'Ти намагаєшся увійти в акаунт, пов’язаний із цією адресою. На цьому пристрої є інші дані (профіль, страви тощо).\n\nЩо хочеш зробити?\n\n• Оновити той акаунт — поточними даними з цього пристрою (профіль і страви буде перенесено).\n\n• Відновити дані акаунта — побачиш дані, прив’язані до акаунта з цією поштою (поточні дані пристрою не буде використано).\n\nВ обох випадках треба підтвердити особу — натисни посилання в листі або введи код підтвердження.';

  @override
  String get premRestoreAccountData => 'Відновити дані акаунта';

  @override
  String get premUpdateWithCurrent => 'Оновити акаунт цими даними';

  @override
  String get premConfirmIdentity => 'Підтвердь особу';

  @override
  String premVerifyEmailSent({required String email}) {
    return 'Ми надіслали лист на $email. Можна натиснути посилання підтвердження в листі або ввести код нижче (перевір також папку Спам).';
  }

  @override
  String get premVerificationCode => 'Код підтвердження';

  @override
  String get premCodeHint => 'напр. 123456';

  @override
  String get premEnterFullCode =>
      'Введи повний код із листа (мін. 6 символів).';

  @override
  String premLoggedInMergeError({required String error}) {
    return 'Вхід виконано. Помилка перенесення даних: $error';
  }

  @override
  String get premVerifyErrorTitle => 'Помилка підтвердження';

  @override
  String get premVerifyErrorBody =>
      'Код закінчився або неправильний. Надішли знову.';

  @override
  String get premConfirm => 'Підтвердити';

  @override
  String get premConnErrorTitle => 'Помилка з’єднання';

  @override
  String get premConnErrorBody =>
      'Не вдалося з’єднатися з оплатою. Спробуй за хвилину або напиши нам: contact@latwaforma.pl';

  @override
  String get premLoginToBuy =>
      'Щоб придбати Premium, увійди (Apple, Google або ел. пошта з кодом вище).';

  @override
  String get premCodeNotForOnce => 'Цей код не працює для одноразової оплати.';

  @override
  String get premTryLaterContact =>
      'Спробуй знову за хвилину або напиши нам: contact@latwaforma.pl';

  @override
  String get premOpenPaymentFailed => 'Не вдалося відкрити оплату';

  @override
  String get premCannotOpenPaymentPage => 'Не можна відкрити сторінку оплати.';

  @override
  String get premCheckoutSessionError => 'Помилка створення сесії оплати.';

  @override
  String get premTryLaterContactShort =>
      'Спробуй за хвилину або напиши нам: contact@latwaforma.pl';

  @override
  String get premLoginToUseCode =>
      'Щоб використати код, увійди (Apple, Google або ел. пошта).';

  @override
  String get premCodeSheetFailed =>
      'Не вдалося відкрити введення коду. Спробуй знову.';

  @override
  String get premEnterCode => 'Введи код.';

  @override
  String get premPlayStoreFailed => 'Не вдалося відкрити Play Store.';

  @override
  String get premLoginToBuyMobile =>
      'Щоб придбати Premium, увійди (Google, Apple або ел. пошта з кодом вище).';

  @override
  String get premThanksActive =>
      'Дякуємо! Premium уже має бути активним. Якщо функції ще заблоковані, зачекай хвилину або повернися до застосунку.';

  @override
  String get premPurchasePending =>
      'Покупку завершено. Статус Premium оновиться за хвилину. Якщо ні — скористайся «Відновити покупки».';

  @override
  String get premInfo => 'Інформація';

  @override
  String get premPurchaseErrorTitle => 'Помилка покупки';

  @override
  String premPurchaseErrorBody({required String error}) {
    return 'Не вдалося завершити покупку. Перевір з’єднання і налаштування магазину або напиши: contact@latwaforma.pl\n\n$error';
  }

  @override
  String get premLoginToRestore => 'Увійди, щоб відновити покупки.';

  @override
  String get premRestoredTitle => 'Покупки відновлено';

  @override
  String get premNoPurchasesTitle => 'Немає активних покупок';

  @override
  String get premRestoredBody =>
      'Твій Premium відновлено. Якщо розблокування не видно, зачекай хвилину.';

  @override
  String get premNoPurchasesBody =>
      'Не знайдено активної підписки, пов’язаної з цим акаунтом магазину.';

  @override
  String premRestoreFailed({required String error}) {
    return 'Не вдалося відновити покупки: $error';
  }

  @override
  String get premSubscription => 'Підписка';

  @override
  String get premManageHint =>
      'Відкрий налаштування підписки в магазині Apple / Google, щоб скасувати Premium або керувати ним.';

  @override
  String get premSessionExpired => 'Сесія закінчилася';

  @override
  String get premLoginAgain => 'Увійди знову.';

  @override
  String get premPortalHintWeb =>
      'Онови сторінку (F5) і спробуй знову. Якщо проблема повторюється, вийди і увійди знову.';

  @override
  String get premPortalHintMobile =>
      'Вийди в профілі і увійди знову, потім ще раз спробуй «Скасувати підписку».';

  @override
  String get premCannotOpenPortal => 'Не можна відкрити портал.';

  @override
  String get premPortalOpenError => 'Помилка відкриття порталу.';

  @override
  String get premSessionExpiredCancel =>
      'Сесія закінчилася. Вийди в профілі і увійди знову, потім ще раз спробуй «Скасувати підписку».';

  @override
  String premErrorWithDetail({required String error}) {
    return 'Помилка: $error';
  }

  @override
  String get premActivatedEnjoy =>
      'Premium активовано. Користуйся повним доступом!';

  @override
  String get premLoginToBuyCard =>
      'Щоб придбати Premium, потрібен акаунт. Увійди через Google, Apple або вкажи адресу ел. пошти — надішлемо лист із посиланням підтвердження і кодом.';

  @override
  String get premSigningIn => 'Вхід…';

  @override
  String get premContinueGoogle => 'Продовжити з Google';

  @override
  String get premContinueApple => 'Продовжити з Apple';

  @override
  String get premOrEmail => 'або ел. пошта:';

  @override
  String get premEmailLabel => 'Адреса ел. пошти';

  @override
  String get premEmailHint => 'напр. jan@example.com';

  @override
  String get premSending => 'Надсилаю…';

  @override
  String get premSendCode => 'Надіслати код';

  @override
  String get premConfirmIdentityHint =>
      'Підтвердь особу: введи нижче код із листа або натисни посилання підтвердження в повідомленні (перевір також папку Спам).';

  @override
  String get premChecking => 'Перевіряю…';

  @override
  String get premConfirmAndSignIn => 'Підтвердити і увійти';

  @override
  String get premResendOtherEmail => 'Надіслати код знову на іншу адресу';

  @override
  String get profTitle => 'Профіль';

  @override
  String get profNotifications => 'Сповіщення';

  @override
  String get profNoProfile => 'Немає профілю';

  @override
  String profErrorWithDetail({required String error}) {
    return 'Помилка: $error';
  }

  @override
  String get profAccountGoogle => 'Акаунт Google';

  @override
  String get profAccountEmail => 'Акаунт ел. пошти';

  @override
  String get profAccountSignedIn => 'Акаунт, у який увійшли';

  @override
  String get profSignOutTitle => 'Вийти';

  @override
  String get profSignOutBody => 'Точно вийти? Потім можна увійти знову.';

  @override
  String get profSignOutConfirm => 'Вийти';

  @override
  String get profDeleteAccountTitle => 'Видалити акаунт';

  @override
  String get profDeleteAccountBody =>
      'Твої дані буде повністю видалено, і їх не можна буде відновити. Коли повернешся до застосунку, профіль доведеться заповнити знову.\n\nЯкщо маєш підписку Premium у Google Play або App Store, скасуй її окремо в магазині — видалення акаунта її не завершує.\n\nТочно видалити акаунт?';

  @override
  String get profAccountDeleted => 'Акаунт видалено';

  @override
  String profDeleteUnavailable({required String email}) {
    return 'Послуга видалення акаунта недоступна. Напиши нам: $email';
  }

  @override
  String get profSessionExpiredRetry =>
      'Сесія закінчилася. Увійди знову і спробуй ще раз.';

  @override
  String get profNoPermission => 'Немає дозволу виконати цю дію.';

  @override
  String get profDeleteFailed => 'Не вдалося видалити акаунт. Спробуй пізніше.';

  @override
  String get profInviteTitle => 'Запроси друга';

  @override
  String get profInviteBody =>
      'Вкажи адресу ел. пошти людини, якій хочеш надіслати запрошення до Łatwa Forma.';

  @override
  String get profEmailLabel => 'Адреса ел. пошти';

  @override
  String get profEmailHintFriend => 'напр. znajomy@example.com';

  @override
  String get profSessionExpiredWebInvite =>
      'Сесія закінчилася. Онови сторінку (F5) і увійди знову, потім надішли запрошення.';

  @override
  String get profLoginAgainRetry => 'Увійди знову і спробуй ще раз.';

  @override
  String get profInviteSent => 'Запрошення надіслано';

  @override
  String get profSessionExpiredWebRetry =>
      'Сесія закінчилася. Онови сторінку (F5) і спробуй знову. Якщо проблема повторюється, вийди і увійди знову.';

  @override
  String get profSessionExpiredInviteMobile =>
      'Сесія закінчилася. Вийди і увійди знову, потім надішли запрошення.';

  @override
  String get profInviteAlreadySent =>
      'На цю адресу вже надіслано запрошення. Перевір пошту (включно зі спамом) або вкажи іншу адресу.';

  @override
  String get profEmailAlreadyRegistered =>
      'Цю адресу ел. пошти вже зареєстровано в Łatwa Forma. Запроси когось іншого.';

  @override
  String get profInviteRateLimit =>
      'Забагато запрошень. Зачекай хвилину і спробуй знову.';

  @override
  String get profEnterValidEmail => 'Вкажи правильну адресу ел. пошти.';

  @override
  String get profInviteSendFailed =>
      'Не вдалося надіслати запрошення. Спробуй знову.';

  @override
  String get profSessionExpiredWebShort =>
      'Сесія закінчилася. Онови сторінку (F5) і спробуй знову.';

  @override
  String get profSessionExpiredSignOutIn =>
      'Сесія закінчилася. Вийди і увійди знову.';

  @override
  String get profSendInvite => 'Надіслати запрошення';

  @override
  String get profInviteSentExclaim => 'Запрошення надіслано!';

  @override
  String get profSaveProgress => 'Збережи прогрес';

  @override
  String get profSaveProgressHint =>
      'Увійди через Apple, Google або ел. пошту, щоб не втратити дані';

  @override
  String get profBasicData => 'Основні дані';

  @override
  String get profGender => 'Стать';

  @override
  String get profAge => 'Вік';

  @override
  String profAgeYears({required int age}) {
    return '$age р.';
  }

  @override
  String get profHeight => 'Зріст';

  @override
  String get profCurrentWeight => 'Поточна вага';

  @override
  String get profTargetWeight => 'Цільова вага';

  @override
  String get profActivityLevel => 'Рівень активності';

  @override
  String get profGoal => 'Ціль';

  @override
  String get profCalculations => 'Розрахунки';

  @override
  String get profBmrExplain =>
      'Потреба в калоріях у спокої — скільки калорій ти спалюєш без активності.';

  @override
  String get profTdeeExplain =>
      'Повна денна потреба — скільки калорій ти спалюєш за день з урахуванням активності.';

  @override
  String get profCalorieGoalExplain =>
      'Рекомендоване денне споживання калорій для досягнення цілі ваги.';

  @override
  String get profWaterGoal => 'Ціль пиття води';

  @override
  String profWaterGoalExplanation({
    required int mlPerKg,
    required String weightKg,
    required int rawMl,
    required int goalMl,
  }) {
    return 'Розраховано з твоєї ваги: $mlPerKg мл на кожен кг ($weightKg кг → бл. $rawMl мл, округлено до $goalMl мл). Ціль можна змінити вручну.';
  }

  @override
  String get profMacros => 'Макро';

  @override
  String get profProtein => 'Білки';

  @override
  String get profFat => 'Жири';

  @override
  String get profCarbs => 'Вуглеводи';

  @override
  String get profCarbsShort => 'Вугл.';

  @override
  String get profTargetDateTitle => 'Дата досягнення цілі:';

  @override
  String get profTargetDateHint => 'Дій за планом, і цей день не зрушиться.';

  @override
  String get profSpeedUpHint =>
      'Хочеш пришвидшити ціль? Зміни темп зміни ваги в режимі редагування профілю (іконка олівця вгорі).';

  @override
  String get profMaintainNoDateTitle => 'Ціль: підтримка ваги';

  @override
  String get profMaintainNoDateBody =>
      'При підтримці ваги немає окремої дати «досягнення». Зміни ціль на схуднення або набір (і цільову вагу) — тоді підкажу, коли приблизно її досягнеш.';

  @override
  String get profMaintainNoDateCta => 'Змінити ціль у профілі';

  @override
  String get profAiAdvice => 'Порада ШІ';

  @override
  String get profAiAdviceHint => 'Запитай про дієту, харчування й активність';

  @override
  String get profBmiTitle => 'Калькулятор BMI';

  @override
  String get profBmiHint => 'Перевір свій індекс маси тіла';

  @override
  String profTrialLeft({required int hours, required int minutes}) {
    return 'Залишилось: $hours год $minutes хв';
  }

  @override
  String get profPremiumTitleActive => 'Łatwa Forma Premium';

  @override
  String get profPremiumTitle => 'Підписка Premium';

  @override
  String get profActive => 'Активна';

  @override
  String get profPremiumHintActive => 'Необмежений ШІ, експорт PDF, інтеграції';

  @override
  String get profPremiumHint => 'Відкрий увесь потенціал — ШІ, PDF, інтеграції';

  @override
  String get profIntegrations => 'Інтеграції';

  @override
  String get profIntegrationsHint =>
      'Strava — імпортуй активності та спалені калорії';

  @override
  String get profExport => 'Експорт даних';

  @override
  String get profExportHint => 'Експортуй свої дані в CSV';

  @override
  String get profInviteHint =>
      'Надішли запрошення ел. поштою до застосунку Łatwa Forma';

  @override
  String get profPrivacy => 'Політика конфіденційності';

  @override
  String get profTerms => 'Умови';

  @override
  String get profEula => 'Terms of Use (EULA)';

  @override
  String get profDeleteAccountPage => 'Видалити акаунт (сторінка)';

  @override
  String get profYourAccount => 'Твій акаунт';

  @override
  String get profDeviceData => 'Дані на цьому пристрої';

  @override
  String get profDeviceDataHint =>
      'Ти користуєшся без акаунта. Можна видалити збережений профіль і страви з цього пристрою.';

  @override
  String get profDeleteData => 'Видалити дані';

  @override
  String get profDeleteDataBody =>
      'Профіль, страви та інші дані на цьому пристрої буде остаточно видалено. Відновити їх неможливо.\n\nТочно хочеш видалити дані?';

  @override
  String get profDataDeleted => 'Дані з пристрою видалено.';

  @override
  String get profGenderMale => 'Чоловік';

  @override
  String get profGenderFemale => 'Жінка';

  @override
  String get profGenderOther => 'Інша';

  @override
  String get profActSedentary => 'Сидячий';

  @override
  String get profActLight => 'Легка';

  @override
  String get profActModerate => 'Помірна';

  @override
  String get profActIntense => 'Інтенсивна';

  @override
  String get profActVeryIntense => 'Дуже інтенсивна';

  @override
  String get profGoalLoss => 'Схуднення';

  @override
  String get profGoalGain => 'Набір ваги';

  @override
  String get profGoalMaintain => 'Підтримка ваги';

  @override
  String get profGenderRequired => 'Стать *';

  @override
  String get profAgeRequired => 'Вік *';

  @override
  String get profYearsSuffix => 'р.';

  @override
  String get profHeightRequired => 'Зріст (см) *';

  @override
  String get profCurrentWeightRequired => 'Поточна вага (кг) *';

  @override
  String get profTargetWeightRequired => 'Цільова вага (кг) *';

  @override
  String get profWeightDiffError =>
      'Різниця між вагами має бути щонайменше 1 кг';

  @override
  String get profActivityRequired => 'Рівень активності *';

  @override
  String get profActSedentaryDesc => 'Немає активності або мінімальна';

  @override
  String get profActLightDesc => '1–3 тренування / тиждень';

  @override
  String get profActModerateDesc => '3–5 тренувань / тиждень';

  @override
  String get profActIntenseDesc => '6–7 тренувань / тиждень';

  @override
  String get profActVeryIntenseDesc => '2 рази на день / важка робота';

  @override
  String get profWaterGoalMl => 'Ціль води (мл)';

  @override
  String get profWaterGoalHelper =>
      'Можна змінити вручну. Нижче пояснення, звідки береться пропозиція.';

  @override
  String get profSaveChanges => 'Зберегти зміни';

  @override
  String get profWantLose => 'Хочу схуднути.';

  @override
  String get profWantGain => 'Хочу набрати вагу.';

  @override
  String get profWantMaintain => 'Хочу зберегти поточну вагу.';

  @override
  String get profAdjustPlan => 'Налаштувати план';

  @override
  String get profPlanPremiumOnly =>
      'Власна ціль калорій і макронутрієнти доступні в Premium.';

  @override
  String get profSeePremium => 'Переглянути Premium';

  @override
  String get profWeightRate => 'Темп зміни ваги';

  @override
  String profRateKgWeek({required String rate}) {
    return '$rate кг/тиж.';
  }

  @override
  String get profRateZero => '0 кг/тиж.';

  @override
  String get profMaintainRateZero => 'Для підтримки ваги темп = 0';

  @override
  String get profRecommendedRate =>
      'Рекомендований темп: 0,5 кг/тиж. — безпечно і здорово. Швидше схуднення може бути шкідливим (втрата м’язів, дефіцити, втома).';

  @override
  String profEstTargetDate({required String date}) {
    return 'Орієнтовна дата досягнення цілі: $date';
  }

  @override
  String get profMoveSlider => 'Посунь повзунок, щоб побачити план';

  @override
  String get profCustomCalorieGoal => 'Власна ціль калорій';

  @override
  String get profGoalKcal => 'Ціль (kcal)';

  @override
  String get profLeaveEmptyFromRate =>
      'Залиш порожнім, щоб порахувати з темпу.';

  @override
  String get profCustomMacros => 'Власні макронутрієнти';

  @override
  String get profMacrosAutoRecalc =>
      'Калорії і дата перерахуються автоматично.';

  @override
  String profMacroSum({required String kcal}) {
    return 'Сума: $kcal kcal';
  }

  @override
  String profMacroPerGram({required int kcal}) {
    return '1 г = $kcal kcal';
  }

  @override
  String get profValuesNotNegative => 'Значення не можуть бути від’ємними.';

  @override
  String profMacroMaxProtein({required String g}) {
    return 'білки макс. $g г';
  }

  @override
  String profMacroMaxFat({required String g}) {
    return 'жири макс. $g г';
  }

  @override
  String profMacroMaxCarbs({required String g}) {
    return 'вуглеводи макс. $g г';
  }

  @override
  String profMacroOverLimit({required String parts}) {
    return '⚠️ Значення перевищують рекомендовані денні ліміти: $parts. Введи реалістичні значення для здорового харчування.';
  }

  @override
  String profMacroCaloriesUnreal({
    required String calories,
    required String max,
  }) {
    return '⚠️ Загальна кількість калорій ($calories kcal) нереалістична для денної потреби. Рекомендований максимум — бл. $max kcal/день.';
  }

  @override
  String profMacroLossSurplus({required String surplus, required String tdee}) {
    return 'Твоя ціль — схуднення (цільова вага нижча за поточну), але введені макронутрієнти дають $surplus kcal понад потребу (TDEE: $tdee kcal). Зменш калорії/макронутрієнти, щоб отримати дефіцит.';
  }

  @override
  String profMacroGainDeficit({required String tdee}) {
    return 'Твоя ціль — набір ваги (цільова вага вища за поточну), але введені макронутрієнти дають дефіцит (TDEE: $tdee kcal). Збільш калорії/макронутрієнти, щоб отримати надлишок.';
  }

  @override
  String profWarnCalAboveTdeeLoss({required String tdee}) {
    return '⚠️ Ціль калорій вища за TDEE ($tdee kcal). Щоб худнути, потрібен дефіцит калорій. Максимальний безпечний дефіцит — ~1100 kcal/день (бл. 1 кг/тиждень).';
  }

  @override
  String profWarnDeficitHuge({required String deficit}) {
    return '⚠️ Дефіцит калорій дуже великий ($deficit kcal/день). Рекомендований максимальний дефіцит — 1000–1500 kcal/день для безпечного схуднення.';
  }

  @override
  String get profWarnDeficitTiny =>
      '⚠️ Дефіцит калорій дуже малий. Для ефективного схуднення рекомендовано дефіцит 500–1000 kcal/день.';

  @override
  String profWarnCalBelowTdeeGain({required String tdee}) {
    return '⚠️ Ціль калорій нижча за TDEE ($tdee kcal). Щоб набирати вагу, потрібен надлишок калорій. Рекомендований надлишок — 250–500 kcal/день (бл. 0,25–0,5 кг/тиждень).';
  }

  @override
  String profWarnSurplusHuge({required String surplus}) {
    return '⚠️ Надлишок калорій дуже великий ($surplus kcal/день). Рекомендований надлишок — 250–500 kcal/день для здорового набору ваги.';
  }

  @override
  String get profWarnSurplusTiny =>
      '⚠️ Надлишок калорій дуже малий. Для ефективного набору ваги рекомендовано надлишок 250–500 kcal/день.';

  @override
  String profWarnMaintainFar({required String tdee}) {
    return '⚠️ Ціль калорій сильно відрізняється від TDEE ($tdee kcal). Для підтримки ваги ціль має бути близькою до TDEE (±100–200 kcal).';
  }

  @override
  String profCannotSaveLoss({required String calories, required String tdee}) {
    return 'Не можна зберегти: ціль калорій ($calories kcal) вища за TDEE ($tdee kcal). Щоб худнути, потрібен дефіцит калорій.';
  }

  @override
  String profCannotSaveGain({required String calories, required String tdee}) {
    return 'Не можна зберегти: ціль калорій ($calories kcal) нижча за TDEE ($tdee kcal). Щоб набирати вагу, потрібен надлишок калорій.';
  }

  @override
  String get profUserNotLoggedIn => 'Користувач не увійшов';

  @override
  String get profGoalHistoryEdit => 'Редагування профілю';

  @override
  String get profUpdatedSuccess =>
      'Профіль успішно оновлено! Ціль перераховано.';

  @override
  String profSaveError({required String error}) {
    return 'Помилка під час збереження: $error';
  }

  @override
  String get profCalorieGoal => 'Ціль калорій';

  @override
  String get trackPremium => 'Premium';

  @override
  String get trackStatistics => 'Статистика';

  @override
  String get trackGoalsAndChallenges => 'Цілі та виклики';

  @override
  String get trackProfile => 'Профіль';

  @override
  String get trackSessionExpired => 'Сесія закінчилася. Увійди знову.';

  @override
  String get trackLoadDataFailed =>
      'Не вдалося завантажити дані. Перевір інтернет і натисни «Спробувати знову».';

  @override
  String trackErrorWithDetails({required String error}) {
    return 'Помилка: $error';
  }

  @override
  String get trackSignIn => 'Увійти';

  @override
  String get trackFeatureEatingOut => 'Страва «у місті»';

  @override
  String trackShareCaloriesText({required String date}) {
    return '📊 Łatwa Forma – Калорії $date';
  }

  @override
  String trackShareError({required String error}) {
    return 'Помилка надсилання: $error';
  }

  @override
  String get trackCaloriesOverview => 'Огляд калорій';

  @override
  String get trackSelectDate => 'Обери дату';

  @override
  String get trackShare => 'Поділитися';

  @override
  String get trackFeatureShareSummary => 'Надсилання підсумку';

  @override
  String get trackEarlierWeek => 'Попередній тиждень';

  @override
  String get trackFeatureBrowseHistory => 'Перегляд історії інших днів';

  @override
  String get trackLaterWeek => 'Наступний тиждень';

  @override
  String trackShowingDataFrom({required String date}) {
    return 'Показано дані з $date';
  }

  @override
  String get trackConsumed => 'Спожито';

  @override
  String get trackTodayTarget => 'Ціль на сьогодні';

  @override
  String trackSurplusKcal({required String kcal}) {
    return 'Надлишок: $kcal kcal';
  }

  @override
  String get trackProtein => 'Білки';

  @override
  String get trackFat => 'Жири';

  @override
  String get trackCarbs => 'Вуглеводи';

  @override
  String get trackCarbsShort => 'Вугл.';

  @override
  String get trackIncludingSaturated => 'з них насичені';

  @override
  String get trackIncludingSugars => 'з них цукри';

  @override
  String get trackFiber => 'клітковина';

  @override
  String get trackFiberLabel => 'Клітковина';

  @override
  String get trackSalt => 'Сіль';

  @override
  String get trackFeatureAiMealAnalysis => 'Аналіз ШІ страви';

  @override
  String get trackAiPhotoAnalysisTooltip => 'Аналіз ШІ зі світлини';

  @override
  String get trackNoResults => 'Немає результатів';

  @override
  String get trackWater => 'Вода';

  @override
  String get trackWaterMotivation => 'Вода потрібна щодня! 💧';

  @override
  String get trackActivitiesToday => 'Активності сьогодні';

  @override
  String trackActivitiesOnDate({required String date}) {
    return 'Активності — $date';
  }

  @override
  String get trackNoActivities => 'Немає активностей';

  @override
  String trackAndMoreCount({required String count}) {
    return '... і ще $count';
  }

  @override
  String get trackMealsToday => 'Страви сьогодні';

  @override
  String trackMealsOnDate({required String date}) {
    return 'Страви — $date';
  }

  @override
  String get trackNoMeals => 'Немає страв';

  @override
  String get trackDayMon => 'Пн';

  @override
  String get trackDayTue => 'Вт';

  @override
  String get trackDayWed => 'Ср';

  @override
  String get trackDayThu => 'Чт';

  @override
  String get trackDayFri => 'Пт';

  @override
  String get trackDaySat => 'Сб';

  @override
  String get trackDaySun => 'Нд';

  @override
  String get trackAdd => 'Додати';

  @override
  String get trackMeal => 'Страва';

  @override
  String get trackEatingOut => 'Їжа в місті';

  @override
  String get trackActivity => 'Активність';

  @override
  String get trackWeight => 'Вага';

  @override
  String get trackMeasurements => 'Виміри';

  @override
  String get trackFavorites => 'Обране';

  @override
  String get trackUserNotLoggedIn => 'Користувач не увійшов';

  @override
  String get trackMealSavedAndFavorited =>
      'Страву збережено і додано до обраного!';

  @override
  String get trackMealAddedSuccess => 'Страву успішно додано!';

  @override
  String get trackFeatureIngredientsMeal => 'Страва зі складників';

  @override
  String get trackOptionEatingOut => 'У місті';

  @override
  String get trackOptionAiAnalysis => 'Аналіз ШІ';

  @override
  String get trackOptionIngredients => 'Складники';

  @override
  String get trackOptionBarcode => 'Штрихкод';

  @override
  String get trackOptionSearchProduct => 'Знайти продукт';

  @override
  String get trackOptionFavorites => 'Обране';

  @override
  String get trackEditMeal => 'Редагувати страву';

  @override
  String get trackAddMeal => 'Додати страву';

  @override
  String get trackMealNameOptional => 'Назва страви (необов’язково)';

  @override
  String get trackHintEmptyDefaultName => 'Порожньо = «Без назви»';

  @override
  String get trackDefaultMealName => 'Без назви';

  @override
  String get trackHintCaloriesFromMacros =>
      'Порожньо = порахує з макронутрієнтів';

  @override
  String get trackEnterCaloriesOrMacros =>
      'Вкажи калорії або заповни макронутрієнти';

  @override
  String get trackProteinG => 'Білки (г)';

  @override
  String get trackFatG => 'Жири (г)';

  @override
  String get trackCarbsG => 'Вуглеводи (г)';

  @override
  String get trackFiberG => 'Клітковина (г)';

  @override
  String get trackSaltG => 'Сіль (г)';

  @override
  String get trackMealTypeOptional => 'Тип страви — необов’язково';

  @override
  String get trackBreakfast => 'Сніданок';

  @override
  String get trackLunch => 'Обід';

  @override
  String get trackDinner => 'Вечеря';

  @override
  String get trackSnack => 'Перекус';

  @override
  String get trackAddToFavorites => 'Додати до обраного';

  @override
  String get trackAddToFavoritesMealSubtitle =>
      'Потім можна швидко додати цю страву';

  @override
  String get trackUpdateMeal => 'Оновити страву';

  @override
  String get trackSaveMeal => 'Зберегти страву';

  @override
  String get trackCalories => 'Калорії';

  @override
  String get trackCameraUnavailableTitle => 'Камера недоступна';

  @override
  String get trackCameraUnavailableBody =>
      'Камера недоступна на цьому пристрої (наприклад, на симуляторі).\n\nСкористайся кнопкою «З галереї», щоб вибрати світлину.';

  @override
  String get trackFromGallery => 'З галереї';

  @override
  String trackPickImageError({required String error}) {
    return 'Помилка вибору світлини: $error';
  }

  @override
  String get trackAnalysisFailedOpenAi =>
      'Не вдалося проаналізувати світлину. Перевір, чи встановлено ключ OpenAI API.';

  @override
  String trackAnalysisError({required String error}) {
    return 'Помилка аналізу: $error';
  }

  @override
  String get trackAiPhotoTitle => 'Аналіз світлини ШІ';

  @override
  String get trackTakeMealPhoto => 'Зроби світлину страви';

  @override
  String get trackAiPhotoDescription =>
      'ШІ проаналізує світлину й оцінить поживну цінність. Світлину надсилають постачальнику ШІ (OpenAI) лише для цього — ми не зберігаємо галерею світлин. Оцінки орієнтовні і не є медичною порадою.';

  @override
  String get trackSimulatorCameraHint =>
      'На симуляторі камера не працює — вибери світлину з галереї.';

  @override
  String get trackTakePhoto => 'Зробити світлину';

  @override
  String get trackAnalyzingPhoto => 'Аналізуємо світлину...';

  @override
  String get trackMayTakeAMoment => 'Це може трохи тривати';

  @override
  String trackProductNotFound({required String code}) {
    return 'Продукт із кодом $code не знайдено в базі продуктів.';
  }

  @override
  String trackFetchProductFailed({required String error}) {
    return 'Не вдалося отримати дані продукту: $error';
  }

  @override
  String get trackBarcodeScannerTitle => 'Сканер штрихкодів';

  @override
  String get trackSimulatorEnterCode => 'На симуляторі введи код вручну';

  @override
  String get trackEnterProductCode => 'Введи код продукту';

  @override
  String get trackSearchProduct => 'Шукати продукт';

  @override
  String get trackScannerUnavailable =>
      'Сканер недоступний — скористайся симулятором або фізичним пристроєм';

  @override
  String get trackPointAtBarcode => 'Наведи на штрихкод продукту';

  @override
  String get trackBarcodePrivacy =>
      'Дані буде отримано з бази продуктів. Камера служить лише для зчитування коду — світлину ми не зберігаємо і не надсилаємо.';

  @override
  String get trackScanBarcode => 'Сканувати штрихкод';

  @override
  String get trackAddProduct => 'Додати продукт';

  @override
  String get trackEnterProductWeight => 'Вкажи вагу продукту';

  @override
  String get trackNutritionPer100g => 'Поживна цінність (на 100 г):';

  @override
  String get trackWeightHintExample => 'напр. 75.5';

  @override
  String get trackWeightHelper => 'Скільки грамів продукту ти їси?';

  @override
  String get trackEditBeforeSave => 'Редагувати перед збереженням';

  @override
  String trackPer100g({required String label}) {
    return '$label/100 г';
  }

  @override
  String get trackWeightG => 'Вага (г)';

  @override
  String get trackSearchProductTitle => 'Знайти продукт';

  @override
  String get trackSearchProductHint => 'Назва продукту, напр. молоко, nutella…';

  @override
  String get trackEnterProductName => 'Введи назву продукту';

  @override
  String get trackSearchProductSubtitle =>
      'Користуємося базою Open Food Facts. Результати з’являться після кількох літер.';

  @override
  String get trackNoResultsTryBarcode =>
      'Спробуй іншу назву або відскануй штрихкод продукту.';

  @override
  String get trackBackToDashboard => 'Повернутися на головний екран';

  @override
  String trackMealsDateTitle({required String date}) {
    return 'Страви — $date';
  }

  @override
  String get trackFavoriteMealsTooltip => 'Обрані страви';

  @override
  String get trackNoMealsForDay => 'Немає страв за цей день';

  @override
  String get trackUsePlusToAddMeal => 'Натисни +, щоб додати страву';

  @override
  String get trackDeleteMealTitle => 'Видалити страву';

  @override
  String trackDeleteMealConfirm({required String name}) {
    return 'Точно видалити «$name»?';
  }

  @override
  String get trackMealDeleted => 'Страву видалено';

  @override
  String get trackAddAtLeastOneIngredient => 'Додай щонайменше один складник';

  @override
  String get trackMealFromIngredientsTitle => 'Страва зі складників';

  @override
  String trackTotalWeightG({required String weight}) {
    return 'Загальна вага: $weight г';
  }

  @override
  String trackIngredientsCount({required String count}) {
    return 'Складники ($count)';
  }

  @override
  String get trackAddIngredient => 'Додати складник';

  @override
  String get trackNoIngredients => 'Немає складників';

  @override
  String get trackAddIngredientsHint => 'Додай складники, щоб зібрати страву';

  @override
  String get trackEditIngredient => 'Редагувати складник';

  @override
  String get trackIngredientNameOptional => 'Назва складника (необов’язково)';

  @override
  String get trackAmountG => 'Кількість (г)';

  @override
  String get trackEnterAmount => 'Вкажи кількість';

  @override
  String get trackEnterValidAmount => 'Вкажи правильну кількість';

  @override
  String get trackEnterCaloriesOrFillMacros =>
      'Вкажи калорії або заповни макронутрієнти';

  @override
  String get trackProteinPer100g => 'Білки (г/100 г)';

  @override
  String get trackFatPer100g => 'Жири (г/100 г)';

  @override
  String get trackCarbsPer100g => 'Вуглеводи (г/100 г)';

  @override
  String get trackEatingOutTitle => '🍽️ Їм у місті';

  @override
  String get trackEatingOutSubtitle => 'Обери, що ти їв (оцінка калорій):';

  @override
  String trackPortionLabel({required String label}) {
    return 'Порція: $label';
  }

  @override
  String trackSlicesCount({required String count}) {
    return 'Кількість шматків: $count';
  }

  @override
  String trackSlicesUnit({required String count}) {
    return '$count шт.';
  }

  @override
  String get trackKcalPerSlice => 'kcal на шматок:';

  @override
  String trackKcalPerPieceLabel({required String kcal}) {
    return '$kcal kcal/шт.';
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
  String get trackSaving => 'Збереження…';

  @override
  String get trackAddToDiary => 'Додати до щоденника';

  @override
  String get trackSelectMealAbove => 'Обери страву вище';

  @override
  String get trackEatingOutTip =>
      'Якщо решта дня була легкою — це нормально. Не переживай.';

  @override
  String trackMealNameEatingOutSlices({
    required String name,
    required String slices,
  }) {
    return '$name ($slices шт.) (у місті)';
  }

  @override
  String trackMealNameEatingOut({required String name}) {
    return '$name (у місті)';
  }

  @override
  String trackAddedEatingOut({
    required String name,
    required String slicesPart,
    required String kcal,
  }) {
    return 'Додано: $name$slicesPart (~$kcal kcal)';
  }

  @override
  String trackSlicesPart({required String slices}) {
    return ' ($slices шт.)';
  }

  @override
  String get trackEatingOutPizza => 'Піца';

  @override
  String get trackEatingOutPizzaLabel => '~250–450 kcal / шматок';

  @override
  String get trackEatingOutKebab => 'Кебаб';

  @override
  String get trackEatingOutKebabLabel => '~600–900 kcal';

  @override
  String get trackEatingOutBurger => 'Бургер (загалом)';

  @override
  String get trackEatingOutBurgerLabel => '~500–800 kcal';

  @override
  String get trackEatingOutChinese => 'Китайська кухня';

  @override
  String get trackEatingOutChineseLabel => '~500–900 kcal';

  @override
  String get trackEatingOutMcdCheeseburger => 'McDonald\'s – Cheeseburger';

  @override
  String get trackEatingOutMcdCheeseburgerLabel => '~300 kcal';

  @override
  String get trackEatingOutMcd2ForYou =>
      'McDonald\'s – 2forYou (Cheeseburger + картопля фрі)';

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
  String get trackEatingOutMcdSmallFries =>
      'McDonald\'s – маленька картопля фрі';

  @override
  String get trackEatingOutMcdSmallFriesLabel => '~230 kcal';

  @override
  String get trackEatingOutMcdMediumFries =>
      'McDonald\'s – середня картопля фрі';

  @override
  String get trackEatingOutMcdMediumFriesLabel => '~340 kcal';

  @override
  String get trackEatingOutKfcDrumstick => 'KFC – стегно/ніжка';

  @override
  String get trackEatingOutKfcDrumstickLabel => '~200 kcal / шт.';

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
    return 'Активності — $date';
  }

  @override
  String get trackNoActivitiesForDay => 'Немає активностей за цей день';

  @override
  String get trackAddFirstActivity => 'Додай першу активність';

  @override
  String get trackDaySummary => 'Підсумок дня';

  @override
  String get trackBurned => 'Спалено';

  @override
  String get trackTime => 'Час';

  @override
  String get trackGarminActivitiesNote =>
      'Дані активності походять із пристроїв Garmin.';

  @override
  String get trackDeleteActivityTitle => 'Видалити активність';

  @override
  String trackDeleteActivityConfirm({required String name}) {
    return 'Точно видалити «$name»?';
  }

  @override
  String get trackActivityDeleted => 'Активність видалено';

  @override
  String get trackExcludeFromBalance => 'Не враховувати в балансі (спалені)';

  @override
  String get trackActivityExcludedFromBalance =>
      'Активність виключено з балансу';

  @override
  String get trackActivityIncludedInBalance => 'Активність враховано в балансі';

  @override
  String get trackOtherActivities => 'Інші активності.';

  @override
  String get trackActivityTypeOther => 'Інша';

  @override
  String get trackActivityTypeLow => 'Низька';

  @override
  String get trackActivityTypeModerate => 'Помірна';

  @override
  String get trackActivityTypeHigh => 'Висока';

  @override
  String get trackActivityTypeVeryHigh => 'Дуже висока';

  @override
  String get trackActivityTypeRun => 'Біг';

  @override
  String get trackActivityTypeCycling => 'Велосипед';

  @override
  String get trackActivityTypeSwim => 'Плавання';

  @override
  String get trackActivityTypeWalk => 'Ходьба';

  @override
  String get trackActivityTypeHike => 'Похід';

  @override
  String get trackActivityTypeRow => 'Веслування';

  @override
  String get trackActivityTypeTennis => 'Теніс';

  @override
  String get trackActivityTypeYoga => 'Йога';

  @override
  String get trackActivityTypeTraining => 'Тренування';

  @override
  String get trackFeatureQuickAddActivities => 'Швидке додавання в активностях';

  @override
  String get trackActivitySavedAndFavorited =>
      'Активність збережено і додано до обраного!';

  @override
  String get trackActivityAddedSuccess => 'Активність успішно додано!';

  @override
  String get trackEditActivity => 'Редагувати активність';

  @override
  String get trackAddActivity => 'Додати активність';

  @override
  String get trackQuickAdd => 'Швидке додавання';

  @override
  String get trackActivityNameOptional => 'Назва активності (необов’язково)';

  @override
  String get trackHintEmptyDefaultActivityName =>
      'Порожньо = «Активність без назви»';

  @override
  String get trackDefaultActivityName => 'Активність без назви';

  @override
  String get trackEnterBurnedCalories => 'Вкажи кількість спалених калорій';

  @override
  String get trackEnterValidCalories => 'Вкажи правильну кількість калорій';

  @override
  String get trackActivityTypeOptional => 'Тип активності — необов’язково';

  @override
  String get trackAddToFavoritesActivitySubtitle =>
      'Потім можна швидко додати цю активність';

  @override
  String get trackUpdateActivity => 'Оновити активність';

  @override
  String get trackSaveActivity => 'Зберегти активність';

  @override
  String get trackDurationMinutes => 'Час (хв)';

  @override
  String get trackBurnedCalories => 'Спалені калорії';

  @override
  String trackAddedWaterMl({required String amount}) {
    return 'Додано $amount мл води';
  }

  @override
  String trackAddWaterError({required String error}) {
    return 'Помилка під час додавання води: $error';
  }

  @override
  String trackUpdatedAmountMl({required String amount}) {
    return 'Оновлено: $amount мл';
  }

  @override
  String trackUpdateError({required String error}) {
    return 'Помилка під час оновлення: $error';
  }

  @override
  String get trackDeleteEntryTitle => 'Видалити запис';

  @override
  String trackDeleteWaterConfirm({required String amount}) {
    return 'Точно видалити запис $amount мл?';
  }

  @override
  String get trackEntryDeleted => 'Запис видалено';

  @override
  String trackDeleteError({required String error}) {
    return 'Помилка під час видалення: $error';
  }

  @override
  String get trackEditAmount => 'Редагувати кількість';

  @override
  String get trackAmountMl => 'Кількість (мл)';

  @override
  String get trackAmountMlHintRange => '1–5000 мл';

  @override
  String get trackAmountMustBeRange => 'Кількість має бути від 1 до 5000 мл';

  @override
  String get trackAddWater => 'Додати воду';

  @override
  String get trackAmountMlHintExample => 'напр. 250';

  @override
  String get trackMaxAmountPerEntry =>
      'Максимальна кількість — 5000 мл на запис';

  @override
  String get trackEnterAmountRange => 'Вкажи кількість від 1 до 5000 мл';

  @override
  String get trackDailyWaterGoal => 'Денна ціль пиття води';

  @override
  String get trackGoalHintExample => 'напр. 2000';

  @override
  String get trackGoalMustBeRange => 'Вкажи значення від 500 до 10000 мл';

  @override
  String get trackWaterGoalUpdated => 'Ціль води оновлено';

  @override
  String get trackChangeDailyWaterGoal => 'Змінити денну ціль пиття води';

  @override
  String get trackEveryDropCounts => 'Кожна крапля має значення!';

  @override
  String get trackCustomAmount => 'Своя';

  @override
  String get trackWaterHistoryHint =>
      'Перегляд — можна редагувати і видаляти. Додавання лише на сьогодні.';

  @override
  String get trackNoEntries => 'Немає записів';

  @override
  String get trackEdit => 'Редагувати';

  @override
  String trackAmountMlLabel({required String amount}) {
    return '$amount мл';
  }

  @override
  String get trackDailyGoal => 'Денна ціль';

  @override
  String get trackEnterWeight => 'Вкажи вагу';

  @override
  String get trackEnterValidWeight => 'Вкажи правильну вагу (30–300 кг)';

  @override
  String get trackWeightSaved => 'Вагу успішно збережено!';

  @override
  String get trackWeightMotivation =>
      'Регулярні виміри допомагають тримати ціль. Кожен запис наближає до бажаної форми!';

  @override
  String get trackPickMeasurementDate => 'Обери дату виміру';

  @override
  String get trackMeasurementSavedWithDate =>
      'Вимір буде збережено з обраною датою';

  @override
  String get trackSaveWeight => 'Зберегти вагу';

  @override
  String get trackDeleteMeasurementTitle => 'Видалити вимір';

  @override
  String trackDeleteWeightConfirm({required String weight}) {
    return 'Точно видалити вимір $weight кг?';
  }

  @override
  String get trackMeasurementDeleted => 'Вимір видалено';

  @override
  String get trackNoWeightMeasurements => 'Немає вимірів ваги';

  @override
  String get trackAddFirstMeasurementHint =>
      'Додай перший вимір, щоб побачити історію';

  @override
  String get trackNoDataToDisplay => 'Немає даних для показу';

  @override
  String get trackWeightKg => 'Вага (кг)';

  @override
  String get trackHistory => 'Історія';

  @override
  String get trackEnterMeasurementValue => 'Вкажи значення виміру';

  @override
  String get trackEnterValidPositiveValue =>
      'Вкажи правильне значення (більше за 0)';

  @override
  String get trackEnterCustomTypeName =>
      'Введи назву власного типу виміру (напр. біцепс)';

  @override
  String get trackMeasurementSaved => 'Вимір успішно збережено!';

  @override
  String get trackBodyMeasurementsTitle => 'Виміри тіла';

  @override
  String get trackBodyMeasurementsMotivation =>
      'Вимірюй розміри регулярно — кожен вимір є доказом прогресу і кроком до бажаної форми!';

  @override
  String get trackMeasurementType => 'Тип виміру';

  @override
  String get trackCustomTypeHint => 'напр. Біцепс, живіт';

  @override
  String get trackCustomTypeName => 'Назва власного типу';

  @override
  String get trackValueCm => 'Значення (см)';

  @override
  String get trackValueHintExample => 'напр. 85.5';

  @override
  String get trackSaveMeasurement => 'Зберегти вимір';

  @override
  String trackMeasurementHistory({required String label}) {
    return 'Історія вимірів — $label';
  }

  @override
  String trackDeleteBodyMeasurementConfirm({required String value}) {
    return 'Точно видалити вимір $value см?';
  }

  @override
  String get trackNoMeasurements => 'Немає вимірів';

  @override
  String get trackTypeWaist => 'Талія';

  @override
  String get trackTypeHips => 'Стегна';

  @override
  String get trackTypeChest => 'Груди';

  @override
  String get trackTypeArm => 'Рука';

  @override
  String get trackTypeThigh => 'Стегно';

  @override
  String get trackTypeCustom => 'Власний';

  @override
  String get trackNoFavorites => 'Немає обраного';

  @override
  String get trackNoFavoritesSubtitle =>
      'Додавай страви або активності до обраного під час збереження';

  @override
  String get trackFavoriteMeals => 'Обрані страви';

  @override
  String get trackNoFavoriteMeals => 'Немає обраних страв';

  @override
  String get trackFavoriteActivities => 'Обрані активності';

  @override
  String get trackNoFavoriteActivities => 'Немає обраних активностей';

  @override
  String trackAddToMealsOnDate({required String date}) {
    return 'Додати до страв $date';
  }

  @override
  String get trackAddToTodaysMeals => 'Додати до сьогоднішніх страв';

  @override
  String get trackRemoveFromFavorites => 'Видалити з обраного';

  @override
  String trackAddToActivitiesOnDate({required String date}) {
    return 'Додати до активностей $date';
  }

  @override
  String get trackAddToTodaysActivities => 'Додати до сьогоднішніх активностей';

  @override
  String trackMealAddedToMealsOnDate({
    required String name,
    required String date,
  }) {
    return '$name додано до страв $date';
  }

  @override
  String trackMealAddedToTodaysMeals({required String name}) {
    return '$name додано до сьогоднішніх страв';
  }

  @override
  String trackActivityAddedToActivitiesOnDate({
    required String name,
    required String date,
  }) {
    return '$name додано до активностей $date';
  }

  @override
  String trackActivityAddedToTodaysActivities({required String name}) {
    return '$name додано до сьогоднішніх активностей';
  }

  @override
  String trackRemoveFromFavoritesConfirm({required String name}) {
    return 'Точно видалити «$name» з обраного?';
  }

  @override
  String get trackRemovedFromFavorites => 'Видалено з обраного';

  @override
  String get trackEditFavoriteMeal => 'Редагувати обрану страву';

  @override
  String get trackFavoriteMealUpdated => 'Обрану страву оновлено';

  @override
  String get trackRecalculateFromIngredients => 'Перерахувати зі складників';

  @override
  String trackMinutesLabel({required String minutes}) {
    return '$minutes хв';
  }

  @override
  String get trackCaloriesKcal => 'Калорії (kcal)';

  @override
  String get trackIncludingSaturatedG => 'з них насичені (г)';

  @override
  String get trackIncludingSugarsG => 'з них цукри (г)';

  @override
  String get trackWeightGOptional => 'Вага (г) — необов’язково';

  @override
  String get trackGoalMl => 'Ціль (мл)';

  @override
  String get trackWaterTitle => 'Вода';

  @override
  String trackOfGoal({required String current, required String goal}) {
    return '$current / $goal мл';
  }

  @override
  String get trackSearchShort => 'Пошук';

  @override
  String get trackWaterToday => 'Вода — Сьогодні';

  @override
  String trackWaterOnDate({required String date}) {
    return 'Вода — $date';
  }

  @override
  String get trackHydrationBasics => 'Зволоження — основа форми.';

  @override
  String get trackSugar => 'Цукри';

  @override
  String get trackSaturatedFat => 'Насичені';

  @override
  String get trackProduct => 'Продукт';

  @override
  String trackMealMacrosLine({
    required String kcal,
    required String protein,
    required String fat,
    required String carbs,
  }) {
    return '$kcal kcal • Б: $proteinг • Ж: $fatг • В: $carbsг';
  }

  @override
  String get trackAnalysisResults => 'Результати аналізу';

  @override
  String get trackName => 'Назва';

  @override
  String get trackProductNotFoundTitle => 'Продукт не знайдено';

  @override
  String get trackBarcodeLabel => 'Штрихкод';

  @override
  String get trackFetchingProductData => 'Отримуємо дані продукту...';

  @override
  String trackBrand({required String brand}) {
    return 'Бренд: $brand';
  }

  @override
  String get trackWeightGRequired => 'Вага (г) *';

  @override
  String get trackYourPortion => 'Твоя порція:';

  @override
  String get trackMacroAbbrevProtein => 'Б';

  @override
  String get trackMacroAbbrevFat => 'Ж';

  @override
  String get trackMacroAbbrevCarbs => 'В';

  @override
  String trackAddedKcal({required String kcal}) {
    return 'Додано: $kcal kcal';
  }

  @override
  String get trackCaloriesPer100g => 'Калорії (kcal/100 г)';

  @override
  String get trackDashToday => 'Сьогодні';

  @override
  String get trackNoDate => 'Немає дати';

  @override
  String get trackEntries => 'Записи';

  @override
  String get trackWeightHistory => 'Історія ваги';

  @override
  String get trackMeasurementName => 'Назва виміру';

  @override
  String get trackChoose => 'Обрати';

  @override
  String get trackDurationMinutesOptional =>
      'Тривалість (хвилини) — необов’язково';

  @override
  String get trackMax5000Helper => 'Максимум 5000 мл на один запис';

  @override
  String get trackRecommendedMin2l => 'Рекомендовано щонайменше 2 л';

  @override
  String get trackSummary => 'Підсумок';

  @override
  String trackBurnedKcalName({required String kcal}) {
    return 'Спалено $kcal kcal';
  }

  @override
  String get trackMeasurementDate => 'Дата виміру';

  @override
  String trackKcalBurned({required String kcal}) {
    return '$kcal kcal спалено';
  }

  @override
  String get trackMacrosInPremium => 'Макро — у Premium';

  @override
  String get trackSearchProductEllipsis => 'Шукати продукт…';

  @override
  String get trackMacros => 'Макро';

  @override
  String get trackRecentMeasurements => 'Останні виміри';

  @override
  String get authEnterFullCode => 'Введи повний код із листа.';

  @override
  String get authSignedIn => 'Вхід успішний!';

  @override
  String get authCodeExpired =>
      'Код закінчився або неправильний. Надішли знову.';

  @override
  String get authEnterEmail => 'Вкажи адресу ел. пошти';

  @override
  String get authInvalidEmail => 'Неправильний формат ел. пошти';

  @override
  String authLinkAndCodeSent({required String email}) {
    return 'Ми надіслали посилання і код на $email. Перевір пошту (також папку Спам) — натисни посилання або введи код у застосунку.';
  }

  @override
  String get authCouldNotStart => 'Не вдалося почати вхід.';

  @override
  String get authEmailTaken =>
      'Цю адресу ел. пошти вже зареєстровано. Увійди за посиланням із листа (перевір спам).';

  @override
  String get authAlreadyLinked =>
      'Цей акаунт уже з’єднано з іншим користувачем.';

  @override
  String get authManualLinking =>
      'З’єднання акаунтів потребує ввімкнення в Supabase. Увімкни \"Manual linking\" у Authentication → Providers.';

  @override
  String get authConnection => 'Помилка з’єднання. Перевір інтернет.';

  @override
  String get authTooManyAttempts => 'Забагато спроб входу. Спробуй за годину.';

  @override
  String get authTooManyEmails =>
      'Забагато листів на цю адресу. Перевір пошту або спробуй за хвилину.';

  @override
  String get authInvalidEmailAddress => 'Неправильна адреса ел. пошти.';

  @override
  String authGenericError({required String detail}) {
    return 'Помилка: $detail';
  }

  @override
  String premAboutPerMonth({required String amount, required String unit}) {
    return 'бл. $amount $unit / місяць';
  }

  @override
  String get premYearlyPerMonthFallback =>
      'у перерахунку бл. 16,25 zł / міс. (оплата раз на рік)';

  @override
  String get moreStreakWater => 'Вода';

  @override
  String get premStoreNotReady =>
      'Покупки в магазині ще не готові. Спробуй знову за хвилину.';

  @override
  String get trackAddToCatalog => 'Додати до бази';

  @override
  String get trackAddToCatalogHint =>
      'Сфотографуй таблицю поживної цінності або впиши дані з етикетки. Продукт потрапить до спільної бази.';

  @override
  String get trackLabelPhoto => 'Фото етикетки';

  @override
  String get trackReadingLabel => 'Читаю етикетку…';

  @override
  String get trackLabelNotRead =>
      'Не вдалося прочитати таблицю. Впиши значення вручну.';

  @override
  String get trackEnterNameAndCalories => 'Вкажи назву і калорії на 100 г.';

  @override
  String get trackProductSavedCatalog =>
      'Продукт збережено. Наступного разу сканер його знайде.';

  @override
  String get trackCatalogNotSaved =>
      'Страву можна додати, але спільна база не зберегла продукт.';

  @override
  String get trackBrandOptional => 'Бренд (необов’язково)';

  @override
  String get trackCopyYesterday => 'Скопіювати вчора';

  @override
  String trackCopiedMealsCount({required int count}) {
    return 'Скопійовано страв: $count';
  }

  @override
  String get trackNoMealsYesterday => 'Учора не було страв для копіювання.';

  @override
  String get trackCopyConfirmTitle => 'Страви вже є';

  @override
  String trackCopyConfirmBody({required int count}) {
    return 'Цього дня вже є $count страв. Скопіювати вчорашні ще раз? (з’являться дублікати)';
  }

  @override
  String get trackCopyAgain => 'Копіювати знову';

  @override
  String get trackCopying => 'Копіювання…';

  @override
  String get trackRecentFoods => 'Нещодавно їв';

  @override
  String get trackMealIdeasTitle => 'Підходить на сьогодні';

  @override
  String trackMealIdeasLeft({required String kcal}) {
    return 'Залишилось бл. $kcal ккал';
  }

  @override
  String get trackWaterTipSerious =>
      'Регулярне пиття підтримує концентрацію та обмін речовин — пий протягом дня.';

  @override
  String get trackAddFirstMealTitle => 'Додай першу страву';

  @override
  String get trackAddFirstMealSubtitle =>
      'Запиши, що їси — решту порахуємо ми.';

  @override
  String get trackAddFirstMealCta => 'Додати страву';

  @override
  String get trackShortcutRecent => 'Нещодавні';

  @override
  String get trackRemainingKcal => 'Залишилось до цілі';

  @override
  String get trackOverGoalLabel => 'Понад ціль';

  @override
  String trackGoalVerificationDays({required int days}) {
    return '$days/7 днів із даними';
  }

  @override
  String get trackCalorieGoalSuccess =>
      'Молодець — сьогодні ти близько до калорійної цілі.';

  @override
  String get trackD1ChecklistTitle => 'Перший день — чекліст';

  @override
  String get trackD1ChecklistMeal => 'Додай страву';

  @override
  String get trackD1ChecklistWater => 'Запиши воду';

  @override
  String get trackD1ChecklistWeight => 'Запиши вагу';

  @override
  String get trackD1ChecklistDismiss => 'Зрозуміло';

  @override
  String get trackPremiumLabel => 'Premium';

  @override
  String trackPercentOfGoal({required String percent}) {
    return '$percent% цілі';
  }
}
