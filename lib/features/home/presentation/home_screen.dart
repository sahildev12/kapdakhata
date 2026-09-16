import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/date_utils.dart';
import 'package:kapdakhata/core/utils/money.dart';
import 'package:kapdakhata/core/widgets/k_empty_state.dart';
import 'package:kapdakhata/features/home/presentation/widgets/dashboard_header.dart';
import 'package:kapdakhata/features/home/presentation/widgets/dashboard_month_selector.dart';
import 'package:kapdakhata/features/home/presentation/widgets/dashboard_section_header.dart';
import 'package:kapdakhata/features/home/presentation/widgets/net_profit_card.dart';
import 'package:kapdakhata/features/home/presentation/widgets/products_sold_card.dart';
import 'package:kapdakhata/features/home/presentation/widgets/quick_action_card.dart';
import 'package:kapdakhata/features/home/presentation/widgets/recent_sale_tile.dart';
import 'package:kapdakhata/features/home/presentation/widgets/summary_card.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final month = ref.watch(selectedMonthProvider);
    final metrics = ref.watch(monthlyMetricsProvider);
    final previousMetrics = ref.watch(previousMonthMetricsProvider);
    final recentSales = ref.watch(recentSalesProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(monthlyMetricsProvider);
            ref.invalidate(previousMonthMetricsProvider);
            ref.invalidate(recentSalesProvider);
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.dashboardPadding,
                    12,
                    AppLayout.dashboardPadding,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      settings.when(
                        data: (s) => DashboardHeader(
                          greeting: AppDateUtils.greeting(),
                          ownerName: s.ownerName,
                          onNotificationTap: () => context.push('/notifications'),
                        ),
                        loading: () => DashboardHeader(
                          greeting: AppDateUtils.greeting(),
                          ownerName: '',
                          isLoading: true,
                          onNotificationTap: () => context.push('/notifications'),
                        ),
                        error: (_, _) => DashboardHeader(
                          greeting: AppDateUtils.greeting(),
                          ownerName: 'Shop Owner',
                          onNotificationTap: () => context.push('/notifications'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      DashboardMonthSelector(
                        selectedMonth: month,
                        onChanged: (m) =>
                            ref.read(selectedMonthProvider.notifier).state = m,
                      ),
                    ],
                  ),
                ),
              ),
              metrics.when(
                data: (m) {
                  final prev = previousMetrics.valueOrNull;
                  final profitChange = prev != null
                      ? MoneyFormatter.formatChangePercent(
                          m.netProfitPaise,
                          prev.netProfitPaise,
                        )
                      : null;

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.dashboardPadding,
                      16,
                      AppLayout.dashboardPadding,
                      8,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 2.6,
                          children: [
                            SummaryCard(
                              label: 'Total Sales',
                              amountPaise: m.totalSalesPaise,
                              icon: Icons.currency_rupee_rounded,
                              accentColor: AppColors.primaryPurple,
                              backgroundColor: AppColors.lavenderSubtle,
                              onTap: () => context.go('/sales'),
                            ),
                            SummaryCard(
                              label: 'Product Cost',
                              amountPaise: m.totalCostPaise,
                              icon: Icons.shopping_bag_outlined,
                              accentColor: AppColors.orangeAccent,
                              backgroundColor: AppColors.orangeSubtle,
                              onTap: () => context.push('/reports'),
                            ),
                            SummaryCard(
                              label: 'Gross Profit',
                              amountPaise: m.grossProfitPaise,
                              icon: Icons.trending_up_rounded,
                              accentColor: AppColors.positiveGreen,
                              backgroundColor: AppColors.greenSubtle,
                              onTap: () => context.push('/reports'),
                            ),
                            SummaryCard(
                              label: 'Expenses',
                              amountPaise: m.totalExpensesPaise,
                              icon: Icons.receipt_long_outlined,
                              accentColor: AppColors.pinkAccent,
                              backgroundColor: AppColors.pinkSubtle,
                              onTap: () => context.go('/expenses'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        NetProfitCard(
                          amountPaise: m.netProfitPaise,
                          changeLabel: profitChange,
                          onTap: () => context.push('/reports'),
                        ),
                        const SizedBox(height: 8),
                        ProductsSoldCard(
                          count: m.productsSold,
                          onTap: () => context.go('/sales'),
                        ),
                        const SizedBox(height: 16),
                        DashboardSectionHeader(title: 'Quick Actions'),
                        const SizedBox(height: 8),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 3.4,
                          children: [
                            QuickActionCard(
                              label: 'Sell',
                              icon: Icons.point_of_sale_rounded,
                              accentColor: AppColors.primaryPurple,
                              backgroundColor: AppColors.lavenderSubtle,
                              onTap: () => context.push('/sales/add'),
                            ),
                            QuickActionCard(
                              label: 'Add Expense',
                              icon: Icons.receipt_long_rounded,
                              accentColor: AppColors.pinkAccent,
                              backgroundColor: AppColors.pinkSubtle,
                              onTap: () => context.push('/expenses/add'),
                            ),
                            QuickActionCard(
                              label: 'Reports',
                              icon: Icons.assessment_outlined,
                              accentColor: AppColors.blueAccent,
                              backgroundColor: AppColors.blueSubtle,
                              onTap: () => context.push('/reports'),
                            ),
                            QuickActionCard(
                              label: 'Products',
                              icon: Icons.inventory_2_outlined,
                              accentColor: AppColors.positiveGreen,
                              backgroundColor: AppColors.greenSubtle,
                              onTap: () => context.go('/products'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        DashboardSectionHeader(
                          title: 'Recent Sales',
                          actionLabel: 'View All',
                          onActionTap: () => context.go('/sales'),
                        ),
                      ]),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: KLoadingState(),
                ),
                error: (e, _) => SliverFillRemaining(
                  child: KErrorState(message: e.toString()),
                ),
              ),
              recentSales.when(
                data: (sales) {
                  if (sales.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppLayout.dashboardPadding,
                          8,
                          AppLayout.dashboardPadding,
                          24,
                        ),
                        child: Text(
                          'No sales recorded yet',
                          style: TextStyle(color: AppColors.mutedText),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppLayout.dashboardPadding,
                      10,
                      AppLayout.dashboardPadding,
                      24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final sale = sales[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RecentSaleTile(
                              sale: sale,
                              onTap: () =>
                                  context.push('/sales/${sale.sale.id}'),
                            ),
                          );
                        },
                        childCount: sales.length.clamp(0, 10),
                      ),
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: SizedBox()),
                error: (_, _) => const SliverToBoxAdapter(child: SizedBox()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
