import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/services/open_food_facts_service.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final OpenFoodFactsService _offService = OpenFoodFactsService();
  bool _isProcessing = false;
  String? _lastScannedCode;
  final TextEditingController _barcodeController = TextEditingController();
  MobileScannerController? _controller;

  // Check if running on simulator - disable mobile_scanner to avoid MLKit issues
  bool get _isSimulator {
    if (kIsWeb) return false;
    if (!Platform.isIOS) return false;
    // For now, always use manual input on iOS simulator to avoid MLKit framework issues
    return true;
  }

  @override
  void initState() {
    super.initState();
    if (!_isSimulator) {
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
    // Unikaj wielokrotnego skanowania tego samego kodu
    if (_lastScannedCode == code) return;
    _lastScannedCode = code;

    setState(() => _isProcessing = true);

    try {
      // Pobierz dane produktu z Open Food Facts
      final product = await _offService.getProductByBarcode(code);
      
      if (!mounted) return;

      if (product == null) {
        _showErrorDialog('Nie znaleziono produktu', 
            'Produkt o kodzie $code nie został znaleziony w bazie Open Food Facts.');
        setState(() => _isProcessing = false);
        return;
      }

      // Przejdź do ekranu wpisania wagi i dodania posiłku
      final result = await context.push<bool>(AppRoutes.barcodeProduct, extra: product);
      if (result == true && mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Błąd', 'Nie udało się pobrać danych produktu: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorView() {
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
                const Text(
                  'Skaner kodów kreskowych',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Na symulatorze wprowadź kod ręcznie',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _barcodeController,
                  decoration: const InputDecoration(
                    labelText: 'Kod kreskowy',
                    hintText: 'Wprowadź kod produktu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                  keyboardType: TextInputType.number,
                  onSubmitted: _handleBarcodeFromInput,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _handleBarcodeFromInput(_barcodeController.text),
                  icon: const Icon(Icons.search),
                  label: const Text('Szukaj produktu'),
                ),
              ],
            ),
          ),
        ),
        if (_isProcessing)
          Container(
            color: Colors.black.withValues(alpha: 0.7),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Pobieranie danych produktu...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScannerView() {
    if (_controller == null) {
      return const Center(
        child: Text('Skaner niedostępny - użyj symulatora lub urządzenia fizycznego'),
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
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Pobieranie danych produktu...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
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
                  const Text(
                    'Wskaż kod kreskowy produktu',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dane zostaną pobrane z bazy Open Food Facts',
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
        title: const Text('Skanuj kod kreskowy'),
      ),
      body: _isSimulator ? _buildSimulatorView() : _buildScannerView(),
    );
  }
}
