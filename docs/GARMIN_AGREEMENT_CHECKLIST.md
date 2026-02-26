# Garmin Connect Developer Program Agreement – checklist zgodności

Skrót kluczowych obowiązków z umowy GCDP (FRM-0952), które dotyczą Łatwej Formy. Pełna umowa ma pierwszeństwo.

---

## Dane i prywatność

- **Polityka prywatności** – wyraźna informacja o przetwarzaniu danych z Garmin, link do polityki Garmin Connect: https://www.garmin.com/privacy/connect (np. w opisie integracji / polityce aplikacji).
- **Zgoda użytkownika** – dane z API tylko w zakresie zgody; użytkownik musi móc **wycofać zgodę** (np. „Odłącz Garmin”).
- **Nie sprzedawać** danych użytkowników z API bez prawnej zgody (§15.5).
- **AI / uczenie modeli** – jeśli dane z Garmin są używane do trenowania lub przetwarzania przez systemy AI, w polityce prywatności musi być **AI Transparency Statement** (§15.10).

---

## Branding i atrybucja

- **Wytyczne Garmin:** https://developer.garmin.com/brand-guidelines/overview/
- **Garmin Brand Features** – przy informowaniu, że użytkownik może pobrać dane z Garmin Connect (lub wgrać do Garmin), używać nazwy/logo zgodnie z wytycznymi.
- **Atrybucja** – przy wyświetlaniu danych z urządzeń Garmin (Garmin Device Sourced Data) wobec użytkowników lub third party – zgodnie z Garmin API Brand Guidelines (§6.4). W Łatwej Formie: np. „(Garmin)” przy aktywności – warto zweryfikować z wytycznymi.
- **Nowe formaty / UI** z danymi Garmin lub z użyciem Garmin Brand – **30 dni przed** wdrożeniem: mail do **connect-support@developer.garmin.com** z opisem / mockupami i potwierdzeniem zgodności z brandingiem (§6.6).

---

## Bezpieczeństwo

- **Minimum Security Requirements** – zabezpieczenie danych i systemów na poziomie co najmniej przyjętych praktyk; client secret i tokeny po stronie serwera, nie w publicznym kodzie.
- **Incydenty** – w ciągu **24 godzin** od wykrycia: powiadomienie Garmin  
  - **security@garmin.com**  
  - **+1 913.440.3500**  
  w przypadku: luk w zabezpieczeniach zagrażających systemom/danym Garmin, potwierdzonego wycieku danych (Personal Data Breach) lub poważnego incydentu bezpieczeństwa systemów współpracujących z Garmin (§5.1(g)(h)).

---

## Zakazy (wybór)

- Nie używać API w aplikacjach „where human life may be at stake” (§5.2(d)).
- Nie sprzedawać/udostępniać License Key ani nie czerpać z samego API dochodu bez pisemnej zgody Garmin (§5.2(e)).
- Nie prosić użytkowników o dane logowania do Garmin; tylko oficjalny flow autoryzacji (OAuth) (§15.8).
- Nie używać API do konkurencji wobec Garmin ani do promocji produktów konkurencyjnych (§5.2(t)).

---

## Kontakty

- **Wsparcie / pytania techniczne i programowe:** connect-support@developer.garmin.com  
- **Bezpieczeństwo / incydenty:** security@garmin.com, +1 913.440.3500  
- **Pisemne komunikacje prawne:** Garmin International, Inc., Attn: Legal Department, 1200 East 151st Street, Olathe, Kansas 66062 (§16.9)

---

*Dokument ma charakter pomocniczy. Obowiązuje pełna treść Garmin Connect Developer Program Agreement (FRM-0952 Rev. E).*
