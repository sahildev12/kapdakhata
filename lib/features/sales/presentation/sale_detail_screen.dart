import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/date_utils.dart';
import 'package:kapdakhata/core/utils/money.dart';
import 'package:kapdakhata/core/widgets/k_cards.dart';
import 'package:kapdakhata/core/widgets/k_empty_state.dart';
import 'package:kapdakhata/database/app_database.dart';
import 'package:kapdakhata/features/home/presentation/widgets/dashboard_section_header.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';

final saleDetailProvider =
    FutureProvider.family<SaleWithProduct?, int>((ref, id) async {
  return ref.watch(databaseProvider).getSaleWithProduct(id);
});

class SaleDetailScreen extends ConsumerWidget {
  const SaleDetailScreen({super.key, required this.saleId});

  final int saleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sale = ref.watch(saleDetailProvider(saleId));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Sale Details',
          style: TextStyle(
            fontSize: AppLayout.titleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: sale.when(
        data: (data) {
          if (data == null) {
            return const KEmptyState(
              icon: Icons.point_of_sale_outlined,
              title: 'Sale not found',
              subtitle: 'This sale record may have been removed.',
            );
          }
          final s = data.sale;
          final profit = s.profitPaise;
          final profitColor =
              profit >= 0 ? AppColors.positiveGreen : AppColors.negativeRed;

          return ListView(
            padding: const EdgeInsets.all(AppLayout.dashboardPadding),
            children: [
              _SaleHeroCard(item: data),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius:
                      BorderRadius.circular(AppLayout.dashboardCardRadius),
                  border: Border.all(color: AppColors.border),
                  boxShadow: const [AppColors.cardShadow],
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: _MetricColumn(
                        label: 'Cost',
                        value: MoneyFormatter.format(s.totalCostPaise),
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppColors.border),
                    Expanded(
                      child: _MetricColumn(
                        label: 'Sell',
                        value: MoneyFormatter.format(s.totalSellingAmountPaise),
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppColors.border),
                    Expanded(
                      child: _MetricColumn(
                        label: 'Profit',
                        value: MoneyFormatter.format(profit),
                        valueColor: profitColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              KProfitCard(profitPaise: profit, compact: false),
              const SizedBox(height: 16),
              const DashboardSectionHeader(title: 'Details'),
              const SizedBox(height: 8),
              KCard(
                child: Column(
                  children: [
                    KDetailRow(label: 'Sale ID', value: '#${s.id}'),
                    const Divider(height: 1),
                    KDetailRow(label: 'Quantity', value: '${s.quantity}'),
                    const Divider(height: 1),
                    KDetailRow(
                      label: 'Unit Cost',
                      value: MoneyFormatter.format(s.unitCostPaise),
                    ),
                    const Divider(height: 1),
                    KDetailRow(
                      label: 'Unit Selling',
                      value: MoneyFormatter.format(s.unitSellingPricePaise),
                    ),
                    const Divider(height: 1),
                    KDetailRow(
                      label: 'Date',
                      value: AppDateUtils.formatDate(s.saleDate),
                    ),
                    const Divider(height: 1),
                    KDetailRow(
                      label: 'Time',
                      value: AppDateUtils.formatTime(s.saleDate),
                    ),
                    if (s.notes != null && s.notes!.isNotEmpty) ...[
                      const Divider(height: 1),
                      KDetailRow(label: 'Notes', value: s.notes!),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const KLoadingState(),
        error: (e, _) => KErrorState(message: 'Error: $e'),
      ),
    );
  }
}

class _SaleHeroCard extends StatelessWidget {
  const _SaleHeroCard({required this.item});

  final SaleWithProduct item;

  @override
  Widget build(BuildContext context) {
    final sale = item.sale;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppColors.cardShadow],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SaleImage(photoPath: item.product.photoPath),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: AppLayout.headlineSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Qty: ${sale.quantity} • ${AppDateUtils.formatDate(sale.saleDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 8),
                if (item.product.size != null || item.product.color != null)
                  KBadge(
                    label: [
                      if (item.product.size != null) item.product.size!,
                      if (item.product.color != null) item.product.color!,
                    ].join(' • '),
                  ),
              ],
            ),
          ),
        ],
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
      height: 76,
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
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
