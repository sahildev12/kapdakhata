import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/money.dart';
import 'package:kapdakhata/core/utils/validators.dart';
import 'package:kapdakhata/core/widgets/k_buttons.dart';
import 'package:kapdakhata/core/widgets/k_cards.dart';
import 'package:kapdakhata/core/widgets/k_inputs.dart';
import 'package:kapdakhata/database/app_database.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:kapdakhata/shared/repositories/repositories.dart';

InputDecoration _saleFieldDecoration({
  required String hintText,
  required IconData icon,
}) {
  return InputDecoration(
    hintText: hintText,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    prefixIconConstraints: const BoxConstraints(
      minWidth: 34,
      maxWidth: 34,
      minHeight: 40,
    ),
    prefixIcon: Icon(icon, size: 18, color: AppColors.mutedText),
  );
}

class _NameSuggestion {
  const _NameSuggestion({required this.name, this.product});

  final String name;
  final ProductWithCategory? product;
}

class AddSaleScreen extends ConsumerStatefulWidget {
  const AddSaleScreen({super.key, this.preselectedProductId});

  final int? preselectedProductId;

  @override
  ConsumerState<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends ConsumerState<AddSaleScreen> {
  final List<_SaleLineForm> _lines = [_SaleLineForm()];
  DateTime _saleDate = DateTime.now();
  final _notesController = TextEditingController();
  bool _isSaving = false;

  static const _pagePadding = EdgeInsets.fromLTRB(16, 12, 16, 24);
  static const _sectionGap = 16.0;

  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  @override
  void dispose() {
    for (final line in _lines) {
      line.dispose();
    }
    _notesController.dispose();
    super.dispose();
  }

  void _addLine() {
    _unfocus();
    setState(() => _lines.add(_SaleLineForm()));
  }

  void _removeLine(int index) {
    if (_lines.length == 1) return;
    setState(() {
      _lines[index].dispose();
      _lines.removeAt(index);
    });
  }

  int get _grandTotalCost =>
      _lines.fold(0, (sum, line) => sum + line.totalCostPaise);

  int get _grandTotalSelling =>
      _lines.fold(0, (sum, line) => sum + line.totalSellingPaise);

  int get _grandProfit => _grandTotalSelling - _grandTotalCost;

  Future<void> _pickDate() async {
    _unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: _saleDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (picked != null) setState(() => _saleDate = picked);
  }

  Future<void> _save() async {
    _unfocus();
    for (var i = 0; i < _lines.length; i++) {
      final line = _lines[i];
      if (Validators.nonNegativeAmount(line.costController.text) != null ||
          Validators.nonNegativeAmount(line.sellingController.text) != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Check prices for item ${i + 1}')),
        );
        return;
      }
      if (line.quantity < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quantity must be at least 1 for item ${i + 1}')),
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    try {
      final quickLines = _lines.asMap().entries.map((entry) {
        final line = entry.value;
        return QuickSaleLine(
          itemName: line.nameController.text.trim().isEmpty
              ? 'Item ${entry.key + 1}'
              : line.nameController.text.trim(),
          unitCostPaise: Money.fromRupeesString(line.costController.text).paise,
          totalSellingPaise:
              Money.fromRupeesString(line.sellingController.text).paise,
          quantity: line.quantity,
        );
      }).toList();

      await ref.read(salesRepositoryProvider).createQuickSaleBatch(
            lines: quickLines,
            saleDate: _saleDate,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sale recorded (${quickLines.length} item${quickLines.length == 1 ? '' : 's'})',
            ),
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 64,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 22),
            onPressed: () => context.pop(),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sell',
                style: Theme.of(context).appBarTheme.titleTextStyle,
              ),
              const Text(
                'Add items to record a sale',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
        body: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          padding: _pagePadding,
          children: [
            ...List.generate(_lines.length, (index) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == _lines.length - 1 ? _sectionGap : 10,
                ),
                child: _SaleLineCard(
                  index: index,
                  line: _lines[index],
                  canRemove: _lines.length > 1,
                  onRemove: () => _removeLine(index),
                  onChanged: () => setState(() {}),
                ),
              );
            }),
            _AddItemButton(onPressed: _addLine),
            const SizedBox(height: _sectionGap),
            KCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                children: [
                  _TotalRow('Total Cost', _grandTotalCost),
                  const SizedBox(height: 4),
                  _TotalRow('Total Sale', _grandTotalSelling),
                  const Divider(height: 20),
                  _TotalRow(
                    _grandProfit >= 0 ? 'Total Profit' : 'Total Loss',
                    _grandProfit.abs(),
                    highlight: true,
                    isLoss: _grandProfit < 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: _sectionGap),
            const Text(
              'Date',
              style: TextStyle(
                fontSize: AppLayout.bodySize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _DateField(
              date: _saleDate,
              onTap: _pickDate,
            ),
            const SizedBox(height: _sectionGap),
            const Text(
              'Notes',
              style: TextStyle(
                fontSize: AppLayout.bodySize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              style: const TextStyle(fontSize: AppLayout.bodySize),
              decoration: const InputDecoration(
                hintText: 'Notes (optional)',
                prefixIcon: Icon(
                  Icons.description_outlined,
                  color: AppColors.mutedText,
                  size: 20,
                ),
              ),
              onTapOutside: (_) => _unfocus(),
            ),
            const SizedBox(height: 20),
            KPrimaryButton(
              label: 'Complete Sale',
              icon: Icons.check,
              compact: false,
              isLoading: _isSaving,
              onPressed: _save,
            ),
          ],
        ),
    );
  }
}

class _AddItemButton extends StatelessWidget {
  const _AddItemButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.purpleSubtle,
      borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 11),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 18, color: AppColors.primaryPurple),
              SizedBox(width: 6),
              Text(
                'Add another item',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.date,
    required this.onTap,
  });

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = '${date.day}/${date.month}/${date.year}';

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppLayout.cardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppLayout.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.primaryPurple,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: AppLayout.bodySize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.primaryPurple,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaleLineForm {
  _SaleLineForm();

  final nameController = TextEditingController();
  final costController = TextEditingController();
  final sellingController = TextEditingController();
  final nameFocusNode = FocusNode();
  final suggestionTapGroup = Object();
  int quantity = 1;
  bool suggestionsDismissed = true;

  int get unitCostPaise => Money.fromRupeesString(costController.text).paise;
  int get totalSellingPaise =>
      Money.fromRupeesString(sellingController.text).paise;
  int get totalCostPaise => unitCostPaise * quantity;
  int get profitPaise => totalSellingPaise - totalCostPaise;

  void dispose() {
    nameController.dispose();
    costController.dispose();
    sellingController.dispose();
    nameFocusNode.dispose();
  }
}

class _SaleLineCard extends ConsumerStatefulWidget {
  const _SaleLineCard({
    required this.index,
    required this.line,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final _SaleLineForm line;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  ConsumerState<_SaleLineCard> createState() => _SaleLineCardState();
}

class _SaleLineCardState extends ConsumerState<_SaleLineCard> {
  @override
  void initState() {
    super.initState();
    widget.line.nameFocusNode.addListener(_onNameFocusChanged);
  }

  @override
  void dispose() {
    widget.line.nameFocusNode.removeListener(_onNameFocusChanged);
    super.dispose();
  }

  void _onNameFocusChanged() {
    if (widget.line.nameFocusNode.hasFocus) {
      _openSuggestions();
    }
  }

  void _openSuggestions() {
    setState(() => widget.line.suggestionsDismissed = false);
  }

  void _closeSuggestions() {
    setState(() => widget.line.suggestionsDismissed = true);
  }

  List<_NameSuggestion> _allSuggestions(
    List<SaleNameSuggestion> customSuggestions,
    List<ProductWithCategory> products,
  ) {
    final productByName = {
      for (final item in products) item.product.name: item,
    };

    return customSuggestions
        .map(
          (suggestion) => _NameSuggestion(
            name: suggestion.name,
            product: productByName[suggestion.name],
          ),
        )
        .toList();
  }

  List<_NameSuggestion> _filteredSuggestions(List<_NameSuggestion> all) {
    final query = widget.line.nameController.text.trim().toLowerCase();
    if (query.isEmpty) return all;
    return all
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  void _selectSuggestion(_NameSuggestion suggestion) {
    widget.line.nameController.text = suggestion.name;
    final product = suggestion.product;
    if (product != null) {
      widget.line.costController.text =
          (product.product.costPricePaise / 100).toString();
      widget.line.sellingController.text =
          ((product.product.sellingPricePaise * widget.line.quantity) / 100)
              .toString();
    }
    setState(() {
      widget.line.suggestionsDismissed = true;
    });
    widget.onChanged();
    widget.line.nameFocusNode.unfocus();
  }

  void _dismissSuggestions() {
    _closeSuggestions();
    widget.line.nameFocusNode.unfocus();
  }

  void _handleTapOutsideSuggestions() {
    _closeSuggestions();
    widget.line.nameFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsStreamProvider).valueOrNull ?? [];
    final customSuggestions =
        ref.watch(saleNameSuggestionsProvider).valueOrNull ?? [];
    final allSuggestions = _allSuggestions(customSuggestions, products);
    final filtered = _filteredSuggestions(allSuggestions);
    final showSuggestions =
        !widget.line.suggestionsDismissed && filtered.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lavenderSubtle,
        borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Item ${widget.index + 1}',
                style: const TextStyle(
                  fontSize: AppLayout.bodySize,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              const Spacer(),
              if (widget.canRemove)
                InkWell(
                  onTap: widget.onRemove,
                  borderRadius: BorderRadius.circular(6),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 16, color: Colors.red),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TapRegion(
            groupId: widget.line.suggestionTapGroup,
            onTapOutside: (_) => _handleTapOutsideSuggestions(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: widget.line.nameController,
                  focusNode: widget.line.nameFocusNode,
                  style: const TextStyle(fontSize: AppLayout.bodySize),
                  decoration: _saleFieldDecoration(
                    hintText: 'Item name (optional)',
                    icon: Icons.search,
                  ),
                  onTap: _openSuggestions,
                  onChanged: (_) {
                    _openSuggestions();
                    widget.onChanged();
                  },
                ),
                if (showSuggestions) ...[
                  const SizedBox(height: 6),
                  _SuggestionPanel(
                    suggestions: filtered,
                    onSelect: _selectSuggestion,
                    onClose: _dismissSuggestions,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.line.costController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: const TextStyle(fontSize: AppLayout.bodySize),
                  decoration: _saleFieldDecoration(
                    hintText: 'Cost per piece',
                    icon: Icons.sell_outlined,
                  ),
                  onChanged: (_) => widget.onChanged(),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.line.sellingController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: const TextStyle(fontSize: AppLayout.bodySize),
                  decoration: _saleFieldDecoration(
                    hintText: 'Total sale amount',
                    icon: Icons.currency_rupee,
                  ),
                  onChanged: (_) => widget.onChanged(),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Qty',
                style: TextStyle(
                  fontSize: AppLayout.bodySize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(width: 10),
              KQuantityStepper(
                quantity: widget.line.quantity,
                onChanged: (q) {
                  widget.line.quantity = q;
                  widget.onChanged();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionPanel extends StatelessWidget {
  const _SuggestionPanel({
    required this.suggestions,
    required this.onSelect,
    required this.onClose,
  });

  final List<_NameSuggestion> suggestions;
  final ValueChanged<_NameSuggestion> onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 4, 0),
            child: Row(
              children: [
                const Text(
                  'Suggestions',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText,
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  icon: const Icon(Icons.close, size: 16),
                  tooltip: 'Close suggestions',
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          NotificationListener<ScrollNotification>(
            onNotification: (notification) => notification.depth == 0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                primary: false,
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const ClampingScrollPhysics(),
                itemCount: suggestions.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = suggestions[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onSelect(item),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            size: 14,
                            color: AppColors.mutedText,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: AppLayout.bodySize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (item.product != null)
                            Text(
                              MoneyFormatter.format(
                                item.product!.product.sellingPricePaise,
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedText,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow(
    this.label,
    this.paise, {
    this.highlight = false,
    this.isLoss = false,
  });

  final String label;
  final int paise;
  final bool highlight;
  final bool isLoss;

  @override
  Widget build(BuildContext context) {
    Color? valueColor;
    if (highlight) {
      valueColor = isLoss ? Colors.red : AppColors.positiveGreen;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppLayout.bodySize,
            color: highlight ? AppColors.primaryText : AppColors.mutedText,
            fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          MoneyFormatter.format(paise),
          style: TextStyle(
            fontSize: highlight ? AppLayout.amountSize : AppLayout.bodySize,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}
