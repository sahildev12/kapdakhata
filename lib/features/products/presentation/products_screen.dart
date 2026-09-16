import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/widgets/k_empty_state.dart';
import 'package:kapdakhata/core/widgets/k_filter_chip.dart';
import 'package:kapdakhata/core/widgets/k_scaffold.dart';
import 'package:kapdakhata/core/widgets/page_search_bar.dart';
import 'package:kapdakhata/features/products/presentation/widgets/product_card.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  void _applyCategorySelection(WidgetRef ref, Set<int> ids) {
    ref.read(productCategoryFilterProvider.notifier).state = ids;
  }

  void _toggleCategoryChip(WidgetRef ref, int? categoryId) {
    final notifier = ref.read(productCategoryFilterProvider.notifier);
    if (categoryId == null) {
      notifier.state = ProductCategoryFilter.toggleAll();
      return;
    }
    notifier.state = ProductCategoryFilter.toggleCategory(
      notifier.state,
      categoryId,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsStreamProvider);
    final categories = ref.watch(productCategoriesProvider);
    final selectedCategories = ref.watch(productCategoryFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: KShellAppBar(
        title: 'Products',
        subtitle: 'Manage your inventory',
        actions: [
          KHeaderAddButton(
            onPressed: () => context.push('/products/add'),
          ),
        ],
      ),
      body: KDismissKeyboard(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: PageSearchBar(
                hint: 'Search products...',
                onChanged: (v) =>
                    ref.read(productSearchProvider.notifier).state = v,
                onFilterTap: () {
                  final cats = categories.valueOrNull;
                  if (cats == null) return;
                  showCategoryFilterSheet(
                    context,
                    categories: cats,
                    selectedCategoryIds: selectedCategories,
                    onApply: (ids) => _applyCategorySelection(ref, ids),
                  );
                },
              ),
            ),
            const SizedBox(height: AppLayout.filterSectionGap),
            categories.when(
              data: (cats) => SizedBox(
                height: AppLayout.filterRowHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: cats.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return KFilterChip(
                        label: 'All',
                        selected: ProductCategoryFilter.isAllSelected(
                          selectedCategories,
                        ),
                        onTap: () => _toggleCategoryChip(ref, null),
                      );
                    }
                    final c = cats[index - 1];
                    return KFilterChip(
                      label: c.name,
                      selected: ProductCategoryFilter.isCategorySelected(
                        selectedCategories,
                        c.id,
                      ),
                      onTap: () => _toggleCategoryChip(ref, c.id),
                    );
                  },
                ),
              ),
              loading: () => const SizedBox(height: AppLayout.filterRowHeight),
              error: (_, _) => const SizedBox(height: AppLayout.filterRowHeight),
            ),
            Expanded(
              child: products.when(
                data: (items) {
                  if (items.isEmpty) {
                    return KEmptyState(
                      icon: Icons.inventory_2_outlined,
                      title: 'No products yet',
                      subtitle:
                          'Add your first product to start tracking your shop.',
                      actionLabel: '+ Add Product',
                      onAction: () => context.push('/products/add'),
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
                      return ProductCard(
                        item: item,
                        onTap: () =>
                            context.push('/products/${item.product.id}'),
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
        onPressed: () => context.push('/products/add'),
        icon: Icons.add,
        label: 'Add Product',
      ),
    );
  }
}
