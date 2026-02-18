import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  /// Odpowiada na pytania użytkownika o dietę, odżywianie i aktywność fizyczną
  Future<String?> getAdvice(String userQuestion) async {
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
