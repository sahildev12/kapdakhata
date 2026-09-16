import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/money.dart';
import 'package:kapdakhata/core/widgets/k_cards.dart';
import 'package:kapdakhata/core/widgets/k_empty_state.dart';
import 'package:kapdakhata/core/widgets/k_filter_chip.dart';
import 'package:kapdakhata/database/app_database.dart';
import 'package:kapdakhata/features/home/presentation/widgets/dashboard_section_header.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  static const _sectionGap = 16.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportsMetricsProvider);
    final range = ref.watch(reportsRangeProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: AppLayout.filterRowHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ReportsRange.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final r = ReportsRange.values[index];
                return KFilterChip(
                  label: _rangeLabel(r),
                  selected: range == r,
                  onTap: () =>
                      ref.read(reportsRangeProvider.notifier).state = r,
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: reports.when(
              data: (data) {
                final m = data.metrics;
                if (m.totalSalesPaise == 0 && m.totalExpensesPaise == 0) {
                  return const KEmptyState(
                    icon: Icons.bar_chart,
                    title: 'Not enough data yet',
                    subtitle: 'Record sales and expenses to see reports.',
                  );
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    const DashboardSectionHeader(title: 'Overview'),
                    const SizedBox(height: 10),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1.55,
                      children: [
                        KFinancialSummaryCard(
                          label: 'Total Sales',
                          amountPaise: m.totalSalesPaise,
                        ),
                        KFinancialSummaryCard(
                          label: 'Total Cost',
                          amountPaise: m.totalCostPaise,
                        ),
                        KFinancialSummaryCard(
                          label: 'Gross Profit',
                          amountPaise: m.grossProfitPaise,
                        ),
                        KFinancialSummaryCard(
                          label: 'Expenses',
                          amountPaise: m.totalExpensesPaise,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    KFinancialSummaryCard(
                      label: 'Net Profit',
                      amountPaise: m.netProfitPaise,
                      isHighlighted: true,
                      subtitle: 'Products sold: ${m.productsSold}',
                    ),
                    const SizedBox(height: _sectionGap),
                    const DashboardSectionHeader(title: 'Profit & Loss'),
                    const SizedBox(height: 10),
                    KCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Column(
                        children: [
                          _PlRow('Revenue', m.totalSalesPaise),
                          _PlRow('COGS', m.totalCostPaise, isNegative: true),
                          _PlRow('Gross Profit', m.grossProfitPaise),
                          _PlRow(
                            'Expenses',
                            m.totalExpensesPaise,
                            isNegative: true,
                          ),
                          const Divider(height: 20),
                          _PlRow('Net Profit', m.netProfitPaise, isBold: true),
                        ],
                      ),
                    ),
                    if (data.monthlyTrend.length > 1) ...[
                      const SizedBox(height: _sectionGap),
                      const DashboardSectionHeader(title: 'Monthly Sales'),
                      const SizedBox(height: 10),
                      KCard(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          height: 200,
                          child: _SalesChart(data: data.monthlyTrend),
                        ),
                      ),
                      const SizedBox(height: _sectionGap),
                      const DashboardSectionHeader(title: 'Net Profit Trend'),
                      const SizedBox(height: 10),
                      KCard(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          height: 200,
                          child: _ProfitChart(data: data.monthlyTrend),
                        ),
                      ),
                    ],
                    if (data.expenseBreakdown.isNotEmpty) ...[
                      const SizedBox(height: _sectionGap),
                      const DashboardSectionHeader(title: 'Expense Breakdown'),
                      const SizedBox(height: 10),
                      ...data.expenseBreakdown.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: KCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    e.categoryName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  MoneyFormatter.format(e.amountPaise),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (data.topByQuantity.isNotEmpty) ...[
                      const SizedBox(height: _sectionGap),
                      const DashboardSectionHeader(title: 'Best Selling Products'),
                      const SizedBox(height: 10),
                      ...data.topByQuantity.map(
                        (p) => _TopProductTile(
                          name: p.productName,
                          subtitle: 'Qty: ${p.quantity}',
                          amount: p.profitPaise,
                        ),
                      ),
                    ],
                    if (data.topByProfit.isNotEmpty) ...[
                      const SizedBox(height: _sectionGap),
                      const DashboardSectionHeader(
                        title: 'Highest Profit Products',
                      ),
                      const SizedBox(height: 10),
                      ...data.topByProfit.map(
                        (p) => _TopProductTile(
                          name: p.productName,
                          subtitle: 'Profit',
                          amount: p.profitPaise,
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPurple),
              ),
              error: (e, _) => KErrorState(message: e.toString()),
            ),
          ),
        ],
      ),
    );
  }

  String _rangeLabel(ReportsRange range) {
    switch (range) {
      case ReportsRange.currentMonth:
        return 'This Month';
      case ReportsRange.previousMonth:
        return 'Previous';
      case ReportsRange.last3Months:
        return '3 Months';
      case ReportsRange.last6Months:
        return '6 Months';
      case ReportsRange.currentYear:
        return 'This Year';
      case ReportsRange.custom:
        return 'Custom';
    }
  }
}

class _PlRow extends StatelessWidget {
  const _PlRow(this.label, this.paise, {this.isNegative = false, this.isBold = false});

  final String label;
  final int paise;
  final bool isNegative;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold ? AppColors.primaryText : AppColors.mutedText,
            ),
          ),
          Text(
            '${isNegative ? '-' : ''}${MoneyFormatter.format(paise.abs())}',
            style: TextStyle(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: isBold
                  ? (paise >= 0 ? AppColors.positiveGreen : Colors.red)
                  : AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesChart extends StatelessWidget {
  const _SalesChart({required this.data});
  final List<MonthlyMetrics> data;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              data.length,
              (i) => FlSpot(i.toDouble(), data[i].totalSalesPaise / 100),
            ),
            isCurved: true,
            color: AppColors.primaryPurple,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.purpleSubtle,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfitChart extends StatelessWidget {
  const _ProfitChart({required this.data});
  final List<MonthlyMetrics> data;

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(data.length, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: data[i].netProfitPaise / 100,
                color: data[i].netProfitPaise >= 0
                    ? AppColors.positiveGreen
                    : Colors.red,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _TopProductTile extends StatelessWidget {
  const _TopProductTile({
    required this.name,
    required this.subtitle,
    required this.amount,
  });

  final String name;
  final String subtitle;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: KCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              MoneyFormatter.format(amount),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.positiveGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
