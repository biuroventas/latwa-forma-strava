import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/platform_stub.dart' if (dart.library.io) '../../../core/utils/platform_io.dart' as platform;
import '../../../shared/models/meal.dart';
import '../../../shared/services/openai_service.dart';
import '../../../shared/widgets/health_disclaimer.dart';

class AIPhotoScreen extends StatefulWidget {
  const AIPhotoScreen({super.key, this.date});

  final DateTime? date;

  @override
  State<AIPhotoScreen> createState() => _AIPhotoScreenState();
}

class _AIPhotoScreenState extends State<AIPhotoScreen> {
  final OpenAIService _aiService = OpenAIService();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  Future<void> _pickImage() async {
    if (platform.isIOSSimulator) {
      final useGallery = await _showCameraUnavailable();
      if (useGallery == true && mounted) {
        await _pickImageFromGallery();
      }
      return;
    }
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _analysisResult = null;
          });
          _analyzeImage();
        }
      }
    } catch (e) {
      if (mounted) {
        final err = e.toString().toLowerCase();
        final isCameraUnavailable = err.contains('camera not available') ||
            err.contains('camera unavailable') ||
            err.contains('no camera') ||
            err.contains('kamera niedostępna');
        if (isCameraUnavailable) {
          final useGallery = await _showCameraUnavailable();
          if (useGallery == true && mounted) {
            await _pickImageFromGallery();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.trackPickImageError(error: '$e'))),
          );
        }
      }
    }
  }

  Future<bool?> _showCameraUnavailable() {
    final l10n = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.trackCameraUnavailableTitle),
        content: Text(l10n.trackCameraUnavailableBody),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: Text(l10n.commonOk),
          ),
          FilledButton(
            onPressed: () => ctx.pop(true),
            child: Text(l10n.trackFromGallery),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        if (mounted) {
          setState(() {
            _imageBytes = bytes;
            _analysisResult = null;
          });
          _analyzeImage();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.trackPickImageError(error: '$e'))),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final result = await _aiService.analyzeMealPhoto(
        _imageBytes!,
        languageCode: Localizations.localeOf(context).languageCode,
      );
      
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysisResult = result;
        });

        if (result == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.trackAnalysisFailedOpenAi),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.trackAnalysisError(error: '$e'))),
        );
      }
    }
  }

  Future<void> _addMeal() async {
    if (_analysisResult == null) return;

    final userId = SupabaseConfig.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.trackUserNotLoggedIn)),
        );
      }
      return;
    }

    final d = widget.date ?? DateTime.now();
    final meal = Meal(
      userId: userId,
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
      createdAt: DateTime(d.year, d.month, d.day, 12, 0),
    );
    final result = await context.push<bool>(AppRoutes.mealsAdd, extra: meal);
    if (result == true && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.trackAiPhotoTitle),
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
                      l10n.trackTakeMealPhoto,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.trackAiPhotoDescription,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    if (platform.isIOS) ...[
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
                                l10n.trackSimulatorCameraHint,
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
                    label: Text(l10n.trackTakePhoto),
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
                    label: Text(l10n.trackFromGallery),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Podgląd zdjęcia
            if (_imageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _imageBytes!,
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
                        l10n.trackAnalyzingPhoto,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.trackMayTakeAMoment,
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
                        l10n.trackAnalysisResults,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      _buildResultRow(l10n.trackName, _analysisResult!['name'] as String),
                      const Divider(),
                      _buildResultRow(l10n.trackCalories, '${(_analysisResult!['calories'] as double).toStringAsFixed(0)} kcal'),
                      _buildResultRow(l10n.trackProtein, '${(_analysisResult!['proteinG'] as double).toStringAsFixed(1)} g'),
                      _buildResultRow(l10n.trackFat, '${(_analysisResult!['fatG'] as double).toStringAsFixed(1)} g'),
                      _buildResultRow(l10n.trackCarbs, '${(_analysisResult!['carbsG'] as double).toStringAsFixed(1)} g'),
                      if (_analysisResult!['weightG'] != null)
                        _buildResultRow(l10n.trackWeight, '${(_analysisResult!['weightG'] as double).toStringAsFixed(0)} g'),
                      const SizedBox(height: 8),
                      const HealthDisclaimer(compact: true),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addMeal,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(l10n.trackAddMeal),
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
