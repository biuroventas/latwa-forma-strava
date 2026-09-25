import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/utils/download_bytes_stub.dart'
    if (dart.library.html) '../../../core/utils/download_bytes_web.dart' as download_util;
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/success_message.dart';
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

  String _genderLabel(AppLocalizations l10n, String? gender) {
    if (gender == 'male') return l10n.moreGenderMale;
    if (gender == 'female') return l10n.moreGenderFemale;
    return l10n.moreGenderOther;
  }

  String _goalLabel(AppLocalizations l10n, String goal) {
    if (goal == 'weight_loss') return l10n.moreGoalWeightLoss;
    if (goal == 'weight_gain') return l10n.moreGoalWeightGain;
    return l10n.moreGoalMaintain;
  }

  Future<void> _exportToCSV() async {
    final l10n = context.l10n;
    setState(() => _isExporting = true);

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) throw Exception(l10n.moreUserNotLoggedIn);

      final service = SupabaseService();
      
      // Pobierz dane (profil + posiłki + aktywności + waga)
      final profile = await service.getProfile(userId);
      final meals = await service.getMeals(userId);
      final activities = await service.getActivities(userId);
      final weightLogs = await service.getWeightLogs(userId, limit: 1000);

      // Generuj CSV
      final csv = StringBuffer();
      
      // Sekcja profilu
      csv.writeln(l10n.moreCsvSectionProfile);
      csv.writeln(l10n.moreCsvHeaderTypeNameValue);
      if (profile != null) {
        csv.writeln('${l10n.moreCsvProfile},${l10n.moreCsvGender},${_genderLabel(l10n, profile.gender)}');
        csv.writeln('${l10n.moreCsvProfile},${l10n.moreCsvAge},${l10n.moreCsvAgeYears(age: '${profile.age}')}');
        csv.writeln('${l10n.moreCsvProfile},${l10n.moreCsvHeight},${profile.heightCm.toStringAsFixed(0)} cm');
        csv.writeln('${l10n.moreCsvProfile},${l10n.moreCsvCurrentWeight},${profile.currentWeightKg.toStringAsFixed(1)} kg');
        csv.writeln('${l10n.moreCsvProfile},${l10n.moreCsvTargetWeight},${profile.targetWeightKg.toStringAsFixed(1)} kg');
        csv.writeln('${l10n.moreCsvProfile},${l10n.moreCsvGoal},${_goalLabel(l10n, profile.goal)}');
        if (profile.bmr != null) csv.writeln('${l10n.moreCsvProfile},BMR,${profile.bmr!.toStringAsFixed(0)} kcal');
        if (profile.tdee != null) csv.writeln('${l10n.moreCsvProfile},TDEE,${profile.tdee!.toStringAsFixed(0)} kcal');
        if (profile.targetCalories != null) csv.writeln('${l10n.moreCsvProfile},${l10n.moreCsvCalorieGoal},${profile.targetCalories!.toStringAsFixed(0)} kcal');
        if (profile.targetProteinG != null) csv.writeln('${l10n.moreCsvProfile},${l10n.moreCsvProteinG},${profile.targetProteinG!.toStringAsFixed(0)}');
        if (profile.targetFatG != null) csv.writeln('${l10n.moreCsvProfile},${l10n.moreCsvFatG},${profile.targetFatG!.toStringAsFixed(0)}');
        if (profile.targetCarbsG != null) csv.writeln('${l10n.moreCsvProfile},${l10n.moreCsvCarbsG},${profile.targetCarbsG!.toStringAsFixed(0)}');
        if (profile.targetDate != null) csv.writeln('${l10n.moreCsvProfile},${l10n.moreCsvTargetDate},${profile.targetDate!.day}.${profile.targetDate!.month}.${profile.targetDate!.year}');
      }
      csv.writeln();
      
      // Sekcja posiłków, aktywności i wagi (Garmin: attribution adjacent to data per API Brand Guidelines)
      csv.writeln(l10n.moreCsvSectionDiary);
      if (activities.any((a) => a.isFromGarmin)) {
        csv.writeln(l10n.moreCsvGarminNote);
      }
      csv.writeln(l10n.moreCsvHeaderDiary);
      
      for (var meal in meals) {
        csv.writeln('${l10n.moreCsvMeal},"${meal.name.replaceAll('"', '""')}",${meal.calories} kcal,${meal.createdAt?.toIso8601String() ?? ""},');
      }
      
      for (var activity in activities) {
        final source = activity.isFromGarmin ? 'Garmin' : '';
        csv.writeln('${l10n.moreCsvActivity},"${activity.name.replaceAll('"', '""')}",${activity.caloriesBurned} kcal,${activity.createdAt?.toIso8601String() ?? ""},$source');
      }
      
      for (var weight in weightLogs) {
        csv.writeln('${l10n.moreCsvWeight},,${weight.weightKg} kg,${weight.createdAt?.toIso8601String() ?? ""}');
      }

      final csvContent = csv.toString();
      final dateStr = DateTime.now().toIso8601String().split('T')[0];

      // Na webie Share często nie działa – od razu kopiuj do schowka i pokaż sukces.
      if (kIsWeb) {
        await Clipboard.setData(ClipboardData(text: csvContent));
        if (mounted) {
          SuccessMessage.show(
            context,
            l10n.moreCsvCopiedClipboard,
            l10n: l10n,
            duration: const Duration(seconds: 3),
          );
        }
        return;
      }

      try {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/latwa_forma_export_$dateStr.csv');
        await file.writeAsString(csvContent, encoding: utf8);
        await Share.shareXFiles(
          [XFile(file.path)],
          text: l10n.moreExportShareText,
          subject: l10n.moreExportShareSubject(date: dateStr),
        );
        if (mounted) {
          SuccessMessage.show(
            context,
            l10n.moreCsvFileReady,
            l10n: l10n,
            duration: const Duration(seconds: 2),
          );
        }
      } on MissingPluginException catch (_) {
        // Fallback gdy path_provider nie jest dostępny – kopiuj do schowka
        await Clipboard.setData(ClipboardData(text: csvContent));
        if (mounted) {
          SuccessMessage.show(
            context,
            l10n.moreCsvClipboardFallback,
            l10n: l10n,
            duration: const Duration(seconds: 2),
          );
        }
      } on PlatformException catch (_) {
        // Fallback dla innych błędów platformy
        await Clipboard.setData(ClipboardData(text: csvContent));
        if (mounted) {
          SuccessMessage.show(
            context,
            l10n.moreCsvClipboardShort,
            l10n: l10n,
            duration: const Duration(seconds: 2),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showSnackBar(
          context,
          l10n: l10n,
          error: e,
          fallback: l10n.moreExportFailed,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  /// Na webie: tylko ASCII (bez czcionki TTF), żeby uniknąć FormatException UTF-8 w pakiecie pdf.
  static const _plToAscii = {
    0x104: 'A', 0x105: 'a', 0x106: 'C', 0x107: 'c', 0x118: 'E', 0x119: 'e',
    0x141: 'L', 0x142: 'l', 0x143: 'N', 0x144: 'n', 0xD3: 'O', 0xF3: 'o',
    0x15A: 'S', 0x15B: 's', 0x179: 'Z', 0x17A: 'z', 0x17B: 'Z', 0x17C: 'z',
    0xA0: ' ', 0x2013: '-', 0x2022: '*',
  };
  static String _toAsciiForPdf(String s) {
    if (s.isEmpty) return s;
    final buf = StringBuffer();
    for (final rune in s.runes) {
      if (rune >= 0x20 && rune <= 0x7E) {
        buf.writeCharCode(rune);
      } else {
        buf.write(_plToAscii[rune] ?? '?');
      }
    }
    return buf.toString();
  }


  Future<void> _exportToPDF() async {
    final l10n = context.l10n;
    final canProceed = await checkPremiumOrNavigate(
      context,
      ref,
      featureName: l10n.moreExportPdfFeature,
    );
    if (!canProceed || !mounted) return;

    setState(() => _isExporting = true);

    try {
      final userId = SupabaseConfig.auth.currentUser?.id;
      if (userId == null) throw Exception(l10n.moreUserNotLoggedIn);

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

      // Wszędzie (web + mobile): bez czcionki TTF, tylko ASCII – unikamy FormatException UTF-8 w pakiecie pdf.
      String pdfText(String s) => _toAsciiForPdf(s);

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
              pdfText(l10n.morePdfReportTitle),
              style: pw.Theme.of(ctx).defaultTextStyle.copyWith(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
          ),
          footer: (ctx) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 12),
            child: pw.Text(
              pdfText(l10n.morePdfPageFooter(
                page: '${ctx.pageNumber}',
                pages: '${ctx.pagesCount}',
                date: dateStr,
              )),
              style: pw.Theme.of(ctx).defaultTextStyle.copyWith(fontSize: 8),
            ),
          ),
          build: (ctx) => [
            pw.Header(
              level: 0,
              child: pw.Text(
                pdfText(l10n.morePdfProfileSummary),
                style: pw.Theme.of(ctx).defaultTextStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
            ),
            if (profile != null) ...[
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(pdfText(
                  l10n.morePdfProfileLine1(
                    gender: _genderLabel(l10n, profile.gender),
                    age: '${profile.age}',
                    height: profile.heightCm.toStringAsFixed(0),
                  ),
                )),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 8),
                child: pw.Text(pdfText(
                  l10n.morePdfProfileLine2(
                    weight: profile.currentWeightKg.toStringAsFixed(1),
                    target: profile.targetWeightKg.toStringAsFixed(1),
                    calories: profile.targetCalories?.toStringAsFixed(0) ?? '-',
                  ),
                )),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 16),
                child: pw.Text(pdfText(
                  profile.goal == 'weight_loss'
                      ? l10n.morePdfGoalWeightLoss
                      : profile.goal == 'weight_gain'
                          ? l10n.morePdfGoalWeightGain
                          : l10n.morePdfGoalMaintain,
                )),
              ),
            ] else pw.Padding(padding: const pw.EdgeInsets.only(bottom: 16), child: pw.Text(pdfText(l10n.morePdfNoProfile))),
            pw.Header(
              level: 0,
              child: pw.Text(
                pdfText(l10n.morePdfMealsLast30),
                style: pw.Theme.of(ctx).defaultTextStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
            ),
            if (meals.isEmpty)
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 16), child: pw.Text(pdfText(l10n.morePdfNoMeals)))
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(child: pw.Text(pdfText(l10n.morePdfDate)), padding: const pw.EdgeInsets.all(6)),
                      pw.Padding(child: pw.Text(pdfText(l10n.morePdfName)), padding: const pw.EdgeInsets.all(6)),
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
                          child: pw.Text(() {
                            final safe = pdfText(m.name);
                            return safe.length > 40 ? '${safe.substring(0, 40)}...' : safe;
                          }()),
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
                pdfText(l10n.morePdfActivitiesLast30),
                style: pw.Theme.of(ctx).defaultTextStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
            ),
            if (activities.isEmpty)
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 16), child: pw.Text(pdfText(l10n.morePdfNoActivities)))
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(child: pw.Text(pdfText(l10n.morePdfDate)), padding: const pw.EdgeInsets.all(6)),
                      pw.Padding(child: pw.Text(pdfText(l10n.morePdfName)), padding: const pw.EdgeInsets.all(6)),
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
                          child: pw.Text(() {
                            final safe = pdfText(a.name);
                            return safe.length > 40 ? '${safe.substring(0, 40)}...' : safe;
                          }()),
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
            if (activities.any((a) => a.isFromGarmin))
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 8),
                child: pw.Text(
                  pdfText(l10n.morePdfGarminAttribution),
                  style: pw.Theme.of(ctx).defaultTextStyle.copyWith(fontSize: 8),
                ),
              ),
            pw.SizedBox(height: 20),
            pw.Header(
              level: 0,
              child: pw.Text(
                pdfText(l10n.morePdfWeightHistory),
                style: pw.Theme.of(ctx).defaultTextStyle.copyWith(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
              ),
            ),
            if (weightLogs.isEmpty)
              pw.Padding(padding: const pw.EdgeInsets.only(bottom: 16), child: pw.Text(pdfText(l10n.morePdfNoMeasurements)))
            else
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300),
                children: [
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                    children: [
                      pw.Padding(child: pw.Text(pdfText(l10n.morePdfDate)), padding: const pw.EdgeInsets.all(6)),
                      pw.Padding(child: pw.Text(pdfText(l10n.morePdfWeightKg)), padding: const pw.EdgeInsets.all(6)),
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
      if (kIsWeb) {
        final pdfFileName = 'latwa_forma_raport_$fileDateStr.pdf';
        try {
          final xFile = XFile.fromData(
            bytes,
            name: pdfFileName,
            mimeType: 'application/pdf',
          );
          await Share.shareXFiles(
            [xFile],
            text: l10n.morePdfReportShareText,
            subject: l10n.morePdfReportShareSubject(date: dateStr),
          );
        } catch (_) {
          // Fallback: pobranie pliku (np. gdy przeglądarka nie obsługuje udostępniania PDF)
          try {
            await download_util.downloadBytesAsFile(bytes, pdfFileName, mimeType: 'application/pdf');
            if (mounted) {
              SuccessMessage.show(
                context,
                l10n.morePdfDownloaded,
                l10n: l10n,
            duration: const Duration(seconds: 3),
              );
            }
            return;
          } catch (_) {
            if (mounted) {
              ErrorHandler.showSnackBar(
          context,
          l10n: l10n,
                error: Exception('download'),
                fallback: l10n.morePdfShareOrDownloadFailed,
              );
            }
            return;
          }
        }
      } else {
        // Mobile: Printing.sharePdf (iOS sheet) + fallback Share z sharePositionOrigin
        final pdfFileName = 'latwa_forma_raport_$fileDateStr.pdf';
        var shared = false;
        try {
          await Printing.sharePdf(bytes: bytes, filename: pdfFileName);
          shared = true;
        } catch (e) {
          debugPrint('Printing.sharePdf failed: $e');
        }
        if (!shared) {
          try {
            final dir = await getTemporaryDirectory();
            final file = File('${dir.path}/$pdfFileName');
            await file.writeAsBytes(bytes);
            if (!mounted) return;
            final size = MediaQuery.sizeOf(context);
            final origin = Rect.fromCenter(
              center: Offset(size.width / 2, size.height / 2),
              width: 2,
              height: 2,
            );
            await Share.shareXFiles(
              [XFile(file.path, mimeType: 'application/pdf', name: pdfFileName)],
              text: l10n.morePdfReportShareText,
              subject: l10n.morePdfReportShareSubject(date: dateStr),
              sharePositionOrigin: origin,
            );
          } catch (e) {
            if (mounted) {
              ErrorHandler.showSnackBar(
                context,
                l10n: l10n,
                error: e,
                fallback: l10n.morePdfShareFailed,
              );
            }
            return;
          }
        }
      }

      if (mounted) {
        SuccessMessage.show(
          context,
          l10n.morePdfFileReady,
          l10n: l10n,
            duration: const Duration(seconds: 2),
        );
      }
    } catch (e, st) {
      debugPrint('Eksport PDF: $e');
      debugPrint('$st');
      if (mounted) {
        final hint = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        final shortHint = hint.length > 60 ? '${hint.substring(0, 57)}...' : hint;
        ErrorHandler.showSnackBar(
          context,
          l10n: l10n,
          error: e,
          fallback: shortHint.isNotEmpty
              ? l10n.morePdfExportFailedWithHint(hint: shortHint)
              : l10n.morePdfExportFailed,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.moreExportTitle),
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
                      l10n.moreExportTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.moreExportDescription,
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
              label: Text(_isExporting ? l10n.moreExporting : l10n.moreExportToCsv),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _isExporting ? null : _exportToPDF,
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: Text(_isExporting ? l10n.moreExporting : l10n.moreExportToPdfPremium),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                overlayColor: Colors.black26,
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
