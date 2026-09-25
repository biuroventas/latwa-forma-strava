// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get appTitle => 'Łatwa Forma';

  @override
  String get navToday => 'Today';

  @override
  String get navMeals => 'Meals';

  @override
  String get navWater => 'Water';

  @override
  String get navProfile => 'Me';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonClose => 'Close';

  @override
  String get commonRetry => 'Try again';

  @override
  String get commonWarning => 'Notice';

  @override
  String get commonError => 'Error';

  @override
  String get commonBack => 'Back';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get commonContinue => 'Continue';

  @override
  String get healthDisclaimer =>
      'Łatwa Forma is not a medical device and does not diagnose, treat, cure, or prevent any disease or health condition. Calorie and macronutrient calculations and AI advice are estimates. For health matters, talk to a doctor or dietitian.';

  @override
  String get onbContinueApple => 'Continue with Apple';

  @override
  String get onbContinueGoogle => 'Continue with Google';

  @override
  String get onbContinueWithEmail => 'Continue with email';

  @override
  String get onbStartWithoutAccount => 'Start without an account';

  @override
  String get onbCreateAccount => 'Create account';

  @override
  String get onbCreateAccountEmail => 'Create account with email';

  @override
  String get onbEnterCodeLink => 'I already have a code from email – enter it';

  @override
  String get onbAlreadyHaveCode => 'I already have a code from email';

  @override
  String get onbLegalPrefix => 'By using the app, you accept the ';

  @override
  String get onbTerms => 'Terms of Service';

  @override
  String get onbLegalAnd => ' and ';

  @override
  String get onbPrivacyPolicyAccusative => 'Privacy Policy';

  @override
  String get onbLegalPeriod => '.';

  @override
  String get onbPrivacyPolicy => 'Privacy Policy';

  @override
  String get onbContact => 'Contact';

  @override
  String get onbFollowUs => 'Follow us: ';

  @override
  String onbSocialComingSoon({required String name}) {
    return '$name – coming soon';
  }

  @override
  String onbCopyrightFull({
    required String company,
    required String nip,
    required String address,
  }) {
    return '© 2026 Łatwa Forma | $company\nTax ID $nip · $address';
  }

  @override
  String onbCopyrightShort({required String company, required String nip}) {
    return '© 2026 Łatwa Forma | $company\nTax ID $nip';
  }

  @override
  String get onbFeatureCaloriesTitle => 'Calories and macros tailored to you';

  @override
  String get onbFeatureCaloriesDesc => 'Daily limit and macros for your goal';

  @override
  String get onbFeatureWeightTitle => 'Weight and progress tracking';

  @override
  String get onbFeatureWeightDesc => 'Weight and changes in one place';

  @override
  String get onbFeaturePlanTitle => 'A simple plan to your goal';

  @override
  String get onbFeaturePlanDesc => 'A clear path to your target weight';

  @override
  String get onbFeatureAiTitle => 'AI help';

  @override
  String get onbFeatureAiDesc => 'Tips and meals from a photo';

  @override
  String get onbFeatureProductsTitle => 'Product database';

  @override
  String get onbFeatureProductsDesc => 'Search and scan barcodes';

  @override
  String get onbBenefitCalories => 'a calorie plan tailored to you';

  @override
  String get onbBenefitWeight => 'weight and progress tracking';

  @override
  String get onbBenefitPlan => 'a simple plan to your goal';

  @override
  String get onbBenefitAi => 'AI help';

  @override
  String get onbLoginOrRegister => 'Sign in or create an account';

  @override
  String get onbLoginOrCreateShort => 'Sign in or create an account';

  @override
  String get onbLoginSheetBody =>
      'Have an account? Sign in. New here? Create an account – your data will be saved.';

  @override
  String get onbFaqTitle => 'FAQ – frequently asked questions';

  @override
  String get onbFaqShowLess => 'Show less';

  @override
  String onbFaqShowMore({required int count}) {
    return 'See more questions ($count)';
  }

  @override
  String get onbFaqFreeQ => 'Is the app free?';

  @override
  String get onbFaqFreeA =>
      'Yes. Łatwa Forma is free for everyday use: tracking calories, meals, weight, water, and activity. Some features (e.g. AI meal photo analysis, advanced stats) are available with Premium.';

  @override
  String get onbFaqPhotoQ => 'How does calorie tracking from a photo work?';

  @override
  String get onbFaqPhotoA =>
      'On the add-meal screen, choose “AI analysis”. Take a photo of your dish or pick one from your gallery. The app sends the image to an AI vision model that recognizes the food and estimates calories and macros (protein, fat, carbs). You can edit and save them afterward. This feature requires Premium.';

  @override
  String get onbFaqLimitQ =>
      'How does the app calculate my daily calorie limit?';

  @override
  String get onbFaqLimitA =>
      'Based on your profile (age, sex, weight, height, activity level) we calculate BMR (Harris–Benedict formula), then TDEE. Depending on your goal (lose, maintain, or gain weight) we adjust your calorie limit and macros.';

  @override
  String get onbFaqNoAccountQ => 'What is “Start without an account”?';

  @override
  String get onbFaqNoAccountA =>
      'You can use the app without signing in. Data is stored locally. Later you can link it to an account (Apple, Google, or email) for backup and sync across devices.';

  @override
  String get onbFaqStravaQ => 'Can I connect Strava or Garmin?';

  @override
  String get onbFaqStravaA =>
      'Yes for Strava. In settings (Profile → Integrations) you can connect your Strava account. Imported activities count toward your calorie balance (kcal burned). Garmin Connect will appear once that integration launches.';

  @override
  String get onbFaqPremiumQ => 'What does Premium include?';

  @override
  String get onbFaqPremiumA =>
      'Among other things: AI meal photo analysis, advanced stats, data export, and a higher AI advice limit. In store builds, payments go through Google Play / App Store; on latwaforma.pl – through Stripe.';

  @override
  String get onbFaqGoalQ => 'How do I change my goal (lose / maintain / gain)?';

  @override
  String get onbFaqGoalA =>
      'In Profile, set your target weight. The app suggests a goal and daily limit from that; you can also adjust macros manually in profile settings.';

  @override
  String get onbFaqAddMealQ => 'How do I add a meal?';

  @override
  String get onbFaqAddMealA =>
      'From the home screen or the “Meals” tab, choose “Add meal”. You can enter details manually, scan a barcode (Open Food Facts), or use AI photo analysis (Premium).';

  @override
  String get onbFaqDataQ => 'Where is my data stored?';

  @override
  String get onbFaqDataA =>
      'Data is stored on servers in Europe (Supabase). With “Start without an account”, data stays local until you link an account.';

  @override
  String get onbFaqDeleteQ => 'How do I delete my account and data?';

  @override
  String get onbFaqDeleteA =>
      'In the app: Profile → Delete account. You can also submit a request at latwaforma.pl/usun-konto.html. After approval, the account and related data are deleted (this is not account freezing). Cancel a Google Play / App Store subscription separately in the store. If you need help: contact@latwaforma.pl.';

  @override
  String get onbFaqMedicalQ => 'Is this a medical app?';

  @override
  String get onbFaqMedicalA =>
      'No. Łatwa Forma is not a medical device and does not diagnose, treat, or prevent disease. Calculations and AI advice are estimates. For health matters, talk to a doctor or dietitian.';

  @override
  String get onbSendingLinkAndCode => 'Sending link and code...';

  @override
  String get onbSignedIn => 'Signed in';

  @override
  String get onbSignedInSuccess => 'Signed in successfully!';

  @override
  String get onbSignedInDataSaved => 'You are signed in. Your data is saved.';

  @override
  String get onbAccountLinked => 'Account linked';

  @override
  String get onbEmailLinkedSuccess =>
      'Your email has been linked to your account. You can now sign in with this email.';

  @override
  String get onbEnterEmailTitle => 'Enter your email address';

  @override
  String get onbEnterEmailWhichAddress =>
      'Which address did we send the link and code to? Enter it, then you’ll enter the code.';

  @override
  String get onbEmailAddressLabel => 'Email address';

  @override
  String get onbEmailAddressLabelAlt => 'Email address';

  @override
  String get onbEmailAddressHint => 'e.g. jane@example.com';

  @override
  String get onbCheckInbox => 'Check your inbox';

  @override
  String get onbEnterCodeFromEmailTitle => 'Enter the code from email';

  @override
  String get onbEnterCodeFromEmailLabel => 'Enter the code from email:';

  @override
  String get onbEmailCodeLabel => 'Code from email';

  @override
  String get onbEmailCodeHint => 'e.g. 123456';

  @override
  String onbSentLinkAndCode({required String email}) {
    return 'We sent a link and code to $email. Check your inbox (including Spam) – you can tap the link in the email or enter the code below.';
  }

  @override
  String onbEnterCodeReceived({required String email}) {
    return 'Enter the code you received at $email below.';
  }

  @override
  String onbCodeSentTo({required String email}) {
    return 'Code sent to: $email';
  }

  @override
  String onbCodeSentEnterBelow({required String email}) {
    return 'We sent a code to $email. Enter it below.';
  }

  @override
  String get onbResend => 'Resend';

  @override
  String get onbSignIn => 'Sign in';

  @override
  String get onbConfirmCode => 'Confirm code';

  @override
  String get onbSuccess => 'Success';

  @override
  String get onbSendLinkAndCode => 'Send link and code';

  @override
  String get onbEmailSignupBody =>
      'Enter your email address. We’ll send a link and code to finish creating your account.';

  @override
  String get onbEnterEmailRequired => 'Enter an email address';

  @override
  String get onbIntroTitle => 'Tell us a few things about yourself';

  @override
  String get onbIntroBody =>
      'We’ll show you how much to eat each day\nto reach your goal.';

  @override
  String get onbIntroDuration => 'Takes less than a minute';

  @override
  String get onbIntroStart => 'Get started';

  @override
  String get onbAnonErrorTitle => 'Couldn’t start without an account';

  @override
  String get onbAnonErrorNoConfig =>
      'The app isn’t connected to the server (missing configuration in this build).';

  @override
  String get onbAnonErrorTimeout =>
      'The server didn’t respond in time. Check your internet or try again later.';

  @override
  String get onbAnonErrorFailed => 'Connecting to the server failed. You can:';

  @override
  String get onbAnonErrorTipDomain => '• Make sure you’re on latwaforma.pl.';

  @override
  String get onbAnonErrorTipRefresh => '• Refresh the page (F5) and try again.';

  @override
  String get onbAnonErrorTipLogin =>
      '• Or sign in with Apple, Google, or email – button at the top.';

  @override
  String get onbOpenLatwaForma => 'Open latwaforma.pl';

  @override
  String get onbSplashNoServerConfig =>
      'No server connection. Check configuration (.env) and your internet.';

  @override
  String get onbSplashNoConnection =>
      'No connection. Check your internet and try again.';

  @override
  String get onbSplashLoginFailed =>
      'Sign-in failed. Complete your profile or try signing in again.';

  @override
  String get onbSplashGoogleFailed =>
      'Google sign-in failed. Sign in again in the same tab.';

  @override
  String get onbSplashAbort => 'Cancel';

  @override
  String get onbPlanThanks => 'Thank you!';

  @override
  String get onbPlanGotIt => 'Got it!';

  @override
  String get onbPlanStepData => 'Data';

  @override
  String get onbPlanStepCalc => 'Calculation';

  @override
  String get onbPlanStepMacro => 'Macros';

  @override
  String get onbPlanStepDone => 'Done';

  @override
  String get onbPlanStatusAnalyzing => 'Analyzing your data…';

  @override
  String get onbPlanStatusCalories => 'Calculating calories…';

  @override
  String get onbPlanStatusMacro => 'Macros…';

  @override
  String get onbPlanStatusAlmost => 'Almost ready…';

  @override
  String get onbPlanReadyTitle => 'Your plan is ready!';

  @override
  String get onbPlanWhatDone => 'What we did:';

  @override
  String get onbPlanCaloriesComputed =>
      '• Based on your height, weight, age, and activity level, we calculated your daily calorie needs.';

  @override
  String onbPlanCaloriesComputedWithValue({required String calories}) {
    return '• Based on your height, weight, age, and activity level, we calculated your daily calorie needs: $calories kcal.';
  }

  @override
  String onbPlanTargetDate({required String date}) {
    return '• Estimated date to reach your goal: $date';
  }

  @override
  String get onbPlanChangeInProfile =>
      'You can change these details anytime in the Profile tab (person icon at the top).';

  @override
  String get onbPlanHowToUse => 'How to use the app:';

  @override
  String get onbPlanTipMeals =>
      '• Add meals – track what you eat and how many calories you take in';

  @override
  String get onbPlanTipWater => '• Drink water – set reminders in settings';

  @override
  String get onbPlanTipWeight =>
      '• Log your weight regularly – see progress on the chart';

  @override
  String get onbPlanTipDashboard =>
      '• Check the dashboard – see your daily goal and progress there';

  @override
  String get onbPlanMedicalNote =>
      'Łatwa Forma is not a medical device and does not diagnose, treat, or prevent disease. For health matters, talk to a doctor or dietitian.';

  @override
  String get onbPlanStartButton => 'Got it, let’s start!';

  @override
  String get onbSaveProgressTitle => 'Save your progress';

  @override
  String onbSaveProgressBodyWithMeals({required int count}) {
    return 'You already have $count meals! Sign in so you don’t lose data if you reinstall the app.';
  }

  @override
  String get onbSaveProgressBodyEmpty =>
      'Create an account so your meals, activities, and weight are saved in the cloud and available on every device – nothing is lost if you reinstall.';

  @override
  String get onbChooseLoginMethod => 'Choose a sign-in method:';

  @override
  String get onbLater => 'Later';

  @override
  String guestTrialDaysLeft({required int days}) {
    return 'Without an account: $days days left';
  }

  @override
  String get guestTrialOneDay => 'Without an account: 1 day left';

  @override
  String get guestTrialLastDay =>
      'Without an account: last day. From tomorrow, new entries need an account.';

  @override
  String get guestTrialCardBody =>
      'Link an account so your data stays if you change phones.';

  @override
  String get guestTrialEndedTitle => 'The no-account period has ended';

  @override
  String get guestTrialEndedBody =>
      'You can still view saved meals, water and weight. Link an account to add more — your data stays.';

  @override
  String get guestTrialViewOnly => 'View only';

  @override
  String get onbLinkingAccount => 'Linking account...';

  @override
  String get onbAccountSavedSuccess => 'Account saved successfully!';

  @override
  String get onbSaveWithEmailTitle => 'Save with email';

  @override
  String get onbEmailAlreadyRegistered => 'Email already registered';

  @override
  String get onbClickBelowToLogin => 'Tap below to go to sign-in:';

  @override
  String get onbSignOutAndSignIn => 'Sign out and sign in';

  @override
  String get onbGoBackTitle => 'Go back?';

  @override
  String get onbGoBackBody =>
      'Your data won’t be saved. You’ll return to the start screen.';

  @override
  String get onbGoBackConfirm => 'Yes, go back';

  @override
  String get onbBackTooltip => 'Back';

  @override
  String get onbCompleteData => 'Complete your details';

  @override
  String get onbGenderLabel => 'Sex *';

  @override
  String get onbGenderFemale => 'Female';

  @override
  String get onbGenderMale => 'Male';

  @override
  String get onbAgeLabel => 'Age *';

  @override
  String get onbYearsUnit => 'yrs';

  @override
  String get onbHeightLabel => 'Height (cm) *';

  @override
  String get onbCurrentWeightLabel => 'Current weight (kg) *';

  @override
  String get onbTargetWeightLabel => 'Target weight (kg) *';

  @override
  String onbWeightDiff({required String diff}) {
    return 'Difference: $diff kg';
  }

  @override
  String get onbWeightDiffMin =>
      'The difference between weights must be at least 1 kg';

  @override
  String get onbActivityLabel => 'Activity level *';

  @override
  String get onbActivitySedentary => 'Sedentary';

  @override
  String get onbActivitySedentaryDesc => 'Little or no activity';

  @override
  String get onbActivityLight => 'Light';

  @override
  String get onbActivityLightDesc => 'Exercise 1–3 times a week';

  @override
  String get onbActivityModerate => 'Moderate';

  @override
  String get onbActivityModerateDesc => 'Exercise 3–5 times a week';

  @override
  String get onbActivityIntense => 'Intense';

  @override
  String get onbActivityIntenseDesc => 'Exercise 6–7 times a week';

  @override
  String get onbActivityVeryIntense => 'Very intense';

  @override
  String get onbActivityVeryIntenseDesc =>
      'Very hard physical work or training twice a day';

  @override
  String get onbSaveAndStart => 'Save and start';

  @override
  String get onbGoalLose => 'I want to lose weight.';

  @override
  String get onbGoalGain => 'I want to gain weight.';

  @override
  String get onbGoalMaintain => 'I want to maintain my current weight.';

  @override
  String get onbGoalUnchangedSameWeight =>
      'Your goal did not change. The target weight is the same as your current weight, so the plan is to maintain it.';

  @override
  String get onbErrorCreatingAccount => 'Error creating account.';

  @override
  String get onbErrorNetworkPermission =>
      'Network permission error.\n\nFix:\n1. Stop the app\n2. Run again: flutter run\n3. If it still fails, check that anonymous auth is enabled in Supabase';

  @override
  String get onbErrorAnonymousDisabled =>
      'Anonymous auth is not enabled in Supabase.\n\nGo to: Authentication → Providers → Anonymous → Enable';

  @override
  String get onbErrorInternet =>
      'Internet connection error.\nCheck your connection and try again.';

  @override
  String get onbErrorInternetShort =>
      'Internet connection error. Check your connection and try again.';

  @override
  String get onbErrorSupabaseConfig =>
      'Supabase configuration error.\nCheck the API keys in the .env file';

  @override
  String onbErrorWithDetails({required String details}) {
    return 'Error: $details';
  }

  @override
  String get onbErrorSaving => 'Error while saving';

  @override
  String get onbErrorAuth =>
      'Authorization error. Check your Supabase configuration.';

  @override
  String get moreStatisticsTitle => 'Statistics';

  @override
  String get moreStreaksTooltip => 'Streaks';

  @override
  String get moreWeeklySummary => 'Weekly summary';

  @override
  String get moreShareTooltip => 'Share';

  @override
  String get moreShareWeeklyStatsFeature => 'Sharing weekly statistics';

  @override
  String get moreShareWeeklySummaryText => '📊 Łatwa Forma – Weekly summary';

  @override
  String moreShareError({required String error}) {
    return 'Share error: $error';
  }

  @override
  String get moreAvgDailyCalories => 'Average daily calories';

  @override
  String get moreTotalCaloriesWeek => 'Total calories (week)';

  @override
  String get moreBurnedCaloriesWeek => 'Calories burned (week)';

  @override
  String get moreWaterWeek => 'Water (week)';

  @override
  String get moreCaloriesDuringWeek => 'Calories during the week';

  @override
  String get moreMacrosWeek => 'Macros (week)';

  @override
  String get moreProtein => 'Protein';

  @override
  String get moreFat => 'Fat';

  @override
  String get moreCarbs => 'Carbs';

  @override
  String get moreCarbsFull => 'Carbohydrates';

  @override
  String get moreGoalVerification => 'Goal verification';

  @override
  String get moreGoalVerificationHint =>
      'Log meals and weight every day for a week. The app will verify your goal and suggest adjustments if your real needs differ from the calculator.';

  @override
  String moreProgressDaysWithData({required int days}) {
    return 'Progress: $days/7 days with data';
  }

  @override
  String get moreBasedOnLast7Days => 'Based on the last 7 days:';

  @override
  String moreAvgCaloriesPerDayBullet({required String calories}) {
    return '• Average: ~$calories kcal/day';
  }

  @override
  String get moreWeightStable => 'stable';

  @override
  String moreWeightIncrease({required String kg}) {
    return 'increase (+$kg kg)';
  }

  @override
  String moreWeightDecrease({required String kg}) {
    return 'decrease ($kg kg)';
  }

  @override
  String moreWeightBullet({required String change}) {
    return '• Weight: $change';
  }

  @override
  String get moreSaving => 'Saving…';

  @override
  String get moreApplyCorrectedGoal => 'Apply corrected goal';

  @override
  String get moreGoalAligned =>
      'You have enough data. Your current goal matches the trend – no adjustment needed.';

  @override
  String moreRealTdee({required String calories}) {
    return 'Real needs: ~$calories kcal';
  }

  @override
  String moreGoalUpdated({required String calories}) {
    return 'Goal updated to ~$calories kcal';
  }

  @override
  String moreErrorWithDetails({required String error}) {
    return 'Error: $error';
  }

  @override
  String get moreGoalHistoryReason => 'Verification based on last week’s data';

  @override
  String get moreDayMon => 'Mon';

  @override
  String get moreDayTue => 'Tue';

  @override
  String get moreDayWed => 'Wed';

  @override
  String get moreDayThu => 'Thu';

  @override
  String get moreDayFri => 'Fri';

  @override
  String get moreDaySat => 'Sat';

  @override
  String get moreDaySun => 'Sun';

  @override
  String moreSuggestionWeightLossFlat({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'Weight stable at ~$avg kcal. Your real needs are ~$real kcal. Want to lose weight? Try ~$corr kcal.';
  }

  @override
  String moreSuggestionWeightLossDown({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'You’re losing weight at ~$avg kcal. Real TDEE: ~$real kcal. Suggested goal: ~$corr kcal.';
  }

  @override
  String moreSuggestionWeightGainFlat({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'Weight stable at ~$avg kcal. Your real needs are ~$real kcal. Want to gain weight? Try ~$corr kcal.';
  }

  @override
  String moreSuggestionWeightGainUp({
    required String avg,
    required String real,
    required String corr,
  }) {
    return 'You’re gaining weight at ~$avg kcal. Real TDEE: ~$real kcal. Suggested goal: ~$corr kcal.';
  }

  @override
  String moreSuggestionMaintain({
    required String real,
    required String calc,
    required String corr,
  }) {
    return 'Real needs: ~$real kcal (calculator: $calc kcal). Goal: ~$corr kcal.';
  }

  @override
  String get moreBmiCalculatorTitle => 'BMI calculator';

  @override
  String get moreYourBmi => 'Your BMI';

  @override
  String get moreCalculatedBasedOn => 'Calculated based on:';

  @override
  String moreCurrentWeightBullet({required String weight}) {
    return '• Current weight: $weight kg';
  }

  @override
  String moreHeightBullet({required String height}) {
    return '• Height: $height cm';
  }

  @override
  String moreNormalBmiRangeHint({
    required String minKg,
    required String maxKg,
  }) {
    return 'To stay in the normal range (BMI 18.5–24.9), aim for a weight between $minKg and $maxKg kg.';
  }

  @override
  String get moreCompleteProfileForBmi =>
      'Complete your profile (weight and height) to see your BMI';

  @override
  String get moreBmiScale => 'BMI scale';

  @override
  String get moreBmiUnderweight => 'Underweight';

  @override
  String get moreBmiNormal => 'Normal';

  @override
  String get moreBmiOverweight => 'Overweight';

  @override
  String get moreBmiObesity1 => 'Obesity class I';

  @override
  String get moreBmiObesity2 => 'Obesity class II';

  @override
  String get moreBmiObesity3 => 'Obesity class III';

  @override
  String get moreBmiFormulaTitle => 'BMI formula';

  @override
  String get moreBmiFormula => 'BMI = weight (kg) / height (m)²';

  @override
  String get moreBmiExplanation =>
      'BMI is a body mass index that helps assess whether weight is appropriate for height.';

  @override
  String get moreExportTitle => 'Data export';

  @override
  String get moreExportDescription =>
      'Export data to a CSV file (full list) or PDF (report for the last 30 days). A share sheet will open.';

  @override
  String get moreExporting => 'Exporting...';

  @override
  String get moreExportToCsv => 'Export to CSV';

  @override
  String get moreExportToPdfPremium => 'Export to PDF (Premium)';

  @override
  String get moreExportPdfFeature => 'PDF export';

  @override
  String get moreUserNotLoggedIn => 'User is not logged in';

  @override
  String get moreCsvCopiedClipboard =>
      'Data copied to the clipboard. Paste into Notepad or Excel and save as .csv';

  @override
  String get moreCsvFileReady => 'CSV file ready. You can save or share it.';

  @override
  String get moreCsvClipboardFallback =>
      'Data exported to the clipboard (CSV). Paste it into Notes and save as a .csv file';

  @override
  String get moreCsvClipboardShort => 'Data exported to the clipboard (CSV).';

  @override
  String get moreExportFailed =>
      'Export failed. Check your connection and try again.';

  @override
  String get moreExportShareText => 'Łatwa Forma data export';

  @override
  String moreExportShareSubject({required String date}) {
    return 'Łatwa Forma data - $date';
  }

  @override
  String get morePdfReportShareText => 'Łatwa Forma report';

  @override
  String morePdfReportShareSubject({required String date}) {
    return 'Łatwa Forma report - $date';
  }

  @override
  String get morePdfDownloaded =>
      'PDF downloaded. Check your Downloads folder.';

  @override
  String get morePdfShareOrDownloadFailed =>
      'Could not share or download the PDF. Try Chrome or export to CSV.';

  @override
  String get morePdfShareFailed =>
      'Could not share the PDF. Try exporting to CSV.';

  @override
  String get morePdfFileReady => 'PDF file ready. You can save or share it.';

  @override
  String morePdfExportFailedWithHint({required String hint}) {
    return 'PDF export failed ($hint). Try CSV.';
  }

  @override
  String get morePdfExportFailed =>
      'PDF export failed. Try again or export to CSV.';

  @override
  String get moreCsvSectionProfile => '=== PROFILE ===';

  @override
  String get moreCsvHeaderTypeNameValue => 'Type,Name,Value';

  @override
  String get moreCsvProfile => 'Profile';

  @override
  String get moreCsvGender => 'Gender';

  @override
  String get moreGenderMale => 'Male';

  @override
  String get moreGenderFemale => 'Female';

  @override
  String get moreGenderOther => 'Other';

  @override
  String get moreCsvAge => 'Age';

  @override
  String moreCsvAgeYears({required String age}) {
    return '$age years';
  }

  @override
  String get moreCsvHeight => 'Height';

  @override
  String get moreCsvCurrentWeight => 'Current weight';

  @override
  String get moreCsvTargetWeight => 'Target weight';

  @override
  String get moreCsvGoal => 'Goal';

  @override
  String get moreGoalWeightLoss => 'Weight loss';

  @override
  String get moreGoalWeightGain => 'Weight gain';

  @override
  String get moreGoalMaintain => 'Maintenance';

  @override
  String get moreGoalMaintainWeight => 'Weight maintenance';

  @override
  String get moreCsvCalorieGoal => 'Calorie goal';

  @override
  String get moreCsvProteinG => 'Protein (g)';

  @override
  String get moreCsvFatG => 'Fat (g)';

  @override
  String get moreCsvCarbsG => 'Carbohydrates (g)';

  @override
  String get moreCsvTargetDate => 'Estimated goal date';

  @override
  String get moreCsvSectionDiary => '=== DIARY DATA ===';

  @override
  String get moreCsvGarminNote =>
      '# Activity data may include data from Garmin devices.';

  @override
  String get moreCsvHeaderDiary => 'Type,Name,Value,Date,Data source';

  @override
  String get moreCsvMeal => 'Meal';

  @override
  String get moreCsvActivity => 'Activity';

  @override
  String get moreCsvWeight => 'Weight';

  @override
  String get morePdfReportTitle => 'Łatwa Forma – Report';

  @override
  String morePdfPageFooter({
    required String page,
    required String pages,
    required String date,
  }) {
    return 'Page $page of $pages • Generated $date';
  }

  @override
  String get morePdfProfileSummary => 'Profile summary';

  @override
  String morePdfProfileLine1({
    required String gender,
    required String age,
    required String height,
  }) {
    return 'Gender: $gender • Age: $age years • Height: $height cm';
  }

  @override
  String morePdfProfileLine2({
    required String weight,
    required String target,
    required String calories,
  }) {
    return 'Weight: $weight kg • Target: $target kg • Calorie goal: $calories kcal';
  }

  @override
  String get morePdfGoalWeightLoss => 'Goal: Weight loss';

  @override
  String get morePdfGoalWeightGain => 'Goal: Weight gain';

  @override
  String get morePdfGoalMaintain => 'Goal: Weight maintenance';

  @override
  String get morePdfNoProfile => 'No profile';

  @override
  String get morePdfMealsLast30 => 'Last 30 days – meals';

  @override
  String get morePdfNoMeals => 'No meals';

  @override
  String get morePdfDate => 'Date';

  @override
  String get morePdfName => 'Name';

  @override
  String get morePdfActivitiesLast30 => 'Last 30 days – activities';

  @override
  String get morePdfNoActivities => 'No activities';

  @override
  String get morePdfGarminAttribution =>
      'Activity data comes from Garmin devices.';

  @override
  String get morePdfWeightHistory => 'Weight history';

  @override
  String get morePdfNoMeasurements => 'No measurements';

  @override
  String get morePdfWeightKg => 'Weight (kg)';

  @override
  String get moreNotificationsTitle => 'Notifications';

  @override
  String get moreWaterReminders => 'Water reminders';

  @override
  String get moreMealReminders => 'Meal reminders';

  @override
  String get moreAdd => 'Add';

  @override
  String get moreMealBreakfast => 'Breakfast';

  @override
  String get moreMealLunch => 'Lunch';

  @override
  String get moreMealDinner => 'Dinner';

  @override
  String get moreMealSnack => 'Snack';

  @override
  String get moreMealDefault => 'Meal';

  @override
  String get moreNewMealReminder => 'New meal reminder';

  @override
  String get moreMealNameLabel => 'Meal name';

  @override
  String get moreMealNameHint => 'e.g. Second breakfast, Afternoon snack';

  @override
  String get moreEditReminder => 'Edit reminder';

  @override
  String get moreNotifWaterTitle => 'Remember to drink water! 💧';

  @override
  String get moreNotifWaterBody => 'Time for a glass of water';

  @override
  String get moreNotifWaterChannel => 'Water reminders';

  @override
  String get moreNotifWaterChannelDesc => 'Reminders to drink water';

  @override
  String moreNotifMealTitle({required String label}) {
    return 'Time for $label! 🍽️';
  }

  @override
  String get moreNotifMealBody => 'Don’t forget to log your meal';

  @override
  String get moreNotifMealChannel => 'Meal reminders';

  @override
  String get moreNotifMealChannelDesc => 'Reminders to log meals';

  @override
  String get moreIntegrationsTitle => 'Integrations';

  @override
  String get moreLoginToFinishStrava => 'Sign in to finish connecting Strava';

  @override
  String get moreLoginToFinishGarmin => 'Sign in to finish connecting Garmin';

  @override
  String moreStravaConnectedImported({required int count}) {
    return 'Strava connected. Imported $count activities.';
  }

  @override
  String get moreStravaConnectedNoNew =>
      'Strava connected. No new activities to import.';

  @override
  String get moreStravaConnectedSuccess => 'Strava connected successfully';

  @override
  String get moreStravaSyncFailedLater =>
      'Sync failed. Tap “Sync activities” later.';

  @override
  String get moreGarminSessionExpiredRetry =>
      'Session expired. Try connecting Garmin again.';

  @override
  String moreGarminSessionRejected({required String message}) {
    return 'Session rejected: $message. Sign out, sign back in, and try connecting Garmin.';
  }

  @override
  String get moreGarminSessionExpiredRelogin =>
      'Session expired. Sign out and back into Łatwa Forma, then tap “Connect Garmin Connect”.';

  @override
  String get moreConnectedSuccessfully => 'Connected successfully!';

  @override
  String get moreGarminSessionExpiredShort =>
      'Session expired. Sign out and back in, then connect Garmin.';

  @override
  String moreGarminError({required String error}) {
    return 'Garmin error: $error';
  }

  @override
  String get moreStravaEnvMissing =>
      'Add STRAVA_CLIENT_ID and STRAVA_CLIENT_SECRET to the .env file';

  @override
  String get moreGarminEnvMissing =>
      'Add GARMIN_CLIENT_ID to env (after program approval).';

  @override
  String get moreLoginAgainForGarmin =>
      'Sign in again to complete Garmin data.';

  @override
  String moreCouldNotComplete({required String message}) {
    return 'Could not complete: $message';
  }

  @override
  String get moreGarminNoUserId =>
      'Garmin did not return a User ID. Try disconnecting and connecting again.';

  @override
  String get moreGarminReceiveDataSaved =>
      'Activity receive data saved. New workouts from Garmin Connect will appear in the app.';

  @override
  String moreGarminDisconnectFailed({required String error}) {
    return 'Could not disconnect from Garmin: $error';
  }

  @override
  String get moreGarminDisconnectedTitle => 'Garmin Connect disconnected';

  @override
  String get moreGarminDisconnectedBody =>
      'Your Garmin Connect link was removed. New activities will no longer be added automatically. You can reconnect anytime.';

  @override
  String get moreStravaDisconnected => 'Strava disconnected';

  @override
  String get moreConnectStravaFirst => 'Connect your Strava account first';

  @override
  String moreImportedFromStrava({required int count}) {
    return 'Imported $count activities from Strava';
  }

  @override
  String get moreNoNewActivities => 'No new activities to import';

  @override
  String moreSyncError({required String error}) {
    return 'Sync error: $error';
  }

  @override
  String get moreStravaImportDesc =>
      'Import all activities and calories burned';

  @override
  String get moreConnected => 'Connected';

  @override
  String get moreSyncing => 'Syncing...';

  @override
  String get moreSyncActivities => 'Sync activities';

  @override
  String get moreDisconnectStrava => 'Disconnect Strava';

  @override
  String get moreConnecting => 'Connecting...';

  @override
  String get moreConnectStrava => 'Connect to Strava';

  @override
  String get moreGarminImportDesc =>
      'Garmin activities are added automatically after syncing with Garmin Connect';

  @override
  String get moreGarminAutoImportInfo =>
      'All new activities from Garmin Connect are imported into the app. You decide which ones count toward your balance.';

  @override
  String get moreGarminNeedUserId =>
      'To show Garmin activities in the app, save the connection data (Garmin ID).';

  @override
  String get moreSavingShort => 'Saving...';

  @override
  String get moreCompleteActivityReceiveData =>
      'Complete activity receive data';

  @override
  String get moreDisconnectGarmin => 'Disconnect Garmin';

  @override
  String get moreConnectGarmin => 'Connect Garmin Connect';

  @override
  String moreGarminDisconnectErrorStatus({required String status}) {
    return 'Disconnect error: $status';
  }

  @override
  String moreErrorStatusCode({required String code}) {
    return 'Error $code';
  }

  @override
  String get moreChallengesTitle => 'Goals and challenges';

  @override
  String get moreNoChallenges => 'No goals or challenges';

  @override
  String get moreNoChallengesHint =>
      'Add a goal or challenge to track your progress';

  @override
  String moreProgressPercent({required String percent}) {
    return 'Progress: $percent%';
  }

  @override
  String moreStartDate({required String date}) {
    return 'Start: $date';
  }

  @override
  String moreEndDate({required String date}) {
    return 'End: $date';
  }

  @override
  String get moreDeleteChallengeTitle => 'Delete challenge';

  @override
  String moreDeleteChallengeConfirm({required String title}) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get moreChallengeDeleted => 'Challenge deleted';

  @override
  String get morePickStartDate => 'Pick a start date';

  @override
  String get morePickEndDate => 'Pick an end date';

  @override
  String get morePick => 'Pick';

  @override
  String get moreChallengeAdded => 'Challenge added successfully!';

  @override
  String get moreTargetWeightKg => 'Weight goal (kg)';

  @override
  String get moreCalorieDeficitKcal => 'Calorie deficit (kcal)';

  @override
  String get moreWaterAmountMl => 'Water amount (ml)';

  @override
  String get moreWorkoutCount => 'Number of workouts';

  @override
  String get moreStreakLengthDays => 'Streak length (days)';

  @override
  String get moreTargetValue => 'Target value';

  @override
  String get moreAddChallenge => 'Add challenge';

  @override
  String get moreChallengeType => 'Challenge type';

  @override
  String get moreCalorieDeficit => 'Calorie deficit';

  @override
  String get moreWater => 'Water';

  @override
  String get moreExercise => 'Exercise';

  @override
  String get moreStreak => 'Streak';

  @override
  String get moreChallengeTitleLabel => 'Challenge title';

  @override
  String get moreChallengeTitleHint => 'e.g. Lose 5 kg';

  @override
  String get moreChallengeTitleRequired => 'Enter a challenge title';

  @override
  String get moreDescriptionOptional => 'Description (optional)';

  @override
  String get moreChallengeDescHint => 'Additional challenge details';

  @override
  String get moreOptional => 'Optional';

  @override
  String get moreStartDateLabel => 'Start date';

  @override
  String get moreSetEndDate => 'Set an end date';

  @override
  String get moreEndDateLabel => 'End date';

  @override
  String get morePickDate => 'Pick a date';

  @override
  String get moreStreaksTitle => 'Streaks';

  @override
  String get moreNoStreaks => 'No streaks';

  @override
  String get moreNoStreaksHint => 'Start tracking your habits to see streaks';

  @override
  String moreLastTime({required String date}) {
    return 'Last time: $date';
  }

  @override
  String get moreCurrentStreak => 'Current streak';

  @override
  String get moreLongestStreak => 'Longest streak';

  @override
  String get moreStreakMeals => 'Meals';

  @override
  String get moreStreakActivities => 'Activities';

  @override
  String get moreStreakWeight => 'Weight';

  @override
  String get moreAiAdviceTitle => 'AI advice';

  @override
  String moreAiLimitReachedPremium({required String limit}) {
    return 'You’ve used today’s limit ($limit queries). Try again tomorrow.';
  }

  @override
  String moreAiLimitReachedFree({required String limit}) {
    return 'You’ve used today’s limit ($limit queries). Try again tomorrow or upgrade to Premium.';
  }

  @override
  String get moreAiNeedsConnection =>
      'AI advice requires an app connection (Supabase) or an OpenAI key in the configuration.';

  @override
  String get moreAiNoResponse => 'Could not get a response. Please try again.';

  @override
  String moreAiRemainingToday({
    required String remaining,
    required String limit,
  }) {
    return 'Queries left today: $remaining / $limit';
  }

  @override
  String moreAiRemainingTodayPremium({
    required String remaining,
    required String limit,
  }) {
    return 'Queries left today: $remaining / $limit (Premium)';
  }

  @override
  String get moreAiIntro =>
      'Ask for advice on diet, nutrition, or physical activity. The answer is generated by AI and does not replace advice from a doctor.';

  @override
  String get moreAiHint =>
      'e.g. How much protein do I need for strength training?';

  @override
  String get moreAiAnswer => 'Answer';

  @override
  String get profErrNetwork =>
      'No internet connection. Check your network and try again.';

  @override
  String get profErrCors =>
      'Could not reach the service. Refresh the page and try again.';

  @override
  String get profErrTimeout => 'Request timed out. Please try again.';

  @override
  String get profErrAuth => 'Authorization error. Please sign in again.';

  @override
  String get profErrNotFound => 'Resource not found.';

  @override
  String get profErrServer => 'Server error. Please try again later.';

  @override
  String get profErrGeneric => 'Something went wrong. Please try again.';

  @override
  String get profOfflineBanner => 'No internet connection.';

  @override
  String get premFeatureTitle => 'Premium feature';

  @override
  String premFeatureDialog({required String feature}) {
    return '$feature is available with Premium. Want to learn more?';
  }

  @override
  String get premFeatureThis => 'This feature';

  @override
  String get premSeePremium => 'See Premium';

  @override
  String premLockedTitle({required String feature}) {
    return '$feature is in Premium';
  }

  @override
  String get premLockedBody =>
      'Unlock unlimited AI advice, PDF export, and more.';

  @override
  String get premCheckPremium => 'Check Premium';

  @override
  String get premThanks => 'Thank you!';

  @override
  String get premActivatedBody =>
      'Premium is now active.\nEnjoy full access to Łatwa Forma — PDF export, AI advice, integrations, and more.';

  @override
  String get premBackToApp => 'Back to the app';

  @override
  String get premCloseTabHint =>
      'You can also close this tab if payment opened in a separate window.';

  @override
  String get premPaymentCancelled => 'Payment cancelled';

  @override
  String get premCancelBody =>
      'Nothing was charged. You can go back and choose a plan whenever you\'re ready.';

  @override
  String get premBackToPlans => 'Back to Premium plans';

  @override
  String get premGoToApp => 'Go to the app';

  @override
  String get premTitle => 'Łatwa Forma Premium';

  @override
  String get premHavePremium => 'You have Premium!';

  @override
  String get premUnlockPotential => 'Unlock your full potential';

  @override
  String get premAllFeaturesAvailable =>
      'All premium features are available for you.';

  @override
  String premValidUntil({required String date}) {
    return 'Valid until: $date';
  }

  @override
  String get premTrialTitle => 'Trial period (24 h)';

  @override
  String premTrialLeft({required int hours, required int minutes}) {
    return 'Left: ${hours}h ${minutes}min. ';
  }

  @override
  String premTrialBody({required String remaining}) {
    return 'All premium features are available now. ${remaining}After that, Premium features turn off until you purchase a plan. The trial does not charge you and does not auto-enroll you in a subscription.';
  }

  @override
  String get premFeatHistoryOtherDays =>
      'Browse history for days other than today';

  @override
  String get premFeatMacrosDash => 'Macro breakdown on the dashboard';

  @override
  String get premFeatAiAdvice => 'AI advice (100/day limit)';

  @override
  String get premFeatAiPhoto => 'AI meal analysis from a photo';

  @override
  String get premFeatIngredients => 'Add a meal from ingredients';

  @override
  String get premFeatEatingOut => 'Add an eating-out meal';

  @override
  String get premFeatQuickActivity => 'Quick add in activities';

  @override
  String get premFeatShare => 'Share summary and weekly stats';

  @override
  String get premFeatPdf => 'Export reports to PDF';

  @override
  String get premFeatCustomCalories => 'Custom calorie goal in profile edit';

  @override
  String get premFeatCustomMacros => 'Custom macros in profile edit';

  @override
  String get premFeatStrava => 'Unlimited Strava integrations';

  @override
  String get premFeatGoals => 'Advanced goals and challenges';

  @override
  String get premChoosePlan => 'Choose a plan';

  @override
  String get premPlanMonthly => 'Łatwa Forma Premium – monthly';

  @override
  String get premPlanMonthlyPeriod => '1 month, auto-renewing';

  @override
  String get premPlanYearly => 'Łatwa Forma Premium – yearly';

  @override
  String get premPlanYearlyPeriod => '12 months, auto-renewing';

  @override
  String get premBadgeSave => 'Save ~17%';

  @override
  String get premPlanYearlyOnce => 'Yearly (one-time)';

  @override
  String get premPlanYearlyOncePeriod => 'per year';

  @override
  String get premBadgeBlik => 'BLIK only';

  @override
  String get premYearlyOnceSubtitle => 'pay once a year, no subscription';

  @override
  String get premHaveCode => 'I have a code';

  @override
  String get premCodeLabel => 'Code';

  @override
  String get premRedeemTooltip => 'Redeem';

  @override
  String get premOpeningPayment => 'Opening payment…';

  @override
  String get premProcessingPurchase => 'Processing purchase…';

  @override
  String get premBuy => 'Get Premium';

  @override
  String get premRestoring => 'Restoring…';

  @override
  String get premRestorePurchases => 'Restore purchases';

  @override
  String get premPaymentNoteWeb =>
      'Yearly (one-time) – BLIK only. Subscription – card, Apple Pay, Google Pay. Subscription renews automatically until you cancel.';

  @override
  String get premPaymentNoteMobile =>
      'Payment via App Store / Google Play. “Łatwa Forma Premium – monthly” (1 month) and “Łatwa Forma Premium – yearly” (12 months) renew automatically at the price shown above until you cancel in store settings. BLIK is on latwaforma.pl. Basic features work without a subscription.';

  @override
  String get premAutoActivate =>
      'After payment, Premium activates automatically.';

  @override
  String get premPrivacy => 'Privacy policy';

  @override
  String get premTerms => 'Terms of service';

  @override
  String get premEula => 'Terms of Use (EULA)';

  @override
  String get premActivating => 'Activating…';

  @override
  String get premActivateTest => 'Activate Premium (test)';

  @override
  String get premAvailableFeatures => 'Available features:';

  @override
  String get premFeatActiveHistory => 'History of other days';

  @override
  String get premFeatActiveMacros => 'Macros on dashboard';

  @override
  String get premFeatActiveAiPhoto => 'AI meal analysis';

  @override
  String get premFeatActiveIngredients => 'Meal from ingredients';

  @override
  String get premFeatActiveEatingOut => 'Eating-out meal';

  @override
  String get premFeatActiveQuickActivity => 'Quick activity add';

  @override
  String get premFeatActiveShare => 'Share summary and stats';

  @override
  String get premFeatActivePdf => 'Export to PDF';

  @override
  String get premFeatActiveCalories => 'Custom calorie goal';

  @override
  String get premFeatActiveMacrosCustom => 'Custom macros';

  @override
  String get premFeatActiveStrava => 'Strava integrations';

  @override
  String get premFeatActiveGoals => 'Advanced goals';

  @override
  String get premOpening => 'Opening…';

  @override
  String get premCancelSub => 'Cancel subscription';

  @override
  String get premManageSub => 'Manage subscription';

  @override
  String get premCancelNoteWeb =>
      'You can cancel the subscription. Premium access remains until the end of the paid period.';

  @override
  String get premCancelNoteMobile =>
      'Cancel in App Store / Google Play settings. Premium access until the end of the paid period.';

  @override
  String get premEnterEmail => 'Enter an email address.';

  @override
  String get premCodeSent => 'Code sent';

  @override
  String premCodeSentBody({required String email}) {
    return 'We sent a link and code to $email. Check your inbox (and Spam) — tap the link in the email or enter the code below.';
  }

  @override
  String get premSignedIn => 'Signed in';

  @override
  String get premSignedInBuy => 'You can now purchase Premium.';

  @override
  String get premAccountExistsTitle =>
      'An account with this email already exists.';

  @override
  String get premAccountExistsBody =>
      'You\'re signing in to an account linked to this email. This device has different data (profile, meals, etc.).\n\nWhat do you want to do?\n\n• Update that account – with the current data from this device (profile and meals will be moved).\n\n• Restore account data – you\'ll see data linked to the email account (current device data won\'t be used).\n\nIn both cases you must verify your identity — tap the link in the email or enter the verification code.';

  @override
  String get premRestoreAccountData => 'Restore account data';

  @override
  String get premUpdateWithCurrent => 'Update account with this data';

  @override
  String get premConfirmIdentity => 'Confirm identity';

  @override
  String premVerifyEmailSent({required String email}) {
    return 'We sent a message to $email. You can tap the verification link in the email or enter the code below (check Spam too).';
  }

  @override
  String get premVerificationCode => 'Verification code';

  @override
  String get premCodeHint => 'e.g. 123456';

  @override
  String get premEnterFullCode =>
      'Enter the full code from the email (min. 6 characters).';

  @override
  String premLoggedInMergeError({required String error}) {
    return 'Signed in. Data transfer error: $error';
  }

  @override
  String get premVerifyErrorTitle => 'Verification error';

  @override
  String get premVerifyErrorBody =>
      'The code expired or is invalid. Send it again.';

  @override
  String get premConfirm => 'Confirm';

  @override
  String get premConnErrorTitle => 'Connection error';

  @override
  String get premConnErrorBody =>
      'Could not connect to payments. Try again shortly or email us: contact@latwaforma.pl';

  @override
  String get premLoginToBuy =>
      'To buy Premium, sign in (Apple, Google, or email with the code above).';

  @override
  String get premCodeNotForOnce =>
      'This code does not work with one-time payment.';

  @override
  String get premTryLaterContact =>
      'Try again shortly or email us: contact@latwaforma.pl';

  @override
  String get premOpenPaymentFailed => 'Could not open payment';

  @override
  String get premCannotOpenPaymentPage => 'Could not open the payment page.';

  @override
  String get premCheckoutSessionError =>
      'Could not create the payment session.';

  @override
  String get premTryLaterContactShort =>
      'Try again shortly or email us: contact@latwaforma.pl';

  @override
  String get premLoginToUseCode =>
      'To use a code, sign in (Apple, Google, or email).';

  @override
  String get premCodeSheetFailed =>
      'Could not open the code entry sheet. Please try again.';

  @override
  String get premEnterCode => 'Enter a code.';

  @override
  String get premPlayStoreFailed => 'Could not open the Play Store.';

  @override
  String get premLoginToBuyMobile =>
      'To buy Premium, sign in (Google, Apple, or email with the code above).';

  @override
  String get premThanksActive =>
      'Thank you! Premium should now be active. If features are still locked, wait a moment or reopen the app.';

  @override
  String get premPurchasePending =>
      'Purchase finished. Premium status will refresh shortly. If not — use “Restore purchases”.';

  @override
  String get premInfo => 'Info';

  @override
  String get premPurchaseErrorTitle => 'Purchase error';

  @override
  String premPurchaseErrorBody({required String error}) {
    return 'Could not complete the purchase. Check your connection and store setup, or email: contact@latwaforma.pl\n\n$error';
  }

  @override
  String get premLoginToRestore => 'Sign in to restore purchases.';

  @override
  String get premRestoredTitle => 'Purchases restored';

  @override
  String get premNoPurchasesTitle => 'No active purchases';

  @override
  String get premRestoredBody =>
      'Your Premium has been restored. If you don\'t see unlocks yet, wait a moment.';

  @override
  String get premNoPurchasesBody =>
      'No active subscription was found for this store account.';

  @override
  String premRestoreFailed({required String error}) {
    return 'Could not restore purchases: $error';
  }

  @override
  String get premSubscription => 'Subscription';

  @override
  String get premManageHint =>
      'Open subscription settings in the Apple / Google store to cancel or manage Premium.';

  @override
  String get premSessionExpired => 'Session expired';

  @override
  String get premLoginAgain => 'Please sign in again.';

  @override
  String get premPortalHintWeb =>
      'Refresh the page (F5) and try again. If it keeps happening, sign out and sign back in.';

  @override
  String get premPortalHintMobile =>
      'Sign out in Profile and sign back in, then try “Cancel subscription” again.';

  @override
  String get premCannotOpenPortal => 'Could not open the portal.';

  @override
  String get premPortalOpenError => 'Could not open the portal.';

  @override
  String get premSessionExpiredCancel =>
      'Session expired. Sign out in Profile and sign back in, then try “Cancel subscription” again.';

  @override
  String premErrorWithDetail({required String error}) {
    return 'Error: $error';
  }

  @override
  String get premActivatedEnjoy => 'Premium activated. Enjoy full access!';

  @override
  String get premLoginToBuyCard =>
      'To buy Premium you need an account. Sign in with Google, Apple, or enter your email — we\'ll send a verification link and code.';

  @override
  String get premSigningIn => 'Signing in…';

  @override
  String get premContinueGoogle => 'Continue with Google';

  @override
  String get premContinueApple => 'Continue with Apple';

  @override
  String get premOrEmail => 'or email:';

  @override
  String get premEmailLabel => 'Email address';

  @override
  String get premEmailHint => 'e.g. jane@example.com';

  @override
  String get premSending => 'Sending…';

  @override
  String get premSendCode => 'Send code';

  @override
  String get premConfirmIdentityHint =>
      'Confirm identity: enter the code from the email below or tap the verification link in the message (check Spam too).';

  @override
  String get premChecking => 'Checking…';

  @override
  String get premConfirmAndSignIn => 'Confirm and sign in';

  @override
  String get premResendOtherEmail => 'Send code again to another address';

  @override
  String get profTitle => 'Profile';

  @override
  String get profNotifications => 'Notifications';

  @override
  String get profNoProfile => 'No profile';

  @override
  String profErrorWithDetail({required String error}) {
    return 'Error: $error';
  }

  @override
  String get profAccountGoogle => 'Google account';

  @override
  String get profAccountEmail => 'Email account';

  @override
  String get profAccountSignedIn => 'Signed-in account';

  @override
  String get profSignOutTitle => 'Sign out';

  @override
  String get profSignOutBody =>
      'Are you sure you want to sign out? You can sign in again later.';

  @override
  String get profSignOutConfirm => 'Sign out';

  @override
  String get profDeleteAccountTitle => 'Delete account';

  @override
  String get profDeleteAccountBody =>
      'Your data will be permanently deleted and cannot be restored. When you return to the app, you\'ll need to set up your profile again.\n\nIf you have a Premium subscription in Google Play or the App Store, cancel it separately in the store — deleting the account does not end it.\n\nAre you sure you want to delete your account?';

  @override
  String get profAccountDeleted => 'Account deleted';

  @override
  String profDeleteUnavailable({required String email}) {
    return 'Account deletion is unavailable. Contact us: $email';
  }

  @override
  String get profSessionExpiredRetry =>
      'Session expired. Sign in again and try once more.';

  @override
  String get profNoPermission => 'You don\'t have permission to do this.';

  @override
  String get profDeleteFailed =>
      'Could not delete the account. Please try again later.';

  @override
  String get profInviteTitle => 'Invite a friend';

  @override
  String get profInviteBody =>
      'Enter the email of the person you want to invite to Łatwa Forma.';

  @override
  String get profEmailLabel => 'Email address';

  @override
  String get profEmailHintFriend => 'e.g. friend@example.com';

  @override
  String get profSessionExpiredWebInvite =>
      'Session expired. Refresh the page (F5), sign in again, then send the invite.';

  @override
  String get profLoginAgainRetry => 'Sign in again and try once more.';

  @override
  String get profInviteSent => 'Invitation sent';

  @override
  String get profSessionExpiredWebRetry =>
      'Session expired. Refresh the page (F5) and try again. If it keeps happening, sign out and sign back in.';

  @override
  String get profSessionExpiredInviteMobile =>
      'Session expired. Sign out and sign back in, then send the invite.';

  @override
  String get profInviteAlreadySent =>
      'An invitation was already sent to this address. Check the inbox (including spam) or use another address.';

  @override
  String get profEmailAlreadyRegistered =>
      'This email is already registered in Łatwa Forma. Invite someone else.';

  @override
  String get profInviteRateLimit =>
      'Too many invitations. Wait a moment and try again.';

  @override
  String get profEnterValidEmail => 'Enter a valid email address.';

  @override
  String get profInviteSendFailed =>
      'Could not send the invitation. Please try again.';

  @override
  String get profSessionExpiredWebShort =>
      'Session expired. Refresh the page (F5) and try again.';

  @override
  String get profSessionExpiredSignOutIn =>
      'Session expired. Sign out and sign back in.';

  @override
  String get profSendInvite => 'Send invitation';

  @override
  String get profInviteSentExclaim => 'Invitation sent!';

  @override
  String get profSaveProgress => 'Save progress';

  @override
  String get profSaveProgressHint =>
      'Sign in with Apple, Google, or email so you don\'t lose your data';

  @override
  String get profBasicData => 'Basic info';

  @override
  String get profGender => 'Gender';

  @override
  String get profAge => 'Age';

  @override
  String profAgeYears({required int age}) {
    return '$age years';
  }

  @override
  String get profHeight => 'Height';

  @override
  String get profCurrentWeight => 'Current weight';

  @override
  String get profTargetWeight => 'Target weight';

  @override
  String get profActivityLevel => 'Activity level';

  @override
  String get profGoal => 'Goal';

  @override
  String get profCalculations => 'Calculations';

  @override
  String get profBmrExplain =>
      'Resting calorie needs — how many calories you burn with no activity.';

  @override
  String get profTdeeExplain =>
      'Total daily energy expenditure — calories burned in a day including activity.';

  @override
  String get profCalorieGoalExplain =>
      'Recommended daily calorie intake to reach your weight goal.';

  @override
  String get profWaterGoal => 'Water goal';

  @override
  String profWaterGoalExplanation({
    required int mlPerKg,
    required String weightKg,
    required int rawMl,
    required int goalMl,
  }) {
    return 'Calculated from your weight: $mlPerKg ml per kg ($weightKg kg → about $rawMl ml, rounded to $goalMl ml). You can change the goal manually.';
  }

  @override
  String get profMacros => 'Macros';

  @override
  String get profProtein => 'Protein';

  @override
  String get profFat => 'Fat';

  @override
  String get profCarbs => 'Carbs';

  @override
  String get profCarbsShort => 'Carbs';

  @override
  String get profTargetDateTitle => 'Target date:';

  @override
  String get profTargetDateHint =>
      'Stick to the plan and this day won\'t slip.';

  @override
  String get profSpeedUpHint =>
      'Want to reach your goal sooner? Edit the weight-change rate in profile edit mode (pencil icon at the top).';

  @override
  String get profMaintainNoDateTitle => 'Goal: maintain weight';

  @override
  String get profMaintainNoDateBody =>
      'With a maintain-weight goal there is no separate \"reach by\" date. Change your goal to lose or gain (and set a target weight) — then I\'ll estimate when you\'ll get there.';

  @override
  String get profMaintainNoDateCta => 'Edit goal in profile';

  @override
  String get profAiAdvice => 'AI advice';

  @override
  String get profAiAdviceHint => 'Ask about diet, nutrition, and activity';

  @override
  String get profBmiTitle => 'BMI calculator';

  @override
  String get profBmiHint => 'Check your body mass index';

  @override
  String profTrialLeft({required int hours, required int minutes}) {
    return 'Left: ${hours}h ${minutes}min';
  }

  @override
  String get profPremiumTitleActive => 'Łatwa Forma Premium';

  @override
  String get profPremiumTitle => 'Premium subscription';

  @override
  String get profActive => 'Active';

  @override
  String get profPremiumHintActive => 'Unlimited AI, PDF export, integrations';

  @override
  String get profPremiumHint => 'Unlock full potential — AI, PDF, integrations';

  @override
  String get profIntegrations => 'Integrations';

  @override
  String get profIntegrationsHint =>
      'Strava — import activities and calories burned';

  @override
  String get profExport => 'Data export';

  @override
  String get profExportHint => 'Export your data to CSV';

  @override
  String get profInviteHint => 'Send an email invite to the Łatwa Forma app';

  @override
  String get profPrivacy => 'Privacy policy';

  @override
  String get profTerms => 'Terms of service';

  @override
  String get profEula => 'Terms of Use (EULA)';

  @override
  String get profDeleteAccountPage => 'Delete account (web)';

  @override
  String get profYourAccount => 'Your account';

  @override
  String get profDeviceData => 'Data on this device';

  @override
  String get profDeviceDataHint =>
      'You\'re using the app without an account. You can delete the saved profile and meals from this device.';

  @override
  String get profDeleteData => 'Delete data';

  @override
  String get profDeleteDataBody =>
      'Your profile, meals and other data on this device will be permanently deleted. This cannot be undone.\n\nAre you sure you want to delete the data?';

  @override
  String get profDataDeleted => 'Device data has been deleted.';

  @override
  String get profGenderMale => 'Male';

  @override
  String get profGenderFemale => 'Female';

  @override
  String get profGenderOther => 'Other';

  @override
  String get profActSedentary => 'Sedentary';

  @override
  String get profActLight => 'Light';

  @override
  String get profActModerate => 'Moderate';

  @override
  String get profActIntense => 'Intense';

  @override
  String get profActVeryIntense => 'Very intense';

  @override
  String get profGoalLoss => 'Weight loss';

  @override
  String get profGoalGain => 'Weight gain';

  @override
  String get profGoalMaintain => 'Maintain weight';

  @override
  String get profGenderRequired => 'Gender *';

  @override
  String get profAgeRequired => 'Age *';

  @override
  String get profYearsSuffix => 'yrs';

  @override
  String get profHeightRequired => 'Height (cm) *';

  @override
  String get profCurrentWeightRequired => 'Current weight (kg) *';

  @override
  String get profTargetWeightRequired => 'Target weight (kg) *';

  @override
  String get profWeightDiffError =>
      'The difference between weights must be at least 1 kg';

  @override
  String get profActivityRequired => 'Activity level *';

  @override
  String get profActSedentaryDesc => 'No activity or minimal';

  @override
  String get profActLightDesc => '1–3 workouts / week';

  @override
  String get profActModerateDesc => '3–5 workouts / week';

  @override
  String get profActIntenseDesc => '6–7 workouts / week';

  @override
  String get profActVeryIntenseDesc => '2× daily / hard physical work';

  @override
  String get profWaterGoalMl => 'Water goal (ml)';

  @override
  String get profWaterGoalHelper =>
      'You can change it manually. Below is how the suggestion is calculated.';

  @override
  String get profSaveChanges => 'Save changes';

  @override
  String get profWantLose => 'I want to lose weight.';

  @override
  String get profWantGain => 'I want to gain weight.';

  @override
  String get profWantMaintain => 'I want to maintain my current weight.';

  @override
  String get profAdjustPlan => 'Adjust plan';

  @override
  String get profPlanPremiumOnly =>
      'Custom calorie goal and macros are available with Premium.';

  @override
  String get profSeePremium => 'See Premium';

  @override
  String get profWeightRate => 'Weight change rate';

  @override
  String profRateKgWeek({required String rate}) {
    return '$rate kg/week';
  }

  @override
  String get profRateZero => '0 kg/week';

  @override
  String get profMaintainRateZero => 'For weight maintenance the rate is 0';

  @override
  String get profRecommendedRate =>
      'Recommended rate: 0.5 kg/week — safe and healthy. Faster loss can be unhealthy (muscle loss, deficiencies, fatigue).';

  @override
  String profEstTargetDate({required String date}) {
    return 'Estimated target date: $date';
  }

  @override
  String get profMoveSlider => 'Move the slider to see the plan';

  @override
  String get profCustomCalorieGoal => 'Custom calorie goal';

  @override
  String get profGoalKcal => 'Goal (kcal)';

  @override
  String get profLeaveEmptyFromRate =>
      'Leave empty to calculate from the rate.';

  @override
  String get profCustomMacros => 'Custom macros';

  @override
  String get profMacrosAutoRecalc =>
      'Calories and date will recalculate automatically.';

  @override
  String profMacroSum({required String kcal}) {
    return 'Total: $kcal kcal';
  }

  @override
  String profMacroPerGram({required int kcal}) {
    return '1g = $kcal kcal';
  }

  @override
  String get profValuesNotNegative => 'Values cannot be negative.';

  @override
  String profMacroMaxProtein({required String g}) {
    return 'protein max $g g';
  }

  @override
  String profMacroMaxFat({required String g}) {
    return 'fat max $g g';
  }

  @override
  String profMacroMaxCarbs({required String g}) {
    return 'carbs max $g g';
  }

  @override
  String profMacroOverLimit({required String parts}) {
    return '⚠️ Values exceed recommended daily limits: $parts. Enter realistic values for a healthy diet.';
  }

  @override
  String profMacroCaloriesUnreal({
    required String calories,
    required String max,
  }) {
    return '⚠️ Total calories ($calories kcal) are unrealistic for daily needs. Recommended max is about $max kcal/day.';
  }

  @override
  String profMacroLossSurplus({required String surplus, required String tdee}) {
    return 'Your goal is weight loss (target below current), but the macros give $surplus kcal above needs (TDEE: $tdee kcal). Lower calories/macros to create a deficit.';
  }

  @override
  String profMacroGainDeficit({required String tdee}) {
    return 'Your goal is weight gain (target above current), but the macros create a deficit (TDEE: $tdee kcal). Increase calories/macros to create a surplus.';
  }

  @override
  String profWarnCalAboveTdeeLoss({required String tdee}) {
    return '⚠️ Calorie goal is above TDEE ($tdee kcal). To lose weight you need a calorie deficit. Max safe deficit is ~1100 kcal/day (about 1 kg/week).';
  }

  @override
  String profWarnDeficitHuge({required String deficit}) {
    return '⚠️ Calorie deficit is very large ($deficit kcal/day). Recommended max deficit is 1000–1500 kcal/day for safe weight loss.';
  }

  @override
  String get profWarnDeficitTiny =>
      '⚠️ Calorie deficit is very small. For effective weight loss, a 500–1000 kcal/day deficit is recommended.';

  @override
  String profWarnCalBelowTdeeGain({required String tdee}) {
    return '⚠️ Calorie goal is below TDEE ($tdee kcal). To gain weight you need a calorie surplus. Recommended surplus is 250–500 kcal/day (about 0.25–0.5 kg/week).';
  }

  @override
  String profWarnSurplusHuge({required String surplus}) {
    return '⚠️ Calorie surplus is very large ($surplus kcal/day). Recommended surplus is 250–500 kcal/day for healthy weight gain.';
  }

  @override
  String get profWarnSurplusTiny =>
      '⚠️ Calorie surplus is very small. For effective weight gain, a 250–500 kcal/day surplus is recommended.';

  @override
  String profWarnMaintainFar({required String tdee}) {
    return '⚠️ Calorie goal differs a lot from TDEE ($tdee kcal). For maintenance it should be close to TDEE (±100–200 kcal).';
  }

  @override
  String profCannotSaveLoss({required String calories, required String tdee}) {
    return 'Cannot save: Calorie goal ($calories kcal) is above TDEE ($tdee kcal). To lose weight you need a calorie deficit.';
  }

  @override
  String profCannotSaveGain({required String calories, required String tdee}) {
    return 'Cannot save: Calorie goal ($calories kcal) is below TDEE ($tdee kcal). To gain weight you need a calorie surplus.';
  }

  @override
  String get profUserNotLoggedIn => 'User is not signed in';

  @override
  String get profGoalHistoryEdit => 'Profile edit';

  @override
  String get profUpdatedSuccess =>
      'Profile updated successfully! Your goal was recalculated.';

  @override
  String profSaveError({required String error}) {
    return 'Error while saving: $error';
  }

  @override
  String get profCalorieGoal => 'Calorie goal';

  @override
  String get trackPremium => 'Premium';

  @override
  String get trackStatistics => 'Statistics';

  @override
  String get trackGoalsAndChallenges => 'Goals & challenges';

  @override
  String get trackProfile => 'Profile';

  @override
  String get trackSessionExpired => 'Session expired. Please sign in again.';

  @override
  String get trackLoadDataFailed =>
      'Couldn\'t load data. Check your internet connection and tap “Try again”.';

  @override
  String trackErrorWithDetails({required String error}) {
    return 'Error: $error';
  }

  @override
  String get trackSignIn => 'Sign in';

  @override
  String get trackFeatureEatingOut => 'Eating out meal';

  @override
  String trackShareCaloriesText({required String date}) {
    return '📊 Łatwa Forma – Calories $date';
  }

  @override
  String trackShareError({required String error}) {
    return 'Sharing error: $error';
  }

  @override
  String get trackCaloriesOverview => 'Calorie overview';

  @override
  String get trackSelectDate => 'Select date';

  @override
  String get trackShare => 'Share';

  @override
  String get trackFeatureShareSummary => 'Share summary';

  @override
  String get trackEarlierWeek => 'Previous week';

  @override
  String get trackFeatureBrowseHistory => 'Browse other days\' history';

  @override
  String get trackLaterWeek => 'Next week';

  @override
  String trackShowingDataFrom({required String date}) {
    return 'Showing data from $date';
  }

  @override
  String get trackConsumed => 'Consumed';

  @override
  String get trackTodayTarget => 'Today\'s goal';

  @override
  String trackSurplusKcal({required String kcal}) {
    return 'Surplus: $kcal kcal';
  }

  @override
  String get trackProtein => 'Protein';

  @override
  String get trackFat => 'Fat';

  @override
  String get trackCarbs => 'Carbs';

  @override
  String get trackCarbsShort => 'Carbs';

  @override
  String get trackIncludingSaturated => 'incl. saturated';

  @override
  String get trackIncludingSugars => 'incl. sugars';

  @override
  String get trackFiber => 'fiber';

  @override
  String get trackFiberLabel => 'Fiber';

  @override
  String get trackSalt => 'Salt';

  @override
  String get trackFeatureAiMealAnalysis => 'AI meal analysis';

  @override
  String get trackAiPhotoAnalysisTooltip => 'AI photo analysis';

  @override
  String get trackNoResults => 'No results';

  @override
  String get trackWater => 'Water';

  @override
  String get trackWaterMotivation => 'You\'re not a camel — drink up! 💧';

  @override
  String get trackActivitiesToday => 'Activities today';

  @override
  String trackActivitiesOnDate({required String date}) {
    return 'Activities – $date';
  }

  @override
  String get trackNoActivities => 'No activities';

  @override
  String trackAndMoreCount({required String count}) {
    return '... and $count more';
  }

  @override
  String get trackMealsToday => 'Meals today';

  @override
  String trackMealsOnDate({required String date}) {
    return 'Meals – $date';
  }

  @override
  String get trackNoMeals => 'No meals';

  @override
  String get trackDayMon => 'Mon';

  @override
  String get trackDayTue => 'Tue';

  @override
  String get trackDayWed => 'Wed';

  @override
  String get trackDayThu => 'Thu';

  @override
  String get trackDayFri => 'Fri';

  @override
  String get trackDaySat => 'Sat';

  @override
  String get trackDaySun => 'Sun';

  @override
  String get trackAdd => 'Add';

  @override
  String get trackMeal => 'Meal';

  @override
  String get trackEatingOut => 'Eating out';

  @override
  String get trackActivity => 'Activity';

  @override
  String get trackWeight => 'Weight';

  @override
  String get trackMeasurements => 'Measurements';

  @override
  String get trackFavorites => 'Favorites';

  @override
  String get trackUserNotLoggedIn => 'User is not signed in';

  @override
  String get trackMealSavedAndFavorited => 'Meal saved and added to favorites!';

  @override
  String get trackMealAddedSuccess => 'Meal added successfully!';

  @override
  String get trackFeatureIngredientsMeal => 'Meal from ingredients';

  @override
  String get trackOptionEatingOut => 'Eating out';

  @override
  String get trackOptionAiAnalysis => 'AI analysis';

  @override
  String get trackOptionIngredients => 'Ingredients';

  @override
  String get trackOptionBarcode => 'Barcode';

  @override
  String get trackOptionSearchProduct => 'Search product';

  @override
  String get trackOptionFavorites => 'Favorites';

  @override
  String get trackEditMeal => 'Edit meal';

  @override
  String get trackAddMeal => 'Add meal';

  @override
  String get trackMealNameOptional => 'Meal name (optional)';

  @override
  String get trackHintEmptyDefaultName => 'Leave empty = \"Untitled\"';

  @override
  String get trackDefaultMealName => 'Untitled';

  @override
  String get trackHintCaloriesFromMacros =>
      'Leave empty = calculated from macros';

  @override
  String get trackEnterCaloriesOrMacros =>
      'Enter calories or fill in the macros';

  @override
  String get trackProteinG => 'Protein (g)';

  @override
  String get trackFatG => 'Fat (g)';

  @override
  String get trackCarbsG => 'Carbs (g)';

  @override
  String get trackFiberG => 'Fiber (g)';

  @override
  String get trackSaltG => 'Salt (g)';

  @override
  String get trackMealTypeOptional => 'Meal type – optional';

  @override
  String get trackBreakfast => 'Breakfast';

  @override
  String get trackLunch => 'Lunch';

  @override
  String get trackDinner => 'Dinner';

  @override
  String get trackSnack => 'Snack';

  @override
  String get trackAddToFavorites => 'Add to favorites';

  @override
  String get trackAddToFavoritesMealSubtitle =>
      'You can quickly add this meal later';

  @override
  String get trackUpdateMeal => 'Update meal';

  @override
  String get trackSaveMeal => 'Save meal';

  @override
  String get trackCalories => 'Calories';

  @override
  String get trackCameraUnavailableTitle => 'Camera unavailable';

  @override
  String get trackCameraUnavailableBody =>
      'The camera is not available on this device (e.g. on a simulator).\n\nUse “From gallery” to pick a photo from your gallery.';

  @override
  String get trackFromGallery => 'From gallery';

  @override
  String trackPickImageError({required String error}) {
    return 'Error picking image: $error';
  }

  @override
  String get trackAnalysisFailedOpenAi =>
      'Couldn\'t analyze the photo. Check that the OpenAI API key is set.';

  @override
  String trackAnalysisError({required String error}) {
    return 'Analysis error: $error';
  }

  @override
  String get trackAiPhotoTitle => 'AI photo analysis';

  @override
  String get trackTakeMealPhoto => 'Take a meal photo';

  @override
  String get trackAiPhotoDescription =>
      'AI will analyze the photo and estimate nutrition. The image is sent to the AI provider (OpenAI) only for this purpose – we do not save a photo gallery. Estimates are approximate and are not medical advice.';

  @override
  String get trackSimulatorCameraHint =>
      'The camera doesn\'t work on a simulator – pick a photo from the gallery.';

  @override
  String get trackTakePhoto => 'Take photo';

  @override
  String get trackAnalyzingPhoto => 'Analyzing photo...';

  @override
  String get trackMayTakeAMoment => 'This may take a moment';

  @override
  String trackProductNotFound({required String code}) {
    return 'No product with code $code was found in the product database.';
  }

  @override
  String trackFetchProductFailed({required String error}) {
    return 'Couldn\'t fetch product data: $error';
  }

  @override
  String get trackBarcodeScannerTitle => 'Barcode scanner';

  @override
  String get trackSimulatorEnterCode =>
      'On a simulator, enter the code manually';

  @override
  String get trackEnterProductCode => 'Enter product code';

  @override
  String get trackSearchProduct => 'Search product';

  @override
  String get trackScannerUnavailable =>
      'Scanner unavailable – use the simulator or a physical device';

  @override
  String get trackPointAtBarcode => 'Point at the product barcode';

  @override
  String get trackBarcodePrivacy =>
      'Data will be fetched from the product database. The camera is only used to read the code – we do not save or send photos.';

  @override
  String get trackScanBarcode => 'Scan barcode';

  @override
  String get trackAddProduct => 'Add product';

  @override
  String get trackEnterProductWeight => 'Enter the product weight';

  @override
  String get trackNutritionPer100g => 'Nutrition (per 100g):';

  @override
  String get trackWeightHintExample => 'e.g. 75.5';

  @override
  String get trackWeightHelper => 'How many grams are you eating?';

  @override
  String get trackEditBeforeSave => 'Edit before saving';

  @override
  String trackPer100g({required String label}) {
    return '$label/100g';
  }

  @override
  String get trackWeightG => 'Weight (g)';

  @override
  String get trackSearchProductTitle => 'Search product';

  @override
  String get trackSearchProductHint => 'Product name, e.g. milk, nutella…';

  @override
  String get trackEnterProductName => 'Enter a product name';

  @override
  String get trackSearchProductSubtitle =>
      'We use the Open Food Facts database. Results appear after you type a few letters.';

  @override
  String get trackNoResultsTryBarcode =>
      'Try another name or scan the product barcode.';

  @override
  String get trackBackToDashboard => 'Back to dashboard';

  @override
  String trackMealsDateTitle({required String date}) {
    return 'Meals - $date';
  }

  @override
  String get trackFavoriteMealsTooltip => 'Favorite meals';

  @override
  String get trackNoMealsForDay => 'No meals for this day';

  @override
  String get trackUsePlusToAddMeal => 'Use the + button to add a meal';

  @override
  String get trackDeleteMealTitle => 'Delete meal';

  @override
  String trackDeleteMealConfirm({required String name}) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get trackMealDeleted => 'Meal deleted';

  @override
  String get trackAddAtLeastOneIngredient => 'Add at least one ingredient';

  @override
  String get trackMealFromIngredientsTitle => 'Meal from ingredients';

  @override
  String trackTotalWeightG({required String weight}) {
    return 'Total weight: $weight g';
  }

  @override
  String trackIngredientsCount({required String count}) {
    return 'Ingredients ($count)';
  }

  @override
  String get trackAddIngredient => 'Add ingredient';

  @override
  String get trackNoIngredients => 'No ingredients';

  @override
  String get trackAddIngredientsHint => 'Add ingredients to build a meal';

  @override
  String get trackEditIngredient => 'Edit ingredient';

  @override
  String get trackIngredientNameOptional => 'Ingredient name (optional)';

  @override
  String get trackAmountG => 'Amount (g)';

  @override
  String get trackEnterAmount => 'Enter an amount';

  @override
  String get trackEnterValidAmount => 'Enter a valid amount';

  @override
  String get trackEnterCaloriesOrFillMacros =>
      'Enter calories or fill in the macros';

  @override
  String get trackProteinPer100g => 'Protein (g/100g)';

  @override
  String get trackFatPer100g => 'Fat (g/100g)';

  @override
  String get trackCarbsPer100g => 'Carbs (g/100g)';

  @override
  String get trackEatingOutTitle => '🍽️ Eating out';

  @override
  String get trackEatingOutSubtitle =>
      'Choose what you ate (calorie estimates):';

  @override
  String trackPortionLabel({required String label}) {
    return 'Portion: $label';
  }

  @override
  String trackSlicesCount({required String count}) {
    return 'Number of slices: $count';
  }

  @override
  String trackSlicesUnit({required String count}) {
    return '$count pcs';
  }

  @override
  String get trackKcalPerSlice => 'kcal per slice:';

  @override
  String trackKcalPerPieceLabel({required String kcal}) {
    return '$kcal kcal/pc';
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
  String get trackSaving => 'Saving…';

  @override
  String get trackAddToDiary => 'Add to diary';

  @override
  String get trackSelectMealAbove => 'Select a meal above';

  @override
  String get trackEatingOutTip =>
      'If the rest of your day was light — that\'s OK. Don\'t stress.';

  @override
  String trackMealNameEatingOutSlices({
    required String name,
    required String slices,
  }) {
    return '$name ($slices pcs) (eating out)';
  }

  @override
  String trackMealNameEatingOut({required String name}) {
    return '$name (eating out)';
  }

  @override
  String trackAddedEatingOut({
    required String name,
    required String slicesPart,
    required String kcal,
  }) {
    return 'Added: $name$slicesPart (~$kcal kcal)';
  }

  @override
  String trackSlicesPart({required String slices}) {
    return ' ($slices pcs)';
  }

  @override
  String get trackEatingOutPizza => 'Pizza';

  @override
  String get trackEatingOutPizzaLabel => '~250–450 kcal / slice';

  @override
  String get trackEatingOutKebab => 'Kebab';

  @override
  String get trackEatingOutKebabLabel => '~600–900 kcal';

  @override
  String get trackEatingOutBurger => 'Burger (general)';

  @override
  String get trackEatingOutBurgerLabel => '~500–800 kcal';

  @override
  String get trackEatingOutChinese => 'Chinese takeout';

  @override
  String get trackEatingOutChineseLabel => '~500–900 kcal';

  @override
  String get trackEatingOutMcdCheeseburger => 'McDonald\'s – Cheeseburger';

  @override
  String get trackEatingOutMcdCheeseburgerLabel => '~300 kcal';

  @override
  String get trackEatingOutMcd2ForYou =>
      'McDonald\'s – 2forYou (Cheeseburger + fries)';

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
  String get trackEatingOutMcdSmallFries => 'McDonald\'s – small fries';

  @override
  String get trackEatingOutMcdSmallFriesLabel => '~230 kcal';

  @override
  String get trackEatingOutMcdMediumFries => 'McDonald\'s – medium fries';

  @override
  String get trackEatingOutMcdMediumFriesLabel => '~340 kcal';

  @override
  String get trackEatingOutKfcDrumstick => 'KFC – drumstick';

  @override
  String get trackEatingOutKfcDrumstickLabel => '~200 kcal / pc';

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
    return 'Activities - $date';
  }

  @override
  String get trackNoActivitiesForDay => 'No activities for this day';

  @override
  String get trackAddFirstActivity => 'Add your first activity';

  @override
  String get trackDaySummary => 'Day summary';

  @override
  String get trackBurned => 'Burned';

  @override
  String get trackTime => 'Time';

  @override
  String get trackGarminActivitiesNote =>
      'Activity data comes from Garmin devices.';

  @override
  String get trackDeleteActivityTitle => 'Delete activity';

  @override
  String trackDeleteActivityConfirm({required String name}) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get trackActivityDeleted => 'Activity deleted';

  @override
  String get trackExcludeFromBalance => 'Don\'t count in balance (burned)';

  @override
  String get trackActivityExcludedFromBalance =>
      'Activity excluded from balance';

  @override
  String get trackActivityIncludedInBalance => 'Activity included in balance';

  @override
  String get trackOtherActivities => 'Other activities.';

  @override
  String get trackActivityTypeOther => 'Other';

  @override
  String get trackActivityTypeLow => 'Low';

  @override
  String get trackActivityTypeModerate => 'Moderate';

  @override
  String get trackActivityTypeHigh => 'High';

  @override
  String get trackActivityTypeVeryHigh => 'Very high';

  @override
  String get trackActivityTypeRun => 'Running';

  @override
  String get trackActivityTypeCycling => 'Cycling';

  @override
  String get trackActivityTypeSwim => 'Swimming';

  @override
  String get trackActivityTypeWalk => 'Walking';

  @override
  String get trackActivityTypeHike => 'Hiking';

  @override
  String get trackActivityTypeRow => 'Rowing';

  @override
  String get trackActivityTypeTennis => 'Tennis';

  @override
  String get trackActivityTypeYoga => 'Yoga';

  @override
  String get trackActivityTypeTraining => 'Training';

  @override
  String get trackFeatureQuickAddActivities => 'Quick add in activities';

  @override
  String get trackActivitySavedAndFavorited =>
      'Activity saved and added to favorites!';

  @override
  String get trackActivityAddedSuccess => 'Activity added successfully!';

  @override
  String get trackEditActivity => 'Edit activity';

  @override
  String get trackAddActivity => 'Add activity';

  @override
  String get trackQuickAdd => 'Quick add';

  @override
  String get trackActivityNameOptional => 'Activity name (optional)';

  @override
  String get trackHintEmptyDefaultActivityName =>
      'Leave empty = \"Untitled activity\"';

  @override
  String get trackDefaultActivityName => 'Untitled activity';

  @override
  String get trackEnterBurnedCalories => 'Enter calories burned';

  @override
  String get trackEnterValidCalories => 'Enter a valid calorie amount';

  @override
  String get trackActivityTypeOptional => 'Activity type – optional';

  @override
  String get trackAddToFavoritesActivitySubtitle =>
      'You can quickly add this activity later';

  @override
  String get trackUpdateActivity => 'Update activity';

  @override
  String get trackSaveActivity => 'Save activity';

  @override
  String get trackDurationMinutes => 'Duration (min)';

  @override
  String get trackBurnedCalories => 'Calories burned';

  @override
  String trackAddedWaterMl({required String amount}) {
    return 'Added $amount ml of water';
  }

  @override
  String trackAddWaterError({required String error}) {
    return 'Error adding water: $error';
  }

  @override
  String trackUpdatedAmountMl({required String amount}) {
    return 'Updated: $amount ml';
  }

  @override
  String trackUpdateError({required String error}) {
    return 'Error updating: $error';
  }

  @override
  String get trackDeleteEntryTitle => 'Delete entry';

  @override
  String trackDeleteWaterConfirm({required String amount}) {
    return 'Are you sure you want to delete the $amount ml entry?';
  }

  @override
  String get trackEntryDeleted => 'Entry deleted';

  @override
  String trackDeleteError({required String error}) {
    return 'Error deleting: $error';
  }

  @override
  String get trackEditAmount => 'Edit amount';

  @override
  String get trackAmountMl => 'Amount (ml)';

  @override
  String get trackAmountMlHintRange => '1–5000 ml';

  @override
  String get trackAmountMustBeRange => 'Amount must be between 1 and 5000 ml';

  @override
  String get trackAddWater => 'Add water';

  @override
  String get trackAmountMlHintExample => 'e.g. 250';

  @override
  String get trackMaxAmountPerEntry => 'Maximum is 5000 ml per entry';

  @override
  String get trackEnterAmountRange => 'Enter an amount from 1 to 5000 ml';

  @override
  String get trackDailyWaterGoal => 'Daily water goal';

  @override
  String get trackGoalHintExample => 'e.g. 2000';

  @override
  String get trackGoalMustBeRange => 'Enter a value from 500 to 10000 ml';

  @override
  String get trackWaterGoalUpdated => 'Water goal updated';

  @override
  String get trackChangeDailyWaterGoal => 'Change daily water goal';

  @override
  String get trackEveryDropCounts => 'Every drop counts!';

  @override
  String get trackCustomAmount => 'Custom';

  @override
  String get trackWaterHistoryHint =>
      'Overview – you can edit and delete. Adding only for today.';

  @override
  String get trackNoEntries => 'No entries';

  @override
  String get trackEdit => 'Edit';

  @override
  String trackAmountMlLabel({required String amount}) {
    return '$amount ml';
  }

  @override
  String get trackDailyGoal => 'Daily goal';

  @override
  String get trackEnterWeight => 'Enter weight';

  @override
  String get trackEnterValidWeight => 'Enter a valid weight (30–300 kg)';

  @override
  String get trackWeightSaved => 'Weight saved successfully!';

  @override
  String get trackWeightMotivation =>
      'Regular weigh-ins help you stay on track. Every entry brings you closer to your goal!';

  @override
  String get trackPickMeasurementDate => 'Select measurement date';

  @override
  String get trackMeasurementSavedWithDate =>
      'The measurement will be saved with the selected date';

  @override
  String get trackSaveWeight => 'Save weight';

  @override
  String get trackDeleteMeasurementTitle => 'Delete measurement';

  @override
  String trackDeleteWeightConfirm({required String weight}) {
    return 'Are you sure you want to delete the $weight kg measurement?';
  }

  @override
  String get trackMeasurementDeleted => 'Measurement deleted';

  @override
  String get trackNoWeightMeasurements => 'No weight measurements';

  @override
  String get trackAddFirstMeasurementHint =>
      'Add your first measurement to see history';

  @override
  String get trackNoDataToDisplay => 'No data to display';

  @override
  String get trackWeightKg => 'Weight (kg)';

  @override
  String get trackHistory => 'History';

  @override
  String get trackEnterMeasurementValue => 'Enter the measurement value';

  @override
  String get trackEnterValidPositiveValue =>
      'Enter a valid value (greater than 0)';

  @override
  String get trackEnterCustomTypeName =>
      'Enter a custom measurement type name (e.g. biceps)';

  @override
  String get trackMeasurementSaved => 'Measurement saved successfully!';

  @override
  String get trackBodyMeasurementsTitle => 'Body measurements';

  @override
  String get trackBodyMeasurementsMotivation =>
      'Track your measurements regularly — each one is proof of your progress and a step toward your dream physique!';

  @override
  String get trackMeasurementType => 'Measurement type';

  @override
  String get trackCustomTypeHint => 'e.g. Biceps, Waist';

  @override
  String get trackCustomTypeName => 'Custom type name';

  @override
  String get trackValueCm => 'Value (cm)';

  @override
  String get trackValueHintExample => 'e.g. 85.5';

  @override
  String get trackSaveMeasurement => 'Save measurement';

  @override
  String trackMeasurementHistory({required String label}) {
    return 'Measurement history - $label';
  }

  @override
  String trackDeleteBodyMeasurementConfirm({required String value}) {
    return 'Are you sure you want to delete the $value cm measurement?';
  }

  @override
  String get trackNoMeasurements => 'No measurements';

  @override
  String get trackTypeWaist => 'Waist';

  @override
  String get trackTypeHips => 'Hips';

  @override
  String get trackTypeChest => 'Chest';

  @override
  String get trackTypeArm => 'Arm';

  @override
  String get trackTypeThigh => 'Thigh';

  @override
  String get trackTypeCustom => 'Custom';

  @override
  String get trackNoFavorites => 'No favorites';

  @override
  String get trackNoFavoritesSubtitle =>
      'Add meals or activities to favorites when saving them';

  @override
  String get trackFavoriteMeals => 'Favorite meals';

  @override
  String get trackNoFavoriteMeals => 'No favorite meals';

  @override
  String get trackFavoriteActivities => 'Favorite activities';

  @override
  String get trackNoFavoriteActivities => 'No favorite activities';

  @override
  String trackAddToMealsOnDate({required String date}) {
    return 'Add to meals on $date';
  }

  @override
  String get trackAddToTodaysMeals => 'Add to today\'s meals';

  @override
  String get trackRemoveFromFavorites => 'Remove from favorites';

  @override
  String trackAddToActivitiesOnDate({required String date}) {
    return 'Add to activities on $date';
  }

  @override
  String get trackAddToTodaysActivities => 'Add to today\'s activities';

  @override
  String trackMealAddedToMealsOnDate({
    required String name,
    required String date,
  }) {
    return '$name added to meals on $date';
  }

  @override
  String trackMealAddedToTodaysMeals({required String name}) {
    return '$name added to today\'s meals';
  }

  @override
  String trackActivityAddedToActivitiesOnDate({
    required String name,
    required String date,
  }) {
    return '$name added to activities on $date';
  }

  @override
  String trackActivityAddedToTodaysActivities({required String name}) {
    return '$name added to today\'s activities';
  }

  @override
  String trackRemoveFromFavoritesConfirm({required String name}) {
    return 'Are you sure you want to remove \"$name\" from favorites?';
  }

  @override
  String get trackRemovedFromFavorites => 'Removed from favorites';

  @override
  String get trackEditFavoriteMeal => 'Edit favorite meal';

  @override
  String get trackFavoriteMealUpdated => 'Favorite meal updated';

  @override
  String get trackRecalculateFromIngredients => 'Recalculate from ingredients';

  @override
  String trackMinutesLabel({required String minutes}) {
    return '$minutes min';
  }

  @override
  String get trackCaloriesKcal => 'Calories (kcal)';

  @override
  String get trackIncludingSaturatedG => 'incl. saturated (g)';

  @override
  String get trackIncludingSugarsG => 'incl. sugars (g)';

  @override
  String get trackWeightGOptional => 'Weight (g) – optional';

  @override
  String get trackGoalMl => 'Goal (ml)';

  @override
  String get trackWaterTitle => 'Water';

  @override
  String trackOfGoal({required String current, required String goal}) {
    return '$current / $goal ml';
  }

  @override
  String get trackSearchShort => 'Search';

  @override
  String get trackWaterToday => 'Water – Today';

  @override
  String trackWaterOnDate({required String date}) {
    return 'Water – $date';
  }

  @override
  String get trackHydrationBasics => 'Hydration is the foundation of fitness.';

  @override
  String get trackSugar => 'Sugars';

  @override
  String get trackSaturatedFat => 'Saturated';

  @override
  String get trackProduct => 'Product';

  @override
  String trackMealMacrosLine({
    required String kcal,
    required String protein,
    required String fat,
    required String carbs,
  }) {
    return '$kcal kcal • P: ${protein}g • F: ${fat}g • C: ${carbs}g';
  }

  @override
  String get trackAnalysisResults => 'Analysis results';

  @override
  String get trackName => 'Name';

  @override
  String get trackProductNotFoundTitle => 'Product not found';

  @override
  String get trackBarcodeLabel => 'Barcode';

  @override
  String get trackFetchingProductData => 'Fetching product data...';

  @override
  String trackBrand({required String brand}) {
    return 'Brand: $brand';
  }

  @override
  String get trackWeightGRequired => 'Weight (g) *';

  @override
  String get trackYourPortion => 'Your portion:';

  @override
  String get trackMacroAbbrevProtein => 'P';

  @override
  String get trackMacroAbbrevFat => 'F';

  @override
  String get trackMacroAbbrevCarbs => 'C';

  @override
  String trackAddedKcal({required String kcal}) {
    return 'Added: $kcal kcal';
  }

  @override
  String get trackCaloriesPer100g => 'Calories (kcal/100g)';

  @override
  String get trackDashToday => 'Today';

  @override
  String get trackNoDate => 'No date';

  @override
  String get trackEntries => 'Entries';

  @override
  String get trackWeightHistory => 'Weight history';

  @override
  String get trackMeasurementName => 'Measurement name';

  @override
  String get trackChoose => 'Choose';

  @override
  String get trackDurationMinutesOptional => 'Duration (minutes) – optional';

  @override
  String get trackMax5000Helper => 'Maximum 5000 ml per entry';

  @override
  String get trackRecommendedMin2l => 'At least 2 L recommended';

  @override
  String get trackSummary => 'Summary';

  @override
  String trackBurnedKcalName({required String kcal}) {
    return 'Burned $kcal kcal';
  }

  @override
  String get trackMeasurementDate => 'Measurement date';

  @override
  String trackKcalBurned({required String kcal}) {
    return '$kcal kcal burned';
  }

  @override
  String get trackMacrosInPremium => 'Macros – in Premium';

  @override
  String get trackSearchProductEllipsis => 'Search product…';

  @override
  String get trackMacros => 'Macros';

  @override
  String get trackRecentMeasurements => 'Recent measurements';

  @override
  String get authEnterFullCode => 'Enter the full code from the email.';

  @override
  String get authSignedIn => 'Signed in.';

  @override
  String get authCodeExpired =>
      'The code expired or is invalid. Send it again.';

  @override
  String get authEnterEmail => 'Enter an email address';

  @override
  String get authInvalidEmail => 'Invalid email format';

  @override
  String authLinkAndCodeSent({required String email}) {
    return 'We sent a link and a code to $email. Check your inbox (and spam) — open the link or enter the code in the app.';
  }

  @override
  String get authCouldNotStart => 'Could not start sign-in.';

  @override
  String get authEmailTaken =>
      'This email is already registered. Sign in with the link from the email (check spam).';

  @override
  String get authAlreadyLinked =>
      'This account is already linked to another user.';

  @override
  String get authManualLinking =>
      'Linking accounts needs to be enabled in Supabase (Authentication → Providers → Manual linking).';

  @override
  String get authConnection => 'Connection error. Check your internet.';

  @override
  String get authTooManyAttempts =>
      'Too many sign-in attempts. Try again in an hour.';

  @override
  String get authTooManyEmails =>
      'Too many messages to this address. Check your inbox or try again shortly.';

  @override
  String get authInvalidEmailAddress => 'Invalid email address.';

  @override
  String authGenericError({required String detail}) {
    return 'Error: $detail';
  }

  @override
  String premAboutPerMonth({required String amount, required String unit}) {
    return 'about $amount $unit / month';
  }

  @override
  String get premYearlyPerMonthFallback =>
      'about 16.25 zł / month (paid once a year)';

  @override
  String get moreStreakWater => 'Water';

  @override
  String get premStoreNotReady =>
      'Store purchases are not ready yet. Try again in a moment.';

  @override
  String get trackAddToCatalog => 'Add to the catalog';

  @override
  String get trackAddToCatalogHint =>
      'Photograph the nutrition table or type the values from the label. The product is saved to the shared catalog.';

  @override
  String get trackLabelPhoto => 'Label photo';

  @override
  String get trackReadingLabel => 'Reading the label…';

  @override
  String get trackLabelNotRead =>
      'Could not read the table. Enter the values yourself.';

  @override
  String get trackEnterNameAndCalories =>
      'Enter a name and calories per 100 g.';

  @override
  String get trackProductSavedCatalog =>
      'Product saved. The next scan will find it.';

  @override
  String get trackCatalogNotSaved =>
      'You can still log the meal, but the shared catalog did not save the product.';

  @override
  String get trackBrandOptional => 'Brand (optional)';

  @override
  String get trackCopyYesterday => 'Copy yesterday';

  @override
  String trackCopiedMealsCount({required int count}) {
    return 'Copied meals: $count';
  }

  @override
  String get trackNoMealsYesterday => 'There were no meals yesterday to copy.';

  @override
  String get trackCopyConfirmTitle => 'Meals already logged';

  @override
  String trackCopyConfirmBody({required int count}) {
    return 'This day already has $count meals. Copy yesterday again? (this creates duplicates)';
  }

  @override
  String get trackCopyAgain => 'Copy again';

  @override
  String get trackCopying => 'Copying…';

  @override
  String get trackRecentFoods => 'Eaten recently';

  @override
  String get trackMealIdeasTitle => 'Fits today';

  @override
  String trackMealIdeasLeft({required String kcal}) {
    return 'About $kcal kcal left';
  }

  @override
  String get trackWaterTipSerious =>
      'Staying hydrated supports focus and metabolism — sip through the day.';

  @override
  String get trackAddFirstMealTitle => 'Add your first meal';

  @override
  String get trackAddFirstMealSubtitle =>
      'Log what you eat — we\'ll handle the rest.';

  @override
  String get trackAddFirstMealCta => 'Add meal';

  @override
  String get trackShortcutRecent => 'Recent';

  @override
  String get trackRemainingKcal => 'Remaining to goal';

  @override
  String get trackOverGoalLabel => 'Over goal';

  @override
  String trackGoalVerificationDays({required int days}) {
    return '$days/7 days logged';
  }

  @override
  String get trackCalorieGoalSuccess =>
      'Nice work — you\'re around your calorie goal today.';

  @override
  String get trackD1ChecklistTitle => 'Day one checklist';

  @override
  String get trackD1ChecklistMeal => 'Log a meal';

  @override
  String get trackD1ChecklistWater => 'Log water';

  @override
  String get trackD1ChecklistWeight => 'Log weight';

  @override
  String get trackD1ChecklistDismiss => 'Got it';

  @override
  String get trackPremiumLabel => 'Premium';

  @override
  String trackPercentOfGoal({required String percent}) {
    return '$percent% of goal';
  }
}
