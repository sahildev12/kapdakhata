import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/utils/date_utils.dart';
import 'package:kapdakhata/core/utils/money.dart';
import 'package:kapdakhata/core/widgets/k_buttons.dart';
import 'package:kapdakhata/core/widgets/k_cards.dart';
import 'package:kapdakhata/core/widgets/k_dialogs.dart';
import 'package:kapdakhata/core/widgets/k_inputs.dart';
import 'package:kapdakhata/database/app_database.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:kapdakhata/shared/repositories/repositories.dart';

final productDetailProvider =
    FutureProvider.family<ProductDetailData?, int>((ref, id) async {
  final db = ref.watch(databaseProvider);
  final item = await db.getProductWithCategory(id);
  if (item == null) return null;
  final stats = await db.getProductStats(id);
  return ProductDetailData(item: item, stats: stats);
});

class ProductDetailData {
  const ProductDetailData({required this.item, required this.stats});
  final ProductWithCategory item;
  final ProductStats stats;
}

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/products/$productId/edit'),
          ),
        ],
      ),
      body: detail.when(
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Product not found'));
          }
          final p = data.item.product;
          final profit = p.sellingPricePaise - p.costPricePaise;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (p.photoPath != null && File(p.photoPath!).existsSync())
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(p.photoPath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.purpleSubtle,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.checkroom,
                    size: 48,
                    color: AppColors.primaryPurple,
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                p.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${data.item.category.name}${p.size != null ? ' • ${p.size}' : ''}${p.color != null ? ' • ${p.color}' : ''}',
                style: const TextStyle(color: AppColors.mutedText),
              ),
              const SizedBox(height: 20),
              KProfitCard(profitPaise: profit),
              const SizedBox(height: 16),
              _InfoRow('Cost Price', MoneyFormatter.format(p.costPricePaise)),
              _InfoRow(
                'Selling Price',
                MoneyFormatter.format(p.sellingPricePaise),
              ),
              _InfoRow(
                'Stock',
                p.stockQuantity == 0 ? 'Out of stock' : '${p.stockQuantity}',
              ),
              _InfoRow('Qty Sold', '${data.stats.quantitySold}'),
              _InfoRow(
                'Total Revenue',
                MoneyFormatter.format(data.stats.totalRevenuePaise),
              ),
              _InfoRow(
                'Total Profit',
                MoneyFormatter.format(data.stats.totalProfitPaise),
              ),
              _InfoRow('Added', AppDateUtils.formatDate(p.createdAt)),
              if (p.notes != null && p.notes!.isNotEmpty)
                _InfoRow('Notes', p.notes!),
              const SizedBox(height: 24),
              KPrimaryButton(
                label: 'Record Sale',
                icon: Icons.point_of_sale,
                onPressed: () =>
                    context.push('/sales/add?productId=$productId'),
              ),
              const SizedBox(height: 12),
              KOutlinedButton(
                label: 'Add Stock',
                icon: Icons.add,
                onPressed: () => _addStock(context, ref, p),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => _deleteProduct(context, ref),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete Product'),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryPurple),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _addStock(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final controller = TextEditingController();
    final qty = await KAppDialog.show<int>(
      context: context,
      title: 'Add Stock',
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Quantity to add'),
      ),
      actionsBuilder: (dialogContext) => [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final q = int.tryParse(controller.text.trim());
            if (q != null && q > 0) Navigator.pop(dialogContext, q);
          },
          child: const Text('Add'),
        ),
      ],
    );

    if (qty != null) {
      await ref.read(productRepositoryProvider).addStock(product.id, qty);
      ref.invalidate(productDetailProvider(productId));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added $qty to stock')),
        );
      }
    }
  }

  Future<void> _deleteProduct(BuildContext context, WidgetRef ref) async {
    final confirmed = await KConfirmDialog.show(
      context,
      title: 'Delete this product?',
      message: 'This cannot be undone. Historical sales will remain intact.',
    );
    if (confirmed) {
      await ref.read(productRepositoryProvider).softDeleteProduct(productId);
      if (context.mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted')),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.mutedText)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
