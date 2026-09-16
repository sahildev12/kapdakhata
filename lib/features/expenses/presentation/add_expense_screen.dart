import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/utils/money.dart';
import 'package:kapdakhata/core/utils/validators.dart';
import 'package:kapdakhata/core/widgets/k_buttons.dart';
import 'package:kapdakhata/features/expenses/presentation/expense_detail_screen.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:kapdakhata/shared/repositories/repositories.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key, this.expenseId});

  final int? expenseId;

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  int? _selectedCategoryId;
  DateTime _expenseDate = DateTime.now();
  bool _isLoading = false;
  bool _isSaving = false;

  bool get _isEditing => widget.expenseId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExpense();
    }
  }

  Future<void> _loadExpense() async {
    setState(() => _isLoading = true);
    final item =
        await ref.read(databaseProvider).getExpenseWithCategory(widget.expenseId!);
    if (item != null && mounted) {
      _titleController.text = item.expense.title;
      _selectedCategoryId = item.expense.categoryId;
      _amountController.text = (item.expense.amountPaise / 100).toString();
      _expenseDate = item.expense.expenseDate;
      _notesController.text = item.expense.notes ?? '';
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(expenseRepositoryProvider);
      final payload = (
        title: _titleController.text.trim(),
        categoryId: _selectedCategoryId!,
        amountPaise: Money.fromRupeesString(_amountController.text).paise,
        expenseDate: _expenseDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (_isEditing) {
        await repo.updateExpense(
          id: widget.expenseId!,
          title: payload.title,
          categoryId: payload.categoryId,
          amountPaise: payload.amountPaise,
          expenseDate: payload.expenseDate,
          notes: payload.notes,
        );
        ref.invalidate(expenseDetailProvider(widget.expenseId!));
      } else {
        await repo.createExpense(
          title: payload.title,
          categoryId: payload.categoryId,
          amountPaise: payload.amountPaise,
          expenseDate: payload.expenseDate,
          notes: payload.notes,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Expense updated' : 'Expense saved'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(expenseCategoriesProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Expense Title *'),
              validator: (v) => Validators.required(v, field: 'Title'),
            ),
            const SizedBox(height: 16),
            categories.when(
              data: (cats) => DropdownButtonFormField<int>(
                initialValue: _selectedCategoryId,
                decoration: const InputDecoration(labelText: 'Category *'),
                items: cats
                    .map(
                      (c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
                validator: (v) => v == null ? 'Category is required' : null,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => const Text('Failed to load categories'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount *'),
              keyboardType: TextInputType.number,
              validator: Validators.positiveAmount,
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(
                '${_expenseDate.day}/${_expenseDate.month}/${_expenseDate.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _expenseDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now().add(const Duration(days: 1)),
                );
                if (picked != null) setState(() => _expenseDate = picked);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            KPrimaryButton(
              label: _isEditing ? 'Update Expense' : 'Save Expense',
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
