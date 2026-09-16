import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/widgets/k_empty_state.dart';
import 'package:kapdakhata/core/widgets/k_inputs.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:kapdakhata/shared/repositories/repositories.dart';

class SaleSuggestionsScreen extends ConsumerStatefulWidget {
  const SaleSuggestionsScreen({super.key});

  @override
  ConsumerState<SaleSuggestionsScreen> createState() =>
      _SaleSuggestionsScreenState();
}

class _SaleSuggestionsScreenState extends ConsumerState<SaleSuggestionsScreen> {
  final _controller = TextEditingController();

  Future<void> _add() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    try {
      await ref.read(settingsRepositoryProvider).addSaleNameSuggestion(name);
      _controller.clear();
      if (mounted) FocusManager.instance.primaryFocus?.unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add suggestion: $e')),
        );
      }
    }
  }

  Future<void> _delete(int id, String name) async {
    final confirmed = await KConfirmDialog.show(
      context,
      title: 'Remove suggestion?',
      message: 'Remove "$name" from your sale item suggestions?',
      confirmLabel: 'Remove',
    );
    if (!confirmed) return;
    await ref.read(settingsRepositoryProvider).deleteSaleNameSuggestion(id);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = ref.watch(saleNameSuggestionsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Sale Item Suggestions',
          style: TextStyle(
            fontSize: AppLayout.titleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppLayout.dashboardPadding,
              8,
              AppLayout.dashboardPadding,
              0,
            ),
            child: const Text(
              'Only these names appear as suggestions when you record a sale.',
              style: TextStyle(
                fontSize: AppLayout.bodySize,
                color: AppColors.neutralText,
                height: 1.45,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppLayout.dashboardPadding),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.circular(AppLayout.dashboardCardRadius),
                border: Border.all(color: AppColors.border),
                boxShadow: const [AppColors.cardShadow],
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        hintText: 'Add item name',
                        isDense: true,
                      ),
                      onSubmitted: (_) => _add(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppColors.primaryPurple,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: _add,
                      borderRadius: BorderRadius.circular(10),
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.add,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: suggestions.when(
              data: (items) {
                if (items.isEmpty) {
                  return const KEmptyState(
                    icon: Icons.lightbulb_outline,
                    title: 'No suggestions yet',
                    subtitle:
                        'Add item names like Pants, Shirt, or Kurta to speed up sales entry.',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppLayout.dashboardPadding,
                    0,
                    AppLayout.dashboardPadding,
                    24,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppLayout.dashboardCardRadius,
                        ),
                        border: Border.all(color: AppColors.border),
                        boxShadow: const [AppColors.cardShadow],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.lavenderSubtle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.sell_outlined,
                            color: AppColors.primaryPurple,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: AppLayout.bodySize,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppColors.negativeRed,
                            size: 20,
                          ),
                          onPressed: () => _delete(item.id, item.name),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const KLoadingState(),
              error: (e, _) => KErrorState(message: 'Error: $e'),
            ),
          ),
        ],
      ),
    );
  }
}
