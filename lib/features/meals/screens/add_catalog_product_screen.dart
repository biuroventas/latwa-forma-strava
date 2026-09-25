import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latwa_forma/l10n/l10n.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/platform_stub.dart'
    if (dart.library.io) '../../../core/utils/platform_io.dart' as platform;
import '../../../core/utils/success_message.dart';
import '../../../shared/services/openai_service.dart';
import '../../../shared/services/product_service.dart';

/// Brakujący produkt: zdjęcie etykiety albo ręczne wartości na 100 g,
/// zapis do wspólnej bazy, potem wybór porcji.
class AddCatalogProductScreen extends StatefulWidget {
  const AddCatalogProductScreen({
    super.key,
    this.barcode,
    this.initialName,
    this.date,
  });

  final String? barcode;
  final String? initialName;
  final DateTime? date;

  @override
  State<AddCatalogProductScreen> createState() => _AddCatalogProductScreenState();
}

class _AddCatalogProductScreenState extends State<AddCatalogProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _fat = TextEditingController();
  final _carbs = TextEditingController();
  final _picker = ImagePicker();
  final _ai = OpenAIService();
  final _products = ProductService();
  bool _reading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final name = widget.initialName?.trim();
    if (name != null && name.isNotEmpty) _name.text = name;
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _calories.dispose();
    _protein.dispose();
    _fat.dispose();
    _carbs.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    if (source == ImageSource.camera && platform.isIOSSimulator) {
      final useGallery = await _showCameraUnavailable();
      if (useGallery == true && mounted) {
        await _pick(ImageSource.gallery);
      }
      return;
    }
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return;
      await _readLabel(await file.readAsBytes());
    } catch (e) {
      if (!mounted) return;
      final err = e.toString().toLowerCase();
      final cameraMissing = err.contains('camera not available') ||
          err.contains('camera unavailable') ||
          err.contains('no camera');
      if (source == ImageSource.camera && cameraMissing) {
        final useGallery = await _showCameraUnavailable();
        if (useGallery == true && mounted) {
          await _pick(ImageSource.gallery);
        }
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.trackPickImageError(error: '$e'))),
      );
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

  Future<void> _readLabel(Uint8List bytes) async {
    setState(() => _reading = true);
    final language = Localizations.localeOf(context).languageCode;
    final label = await _ai.analyzeNutritionLabel(bytes, languageCode: language);
    if (!mounted) return;
    setState(() => _reading = false);
    if (label == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.trackLabelNotRead)),
      );
      return;
    }
    setState(() {
      _name.text = label['name'] as String? ?? _name.text;
      final brand = label['brand'] as String? ?? '';
      if (brand.isNotEmpty) _brand.text = brand;
      _calories.text = _num(label['calories']);
      _protein.text = _num(label['proteinG']);
      _fat.text = _num(label['fatG']);
      _carbs.text = _num(label['carbsG']);
    });
  }

  String _num(dynamic value) {
    final n = (value as num?)?.toDouble() ?? 0;
    if (n <= 0) return '';
    return n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(1);
  }

  double _field(TextEditingController controller) =>
      double.tryParse(controller.text.replaceAll(',', '.')) ?? 0;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _name.text.trim();
    final calories = _field(_calories);
    if (name.isEmpty || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.trackEnterNameAndCalories)),
      );
      return;
    }
    setState(() => _saving = true);
    final barcode = (widget.barcode?.trim().isNotEmpty ?? false)
        ? widget.barcode!.trim()
        : 'user:${DateTime.now().millisecondsSinceEpoch}';
    final brand = _brand.text.trim();
    final saved = await _products.saveProduct(
      barcode: barcode,
      name: name,
      brand: brand.isEmpty ? null : brand,
      caloriesPer100g: calories,
      proteinG: _field(_protein),
      fatG: _field(_fat),
      carbsG: _field(_carbs),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    final l10n = context.l10n;
    if (saved) {
      SuccessMessage.show(context, l10n.trackProductSavedCatalog, l10n: l10n);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.trackCatalogNotSaved)),
      );
    }
    final logged = await context.push<bool>(
      AppRoutes.barcodeProduct,
      extra: mealFlowExtra(
        product: {
          'name': name,
          'barcode': barcode,
          'calories': calories,
          'proteinG': _field(_protein),
          'fatG': _field(_fat),
          'carbsG': _field(_carbs),
          if (brand.isNotEmpty) 'brand': brand,
        },
        date: widget.date,
      ),
    );
    if (logged == true && mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final busy = _reading || _saving;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.trackAddToCatalog)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(l10n.trackLabelPhoto),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.trackFromGallery),
                  ),
                ),
              ],
            ),
            if (_reading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(l10n.trackReadingLabel),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.trackName),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? l10n.trackEnterNameAndCalories : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _brand,
              decoration: InputDecoration(labelText: l10n.trackBrandOptional),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _calories,
              decoration: InputDecoration(labelText: l10n.trackCaloriesPer100g),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,1}'))],
              validator: (value) {
                final n = double.tryParse((value ?? '').replaceAll(',', '.'));
                if (n == null || n <= 0) return l10n.trackEnterNameAndCalories;
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _protein,
              decoration: InputDecoration(labelText: l10n.trackProteinPer100g),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,1}'))],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fat,
              decoration: InputDecoration(labelText: l10n.trackFatPer100g),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,1}'))],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _carbs,
              decoration: InputDecoration(labelText: l10n.trackCarbsPer100g),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d{0,1}'))],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: busy ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}
