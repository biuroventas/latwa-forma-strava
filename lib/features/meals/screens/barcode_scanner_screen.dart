import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/platform_stub.dart'
    if (dart.library.io) '../../../core/utils/platform_io.dart' as platform;
import '../../../shared/services/product_service.dart';
import 'add_catalog_product_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key, this.date});

  final DateTime? date;

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final ProductService _productService = ProductService();
  bool _isProcessing = false;
  String? _lastScannedCode;
  final TextEditingController _barcodeController = TextEditingController();
  MobileScannerController? _controller;

  /// Symulator iOS: ręczne wpisanie (ML Kit). Prawdziwy iPhone: kamera.
  bool get _useManualEntryOnly {
    if (kIsWeb) return false;
    return platform.isIOSSimulator;
  }

  @override
  void initState() {
    super.initState();
    if (!_useManualEntryOnly) {
      _controller = MobileScannerController();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _barcodeController.dispose();
    super.dispose();
  }

  Future<void> _handleBarcodeFromInput(String code) async {
    if (code.isEmpty) return;
    await _processBarcode(code);
  }

  void _onBarcodeDetect(BarcodeCapture barcodeCapture) {
    if (_isProcessing) return;
    
    final barcode = barcodeCapture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;
    
    final code = barcode.rawValue!;
    _processBarcode(code);
  }

  Future<void> _processBarcode(String code) async {
    if (_isProcessing) return;
    // Unikaj wielokrotnego skanowania tego samego kodu
    if (_lastScannedCode == code) return;
    _lastScannedCode = code;

    setState(() => _isProcessing = true);

    try {
      // Najpierw własna baza (Turso/Supabase), potem Open Food Facts
      final product = await _productService.getProductByBarcode(code);
      
      if (!mounted) return;

      if (product == null) {
        _lastScannedCode = null;
        setState(() => _isProcessing = false);
        final added = await _offerAddToCatalog(code);
        if (added == true && mounted) context.pop(true);
        return;
      }

      // Przejdź do ekranu wpisania wagi i dodania posiłku
      final result = await context.push<bool>(
        AppRoutes.barcodeProduct,
        extra: mealFlowExtra(product: product, date: widget.date),
      );
      if (result == true && mounted) {
        context.pop(true);
        return;
      }
      _lastScannedCode = null;
    } catch (e) {
      _lastScannedCode = null;
      if (mounted) {
        _showErrorDialog(context.l10n.commonError, context.l10n.trackFetchProductFailed(error: '$e'));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<bool?> _offerAddToCatalog(String code) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.trackProductNotFoundTitle),
        content: Text(context.l10n.trackProductNotFound(code: code)),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: Text(context.l10n.commonOk),
          ),
          FilledButton(
            onPressed: () => dialogContext.pop(true),
            child: Text(context.l10n.trackAddToCatalog),
          ),
        ],
      ),
    ).then((add) async {
      if (add != true || !mounted) return false;
      return Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => AddCatalogProductScreen(
            barcode: code,
            date: widget.date,
          ),
        ),
      );
    });
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(context.l10n.commonOk),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorView() {
    final l10n = context.l10n;
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
                const SizedBox(height: 24),
                Text(
                  l10n.trackBarcodeScannerTitle,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.trackSimulatorEnterCode,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _barcodeController,
                  decoration: InputDecoration(
                    labelText: l10n.trackBarcodeLabel,
                    hintText: l10n.trackEnterProductCode,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.qr_code),
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: _handleBarcodeFromInput,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _handleBarcodeFromInput(_barcodeController.text),
                  icon: const Icon(Icons.search),
                  label: Text(l10n.trackSearchProduct),
                ),
              ],
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    l10n.trackFetchingProductData,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScannerView() {
    final l10n = context.l10n;
    if (_controller == null) {
      return Center(
        child: Text(l10n.trackScannerUnavailable),
      );
    }
    
    return Stack(
      children: [
        MobileScanner(
          controller: _controller!,
          onDetect: _onBarcodeDetect,
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    l10n.trackFetchingProductData,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        // Instrukcja
        Positioned(
          bottom: 32,
          left: 16,
          right: 16,
          child: Card(
            color: Colors.black.withValues(alpha: 0.7),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    l10n.trackPointAtBarcode,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.trackBarcodePrivacy,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.trackScanBarcode),
      ),
      body: _useManualEntryOnly ? _buildSimulatorView() : _buildScannerView(),
    );
  }
}
