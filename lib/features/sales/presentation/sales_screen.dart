import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/date_utils.dart';
import 'package:kapdakhata/core/widgets/k_date_range_sheet.dart';
import 'package:kapdakhata/core/widgets/k_empty_state.dart';
import 'package:kapdakhata/core/widgets/k_filter_chip.dart';
import 'package:kapdakhata/core/widgets/k_scaffold.dart';
import 'package:kapdakhata/core/widgets/page_search_bar.dart';
import 'package:kapdakhata/features/sales/presentation/widgets/sale_card.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';

class SalesScreen extends ConsumerWidget {
  const SalesScreen({super.key});

  void _resetCustomFilter(WidgetRef ref) {
    ref.read(salesCustomDateRangeProvider.notifier).state = null;
    ref.read(salesDateFilterProvider.notifier).state =
        SalesDateFilter.thisMonth;
  }

  Future<void> _onFilterSelected(
    BuildContext context,
    WidgetRef ref,
    SalesDateFilter filter,
  ) async {
    if (filter == SalesDateFilter.custom) {
      final now = DateTime.now();
      final existing = ref.read(salesCustomDateRangeProvider);
      final result = await showDateRangeBottomSheet(
        context,
        initialStart: existing?.start ?? DateTime(now.year, now.month, 1),
        initialEnd: existing?.end ?? now,
      );
      if (result != null && context.mounted) {
        ref.read(salesCustomDateRangeProvider.notifier).state = result;
        ref.read(salesDateFilterProvider.notifier).state =
            SalesDateFilter.custom;
      }
      return;
    }

    ref.read(salesDateFilterProvider.notifier).state = filter;
  }

  void _openDateFilterSheet(BuildContext context, WidgetRef ref) {
    final filter = ref.read(salesDateFilterProvider);
    showOptionFilterSheet(
      context,
      title: 'Filter by date',
      options: const ['Today', 'This Week', 'This Month', 'Custom'],
      selectedLabel: _filterLabel(filter),
      onSelected: (label) {
        final mapped = switch (label) {
          'Today' => SalesDateFilter.today,
          'This Week' => SalesDateFilter.thisWeek,
          'This Month' => SalesDateFilter.thisMonth,
          _ => SalesDateFilter.custom,
        };
        _onFilterSelected(context, ref, mapped);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sales = ref.watch(salesStreamProvider);
    final filter = ref.watch(salesDateFilterProvider);
    final customRange = ref.watch(salesCustomDateRangeProvider);
    final showReset =
        filter == SalesDateFilter.custom && customRange != null;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: KShellAppBar(
        title: 'Sell',
        subtitle: 'Track your sales',
        actions: [
          KHeaderAddButton(
            onPressed: () => context.push('/sales/add'),
          ),
        ],
      ),
      body: KDismissKeyboard(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: PageSearchBar(
                hint: 'Search by product...',
                onChanged: (v) =>
                    ref.read(salesSearchProvider.notifier).state = v,
                onFilterTap: () => _openDateFilterSheet(context, ref),
              ),
            ),
            const SizedBox(height: AppLayout.filterSectionGap),
            SizedBox(
              height: AppLayout.filterRowHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: SalesDateFilter.values.length + (showReset ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index >= SalesDateFilter.values.length) {
                    return KFilterChip(
                      label: 'Reset',
                      selected: false,
                      onTap: () => _resetCustomFilter(ref),
                    );
                  }
                  final f = SalesDateFilter.values[index];
                  final label = f == SalesDateFilter.custom &&
                          filter == SalesDateFilter.custom &&
                          customRange != null
                      ? '${AppDateUtils.formatDate(customRange.start)} - ${AppDateUtils.formatDate(customRange.end)}'
                      : _filterLabel(f);
                  return KFilterChip(
                    label: label,
                    selected: filter == f,
                    onTap: () => _onFilterSelected(context, ref, f),
                  );
                },
              ),
            ),
            Expanded(
              child: sales.when(
                data: (items) {
                  if (items.isEmpty) {
                    return KEmptyState(
                      icon: Icons.shopping_bag_outlined,
                      title: 'No sales recorded yet',
                      subtitle: 'Record your first sale to track revenue.',
                      actionLabel: 'Sell',
                      onAction: () => context.push('/sales/add'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return SaleCard(
                        item: item,
                        onTap: () => context.push('/sales/${item.sale.id}'),
                      );
                    },
                  );
                },
                loading: () => const KLoadingState(),
                error: (e, _) => KErrorState(message: e.toString()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: KExtendedFab(
        onPressed: () => context.push('/sales/add'),
        icon: Icons.point_of_sale,
        label: 'Sell',
      ),
    );
  }

  String _filterLabel(SalesDateFilter filter) {
    switch (filter) {
      case SalesDateFilter.today:
        return 'Today';
      case SalesDateFilter.thisWeek:
        return 'This Week';
      case SalesDateFilter.thisMonth:
        return 'This Month';
      case SalesDateFilter.custom:
        return 'Custom';
    }
  }
}
