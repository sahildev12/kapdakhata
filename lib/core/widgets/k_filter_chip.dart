import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/widgets/k_buttons.dart';
import 'package:kapdakhata/database/app_database.dart';

class KFilterChip extends StatelessWidget {
  const KFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.centerLabel = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool centerLabel;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryPurple : AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected ? AppColors.primaryPurple : AppColors.border,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              textAlign: centerLabel ? TextAlign.center : TextAlign.start,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.white : AppColors.primaryText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Empty set means "All" categories are included.
class ProductCategoryFilter {
  ProductCategoryFilter._();

  static bool isAllSelected(Set<int> ids) => ids.isEmpty;

  static bool isCategorySelected(Set<int> ids, int categoryId) =>
      ids.contains(categoryId);

  static Set<int> toggleAll() => {};

  static Set<int> toggleCategory(Set<int> current, int categoryId) {
    if (current.isEmpty) {
      return {categoryId};
    }

    final next = {...current};
    if (next.contains(categoryId)) {
      next.remove(categoryId);
      return next;
    }

    next.add(categoryId);
    return next;
  }
}

Future<void> showCategoryFilterSheet(
  BuildContext context, {
  required List<ProductCategory> categories,
  required Set<int> selectedCategoryIds,
  required ValueChanged<Set<int>> onApply,
}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return _CategoryFilterSheet(
        categories: categories,
        initialSelection: selectedCategoryIds,
        onApply: onApply,
      );
    },
  );
}

class _CategoryFilterSheet extends StatefulWidget {
  const _CategoryFilterSheet({
    required this.categories,
    required this.initialSelection,
    required this.onApply,
  });

  final List<ProductCategory> categories;
  final Set<int> initialSelection;
  final ValueChanged<Set<int>> onApply;

  @override
  State<_CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<_CategoryFilterSheet> {
  late Set<int> _selection;

  @override
  void initState() {
    super.initState();
    _selection = {...widget.initialSelection};
  }

  void _toggleAll() {
    setState(() => _selection = ProductCategoryFilter.toggleAll());
  }

  void _toggleCategory(int categoryId) {
    setState(
      () => _selection = ProductCategoryFilter.toggleCategory(
        _selection,
        categoryId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Filter by category',
              style: TextStyle(
                fontSize: AppLayout.titleSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 8.0;
                final itemWidth = (constraints.maxWidth - gap) / 2;
                final chips = <Widget>[
                  SizedBox(
                    width: itemWidth,
                    child: KFilterChip(
                      label: 'All',
                      selected: ProductCategoryFilter.isAllSelected(_selection),
                      centerLabel: true,
                      onTap: _toggleAll,
                    ),
                  ),
                  ...widget.categories.map(
                    (category) => SizedBox(
                      width: itemWidth,
                      child: KFilterChip(
                        label: category.name,
                        selected: ProductCategoryFilter.isCategorySelected(
                          _selection,
                          category.id,
                        ),
                        centerLabel: true,
                        onTap: () => _toggleCategory(category.id),
                      ),
                    ),
                  ),
                ];

                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: chips,
                );
              },
            ),
            const SizedBox(height: 12),
            KPrimaryButton(
              label: 'Apply',
              onPressed: () {
                widget.onApply(_selection);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showOptionFilterSheet(
  BuildContext context, {
  required String title,
  required List<String> options,
  required String selectedLabel,
  required ValueChanged<String> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppLayout.titleSize,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 8.0;
                  final itemWidth = (constraints.maxWidth - gap) / 2;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: options.map((label) {
                      return SizedBox(
                        width: itemWidth,
                        child: KFilterChip(
                          label: label,
                          selected: selectedLabel == label,
                          centerLabel: true,
                          onTap: () {
                            onSelected(label);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
