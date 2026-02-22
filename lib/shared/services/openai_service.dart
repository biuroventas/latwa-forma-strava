import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/supabase_config.dart';

class OpenAIService {
  static String? get apiKey => dotenv.env['OPENAI_API_KEY'];
  static const String baseUrl = 'https://api.openai.com/v1';
  static const String visionEndpoint = '$baseUrl/chat/completions';

  /// Analizuje zdjęcie posiłku i zwraca wartości odżywcze
  Future<Map<String, dynamic>?> analyzeMealPhoto(File imageFile) async {
    if (apiKey == null || apiKey!.isEmpty) {
      debugPrint('⚠️ OpenAI API key nie jest ustawiony');
      return null;
    }

    try {
      // Konwertuj zdjęcie do base64
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final imageDataUrl = 'data:image/jpeg;base64,$base64Image';

      // Przygotuj prompt
      const prompt = '''
Przeanalizuj zdjęcie posiłku i zwróć wartości odżywcze w formacie JSON:
{
  "name": "nazwa posiłku",
  "calories": liczba kalorii (szacunkowa),
  "proteinG": białko w gramach,
  "fatG": tłuszcze w gramach,
  "carbsG": węglowodany w gramach,
  "weightG": szacunkowa waga w gramach (opcjonalnie)
}

Zwróć TYLKO JSON, bez dodatkowych komentarzy. Jeśli nie możesz określić wartości, użyj 0.
''';

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
            'name': mealData['name'] as String? ?? 'Posiłek',
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

  /// Odpowiada na pytania użytkownika o dietę, odżywianie i aktywność fizyczną.
  /// Na webie używa Edge Function (brak CORS, klucz po stronie serwera). Na mobile – Edge Function lub bezpośrednio OpenAI z .env.
  Future<String?> getAdvice(String userQuestion) async {
    if (SupabaseConfig.isInitialized) {
      try {
        final response = await SupabaseConfig.client.functions.invoke(
          'ai-advice',
          body: {'question': userQuestion},
        );
        if (response.status != 200) {
          final data = response.data;
          String msg;
          if (response.status == 404) {
            msg = 'Funkcja Porady AI nie jest wdrożona. Uruchom w terminalu: supabase functions deploy ai-advice --no-verify-jwt';
          } else if (data is Map && data['error'] != null && data['error'] is String) {
            msg = data['error'] as String;
          } else {
            msg = 'Błąd usługi porad (${response.status}). Spróbuj ponownie.';
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
      const systemPrompt = '''Jesteś życzliwym ekspertem ds. żywienia i aktywności fizycznej w aplikacji Łatwa Forma.
Odpowiadaj krótko i konkretnie (max 2–3 akapity). Daj praktyczne porady.
Używaj języka polskiego. Nie podawaj informacji medycznych zastępujących konsultację z lekarzem.''';

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
