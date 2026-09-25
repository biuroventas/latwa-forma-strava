import 'legal_document.dart';

const termsEn = LegalDocument(
  title: 'Terms of Use for the Łatwa Forma app',
  updated: 'Last updated: September 2026',
  sections: [
    LegalSection('1. General provisions', [
      LegalParagraph([
        LegalPiece(
          'These Terms of Use set out the rules for using the mobile app and related services “Łatwa Forma” (hereinafter: the App). The service provider is VENTAS NORBERT WRÓBLEWSKI, ul. Szczytowa 27/10, 41-608 Świętochłowice, Poland, NIP 728-284-53-14 (e-mail: ',
        ),
        LegalPiece('contact@latwaforma.pl', url: 'mailto:contact@latwaforma.pl'),
        LegalPiece('). By using the App, you accept these Terms of Use.'),
      ]),
    ]),
    LegalSection('2. Service', [
      LegalParagraph([
        LegalPiece(
          'The App is used to track calories, macronutrients, physical activity, weight, and hydration. Some features are available free of charge; Premium features require purchasing a subscription or a one-time payment for a Premium period. ',
        ),
        LegalPiece('A subscription is not required', bold: true),
        LegalPiece(
          ' to use basic features (including meal diary, water, and weight).',
        ),
      ]),
      LegalParagraph([
        LegalPiece('Nature of the service: ', bold: true),
        LegalPiece(
          'Łatwa Forma is not a medical device and does not diagnose, treat, prevent, or cure any disease or health condition. Calculations, calorie targets, and AI content are indicative only. For health matters, consult a doctor or dietitian.',
        ),
      ]),
    ]),
    LegalSection('3. Account and data', [
      LegalParagraph([
        LegalPiece('The App is intended for people who are at least '),
        LegalPiece('13 years old', bold: true),
        LegalPiece(
          '. By using the App, you declare that you are at least 13 years old.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'To save data, you may create an account (sign-in via Google, Apple, or e-mail). You are responsible for keeping your login credentials confidential. Personal data processing is described in the ',
        ),
        LegalPiece('Privacy Policy', kind: LegalKind.privacy),
        LegalPiece(
          '. You can delete your account in the App (Profile → Delete account) or via a ',
        ),
        LegalPiece(
          'request on the website',
          url: 'https://latwaforma.pl/usun-konto.html',
        ),
        LegalPiece('.'),
      ]),
      LegalParagraph([
        LegalPiece(
          'Integrations with third-party services (e.g. Strava, Garmin Connect) are subject to those services’ terms of use and privacy policies. Connecting an account means you consent to sharing with us the data you select in those services. More information about data processing for integrations is in the ',
        ),
        LegalPiece('Privacy Policy', kind: LegalKind.privacy),
        LegalPiece('.'),
      ]),
    ]),
    LegalSection('4. Subscription and Premium payments', [
      LegalParagraph([
        LegalPiece('Pricing: ', bold: true),
        LegalPiece(
          'monthly subscription 69,99 zł, annual subscription 194,99 zł, and one-time payment for one year of Premium 194,99 zł (on the website: BLIK only; in store apps: one-time purchase via Apple/Google). Current prices are also shown in the App before purchase.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('In-app payments on mobile ', bold: true),
        LegalPiece(
          '(iOS / Android from the stores) are processed through the store systems: Apple App Store In-App Purchase and Google Play Billing (via RevenueCat). Apple / Google terms and policies apply. ',
        ),
        LegalPiece(
          'Monthly and annual subscriptions renew automatically',
          bold: true,
        ),
        LegalPiece(
          ' at the price shown before purchase until you cancel. The one-time plan (one year) does not renew. Cancellation: Apple ID account settings or ',
        ),
        LegalPiece(
          'Google Play → Subscriptions',
          url: 'https://play.google.com/store/account/subscriptions',
        ),
        LegalPiece(
          ' (also in the App: Premium → Manage subscription). Cancellation takes effect at the end of the current billing period, in accordance with the store’s policy and consumer law.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('Website payments ', bold: true),
        LegalPiece('latwaforma.pl', url: 'https://latwaforma.pl'),
        LegalPiece(
          ' are processed by Stripe. Subscription: card, Apple Pay, Google Pay. One-time payment for one year: BLIK only. Payment data is processed by Stripe; we do not store it. Subscription cancellation: in the App (Profile → Łatwa Forma Premium → Cancel subscription) the Stripe Customer Portal will open.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('Cancellation: ', bold: true),
        LegalPiece(
          'Premium access remains until the end of the paid period. A refund for the unused period is not available unless consumer law or the store’s policy provides otherwise.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('Trial period: ', bold: true),
        LegalPiece(
          'A one-time trial of Premium features (24 h from first use) is offered in the App ',
        ),
        LegalPiece(
          'without charging payment and without automatically enrolling you in a subscription',
          bold: true,
        ),
        LegalPiece(
          '. After it ends, Premium features require a separate purchase. This is not a free Google Play / App Store trial that converts into a paid subscription on its own.',
        ),
      ], bullet: true),
    ]),
    LegalSection('5. Right of withdrawal (consumers)', [
      LegalParagraph([
        LegalPiece(
          'If you are a consumer within the meaning of EU law, you have the right to withdraw from the contract within 14 days of concluding it, without giving a reason. To exercise this right, notify us (',
        ),
        LegalPiece('contact@latwaforma.pl', url: 'mailto:contact@latwaforma.pl'),
        LegalPiece(
          '). For digital services (e.g. Premium), after an express request to begin performance before the 14-day period ends, the right of withdrawal expires upon full performance of the service.',
        ),
      ]),
    ]),
    LegalSection('6. Acceptable use', [
      LegalParagraph([
        LegalPiece(
          'You use the App in accordance with the law and in a manner that does not infringe the rights of other users or the service provider. Among other things, circumventing security measures, mass downloading of data, and using the App for purposes inconsistent with its intended use are prohibited.',
        ),
      ]),
    ]),
    LegalSection('7. Ownership and liability', [
      LegalParagraph([
        LegalPiece(
          'The App and its content (interface, logic, marks) are the property of the service provider. The service is provided “as is”. The service provider is not liable for user decisions made based on content in the App (e.g. dietary advice) or for failures not caused by the service provider.',
        ),
      ]),
    ]),
    LegalSection('8. Changes to the Terms', [
      LegalParagraph([
        LegalPiece(
          'Changes to the Terms of Use will be published in the App with a date. More significant changes (e.g. prices, scope of services) may also be communicated in the App. Continuing to use the App after changes take effect means you accept them.',
        ),
      ]),
    ]),
    LegalSection('9. Governing law and disputes', [
      LegalParagraph([
        LegalPiece(
          'Polish law applies to these Terms of Use and to contracts concluded in connection with the App. Disputes with consumers may be resolved amicably or in court; consumers also have the right to use the ODR platform: ',
        ),
        LegalPiece(
          'ec.europa.eu/consumers/odr',
          url: 'https://ec.europa.eu/consumers/odr',
        ),
        LegalPiece('.'),
      ]),
      LegalParagraph([
        LegalPiece('Contact: '),
        LegalPiece('contact@latwaforma.pl', url: 'mailto:contact@latwaforma.pl'),
        LegalPiece('.'),
      ]),
    ]),
  ],
);

const privacyEn = LegalDocument(
  title: 'Privacy Policy',
  updated: 'Łatwa Forma | Last updated: September 2026',
  sections: [
    LegalSection('1. Data controller', [
      LegalParagraph([
        LegalPiece(
          'The data controller is VENTAS NORBERT WRÓBLEWSKI, ul. Szczytowa 27/10, 41-608 Świętochłowice, Poland, NIP 728-284-53-14. Contact: ',
        ),
        LegalPiece('contact@latwaforma.pl', url: 'mailto:contact@latwaforma.pl'),
        LegalPiece('.'),
      ]),
    ]),
    LegalSection('2. What data we collect', [
      LegalParagraph([
        LegalPiece(
          'The Łatwa Forma App collects and processes data necessary for its operation, including:',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'account data (e-mail, user identifier), including when signing in with Google – e-mail address and identifier from the Google account,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'profile and fitness-related health data (age, sex, weight, height, activity level, body measurements) – used solely for BMR/TDEE calculations and tracking body-composition goals,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('entries about meals, activities, and water intake,'),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'meal photos – only when you use AI photo analysis; the photo is sent to the AI model provider (OpenAI) to estimate nutritional values and is not permanently stored by us as a gallery,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'content of AI Advice queries – processed by OpenAI to generate a response,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'for integrations – access tokens for Strava and Garmin Connect and imported activities,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'for Premium subscriptions – a user identifier passed to the payment operator to link the payment to the account: on the website to Stripe; in store apps – to Apple / Google (and RevenueCat as the billing intermediary). Card data is not stored by us,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'to send notifications (water and meal reminders) – a device identifier for delivering local notifications (via the iOS/Android system).',
        ),
      ], bullet: true),
    ]),
    LegalSection('3. Purposes of processing', [
      LegalParagraph([
        LegalPiece(
          'Data is used solely to provide the service: tracking calorie balance, nutrition, and physical activity within the Łatwa Forma app, handling payments (Stripe on the website; Apple / Google / RevenueCat in mobile apps), AI features (meal photo analysis, dietary advice), and sending notifications if you enable them. We do not sell data and do not use it for personalized advertising.',
        ),
      ]),
    ]),
    LegalSection('4. Legal basis for processing (Article 6 GDPR)', [
      LegalParagraph([
        LegalPiece('We process personal data on the following bases:'),
      ]),
      LegalParagraph([
        LegalPiece(
          'Performance of a contract (Article 6(1)(b) GDPR)',
          bold: true,
        ),
        LegalPiece(
          ' – account data, profile data, meals, activities, water, integrations, and data necessary to handle Premium subscriptions, in order to provide the service in accordance with the terms of use.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('Consent (Article 6(1)(a) GDPR)', bold: true),
        LegalPiece(
          ' – push notifications (water and meal reminders), if you enable them; you can turn them off in device settings.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'Legitimate interest (Article 6(1)(f) GDPR)',
          bold: true,
        ),
        LegalPiece(
          ' – to the extent necessary to pursue claims or defend against claims, and to respond to your inquiries (e.g. contact@latwaforma.pl).',
        ),
      ], bullet: true),
    ]),
    LegalSection('5. Google / Apple sign-in and payments', [
      LegalParagraph([
        LegalPiece(
          'Sign-in via Google or Apple takes place in accordance with those providers’ policies; to provide the service we only receive e-mail and an identifier (to the extent made available by the provider).',
        ),
      ]),
      LegalParagraph([
        LegalPiece('Website: ', bold: true),
        LegalPiece(
          'Premium payments are processed by Stripe – we pass a user identifier (linking the payment to the account). Card, BLIK, Apple Pay, and Google Pay data is processed by Stripe. Details: ',
        ),
        LegalPiece(
          'Stripe Privacy Policy',
          url: 'https://stripe.com/privacy',
        ),
        LegalPiece('.'),
      ]),
      LegalParagraph([
        LegalPiece('iOS / Android apps: ', bold: true),
        LegalPiece(
          'Premium payments are processed by the App Store / Google Play (In-App Purchase / Play Billing), using RevenueCat to sync subscription status with the account. Details: Apple and Google privacy policies and ',
        ),
        LegalPiece('RevenueCat', url: 'https://www.revenuecat.com/privacy'),
        LegalPiece('.'),
      ]),
    ]),
    LegalSection('5a. AI features (OpenAI) and product database', [
      LegalParagraph([
        LegalPiece(
          'Meal photo analysis and AI Advice use the OpenAI interface. The photo or question content is sent to OpenAI to generate a response. Details: ',
        ),
        LegalPiece(
          'OpenAI Privacy Policy',
          url: 'https://openai.com/privacy',
        ),
        LegalPiece(
          '. Calorie estimates and advice do not constitute medical advice.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'Product search by barcode or name uses our database (including Turso) and the public Open Food Facts API. We do not send your health profile in that process.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'The camera is used only at your request: to scan a barcode (the image is neither saved nor sent) or to take a meal photo (in which case the photo goes to OpenAI, as above).',
        ),
      ]),
    ]),
    LegalSection('6. Integrations (Strava, Garmin)', [
      LegalParagraph([
        LegalPiece(
          'If you connect an account with Strava or Garmin Connect, we import only those activities for which you have given consent. We do not share this data with third parties or resell it. You can disconnect the integration at any time in the app settings.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'Data from Garmin Connect is shared with us by you as part of connecting the account and is processed in accordance with the Garmin Connect privacy policy: ',
        ),
        LegalPiece(
          'Garmin Connect Privacy Policy',
          url: 'https://www.garmin.com/privacy/connect',
        ),
        LegalPiece('.'),
      ]),
    ]),
    LegalSection('7. Data storage', [
      LegalParagraph([
        LegalPiece(
          'Data is stored on Supabase servers (Europe). Integrated data (Strava, Garmin) is stored only to the extent necessary for synchronization to work.',
        ),
      ]),
      LegalParagraph([
        LegalPiece('Retention period: ', bold: true),
        LegalPiece(
          'account-related data is stored until the user deletes the account (Profile → Delete account). After account deletion, data is deleted within the timeframe resulting from technical procedures (usually up to 30 days). Data necessary for accounting (e.g. invoices, payment records) is stored for the period required by law (in Poland, among other things, 5 years from the end of the tax year). Data in backups may be deleted with a delay in accordance with the hosting policy.',
        ),
      ]),
    ]),
    LegalSection('8. User rights', [
      LegalParagraph([
        LegalPiece(
          'You have the right of access to your data (Article 15 GDPR), rectification (Article 16), erasure – the “right to be forgotten” (Article 17), restriction of processing (Article 18), data portability (Article 20 – on request we may provide your data in a format enabling transfer to another service provider), and objection to processing (Article 21). Where processing is based on consent, you have the right to withdraw it at any time without affecting the lawfulness of processing based on consent before its withdrawal.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'You can delete your account and related data yourself in the app (Profile → Delete account) or via the page ',
        ),
        LegalPiece(
          'latwaforma.pl/usun-konto.html',
          url: 'https://latwaforma.pl/usun-konto.html',
        ),
        LegalPiece(
          ' (e-mail to contact@latwaforma.pl). Account deletion is not a “freeze” – user data is deleted. If you have a subscription in Google Play or the App Store, cancel it separately in the store – deleting the account does not end it.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'You also have the right to lodge a complaint with a supervisory authority – the President of the Personal Data Protection Office (ul. Stawki 2, 00-193 Warsaw), ',
        ),
        LegalPiece('uodo.gov.pl', url: 'https://uodo.gov.pl'),
        LegalPiece('.'),
      ]),
    ]),
    LegalSection('9. Cookies', [
      LegalParagraph([
        LegalPiece(
          'The App does not use cookies to track users. If cookies necessary for operation (e.g. session) are used, information about that will be included in this policy.',
        ),
      ]),
    ]),
    LegalSection('10. Changes', [
      LegalParagraph([
        LegalPiece(
          'Policy changes will be published in the App. By continuing to use the app after they are introduced, you accept the updated policy.',
        ),
      ]),
    ]),
  ],
);
