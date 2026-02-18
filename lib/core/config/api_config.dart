import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get openAiApiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  
  static String get openFoodFactsApiUrl => 
    dotenv.env['OPEN_FOOD_FACTS_API_URL'] ?? 
    'https://world.openfoodfacts.org/api/v0';
  
  static bool get hasOpenAiKey => openAiApiKey.isNotEmpty;
}
