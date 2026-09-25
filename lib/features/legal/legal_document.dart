import 'package:url_launcher/url_launcher.dart';

import 'legal_document_en.dart';
import 'legal_document_uk.dart';

enum LegalKind { terms, privacy }

class LegalPiece {
  const LegalPiece(
    this.text, {
    this.bold = false,
    this.kind,
    this.url,
  });

  final String text;
  final bool bold;
  final LegalKind? kind;
  final String? url;
}

class LegalParagraph {
  const LegalParagraph(this.pieces, {this.bullet = false});

  final List<LegalPiece> pieces;
  final bool bullet;
}

class LegalSection {
  const LegalSection(this.heading, this.paragraphs);

  final String heading;
  final List<LegalParagraph> paragraphs;
}

class LegalDocument {
  const LegalDocument({
    required this.title,
    required this.updated,
    required this.sections,
  });

  final String title;
  final String updated;
  final List<LegalSection> sections;

  static LegalDocument of(LegalKind kind, {String languageCode = 'pl'}) {
    if (languageCode == 'en') {
      return switch (kind) {
        LegalKind.terms => termsEn,
        LegalKind.privacy => privacyEn,
      };
    }
    if (languageCode == 'uk') {
      return switch (kind) {
        LegalKind.terms => termsUk,
        LegalKind.privacy => privacyUk,
      };
    }
    return switch (kind) {
      LegalKind.terms => _terms,
      LegalKind.privacy => _privacy,
    };
  }
}

const _terms = LegalDocument(
  title: 'Regulamin korzystania z aplikacji Łatwa Forma',
  updated: 'Ostatnia aktualizacja: wrzesień 2026',
  sections: [
    LegalSection('1. Postanowienia ogólne', [
      LegalParagraph([
        LegalPiece(
          'Regulamin określa zasady korzystania z aplikacji mobilnej i powiązanych usług „Łatwa Forma” (dalej: Aplikacja). Usługodawcą jest VENTAS NORBERT WRÓBLEWSKI, ul. Szczytowa 27/10, 41-608 Świętochłowice, Polska, NIP 728-284-53-14 (e-mail: ',
        ),
        LegalPiece('contact@latwaforma.pl', url: 'mailto:contact@latwaforma.pl'),
        LegalPiece('). Korzystając z Aplikacji, akceptujesz niniejszy Regulamin.'),
      ]),
    ]),
    LegalSection('2. Usługa', [
      LegalParagraph([
        LegalPiece(
          'Aplikacja służy do śledzenia kalorii, makroskładników, aktywności fizycznej, wagi i nawodnienia. Część funkcji jest dostępna bezpłatnie; funkcje Premium wymagają wykupienia subskrypcji lub płatności jednorazowej za okres Premium. ',
        ),
        LegalPiece('Subskrypcja nie jest wymagana', bold: true),
        LegalPiece(
          ', aby korzystać z podstawowych funkcji (m.in. dziennik posiłków, woda, waga).',
        ),
      ]),
      LegalParagraph([
        LegalPiece('Charakter usługi: ', bold: true),
        LegalPiece(
          'Łatwa Forma nie jest urządzeniem medycznym i nie diagnozuje, nie leczy, nie zapobiega ani nie leczy żadnej choroby ani stanu zdrowia. Obliczenia, cele kaloryczne i treści AI mają charakter orientacyjny. W sprawach zdrowia skonsultuj się z lekarzem lub dietetykiem.',
        ),
      ]),
    ]),
    LegalSection('3. Konto i dane', [
      LegalParagraph([
        LegalPiece('Aplikacja jest przeznaczona dla osób, które ukończyły '),
        LegalPiece('13 lat', bold: true),
        LegalPiece(
          '. Korzystając z Aplikacji oświadczasz, że masz co najmniej 13 lat.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'Do zapisywania danych możesz założyć konto (logowanie przez Google, Apple lub e-mail). Jesteś odpowiedzialny za poufność danych logowania. Przetwarzanie danych osobowych opisuje ',
        ),
        LegalPiece('Polityka prywatności', kind: LegalKind.privacy),
        LegalPiece(
          '. Konto możesz usunąć w Aplikacji (Profil → Usuń konto) albo przez ',
        ),
        LegalPiece(
          'wniosek na stronie',
          url: 'https://latwaforma.pl/usun-konto.html',
        ),
        LegalPiece('.'),
      ]),
      LegalParagraph([
        LegalPiece(
          'Integracje z usługami zewnętrznymi (np. Strava, Garmin Connect) podlegają regulaminom i politykom prywatności tych usług. Połączenie konta oznacza zgodę na udostępnienie nam danych w zakresie wybranym przez Ciebie w tych usługach. Więcej informacji o przetwarzaniu danych przy integracjach zawiera ',
        ),
        LegalPiece('Polityka prywatności', kind: LegalKind.privacy),
        LegalPiece('.'),
      ]),
    ]),
    LegalSection('4. Subskrypcja i płatności Premium', [
      LegalParagraph([
        LegalPiece('Cennik: ', bold: true),
        LegalPiece(
          'subskrypcja miesięczna 69,99 zł, subskrypcja roczna 194,99 zł oraz płatność jednorazowa za rok Premium 194,99 zł (na stronie: tylko BLIK; w aplikacjach ze sklepów: zakup jednorazowy przez Apple/Google). Aktualne ceny są też pokazane w Aplikacji przed zakupem.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('Płatności w aplikacji mobilnej ', bold: true),
        LegalPiece(
          '(iOS / Android ze sklepów) są realizowane przez systemy sklepów: Apple App Store In-App Purchase oraz Google Play Billing (za pośrednictwem RevenueCat). Obowiązują regulaminy i polityki Apple / Google. ',
        ),
        LegalPiece(
          'Subskrypcja miesięczna i roczna odnawiają się automatycznie',
          bold: true,
        ),
        LegalPiece(
          ' za cenę pokazaną przed zakupem, dopóki jej nie anulujesz. Plan jednorazowy (rok) nie odnawia się. Anulowanie: ustawienia konta Apple ID lub ',
        ),
        LegalPiece(
          'Google Play → Subskrypcje',
          url: 'https://play.google.com/store/account/subscriptions',
        ),
        LegalPiece(
          ' (także w Aplikacji: Premium → Zarządzaj subskrypcją). Anulowanie działa od końca bieżącego okresu rozliczeniowego, zgodnie z polityką sklepu i prawem konsumenckim.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('Płatności na stronie ', bold: true),
        LegalPiece('latwaforma.pl', url: 'https://latwaforma.pl'),
        LegalPiece(
          ' są realizowane przez Stripe. Subskrypcja: karta, Apple Pay, Google Pay. Płatność jednorazowa za rok: tylko BLIK. Dane płatności przetwarza Stripe; nie przechowujemy ich. Anulowanie subskrypcji: w Aplikacji (Profil → Łatwa Forma Premium → Anuluj subskrypcję) otworzy się Stripe Customer Portal.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('Rezygnacja: ', bold: true),
        LegalPiece(
          'Dostęp Premium pozostaje do końca opłaconego okresu. Zwrot za niewykorzystany okres nie przysługuje, chyba że prawo konsumenckie lub polityka sklepu stanowi inaczej.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('Okres próbny: ', bold: true),
        LegalPiece(
          'Jednorazowy okres próbny funkcji Premium (24 h od pierwszego użycia) jest oferowany w Aplikacji ',
        ),
        LegalPiece(
          'bez pobierania płatności i bez automatycznego zapisu na subskrypcję',
          bold: true,
        ),
        LegalPiece(
          '. Po jego zakończeniu funkcje Premium wymagają osobnego zakupu. To nie jest darmowy okres próbny Google Play / App Store, który sam przechodzi w płatność.',
        ),
      ], bullet: true),
    ]),
    LegalSection('5. Odstąpienie od umowy (konsumenci)', [
      LegalParagraph([
        LegalPiece(
          'Jeśli jesteś konsumentem w rozumieniu prawa UE, masz prawo do odstąpienia od umowy w terminie 14 dni od dnia jej zawarcia, bez podawania przyczyny. Aby skorzystać z tego prawa, poinformuj nas (',
        ),
        LegalPiece('contact@latwaforma.pl', url: 'mailto:contact@latwaforma.pl'),
        LegalPiece(
          '). W przypadku usług cyfrowych (np. Premium), po wyraźnej prośbie o rozpoczęcie świadczenia przed upływem 14 dni prawo odstąpienia wygasa z chwilą pełnego wykonania usługi.',
        ),
      ]),
    ]),
    LegalSection('6. Zasady użytkowania', [
      LegalParagraph([
        LegalPiece(
          'Korzystasz z Aplikacji zgodnie z prawem i w sposób nie naruszający praw innych użytkowników ani usługodawcy. Zabronione jest m.in. obchodzenie zabezpieczeń, masowe pobieranie danych, wykorzystywanie Aplikacji do celów niezgodnych z jej przeznaczeniem.',
        ),
      ]),
    ]),
    LegalSection('7. Własność i odpowiedzialność', [
      LegalParagraph([
        LegalPiece(
          'Aplikacja i jej treści (interfejs, logika, znaki) są własnością usługodawcy. Usługa jest świadczona „tak jak jest”. Usługodawca nie ponosi odpowiedzialności za decyzje użytkownika podejmowane na podstawie treści w Aplikacji (np. porady żywieniowe) ani za awarie niezawinione przez niego.',
        ),
      ]),
    ]),
    LegalSection('8. Zmiany Regulaminu', [
      LegalParagraph([
        LegalPiece(
          'Zmiany Regulaminu będą publikowane w Aplikacji z podaniem daty. Ważniejsze zmiany (np. ceny, zakres usług) mogą być dodatkowo komunikowane w Aplikacji. Kontynuowanie korzystania z Aplikacji po wejściu zmian w życie oznacza ich akceptację.',
        ),
      ]),
    ]),
    LegalSection('9. Prawo właściwe i spory', [
      LegalParagraph([
        LegalPiece(
          'Do Regulaminu i umów zawieranych w związku z Aplikacją stosuje się prawo polskie. Spory z konsumentami można rozwiązywać polubownie lub na drodze sądowej; konsument ma także prawo skorzystać z platformy ODR: ',
        ),
        LegalPiece(
          'ec.europa.eu/consumers/odr',
          url: 'https://ec.europa.eu/consumers/odr',
        ),
        LegalPiece('.'),
      ]),
      LegalParagraph([
        LegalPiece('Kontakt: '),
        LegalPiece('contact@latwaforma.pl', url: 'mailto:contact@latwaforma.pl'),
        LegalPiece('.'),
      ]),
    ]),
  ],
);

const _privacy = LegalDocument(
  title: 'Polityka prywatności',
  updated: 'Łatwa Forma | Ostatnia aktualizacja: wrzesień 2026',
  sections: [
    LegalSection('1. Administrator danych', [
      LegalParagraph([
        LegalPiece(
          'Administratorem danych jest VENTAS NORBERT WRÓBLEWSKI, ul. Szczytowa 27/10, 41-608 Świętochłowice, Polska, NIP 728-284-53-14. Kontakt: ',
        ),
        LegalPiece('contact@latwaforma.pl', url: 'mailto:contact@latwaforma.pl'),
        LegalPiece('.'),
      ]),
    ]),
    LegalSection('2. Jakie dane zbieramy', [
      LegalParagraph([
        LegalPiece(
          'Aplikacja Łatwa Forma zbiera i przetwarza dane niezbędne do jej funkcjonowania, w tym:',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'dane konta (e-mail, identyfikator użytkownika), w tym przy logowaniu przez Google – adres e-mail i identyfikator z konta Google,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'dane profilowe i zdrowotne związane z fitness (wiek, płeć, waga, wzrost, poziom aktywności, pomiary ciała) – służą wyłącznie do obliczeń BMR/TDEE i śledzenia celu sylwetkowego,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('wpisy o posiłkach, aktywnościach i piciu wody,'),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'zdjęcia posiłków – wyłącznie gdy użyjesz analizy AI ze zdjęcia; zdjęcie jest wysyłane do dostawcy modelu AI (OpenAI) w celu oszacowania wartości odżywczych i nie jest przez nas trwale przechowywane jako galeria,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'treść zapytań do Porady AI – przetwarzana przez OpenAI w celu wygenerowania odpowiedzi,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'w przypadku integracji – tokeny dostępu do Strava i Garmin Connect oraz importowane aktywności,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'w przypadku subskrypcji Premium – identyfikator użytkownika przekazywany do operatora płatności w celu powiązania płatności z kontem: na stronie internetowej do Stripe; w aplikacjach ze sklepów – do Apple / Google (oraz RevenueCat jako pośrednika rozliczeń). Dane karty nie są przechowywane przez nas,',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'w celu wysyłki powiadomień (przypomnienia o wodzie, posiłkach) – identyfikator urządzenia do dostarczania powiadomień lokalnych (przez system iOS/Android).',
        ),
      ], bullet: true),
    ]),
    LegalSection('3. Cele przetwarzania', [
      LegalParagraph([
        LegalPiece(
          'Dane są wykorzystywane wyłącznie w celu świadczenia usługi: śledzenia bilansu kalorii, odżywiania i aktywności fizycznej w ramach aplikacji Łatwa Forma, obsługi płatności (Stripe na stronie; Apple / Google / RevenueCat w aplikacjach mobilnych), funkcji AI (analiza zdjęcia posiłku, porada żywieniowa) oraz wysyłki powiadomień, o ile je włączysz. Nie sprzedajemy danych i nie wykorzystujemy ich do reklam spersonalizowanych.',
        ),
      ]),
    ]),
    LegalSection('4. Podstawa prawna przetwarzania (art. 6 RODO)', [
      LegalParagraph([
        LegalPiece('Przetwarzamy dane osobowe na następujących podstawach:'),
      ]),
      LegalParagraph([
        LegalPiece(
          'Wykonanie umowy (art. 6 ust. 1 lit. b RODO)',
          bold: true,
        ),
        LegalPiece(
          ' – dane konta, profilowe, posiłki, aktywności, woda, integracje oraz dane niezbędne do obsługi subskrypcji Premium, aby świadczyć usługę zgodnie z regulaminem.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece('Zgoda (art. 6 ust. 1 lit. a RODO)', bold: true),
        LegalPiece(
          ' – powiadomienia push (przypomnienia o wodzie, posiłkach), o ile je włączysz; możesz je wyłączyć w ustawieniach urządzenia.',
        ),
      ], bullet: true),
      LegalParagraph([
        LegalPiece(
          'Prawnie uzasadniony interes (art. 6 ust. 1 lit. f RODO)',
          bold: true,
        ),
        LegalPiece(
          ' – w zakresie niezbędnym do dochodzenia roszczeń lub obrony przed roszczeniami, oraz udzielania odpowiedzi na Twoje zapytania (np. kontakt@latwaforma.pl).',
        ),
      ], bullet: true),
    ]),
    LegalSection('5. Logowanie Google / Apple i płatności', [
      LegalParagraph([
        LegalPiece(
          'Logowanie przez Google lub Apple odbywa się zgodnie z polityką tych dostawców; przekazujemy do świadczenia usługi wyłącznie e-mail i identyfikator (w zakresie udostępnionym przez dostawcę).',
        ),
      ]),
      LegalParagraph([
        LegalPiece('Strona internetowa: ', bold: true),
        LegalPiece(
          'płatności Premium realizuje Stripe – przekazujemy identyfikator użytkownika (powiązanie płatności z kontem). Dane karty, BLIK, Apple Pay i Google Pay przetwarza Stripe. Szczegóły: ',
        ),
        LegalPiece(
          'Polityka prywatności Stripe',
          url: 'https://stripe.com/privacy',
        ),
        LegalPiece('.'),
      ]),
      LegalParagraph([
        LegalPiece('Aplikacje iOS / Android: ', bold: true),
        LegalPiece(
          'płatności Premium realizują App Store / Google Play (In-App Purchase / Play Billing), z wykorzystaniem RevenueCat do synchronizacji statusu subskrypcji z kontem. Szczegóły: polityki prywatności Apple, Google oraz ',
        ),
        LegalPiece('RevenueCat', url: 'https://www.revenuecat.com/privacy'),
        LegalPiece('.'),
      ]),
    ]),
    LegalSection('5a. Funkcje AI (OpenAI) i baza produktów', [
      LegalParagraph([
        LegalPiece(
          'Analiza zdjęcia posiłku i Porada AI korzystają z interfejsu OpenAI. Zdjęcie lub treść pytania są przesyłane do OpenAI w celu wygenerowania odpowiedzi. Szczegóły: ',
        ),
        LegalPiece(
          'Polityka prywatności OpenAI',
          url: 'https://openai.com/privacy',
        ),
        LegalPiece(
          '. Szacunki kalorii i porad nie stanowią porady medycznej.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'Wyszukiwanie produktów po kodzie kreskowym lub nazwie korzysta z naszej bazy (m.in. Turso) oraz publicznego API Open Food Facts. Nie wysyłamy przy tym Twojego profilu zdrowotnego.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'Kamera jest używana wyłącznie na Twoje polecenie: do skanowania kodu kreskowego (obraz nie jest zapisywany ani wysyłany) albo do zrobienia zdjęcia posiłku (wtedy zdjęcie trafia do OpenAI, jak wyżej).',
        ),
      ]),
    ]),
    LegalSection('6. Integracje (Strava, Garmin)', [
      LegalParagraph([
        LegalPiece(
          'Jeśli połączysz konto ze Strava lub Garmin Connect, importujemy wyłącznie te aktywności, do których wyraziłeś zgodę. Nie udostępniamy tych danych podmiotom trzecim ani ich nie odsprzedajemy. Możesz w dowolnym momencie odłączyć integrację w ustawieniach aplikacji.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'Dane z Garmin Connect są udostępniane nam przez Ciebie w ramach połączenia konta i przetwarzane zgodnie z polityką prywatności Garmin Connect: ',
        ),
        LegalPiece(
          'Polityka prywatności Garmin Connect',
          url: 'https://www.garmin.com/privacy/connect',
        ),
        LegalPiece('.'),
      ]),
    ]),
    LegalSection('7. Przechowywanie danych', [
      LegalParagraph([
        LegalPiece(
          'Dane są przechowywane na serwerach Supabase (Europa). Dane zintegrowane (Strava, Garmin) przechowujemy tylko w zakresie niezbędnym do działania synchronizacji.',
        ),
      ]),
      LegalParagraph([
        LegalPiece('Okres przechowywania: ', bold: true),
        LegalPiece(
          'dane powiązane z kontem przechowujemy do momentu usunięcia konta przez użytkownika (Profil → Usuń konto). Po usunięciu konta dane są usuwane w terminie wynikającym z procedur technicznych (zwykle do 30 dni). Dane niezbędne do rozliczeń (np. faktury, dowody płatności) przechowujemy przez okres wymagany przepisami prawa (w Polsce m.in. 5 lat od końca roku podatkowego). Dane w formie kopii zapasowych mogą być usuwane z opóźnieniem zgodnie z polityką hostingu.',
        ),
      ]),
    ]),
    LegalSection('8. Prawa użytkownika', [
      LegalParagraph([
        LegalPiece(
          'Przysługują Ci: prawo dostępu do swoich danych (art. 15 RODO), sprostowania (art. 16), usunięcia – „prawo do bycia zapomnianym” (art. 17), ograniczenia przetwarzania (art. 18), przenoszenia danych (art. 20 – na żądanie możemy przekazać Twoje dane w formacie umożliwiającym przeniesienie do innego usługodawcy) oraz sprzeciwu wobec przetwarzania (art. 21). W przypadku przetwarzania opartego na zgodzie masz prawo do jej wycofania w dowolnym momencie bez wpływu na zgodność z prawem wcześniejszego przetwarzania.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'Konto i powiązane dane możesz usunąć samodzielnie w aplikacji (Profil → Usuń konto) albo przez stronę ',
        ),
        LegalPiece(
          'latwaforma.pl/usun-konto.html',
          url: 'https://latwaforma.pl/usun-konto.html',
        ),
        LegalPiece(
          ' (e-mail na contact@latwaforma.pl). Usunięcie konta nie jest „zamrożeniem” – dane użytkownika są usuwane. Jeśli masz subskrypcję w Google Play lub App Store, anuluj ją osobno w sklepie – usunięcie konta jej nie kończy.',
        ),
      ]),
      LegalParagraph([
        LegalPiece(
          'Masz także prawo wniesienia skargi do organu nadzorczego – Prezesa Urzędu Ochrony Danych Osobowych (ul. Stawki 2, 00-193 Warszawa), ',
        ),
        LegalPiece('uodo.gov.pl', url: 'https://uodo.gov.pl'),
        LegalPiece('.'),
      ]),
    ]),
    LegalSection('9. Pliki cookies', [
      LegalParagraph([
        LegalPiece(
          'Aplikacja nie wykorzystuje cookies do śledzenia użytkowników. W razie stosowania cookies niezbędnych do działania (np. sesja) informacja o tym będzie ujęta w niniejszej polityce.',
        ),
      ]),
    ]),
    LegalSection('10. Zmiany', [
      LegalParagraph([
        LegalPiece(
          'Zmiany polityki będą publikowane w Aplikacji. Kontynuując korzystanie z aplikacji po ich wprowadzeniu, akceptujesz zaktualizowaną politykę.',
        ),
      ]),
    ]),
  ],
);

Future<void> openExternalUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
