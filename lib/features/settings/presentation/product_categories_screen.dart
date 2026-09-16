import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/widgets/k_inputs.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:kapdakhata/shared/repositories/repositories.dart';

class ProductCategoriesScreen extends ConsumerStatefulWidget {
  const ProductCategoriesScreen({super.key});

  @override
  ConsumerState<ProductCategoriesScreen> createState() =>
      _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState
    extends ConsumerState<ProductCategoriesScreen> {
  final _controller = TextEditingController();

  Future<void> _add() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    try {
      await ref.read(settingsRepositoryProvider).addProductCategory(name);
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Category already exists or error: $e')),
        );
      }
    }
  }

  Future<void> _delete(int id, String name) async {
    final confirmed = await KConfirmDialog.show(
      context,
      title: 'Delete category?',
      message: 'Delete "$name"? Products using this category may be affected.',
    );
    if (confirmed) {
      await ref.read(settingsRepositoryProvider).deleteProductCategory(id);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(productCategoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Product Categories')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'New category name',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _add,
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryPurple,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: categories.when(
              data: (items) => ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final cat = items[index];
                  return ListTile(
                    title: Text(cat.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _delete(cat.id, cat.name),
                    ),
                  );
                },
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPurple),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
