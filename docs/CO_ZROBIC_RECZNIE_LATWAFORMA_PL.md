# Co zrobić ręcznie – aplikacja od razu na latwaforma.pl

W kodzie wszystko jest już ustawione na **latwaforma.pl** (bez subdomeny app). Żeby strona **latwaforma.pl** od razu otwierała aplikację, musisz wykonać poniższe kroki w panelach (Netlify, DNS, Supabase). To jedyne rzeczy, których nie da się zrobić z poziomu kodu.

---

## 1. Netlify – domena główna

1. Wejdź na **app.netlify.com** i wybierz swój projekt (ten, który teraz ma domenę app.latwaforma.pl).
2. **Domain settings** (lub **Site configuration** → **Domain management**).
3. **Add custom domain** (lub **Add domain** → **Add an existing domain**).
4. Wpisz: **latwaforma.pl** (bez „app”, bez „www”) i zatwierdź.
5. Netlify pokaże, co ustawić w DNS (krok 2). Zostaw tę kartę otwartą.

**Opcja:** Jeśli chcesz, żeby stary adres **app.latwaforma.pl** dalej działał i przekierowywał na latwaforma.pl, w Netlify w **Domain settings** możesz dodać też **app.latwaforma.pl** i ustawić **Redirect** z app.latwaforma.pl na latwaforma.pl (w Netlify: Redirects – dodaj regułę: z `https://app.latwaforma.pl/*` na `https://latwaforma.pl/:splat` z kodem 301).

---

## 2. DNS (OVH lub gdzie masz domenę)

Domena **latwaforma.pl** musi wskazywać na Netlify, a nie na stary hosting (OVH).

1. Wejdź w panel domeny (np. OVH → **Domeny** → **latwaforma.pl** → **Strefa DNS**).
2. **Jeśli jest rekord A** dla samej **latwaforma.pl** (subdomena pusta lub „@”) wskazujący na IP hostingu OVH – **zmień go**:
   - **Typ:** CNAME (jeśli panel na to pozwala dla głównej domeny) **albo** A
   - **Cel / Wartość:** adres podany przez Netlify (w Domain settings przy latwaforma.pl zobaczysz np. „Configure external DNS” – tam będzie adres typu `loadbalancer.netlify.com` lub podobny; dla domeny głównej Netlify często podaje adres A, np. **75.2.60.5** – sprawdź w Netlify, co dokładnie pokazuje).
3. Zapisz zmiany. Propagacja DNS trwa zwykle 5–30 minut (czasem do kilku godzin).

**Uwaga:** W niektórych rejestratorach dla domeny głównej (bez www) nie da się ustawić CNAME – wtedy używany jest rekord **A** na adres IP podany przez Netlify. Netlify w instrukcji „Set up external DNS” pokaże, czy masz ustawić A, czy CNAME, i jaki dokładnie wpis.

---

## 3. Supabase – adresy dla logowania

Żeby logowanie (Google, e‑mail, „Zacznij bez konta”) działało na **latwaforma.pl**:

1. Wejdź na **supabase.com** → swój projekt → **Authentication** → **URL Configuration**.
2. **Site URL:** ustaw na **https://latwaforma.pl** (bez ukośnika na końcu lub zgodnie z tym, co pokazuje Supabase).
3. **Redirect URLs:** dopisz (każdy w osobnej linii):
   - `https://latwaforma.pl`
   - `https://latwaforma.pl/**`
4. Zapisz (Save).

Szczegóły są też w pliku **docs/SUPABASE_APP_LATWAFORMA_PL.md** (tylko adresy są tam już na latwaforma.pl).

---

## 4. (Opcjonalnie) Stripe – adresy powrotu po płatności

Jeśli w Stripe lub w zmiennych Supabase Edge Functions masz ustawione adresy **app.latwaforma.pl** po płatności (success/cancel), zmień je na **latwaforma.pl**. W kodzie są już domyślnie ustawione na latwaforma.pl; jeśli nadpisujesz je zmiennymi **STRIPE_SUCCESS_URL** / **STRIPE_CANCEL_URL** / **STRIPE_PORTAL_RETURN_URL**, ustaw tam **https://latwaforma.pl/#/premium-success** i **https://latwaforma.pl/#/premium-cancel**.

---

## 5. Strona informacyjna (landing) – co z nią?

Obecnie **latwaforma.pl** może być ustawione w DNS na hosting OVH (strona z przyciskiem „Otwórz aplikację”). Po zmianie DNS na Netlify **cała domena latwaforma.pl** będzie pokazywać aplikację – osobna strona „landing” z OVH przestanie się wyświetlać pod latwaforma.pl.

- **Chcesz tylko aplikację pod latwaforma.pl** – po ustawieniu DNS i Netlify nic więcej nie musisz robić; landing możesz zostawić na OVH pod innym adresem (np. nie używać go) lub usunąć.
- **Chcesz zachować krótką stronę informacyjną** – możesz np. zrobić podstronę w aplikacji (np. latwaforma.pl/o-nas) albo hostować prosty HTML gdzie indziej i linkować do latwaforma.pl.

---

## Podsumowanie

| Krok | Gdzie | Co zrobić |
|------|--------|-----------|
| 1 | Netlify | Dodać domenę **latwaforma.pl** w Domain settings. |
| 2 | OVH (DNS) | Ustawić **latwaforma.pl** (rekord A lub CNAME) na adres z Netlify. |
| 3 | Supabase | Site URL i Redirect URLs ustawić na **https://latwaforma.pl** (i latwaforma.pl/**). |
| 4 | (opcjonalnie) Stripe / zmienne | Success/Cancel URL zmienić na latwaforma.pl, jeśli używasz. |

Po propagacji DNS wejście na **https://latwaforma.pl** powinno od razu otwierać aplikację.
