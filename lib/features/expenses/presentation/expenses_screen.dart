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
import 'package:kapdakhata/core/widgets/month_filter_sheet.dart';
import 'package:kapdakhata/core/widgets/page_search_bar.dart';
import 'package:kapdakhata/features/expenses/presentation/widgets/expense_card.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  String _monthChipLabel(DateTime month) =>
      '${_months[month.month - 1]} ${month.year}';

  String _filterChipLabel(
    ExpenseDateFilterMode mode,
    DateTime month,
    DateRangeSelection? customRange,
  ) {
    if (mode == ExpenseDateFilterMode.custom && customRange != null) {
      return '${AppDateUtils.formatDate(customRange.start)} - ${AppDateUtils.formatDate(customRange.end)}';
    }
    return _monthChipLabel(month);
  }

  void _resetCustomFilter(WidgetRef ref) {
    ref.read(expenseDateFilterModeProvider.notifier).state =
        ExpenseDateFilterMode.month;
    ref.read(expenseCustomDateRangeProvider.notifier).state = null;
  }

  Future<void> _pickMonth(BuildContext context, WidgetRef ref) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final month = ref.read(selectedMonthProvider);
    final picked = await pickMonthDirectly(context, initialMonth: month);
    if (picked != null && context.mounted) {
      ref.read(selectedMonthProvider.notifier).state = picked;
      _resetCustomFilter(ref);
    }
  }

  Future<void> _pickCustomRange(BuildContext context, WidgetRef ref) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final now = DateTime.now();
    final existing = ref.read(expenseCustomDateRangeProvider);
    final result = await showDateRangeBottomSheet(
      context,
      title: 'Custom date range',
      initialStart: existing?.start ?? DateTime(now.year, now.month, 1),
      initialEnd: existing?.end ?? now,
    );
    if (result != null && context.mounted) {
      ref.read(expenseCustomDateRangeProvider.notifier).state = result;
      ref.read(expenseDateFilterModeProvider.notifier).state =
          ExpenseDateFilterMode.custom;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(expensesStreamProvider);
    final month = ref.watch(selectedMonthProvider);
    final filterMode = ref.watch(expenseDateFilterModeProvider);
    final customRange = ref.watch(expenseCustomDateRangeProvider);
    final chipLabel = _filterChipLabel(filterMode, month, customRange);
    final isCustomFilter =
        filterMode == ExpenseDateFilterMode.custom && customRange != null;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: KShellAppBar(
        title: 'Expenses',
        subtitle: 'Track business costs',
        actions: [
          KHeaderAddButton(
            onPressed: () => context.push('/expenses/add'),
          ),
        ],
      ),
      body: KDismissKeyboard(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: PageSearchBar(
                hint: 'Search expenses...',
                onChanged: (v) =>
                    ref.read(expenseSearchProvider.notifier).state = v,
                onFilterTap: () => _pickCustomRange(context, ref),
              ),
            ),
            const SizedBox(height: AppLayout.filterSectionGap),
            SizedBox(
              height: AppLayout.filterRowHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: isCustomFilter ? 2 : 1,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return KFilterChip(
                      label: chipLabel,
                      selected: true,
                      onTap: () => _pickMonth(context, ref),
                    );
                  }
                  return KFilterChip(
                    label: 'Reset',
                    selected: false,
                    onTap: () => _resetCustomFilter(ref),
                  );
                },
              ),
            ),
            Expanded(
              child: expenses.when(
                data: (items) {
                  if (items.isEmpty) {
                    return KEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No expenses recorded yet',
                      subtitle:
                          'Track shop rent, utilities, and other business costs.',
                      actionLabel: '+ Add Expense',
                      onAction: () => context.push('/expenses/add'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ExpenseCard(
                        item: item,
                        onTap: () =>
                            context.push('/expenses/${item.expense.id}'),
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
        onPressed: () => context.push('/expenses/add'),
        icon: Icons.add,
        label: 'Add Expense',
      ),
    );
  }
}
