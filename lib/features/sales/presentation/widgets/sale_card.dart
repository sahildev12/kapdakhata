import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/date_utils.dart';
import 'package:kapdakhata/core/utils/money.dart';
import 'package:kapdakhata/database/app_database.dart';

class SaleCard extends StatelessWidget {
  const SaleCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final SaleWithProduct item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sale = item.sale;
    final profit = sale.profitPaise;
    final profitColor =
        profit >= 0 ? AppColors.positiveGreen : AppColors.negativeRed;

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
                  _SaleImage(photoPath: item.product.photoPath),
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
                                    item.product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: AppLayout.bodySize,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Qty: ${sale.quantity}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.mutedText,
                                    ),
                                  ),
                                  Text(
                                    AppDateUtils.formatDate(sale.saleDate),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.mutedText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricColumn(
                                label: 'Cost',
                                value: MoneyFormatter.format(sale.totalCostPaise),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: AppColors.border,
                            ),
                            Expanded(
                              child: _MetricColumn(
                                label: 'Sell',
                                value: MoneyFormatter.format(
                                  sale.totalSellingAmountPaise,
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 28,
                              color: AppColors.border,
                            ),
                            Expanded(
                              child: _MetricColumn(
                                label: 'Profit',
                                value: MoneyFormatter.format(profit),
                                valueColor: profitColor,
                              ),
                            ),
                          ],
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
}

class _SaleImage extends StatelessWidget {
  const _SaleImage({this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 76,
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
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const _Placeholder(),
                )
              : const _Placeholder(),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

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

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.label,
    required this.value,
    this.valueColor = AppColors.primaryText,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
