import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/date_utils.dart';
import 'package:kapdakhata/core/utils/money.dart';
import 'package:kapdakhata/database/app_database.dart';

class RecentSaleTile extends StatelessWidget {
  const RecentSaleTile({
    super.key,
    required this.sale,
    this.onTap,
  });

  final SaleWithProduct sale;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final profit = sale.sale.profitPaise;
    final isProfit = profit >= 0;
    final profitColor =
        isProfit ? AppColors.positiveGreen : AppColors.negativeRed;
    final profitLabel = isProfit
        ? '${MoneyFormatter.format(profit)} profit'
        : '${MoneyFormatter.format(profit.abs())} loss';

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
            child: Row(
              children: [
                _ProductThumbnail(photoPath: sale.product.photoPath),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sale.product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppLayout.bodySize,
                          color: AppColors.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Qty: ${sale.sale.quantity} • ${MoneyFormatter.format(sale.sale.totalSellingAmountPaise)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppDateUtils.formatDate(sale.sale.saleDate),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      profitLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppLayout.bodySize,
                        color: profitColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductThumbnail extends StatelessWidget {
  const _ProductThumbnail({this.photoPath});

  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.lavenderSubtle,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: photoPath != null && photoPath!.isNotEmpty
          ? Image.file(
              File(photoPath!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.checkroom_outlined,
                color: AppColors.primaryPurple,
                size: 22,
              ),
            )
          : const Icon(
              Icons.checkroom_outlined,
              color: AppColors.primaryPurple,
              size: 22,
            ),
    );
  }
}
