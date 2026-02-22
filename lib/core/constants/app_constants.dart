class AppConstants {
  // App Info
  static const String appName = 'Łatwa Forma';
  
  // Default Values
  static const double defaultWaterGoal = 2000.0; // ml
  /// ml wody na 1 kg masy ciała dziennie (rekomendacja np. EFSA / 30–35 ml/kg)
  static const double waterMlPerKg = 35.0;
  static const double defaultWeightLossRate = 0.5; // kg per week
  static const double maxWeightLossRate = 1.0; // kg per week (zdrowe chudnięcie max 1 kg/tydz.)
  static const double defaultWeightGainRate = 0.25; // kg per week
  
  // Activity Levels Multipliers
  static const double sedentaryMultiplier = 1.2;
  static const double lightActivityMultiplier = 1.375;
  static const double moderateActivityMultiplier = 1.55;
  static const double intenseActivityMultiplier = 1.725;
  static const double veryIntenseActivityMultiplier = 1.9;
  
  // Macro Distribution (for weight loss)
  static const double proteinPerKg = 2.0; // grams per kg of target weight
  static const double fatPercentage = 0.25; // 25% of calories
  static const double carbCaloriesPerGram = 4.0;
  static const double proteinCaloriesPerGram = 4.0;
  static const double fatCaloriesPerGram = 9.0;

  // Max values for custom macros (realistyczne granice dzienne)
  static const double maxProteinG = 400.0;
  static const double maxFatG = 200.0;
  static const double maxCarbsG = 600.0;
  static const double maxCaloriesFromMacros = 8000.0;
  
  // Porada AI – limity zapytań dziennie
  static const int aiAdviceDailyLimit = 2; // bez Premium
  static const int aiAdvicePremiumDailyLimit = 100; // Premium (opłacony + trial 24h)

  // Logowanie opóźnione – po ilu posiłkach pokazać „Zapisz postępy”
  static const int saveProgressMealsThreshold = 5;

  // Streak Types
  static const String streakMeals = 'meals';
  static const String streakWater = 'water';
  static const String streakActivities = 'activities';
  static const String streakWeight = 'weight';
  
  // Default names when user doesn't provide one
  static const String defaultMealName = 'Bez nazwy';
  static const String defaultActivityName = 'Aktywność bez nazwy';

  // Meal Types
  static const String mealBreakfast = 'breakfast';
  static const String mealLunch = 'lunch';
  static const String mealDinner = 'dinner';
  static const String mealSnack = 'snack';
  
  // Meal Sources
  static const String mealSourceManual = 'manual';
  static const String mealSourceBarcode = 'barcode';
  static const String mealSourceIngredients = 'ingredients';
  static const String mealSourceAiPhoto = 'ai_photo';
  
  // Body Measurement Types
  static const String measurementWaist = 'waist';
  static const String measurementHips = 'hips';
  static const String measurementChest = 'chest';
  static const String measurementArm = 'arm';
  static const String measurementThigh = 'thigh';
  
  // Goals
  static const String goalWeightLoss = 'weight_loss';
  static const String goalWeightGain = 'weight_gain';
  static const String goalMaintain = 'maintain';
  
  // Genders
  static const String genderMale = 'male';
  static const String genderFemale = 'female';
  static const String genderOther = 'other';
  
  // Activity Levels
  static const String activitySedentary = 'sedentary';
  static const String activityLight = 'light';
  static const String activityModerate = 'moderate';
  static const String activityIntense = 'intense';
  static const String activityVeryIntense = 'very_intense';

  /// URL polityki prywatności (wymagane w sklepach i RODO).
  static const String privacyPolicyUrl = 'https://latwaforma.pl/polityka-prywatnosci.html';
  /// URL regulaminu (wymagane w sklepach). Po opublikowaniu regulaminu ustaw tutaj docelowy adres.
  static const String termsUrl = 'https://latwaforma.pl/regulamin.html';

  /// Adres powrotu po logowaniu Google/email na webie (musi być w Supabase Auth → Redirect URLs).
  static const String webAuthRedirectUrl = 'https://latwaforma.pl';

  /// Adres e-mail kontaktowy (dla użytkowników: polityka, regulamin, stopka).
  static const String contactEmail = 'contact@latwaforma.pl';
  /// Adres e-mail reprezentanta / właściciela (np. wniosek Garmin, dokumentacja).
  static const String ownerEmail = 'norbert.wroblewski@latwaforma.pl';

  /// URL do profilu Facebook (stopka „Śledź nas”). Gdy null – przycisk nieaktywny.
  static const String? socialFacebookUrl = null;
  /// URL do profilu Instagram (stopka „Śledź nas”). Gdy null – przycisk nieaktywny.
  static const String? socialInstagramUrl = null;
}
