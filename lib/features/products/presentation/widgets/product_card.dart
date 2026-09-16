import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/money.dart';
import 'package:kapdakhata/database/app_database.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ProductWithCategory item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final profit = product.sellingPricePaise - product.costPricePaise;
    final subtitle = _buildSubtitle(item);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
            border: Border.all(color: AppColors.border),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProductImage(photoPath: product.photoPath),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: AppLayout.bodySize,
                                      color: AppColors.primaryText,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.mutedText,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            StockInfo(stock: product.stockQuantity),
                          ],
                        ),
                        const Spacer(),
                        PriceInfo(
                          costPaise: product.costPricePaise,
                          sellPaise: product.sellingPricePaise,
                          profitPaise: profit,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _buildSubtitle(ProductWithCategory item) {
    final category = item.category.name;
    final size = item.product.size?.trim();
    if (size != null && size.isNotEmpty) {
      return '$category • $size';
    }
    return category;
  }
}

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, this.photoPath});

  final String? photoPath;

  static const _width = 76.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.lavenderSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: photoPath != null && photoPath!.isNotEmpty
              ? Image.file(
                  File(photoPath!),
                  width: _width,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _PlaceholderIcon(),
                )
              : const _PlaceholderIcon(),
        ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  const _PlaceholderIcon();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.checkroom_outlined,
        color: AppColors.primaryPurple,
        size: 32,
      ),
    );
  }
}

class PriceInfo extends StatelessWidget {
  const PriceInfo({
    super.key,
    required this.costPaise,
    required this.sellPaise,
    required this.profitPaise,
  });

  final int costPaise;
  final int sellPaise;
  final int profitPaise;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PriceColumn(
            label: 'Cost',
            value: MoneyFormatter.format(costPaise),
            color: AppColors.primaryText,
          ),
        ),
        Container(width: 1, height: 28, color: AppColors.border),
        Expanded(
          child: _PriceColumn(
            label: 'Sell',
            value: MoneyFormatter.format(sellPaise),
            color: AppColors.primaryText,
          ),
        ),
        Container(width: 1, height: 28, color: AppColors.border),
        Expanded(
          child: _PriceColumn(
            label: 'Profit',
            value: MoneyFormatter.format(profitPaise),
            color: AppColors.positiveGreen,
          ),
        ),
      ],
    );
  }
}

class _PriceColumn extends StatelessWidget {
  const _PriceColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class StockInfo extends StatelessWidget {
  const StockInfo({super.key, required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          'Stock',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$stock',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}
