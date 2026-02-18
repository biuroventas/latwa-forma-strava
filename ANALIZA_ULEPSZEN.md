# Analiza aplikacji Łatwa Forma – rekomendacje ulepszeń

## 1. Błędy logiczne (do naprawy)

### 1.1 Dashboard → Posiłki / Aktywności – zła data przy nawigacji
**Problem:** Po wybraniu dnia w kalendarzu tygodniowym (np. wczoraj), po kliknięciu karty „Posiłki dzisiaj” lub „Aktywności dzisiaj” użytkownik trafia na listę **dzisiejszych** danych, a nie wybranego dnia.

**Gdzie:** `dashboard_screen.dart` – `_buildMealsCard` i `_buildActivitiesCard`:
```dart
await context.push(AppRoutes.meals, extra: today);  // BŁĄD: powinno być _selectedDate
await context.push(AppRoutes.activities, extra: today);  // BŁĄD: powinno być _selectedDate
```

**Rozwiązanie:** Zamiast `today` przekazywać `_selectedDate`. Dla spójności zmienić też tytuły kart – jeśli pokazują dane z wybranego dnia, nazwy powinny to odzwierciedlać (np. „Posiłki” zamiast „Posiłki dzisiaj”, lub dynamicznie np. „Posiłki – 12.02.2026”).

---

### 1.2 Dodawanie posiłku/aktywności przy wybranym innym dniu
**Problem:** Gdy użytkownik przegląda listę posiłków/aktywności dla wczoraj i klika „+”, nowy wpis jest zapisywany z `created_at = NOW()`, więc pojawia się w **dzisiejszym** dniu. Lista nie odświeża się o nowy wpis, co może być mylące.

**Rozwiązanie:**
- Przekazywać `date` do `AddMealScreen` i `AddActivityScreen`.
- Przy tworzeniu wpisu ustawiać `created_at` na wybrany dzień (np. środek wybranego dnia).
- Schemat pozwala na przekazanie `created_at` w `insert`.

---

## 2. Niespójności UX

### 2.1 Woda a wybrany dzień
**Problem:** Karta „Woda” na dashboardzie pokazuje wodę dla **wybranego dnia** (np. wczoraj), ale po kliknięciu ekran wody zawsze pokazuje **tylko dzisiaj**.

**Opcje:**
- **A)** Ekran wody obsługuje tylko „dziś” – wtedy na dashboardzie przy wybranym innym dniu albo nie pokazywać karty wody, albo dodać krótką informację: „Woda dotyczy tylko dzisiaj”.
- **B)** Ekran wody przyjmuje `date` – można oglądać wodę z dowolnego dnia (bez dodawania dla przeszłych dni).

---

### 2.2 Cel wody na stałe 2000 ml
**Problem:** Cel wody jest stały (`AppConstants.defaultWaterGoal` = 2000 ml), a zapotrzebowanie zależy od wagi, aktywności itd.

**Rozwiązanie:** Dodać pole `water_goal_ml` w profilu (lub liczyć z wagi, np. 30–35 ml/kg) i używać go zamiast stałej.

---

### 2.3 Ulubione → „Dodaj do dzisiejszych posiłków”
**Problem:** Ulubione można dodać tylko „do dzisiaj”. Gdy użytkownik jest w liście posiłków dla wczoraj, nadal dodaje do dzisiaj.

**Rozwiązanie:** Przekazać do `FavoriteMealsScreen` aktualnie wybraną datę i przy szybkim dodaniu zapisywać posiłek z tą datą (jeśli implementacja będzie wspierać `created_at` z parametrem).

---

## 3. Efektywność dla użytkownika

### 3.1 Dodaj posiłek – za dużo ikon w AppBar
**Problem:** AppBar ma 5 ikon (Jem na mieście, AI, Składniki, Kod, Ulubione), co może być przeładowane, zwłaszcza na małych ekranach.

**Rozwiązanie:**  
- Zastąpić część ikon jednym menu „Więcej” (3 kropki) z rozwijaną listą opcji.  
- Lub przenieść je do FAB / speed dialu zamiast AppBar.

---

### 3.2 Ekran wody – brak możliwości edycji wpisu
**Problem:** Wpisy wody można tylko usuwać, nie można ich edytować (np. poprawić 250 ml na 200 ml).

**Rozwiązanie:** Dodać ikonę edycji obok usuwania i dialog edycji z polem „Ilość (ml)”.

---

### 3.3 Komunikat sukcesu 4 sekundy
**Problem:** `SuccessMessage.show(..., duration: Duration(seconds: 4))` może być długie i blokować inne akcje.

**Rozwiązanie:** Skrócić do ok. 2–3 sekund albo użyć krótkiego snackbara (ok. 2 s).

---

### 3.4 Makroskładniki ukryte za checkboxem
**Problem:** Makroskładniki są domyślnie ukryte. Użytkownicy śledzący makra muszą je włączać za każdym razem.

**Rozwiązanie:**  
- Pokazywać makra domyślnie, albo  
- Zapisywać preferencję (np. SharedPreferences) i przywracać przy kolejnym wejściu.

---

### 3.5 Ekran posiłków – podwójny FAB
**Problem:** Lista posiłków ma FAB „+” i dodatkowo przycisk „+” w AppBar. Powoduje to redundancję.

**Rozwiązanie:** Zostawić jeden, np. FAB (bardziej widoczny) lub tylko ikonę w AppBar.

---

## 4. Usprawnienia nawigacji

### 4.1 Brak możliwości cofnięcia się na dashboard po dodaniu
**Problem:** Po dodaniu posiłku z FAB → Dodaj posiłek → Zapis → `context.pop(true)` wraca na dashboard. To jest poprawne; warto sprawdzić, czy podobnie działa dodawanie aktywności i wagi.

---

### 4.2 Ekran posiłków – brak zmiany dnia
**Problem:** Lista posiłków pokazuje dany dzień, ale nie ma możliwości przełączenia na inny (np. date picker, strzałki „następny / poprzedni dzień”).

**Rozwiązanie:** Gdy wchodzimy z dashboardu z wybraną datą – zachować obecne zachowanie. Dodać możliwość zmiany dnia (np. strzałki lub date picker w AppBar), żeby nie trzeba było wracać na dashboard.

---

## 5. Drobne poprawki

### 5.1 „Aktywności dzisiaj” przy innym dniu
**Problem:** Nagłówek „Aktywności dzisiaj” jest nieprawdziwy, gdy wyświetlane są dane z innego dnia.

**Rozwiązanie:** Używać dynamicznego nagłówka, np. „Aktywności – 12.02.2026” lub „Aktywności na ten dzień”.

---

### 5.2 Dialog własnej ilości wody – brak walidacji górnej granicy
**Problem:** Można wpisać np. 100 000 ml, co jest nierealne.

**Rozwiązanie:** Dodać walidację, np. max 5000 ml na wpis, oraz informację dla użytkownika.

---

### 5.3 Jem na mieście – stan początkowy
**Problem:** Po otwarciu bottom sheet żadna opcja nie jest wybrana; użytkownik może nacisnąć „Zapisz” bez wyboru.

**Rozwiązanie:** Sprawdzić, czy przy pustym wyborze przycisk jest zablokowany. Jeśli nie – dodać walidację i wyłączenie przycisku, dopóki nie wybrano opcji.

---

### 5.4 Usuwanie wody – brak potwierdzenia
**Problem:** Usuwanie wpisu wody odbywa się od razu, bez dialogu potwierdzenia (w przeciwieństwie do posiłków).

**Rozwiązanie:** Użyć `DeleteConfirmationDialog` także przy usuwaniu wpisów wody.

---

## 6. Podsumowanie priorytetów

| Priorytet | Element | Wysiłek | Wpływ |
|-----------|---------|---------|-------|
| **Wysoki** | Dashboard → przekazywanie `_selectedDate` do Posiłków i Aktywności | Niski | Duży |
| **Wysoki** | Dodawanie posiłku/aktywności z możliwością wyboru dnia | Średni | Duży |
| **Średni** | Cel wody z profilu | Średni | Średni |
| **Średni** | Edycja wpisów wody | Niski | Średni |
| **Średni** | Zapisywanie preferencji pokazywania makroskładników | Niski | Średni |
| **Niski** | Uproszczenie AppBar w Dodaj posiłek | Średni | Niski |
| **Niski** | Date picker w liście posiłków | Średni | Średni |
| **Niski** | Potwierdzenie przy usuwaniu wody | Bardzo niski | Niski |
| **Niski** | Skrócenie czasu sukcesu | Bardzo niski | Niski |
