import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/services/product_service.dart';
import '../../../shared/widgets/empty_state_widget.dart';

/// Wyszukiwanie produktów po nazwie (najpierw własna baza, potem Open Food Facts).
/// Po wyborze produktu przechodzi do ekranu dodawania z wagą (jak po skanowaniu kodu).
class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  final ProductService _productService = ProductService();
  List<Map<String, dynamic>> _products = [];
  bool _loading = false;
  String _lastQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _runSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _products = [];
        _loading = false;
        _lastQuery = '';
      });
      return;
    }
    setState(() => _loading = true);
    final results = await _productService.searchProducts(query.trim(), pageSize: 24);
    if (mounted) {
      setState(() {
        _products = results;
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
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(value));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wyszukaj produkt'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _queryController,
              onChanged: _onQueryChanged,
              decoration: InputDecoration(
                hintText: 'Nazwa produktu, np. mleko, nutella…',
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

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_queryController.text.trim().isEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.search,
          title: 'Wpisz nazwę produktu',
          subtitle: 'Korzystamy z bazy Open Food Facts. Wyniki pojawią się po wpisaniu min. kilku liter.',
          iconColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
      );
    }
    if (_products.isEmpty && _lastQuery.isNotEmpty) {
      return Center(
        child: EmptyStateWidget(
          icon: Icons.inventory_2_outlined,
          title: 'Brak wyników',
          subtitle: 'Spróbuj innej nazwy lub zeskanuj kod kreskowy produktu.',
          iconColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
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
            final result = await context.push<bool>(AppRoutes.barcodeProduct, extra: p);
            if (mounted && result == true) context.pop(true);
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
    final name = product['name'] as String? ?? 'Produkt';
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
                  errorBuilder: (_, __, ___) => _placeholderIcon(context),
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
