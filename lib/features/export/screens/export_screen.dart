import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/utils/success_message.dart';
import '../../../core/utils/error_handler.dart';
import '../../../shared/services/supabase_service.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../shared/widgets/premium_gate.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _isExporting = false;

  Future<void> _exportToCSV() async {
    setState(() => _isExporting = true);

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) throw Exception('Użytkownik nie jest zalogowany');

      final service = SupabaseService();
      
      // Pobierz dane (profil + posiłki + aktywności + waga)
      final profile = await service.getProfile(userId);
      final meals = await service.getMeals(userId);
      final activities = await service.getActivities(userId);
      final weightLogs = await service.getWeightLogs(userId, limit: 1000);

      // Generuj CSV
      final csv = StringBuffer();
      
      // Sekcja profilu
      csv.writeln('=== PROFIL ===');
      csv.writeln('Typ,Nazwa,Wartość');
      if (profile != null) {
        csv.writeln('Profil,Płeć,${profile.gender == "male" ? "Mężczyzna" : profile.gender == "female" ? "Kobieta" : "Inna"}');
        csv.writeln('Profil,Wiek,${profile.age} lat');
        csv.writeln('Profil,Wzrost,${profile.heightCm.toStringAsFixed(0)} cm');
        csv.writeln('Profil,Aktualna waga,${profile.currentWeightKg.toStringAsFixed(1)} kg');
        csv.writeln('Profil,Waga docelowa,${profile.targetWeightKg.toStringAsFixed(1)} kg');
        csv.writeln('Profil,Cel,${profile.goal == "weight_loss" ? "Utrata wagi" : profile.goal == "weight_gain" ? "Przybranie wagi" : "Utrzymanie"}');
        if (profile.bmr != null) csv.writeln('Profil,BMR,${profile.bmr!.toStringAsFixed(0)} kcal');
        if (profile.tdee != null) csv.writeln('Profil,TDEE,${profile.tdee!.toStringAsFixed(0)} kcal');
        if (profile.targetCalories != null) csv.writeln('Profil,Cel kaloryczny,${profile.targetCalories!.toStringAsFixed(0)} kcal');
        if (profile.targetProteinG != null) csv.writeln('Profil,Białko (g),${profile.targetProteinG!.toStringAsFixed(0)}');
        if (profile.targetFatG != null) csv.writeln('Profil,Tłuszcze (g),${profile.targetFatG!.toStringAsFixed(0)}');
        if (profile.targetCarbsG != null) csv.writeln('Profil,Węglowodany (g),${profile.targetCarbsG!.toStringAsFixed(0)}');
        if (profile.targetDate != null) csv.writeln('Profil,Szacowany termin osiągnięcia celu,${profile.targetDate!.day}.${profile.targetDate!.month}.${profile.targetDate!.year}');
      }
      csv.writeln();
      
      // Sekcja posiłków, aktywności i wagi
      csv.writeln('=== DANE DZIENNIKA ===');
      csv.writeln('Typ,Nazwa,Wartość,Data');
      
      for (var meal in meals) {
        csv.writeln('Posiłek,"${meal.name.replaceAll('"', '""')}",${meal.calories} kcal,${meal.createdAt?.toIso8601String() ?? ""}');
      }
      
      for (var activity in activities) {
        csv.writeln('Aktywność,"${activity.name.replaceAll('"', '""')}",${activity.caloriesBurned} kcal,${activity.createdAt?.toIso8601String() ?? ""}');
      }
      
      for (var weight in weightLogs) {
        csv.writeln('Waga,,${weight.weightKg} kg,${weight.createdAt?.toIso8601String() ?? ""}');
      }

      final csvContent = csv.toString();

      // Spróbuj zapisać do pliku i udostępnić
      try {
        final dir = await getTemporaryDirectory();
        final dateStr = DateTime.now().toIso8601String().split('T')[0];
        final file = File('${dir.path}/latwa_forma_export_$dateStr.csv');
        await file.writeAsString(csvContent, encoding: utf8);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Eksport danych Łatwa Forma',
          subject: 'Dane Łatwa Forma - $dateStr',
        );

        if (mounted) {
          SuccessMessage.show(
            context,
            'Plik CSV gotowy. Możesz go zapisać lub udostępnić.',
            duration: const Duration(seconds: 2),
          );
        }
      } on MissingPluginException catch (_) {
        // Fallback gdy path_provider nie jest dostępny – kopiuj do schowka
        await Clipboard.setData(ClipboardData(text: csvContent));
        if (mounted) {
          SuccessMessage.show(
            context,
            'Dane wyeksportowane do schowka (CSV). Wklej je np. do Notatek i zapisz jako plik .csv',
            duration: const Duration(seconds: 2),
          );
        }
      } on PlatformException catch (_) {
        // Fallback dla innych błędów platformy
        await Clipboard.setData(ClipboardData(text: csvContent));
        if (mounted) {
          SuccessMessage.show(
            context,
            'Dane wyeksportowane do schowka (CSV).',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (mounted) ErrorHandler.showSnackBar(context, error: e);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _exportToPDF() async {
    final canProceed = await checkPremiumOrNavigate(
      context,
      ref,
      featureName: 'Eksport do PDF',
    );
    if (!canProceed || !mounted) return;

    setState(() => _isExporting = true);

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) throw Exception('Użytkownik nie jest zalogowany');

      final service = SupabaseService();
      final profile = await service.getProfile(userId);
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      final meals = (await service.getMeals(userId))
          .where((m) => (m.createdAt ?? DateTime.now()).isAfter(cutoff))
          .toList()
        ..sort((a, b) => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
      final activities = (await service.getActivities(userId))
          .where((a) => (a.createdAt ?? DateTime.now()).isAfter(cutoff))
          .toList()
        ..sort((a, b) => (a.createdAt ?? DateTime(0)).compareTo(b.createdAt ?? DateTime(0)));
      final weightLogs = await service.getWeightLogs(userId, limit: 100);

      final pdf = pw.Document();
      final now = DateTime.now();
      final dateStr = '${now.day}.${now.month}.${now.year}';
      final fileDateStr = now.toIso8601String().split('T')[0];

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(24),
          header: (ctx) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 12),
            child: pw.Text(
              'Łatwa Forma – Raport',
              style: pw.Theme.of(ctx).defaultTextStyle.copyWith(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
          ),
          footer: (ctx) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 12),
            child: pw.Text(
              'Strona ${ctx.pageNumber} z ${ctx.pagesCount} • Wygenerowano $dateStr',
              style: pw.Theme.of(ctx).defaultTextStyle.copyWith(fontSize: 8),
            ),
          ),
          build: (ctx) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Podsumowanie profilu',
                style: pw.Theme.of(ctx).defaultTextStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
            ),
            if (profile != null) ...[
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(
                  'Płeć: ${profile.gender == "male" ? "Mężczyzna" : profile.gender == "female" ? "Kobieta" : "Inna"} • '
                  'Wiek: ${profile.age} lat • Wzrost: ${profile.heightCm.toStringAsFixed(0)} cm',
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(
                  'Waga: ${profile.currentWeightKg.toStringAsFixed(1)} kg • '
                  'Cel: ${profile.targetWeightKg.toStringAsFixed(1)} kg • '
                  'Cel kaloryczny: ${profile.targetCalories?.toStringAsFixed(0) ?? "-"} kcal',
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Text(
                  profile.goal == 'weight_loss'
                      ? 'Cel: Utrata wagi'
                      : profile.goal == 'weight_gain'
                          ? 'Cel: Przybranie wagi'
                          : 'Cel: Utrzymanie wagi',
                ),
              ),
            ] else pw.Padding(padding: const pw.EdgeInsets.only(bottom: 16), child: pw.Text('Brak profilu')),
            pw.Header(
              level: 0,
              child: pw.Text(
                'Ostatnie 30 dni – posiłki',
                style: pw.Theme.of(ctx).defaultTextStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
            ),
            if (meals.isEmpty)
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 16), child: pw.Text('Brak posiłków'))
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(child: pw.Text('Data'), padding: const pw.EdgeInsets.all(6)),
                      pw.Padding(child: pw.Text('Nazwa'), padding: const pw.EdgeInsets.all(6)),
                      pw.Padding(child: pw.Text('kcal'), padding: const pw.EdgeInsets.all(6)),
                    ],
                  ),
                  ...meals.take(100).map((m) {
                    final d = m.createdAt ?? DateTime.now();
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          child: pw.Text('${d.day}.${d.month}.${d.year}'),
                          padding: const pw.EdgeInsets.all(6),
                        ),
                        pw.Padding(
                          child: pw.Text(m.name.length > 40 ? '${m.name.substring(0, 40)}...' : m.name),
                          padding: const pw.EdgeInsets.all(6),
                        ),
                        pw.Padding(
                          child: pw.Text(m.calories.toStringAsFixed(0)),
                          padding: const pw.EdgeInsets.all(6),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 0,
              child: pw.Text(
                'Ostatnie 30 dni – aktywności',
                style: pw.Theme.of(ctx).defaultTextStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
            ),
            if (activities.isEmpty)
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 16), child: pw.Text('Brak aktywności'))
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(child: pw.Text('Data'), padding: const pw.EdgeInsets.all(6)),
                      pw.Padding(child: pw.Text('Nazwa'), padding: const pw.EdgeInsets.all(6)),
                      pw.Padding(child: pw.Text('kcal'), padding: const pw.EdgeInsets.all(6)),
                    ],
                  ),
                  ...activities.take(80).map((a) {
                    final d = a.createdAt ?? DateTime.now();
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          child: pw.Text('${d.day}.${d.month}.${d.year}'),
                          padding: const pw.EdgeInsets.all(6),
                        ),
                        pw.Padding(
                          child: pw.Text(a.name.length > 40 ? '${a.name.substring(0, 40)}...' : a.name),
                          padding: const pw.EdgeInsets.all(6),
                        ),
                        pw.Padding(
                          child: pw.Text(a.caloriesBurned.toStringAsFixed(0)),
                          padding: const pw.EdgeInsets.all(6),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 0,
              child: pw.Text(
                'Historia wagi',
                style: pw.Theme.of(ctx).defaultTextStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
            ),
            if (weightLogs.isEmpty)
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 16), child: pw.Text('Brak pomiarów'))
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(child: pw.Text('Data'), padding: const pw.EdgeInsets.all(6)),
                      pw.Padding(child: pw.Text('Waga (kg)'), padding: const pw.EdgeInsets.all(6)),
                    ],
                  ),
                  ...weightLogs.take(50).map((w) {
                    final d = w.createdAt ?? DateTime.now();
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          child: pw.Text('${d.day}.${d.month}.${d.year}'),
                          padding: const pw.EdgeInsets.all(6),
                        ),
                        pw.Padding(
                          child: pw.Text(w.weightKg.toStringAsFixed(1)),
                          padding: const pw.EdgeInsets.all(6),
                        ),
                      ],
                    );
                  }),
                ],
              ),
          ],
        ),
      );

      final bytes = await pdf.save();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/latwa_forma_raport_$fileDateStr.pdf');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Raport Łatwa Forma',
        subject: 'Raport Łatwa Forma - $dateStr',
      );

      if (mounted) {
        SuccessMessage.show(
          context,
          'Plik PDF gotowy. Możesz go zapisać lub udostępnić.',
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      if (mounted) ErrorHandler.showSnackBar(context, error: e);
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eksport danych'),
      ),
      body: LoadingOverlay(
        isLoading: _isExporting,
        child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eksport danych',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Wyeksportuj dane do pliku CSV (pełna lista) lub PDF (raport z ostatnich 30 dni). Otworzy się okno udostępniania.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isExporting ? null : _exportToCSV,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.table_chart),
              label: Text(_isExporting ? 'Eksportowanie...' : 'Eksportuj do CSV'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: _isExporting ? null : _exportToPDF,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: Text(_isExporting ? 'Eksportowanie...' : 'Eksportuj do PDF (Premium)'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
