import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/date_utils.dart';
import 'package:kapdakhata/core/utils/money.dart';
import 'package:kapdakhata/core/widgets/k_cards.dart';
import 'package:kapdakhata/core/widgets/k_empty_state.dart';
import 'package:kapdakhata/core/widgets/k_inputs.dart';
import 'package:kapdakhata/database/app_database.dart';
import 'package:kapdakhata/features/home/presentation/widgets/dashboard_section_header.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:kapdakhata/shared/repositories/repositories.dart';

final expenseDetailProvider =
    FutureProvider.family<ExpenseWithCategory?, int>((ref, id) async {
  return ref.watch(databaseProvider).getExpenseWithCategory(id);
});

class ExpenseDetailScreen extends ConsumerWidget {
  const ExpenseDetailScreen({super.key, required this.expenseId});

  final int expenseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expense = ref.watch(expenseDetailProvider(expenseId));

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text(
          'Expense Details',
          style: TextStyle(
            fontSize: AppLayout.titleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/expenses/$expenseId/edit'),
          ),
        ],
      ),
      body: expense.when(
        data: (data) {
          if (data == null) {
            return const KEmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Expense not found',
              subtitle: 'This expense may have been deleted.',
            );
          }
          final e = data.expense;

          return ListView(
            padding: const EdgeInsets.all(AppLayout.dashboardPadding),
            children: [
              _ExpenseSummaryCard(item: data),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pinkSubtle,
                  borderRadius:
                      BorderRadius.circular(AppLayout.dashboardCardRadius),
                  border: Border.all(
                    color: AppColors.pinkAccent.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      color: AppColors.pinkAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Amount spent',
                            style: TextStyle(
                              fontSize: AppLayout.labelSize,
                              color: AppColors.neutralText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            MoneyFormatter.format(e.amountPaise),
                            style: const TextStyle(
                              fontSize: AppLayout.amountLargeSize,
                              fontWeight: FontWeight.w700,
                              color: AppColors.pinkAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const DashboardSectionHeader(title: 'Details'),
              const SizedBox(height: 8),
              KCard(
                child: Column(
                  children: [
                    KDetailRow(label: 'Category', value: data.category.name),
                    const Divider(height: 1),
                    KDetailRow(
                      label: 'Date',
                      value: AppDateUtils.formatDate(e.expenseDate),
                    ),
                    const Divider(height: 1),
                    KDetailRow(
                      label: 'Time',
                      value: AppDateUtils.formatTime(e.expenseDate),
                    ),
                    if (e.notes != null && e.notes!.isNotEmpty) ...[
                      const Divider(height: 1),
                      KDetailRow(label: 'Notes', value: e.notes!),
                    ],
                    const Divider(height: 1),
                    KDetailRow(
                      label: 'Added',
                      value: AppDateUtils.formatDate(e.createdAt),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () => _deleteExpense(context, ref),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.negativeRed,
                  side: const BorderSide(color: AppColors.negativeRed),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
                  ),
                ),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text(
                  'Delete Expense',
                  style: TextStyle(fontWeight: FontWeight.w600),
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

  Future<void> _deleteExpense(BuildContext context, WidgetRef ref) async {
    final confirmed = await KConfirmDialog.show(
      context,
      title: 'Delete this expense?',
      message: 'This cannot be undone.',
    );
    if (!confirmed) return;

    await ref.read(expenseRepositoryProvider).deleteExpense(expenseId);
    if (context.mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense deleted')),
      );
    }
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({required this.item});

  final ExpenseWithCategory item;

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.pinkSubtle,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.pinkAccent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expense #${item.expense.id}',
                  style: const TextStyle(
                    fontSize: AppLayout.labelSize,
                    color: AppColors.mutedText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.expense.title,
                  style: const TextStyle(
                    fontSize: AppLayout.headlineSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                KBadge(label: item.category.name),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
