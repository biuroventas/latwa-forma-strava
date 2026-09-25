import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';

class OpenAIService {
  static String? get apiKey => dotenv.env['OPENAI_API_KEY'];
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String visionEndpoint = '$baseUrl/chat/completions';

  /// Analizuje zdjęcie posiłku (bajty) i zwraca wartości odżywcze. Działa na web i mobile.
  Future<Map<String, dynamic>?> analyzeMealPhoto(
    Uint8List imageBytes, {
    String languageCode = 'pl',
  }) async {
    if (apiKey == null || apiKey!.isEmpty) {
      debugPrint('⚠️ OpenAI API key nie jest ustawiony');
      return null;
    }

    try {
      final base64Image = base64Encode(imageBytes);
      final imageDataUrl = 'data:image/jpeg;base64,$base64Image';

      final prompt = switch (languageCode) {
        'en' => '''
Analyze the meal photo and return nutrition as JSON:
{
  "name": "meal name in English",
  "calories": estimated calories,
  "proteinG": protein in grams,
  "fatG": fat in grams,
  "carbsG": carbohydrates in grams,
  "weightG": estimated weight in grams (optional)
}

Return ONLY JSON, with no extra comments. If the photo has no food or you cannot estimate the values, use 0 and name "No meal". Estimates are approximate and are not medical advice.
''',
        'uk' => '''
Проаналізуй світлину страви і поверни поживну цінність у форматі JSON:
{
  "name": "назва страви українською",
  "calories": орієнтовні калорії,
  "proteinG": білки в грамах,
  "fatG": жири в грамах,
  "carbsG": вуглеводи в грамах,
  "weightG": орієнтовна вага в грамах (необов’язково)
}

Поверни ЛИШЕ JSON, без додаткових коментарів. Якщо на світлині немає їжі або не можна оцінити значення, використай 0 і name "Немає страви". Оцінки орієнтовні і не є медичною порадою.
''',
        _ => '''
Przeanalizuj zdjęcie posiłku i zwróć wartości odżywcze w formacie JSON:
{
  "name": "nazwa posiłku",
  "calories": liczba kalorii (szacunkowa),
  "proteinG": białko w gramach,
  "fatG": tłuszcze w gramach,
  "carbsG": węglowodany w gramach,
  "weightG": szacunkowa waga w gramach (opcjonalnie)
}

Zwróć TYLKO JSON, bez dodatkowych komentarzy. Jeśli na zdjęciu nie ma jedzenia lub nie możesz określić wartości, użyj 0 i name "Brak posiłku". Szacunki są orientacyjne, nie stanowią porady medycznej.
''',
      };

      // Wywołaj API
      final response = await http.post(
        Uri.parse(visionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'text',
                  'text': prompt,
                },
                {
                  'type': 'image_url',
                  'image_url': {
                    'url': imageDataUrl,
                  },
                },
              ],
            },
          ],
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final content = data['choices'][0]['message']['content'] as String;
        
        // Wyciągnij JSON z odpowiedzi (może zawierać markdown)
        final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
        if (jsonMatch != null) {
          final jsonString = jsonMatch.group(0)!;
          final mealData = json.decode(jsonString) as Map<String, dynamic>;
          
          return {
            'name': mealData['name'] as String? ?? switch (languageCode) {
              'en' => 'Meal',
              'uk' => 'Страва',
              _ => 'Posiłek',
            },
            'calories': (mealData['calories'] as num?)?.toDouble() ?? 0.0,
            'proteinG': (mealData['proteinG'] as num?)?.toDouble() ?? 0.0,
            'fatG': (mealData['fatG'] as num?)?.toDouble() ?? 0.0,
            'carbsG': (mealData['carbsG'] as num?)?.toDouble() ?? 0.0,
            'weightG': (mealData['weightG'] as num?)?.toDouble(),
          };
        }
      } else {
        debugPrint('Błąd OpenAI API: ${response.statusCode} - ${response.body}');
      }
      
      return null;
    } catch (e) {
      debugPrint('Błąd analizy zdjęcia: $e');
      return null;
    }
  }

  /// Czyta tabelę wartości odżywczych z etykiety i zwraca dane na 100 g.
  Future<Map<String, dynamic>?> analyzeNutritionLabel(
    Uint8List imageBytes, {
    String languageCode = 'pl',
  }) async {
    if (apiKey == null || apiKey!.isEmpty) return null;

    final prompt = switch (languageCode) {
      'en' => '''
Read the nutrition table on this food label. Return values PER 100 g (or per 100 ml), not per serving, as JSON:
{
  "name": "product name from the package",
  "brand": "brand or empty string",
  "calories": kcal per 100 g,
  "proteinG": protein grams per 100 g,
  "fatG": fat grams per 100 g,
  "carbsG": carbohydrate grams per 100 g
}
Return ONLY JSON. If the photo has no nutrition table, use 0 and name "".
''',
      'uk' => '''
Прочитай таблицю поживної цінності на етикетці. Поверни значення НА 100 г (або на 100 мл), не на порцію, у форматі JSON:
{
  "name": "назва продукту з упаковки",
  "brand": "бренд або порожній рядок",
  "calories": ккал на 100 г,
  "proteinG": білки в грамах на 100 г,
  "fatG": жири в грамах на 100 г,
  "carbsG": вуглеводи в грамах на 100 г
}
Поверни ЛИШЕ JSON. Якщо на світлині немає таблиці, використай 0 і name "".
''',
      _ => '''
Odczytaj tabelę wartości odżywczych z etykiety. Zwróć wartości NA 100 g (albo na 100 ml), nie na porcję, w formacie JSON:
{
  "name": "nazwa produktu z opakowania",
  "brand": "marka albo pusty tekst",
  "calories": kcal na 100 g,
  "proteinG": białko w gramach na 100 g,
  "fatG": tłuszcz w gramach na 100 g,
  "carbsG": węglowodany w gramach na 100 g
}
Zwróć TYLKO JSON. Jeśli na zdjęciu nie ma tabeli, użyj 0 i name "".
''',
    };

    try {
      final imageDataUrl = 'data:image/jpeg;base64,${base64Encode(imageBytes)}';
      final response = await http.post(
        Uri.parse(visionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-4o',
          'messages': [
            {
              'role': 'user',
              'content': [
                {'type': 'text', 'text': prompt},
                {
                  'type': 'image_url',
                  'image_url': {'url': imageDataUrl},
                },
              ],
            },
          ],
          'max_tokens': 400,
        }),
      );
      if (response.statusCode != 200) return null;
      final data = json.decode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(content);
      if (jsonMatch == null) return null;
      final label = json.decode(jsonMatch.group(0)!) as Map<String, dynamic>;
      final name = (label['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) return null;
      return {
        'name': name,
        'brand': (label['brand'] as String?)?.trim() ?? '',
        'calories': (label['calories'] as num?)?.toDouble() ?? 0.0,
        'proteinG': (label['proteinG'] as num?)?.toDouble() ?? 0.0,
        'fatG': (label['fatG'] as num?)?.toDouble() ?? 0.0,
        'carbsG': (label['carbsG'] as num?)?.toDouble() ?? 0.0,
      };
    } catch (e) {
      debugPrint('Błąd odczytu etykiety: $e');
      return null;
    }
  }

  /// Odpowiada na pytania użytkownika o dietę, odżywianie i aktywność fizyczną.
  /// Na webie używa Edge Function (brak CORS, klucz po stronie serwera). Na mobile – Edge Function lub bezpośrednio OpenAI z .env.
  Future<String?> getAdvice(String userQuestion, {String languageCode = 'pl'}) async {
    if (SupabaseConfig.isInitialized) {
      try {
        final response = await SupabaseConfig.client.functions.invoke(
          'ai-advice',
          body: {'question': userQuestion, 'language': languageCode},
        );
        if (response.status != 200) {
          final data = response.data;
          String msg;
          if (response.status == 404) {
            msg = switch (languageCode) {
              'en' => 'AI advice is not available yet. Try again later.',
              'uk' => 'Порада ШІ ще недоступна. Спробуй пізніше.',
              _ => 'Funkcja Porady AI nie jest wdrożona. Uruchom w terminalu: supabase functions deploy ai-advice --no-verify-jwt',
            };
          } else if (data is Map && data['error'] != null && data['error'] is String) {
            msg = data['error'] as String;
          } else {
            msg = switch (languageCode) {
              'en' => 'Advice service error (${response.status}). Try again.',
              'uk' => 'Помилка служби порад (${response.status}). Спробуй знову.',
              _ => 'Błąd usługi porad (${response.status}). Spróbuj ponownie.',
            };
          }
          debugPrint('Błąd ai-advice: ${response.status} $msg');
          throw Exception(msg);
        }
        final data = response.data;
        if (data is Map && data['content'] != null) {
          return data['content'] as String?;
        }
        return null;
      } catch (e) {
        debugPrint('Błąd porady AI (Edge Function): $e');
        if (e is FunctionException) {
          final details = e.details;
          if (details is Map && details['error'] != null && details['error'] is String) {
            throw Exception(details['error'] as String);
          }
        }
        rethrow;
      }
    }

    // Fallback: bezpośrednie wywołanie OpenAI (np. lokalnie z .env, bez Supabase)
    if (apiKey == null || apiKey!.isEmpty) {
      debugPrint('⚠️ OpenAI API key nie jest ustawiony');
      return null;
    }

    try {
      final systemPrompt = switch (languageCode) {
        'en' => '''You are a friendly nutrition and physical activity expert in the Łatwa Forma app.
Answer briefly and specifically (max 2–3 paragraphs). Give practical advice.
Use English.
Do not diagnose illnesses, prescribe medication, or replace a medical consultation.
Refuse requests for dangerous diets, extreme calorie restriction, self-harm, illegal, or medical content.
If the question is about a disease, symptoms, or treatment, suggest talking to a doctor or dietitian.
End the short answer with: "This is not medical advice."''',
        'uk' => '''Ти доброзичливий експерт із харчування та фізичної активності в застосунку Łatwa Forma.
Відповідай коротко і конкретно (максимум 2–3 абзаци). Давай практичні поради.
Використовуй українську мову.
Не став діагнозів, не призначай ліків і не замінюй консультацію лікаря.
Відхиляй прохання про небезпечні дієти, крайнє обмеження калорій, самоушкодження, незаконний або медичний зміст.
Якщо питання стосується хвороби, симптомів або лікування — порадь звернутися до лікаря чи дієтолога.
Наприкінці короткої відповіді додай: «Це не медична порада.»''',
        _ => '''Jesteś życzliwym ekspertem ds. żywienia i aktywności fizycznej w aplikacji Łatwa Forma.
Odpowiadaj krótko i konkretnie (max 2–3 akapity). Daj praktyczne porady.
Używaj języka polskiego.
Nie diagnozuj chorób, nie przepisuj leków i nie zastępuj konsultacji z lekarzem.
Odrzucaj prośby o niebezpieczne diety, skrajne ograniczenie kalorii, treści samookaleczające, nielegalne lub medyczne.
Jeśli pytanie dotyczy choroby, objawów lub leczenia – zasugeruj konsultację z lekarzem lub dietetykiem.
Na końcu krótkiej odpowiedzi dodaj: „To nie jest porada medyczna.”''',
      };

      final response = await http.post(
        Uri.parse(visionEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userQuestion},
          ],
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices']?[0]?['message']?['content'] as String?;
      }
      debugPrint('Błąd OpenAI API: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Błąd porady AI: $e');
      return null;
    }
  }
}
