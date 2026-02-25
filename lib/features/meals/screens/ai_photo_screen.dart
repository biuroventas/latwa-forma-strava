import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/meal.dart';
import '../../../shared/services/openai_service.dart';

class AIPhotoScreen extends StatefulWidget {
  const AIPhotoScreen({super.key});

  @override
  State<AIPhotoScreen> createState() => _AIPhotoScreenState();
}

class _AIPhotoScreenState extends State<AIPhotoScreen> {
  final OpenAIService _aiService = OpenAIService();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
        });
        _analyzeImage();
      }
    } catch (e) {
      if (mounted) {
        final err = e.toString().toLowerCase();
        final isCameraUnavailable = err.contains('camera not available') ||
            err.contains('camera unavailable') ||
            err.contains('no camera') ||
            err.contains('kamera niedostępna');
        if (isCameraUnavailable) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Kamera niedostępna'),
              content: const Text(
                'Kamera nie jest dostępna na tym urządzeniu (np. na symulatorze).\n\n'
                'Użyj przycisku „Z galerii”, aby wybrać zdjęcie z galerii.',
              ),
              actions: [
                TextButton(
                  onPressed: () => ctx.pop(),
                  child: const Text('OK'),
                ),
                FilledButton(
                  onPressed: () {
                    ctx.pop();
                    _pickImageFromGallery();
                  },
                  child: const Text('Z galerii'),
                ),
              ],
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Błąd wyboru zdjęcia: $e')),
          );
        }
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = null;
        });
        _analyzeImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd wyboru zdjęcia: $e')),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final result = await _aiService.analyzeMealPhoto(_selectedImage!);
      
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = result;
        });

        if (result == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nie udało się przeanalizować zdjęcia. Sprawdź czy klucz OpenAI API jest ustawiony.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd analizy: $e')),
        );
      }
    }
  }

  Future<void> _addMeal() async {
    if (_analysisResult == null) return;

    final meal = Meal(
      userId: SupabaseConfig.auth.currentUser!.id,
      name: _analysisResult!['name'] as String,
      calories: _analysisResult!['calories'] as double,
      proteinG: _analysisResult!['proteinG'] as double,
      fatG: _analysisResult!['fatG'] as double,
      carbsG: _analysisResult!['carbsG'] as double,
      saturatedFatG: (_analysisResult!['saturatedFatG'] as num?)?.toDouble() ?? 0,
      sugarG: (_analysisResult!['sugarG'] as num?)?.toDouble() ?? 0,
      fiberG: (_analysisResult!['fiberG'] as num?)?.toDouble() ?? 0,
      saltG: (_analysisResult!['saltG'] as num?)?.toDouble() ?? 0,
      weightG: _analysisResult!['weightG'] as double?,
      source: AppConstants.mealSourceAiPhoto,
    );
    final result = await context.push<bool>(AppRoutes.mealsAdd, extra: meal);
    if (result == true && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analiza zdjęcia AI'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instrukcja
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Icon(Icons.camera_alt, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Zrób zdjęcie posiłku',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'AI przeanalizuje zdjęcie i oszacuje wartości odżywcze',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    if (Platform.isIOS) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 20, color: Colors.amber.shade800),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Na symulatorze kamera nie działa – wybierz zdjęcie z galerii.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.amber.shade900,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Przyciski wyboru zdjęcia
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAnalyzing ? null : _pickImage,
                    icon: const Icon(Icons.camera),
                    label: const Text('Zrób zdjęcie'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isAnalyzing ? null : _pickImageFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Z galerii'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Podgląd zdjęcia
            if (_selectedImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
            ],
            // Status analizy
            if (_isAnalyzing)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Analizowanie zdjęcia...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'To może chwilę potrwać',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            // Wyniki analizy
            if (_analysisResult != null && !_isAnalyzing) ...[
              Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Wyniki analizy',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultRow('Nazwa', _analysisResult!['name'] as String),
                      const Divider(),
                      _buildResultRow('Kalorie', '${(_analysisResult!['calories'] as double).toStringAsFixed(0)} kcal'),
                      _buildResultRow('Białko', '${(_analysisResult!['proteinG'] as double).toStringAsFixed(1)} g'),
                      _buildResultRow('Tłuszcze', '${(_analysisResult!['fatG'] as double).toStringAsFixed(1)} g'),
                      _buildResultRow('Węglowodany', '${(_analysisResult!['carbsG'] as double).toStringAsFixed(1)} g'),
                      if (_analysisResult!['weightG'] != null)
                        _buildResultRow('Waga', '${(_analysisResult!['weightG'] as double).toStringAsFixed(0)} g'),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addMeal,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Dodaj posiłek'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
