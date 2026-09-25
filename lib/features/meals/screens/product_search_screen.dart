import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latwa_forma/l10n/l10n.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/services/product_service.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import 'add_catalog_product_screen.dart';

/// Wyszukiwanie produktów po nazwie (najpierw własna baza, potem Open Food Facts).
/// Po wyborze produktu przechodzi do ekranu dodawania z wagą (jak po skanowaniu kodu).
class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key, this.initialQuery, this.date});

  final String? initialQuery;
  final DateTime? date;

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  late final TextEditingController _queryController;
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _products = [];
  bool _loading = false;
  String _lastQuery = '';
  Timer? _debounce;
  int _searchGen = 0;

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery != null && widget.initialQuery!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _runSearch(widget.initialQuery!.trim());
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().isEmpty) {
      _searchGen++;
      setState(() {
        _products = [];
        _loading = false;
        _lastQuery = '';
      });
      return;
    }
    final gen = ++_searchGen;
    setState(() => _loading = true);
    try {
      final results = await _productService.searchProducts(query.trim(), pageSize: 20);
      if (!mounted || gen != _searchGen) return;
      setState(() {
        _products = results;
        _loading = false;
        _lastQuery = query.trim();
      });
    } catch (e, st) {
      debugPrint('ProductSearchScreen: błąd wyszukiwania: $e');
      debugPrint('$st');
      if (!mounted || gen != _searchGen) return;
      setState(() {
        _products = [];
        _loading = false;
        _lastQuery = query.trim();
      });
    }
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _products = [];
        _lastQuery = '';
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () => _runSearch(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.trackSearchProductTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _queryController,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: context.l10n.trackSearchProductHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (v) => _runSearch(v),
              autofocus: true,
            ),
          ),
          Expanded(
            child: _buildBody(context),
          ),
        ],
      ),
    );
  }

  Future<void> _addMissing(String name) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddCatalogProductScreen(
          initialName: name,
          date: widget.date,
        ),
      ),
    );
    if (added == true && mounted) context.pop(true);
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_queryController.text.trim().isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.search,
          title: context.l10n.trackEnterProductName,
          subtitle: context.l10n.trackSearchProductSubtitle,
          iconColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
      );
    }
    if (_products.isEmpty && _lastQuery.isNotEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          title: context.l10n.trackNoResults,
          subtitle: context.l10n.trackNoResultsTryBarcode,
          iconColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
          action: FilledButton.icon(
            onPressed: () => _addMissing(_lastQuery),
            icon: const Icon(Icons.add),
            label: Text(context.l10n.trackAddToCatalog),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final p = _products[index];
        return _ProductTile(
          product: p,
          onTap: () async {
            final result = await context.push<bool>(
              AppRoutes.barcodeProduct,
              extra: mealFlowExtra(product: p, date: widget.date),
            );
            if (!context.mounted) return;
            if (result == true) context.pop(true);
          },
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onTap;

  const _ProductTile({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = product['name'] as String? ?? context.l10n.trackProduct;
    final brand = product['brand'] as String?;
    final cal = (product['calories'] as num?)?.toDouble();
    final imageUrl = product['imageUrl'] as String?;
    final hasData = cal != null && cal > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: imageUrl != null && imageUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, Object error, StackTrace? stackTrace) => _placeholderIcon(context),
                ),
              )
            : _placeholderIcon(context),
        title: Text(
          name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          [if (brand != null && brand.isNotEmpty) brand, if (hasData) '${cal.toStringAsFixed(0)} kcal / 100 g']
              .join(' · '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _placeholderIcon(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.restaurant, color: Theme.of(context).colorScheme.onSurfaceVariant),
    );
  }
}
