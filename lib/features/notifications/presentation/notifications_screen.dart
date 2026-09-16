import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/widgets/k_empty_state.dart';
import 'package:kapdakhata/features/home/presentation/widgets/dashboard_section_header.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final alerts = ref.watch(stockAlertsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontSize: AppLayout.titleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(stockAlertsProvider);
          ref.invalidate(settingsProvider);
        },
        child: settings.when(
          data: (shopSettings) {
            if (!shopSettings.notificationsEnabled) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  KEmptyState(
                    icon: Icons.notifications_off_outlined,
                    title: 'Notifications are off',
                    subtitle:
                        'Turn on notifications in Settings to get low stock alerts.',
                  ),
                ],
              );
            }

            return alerts.when(
              data: (items) {
                if (items.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      KEmptyState(
                        icon: Icons.notifications_none_outlined,
                        title: 'All caught up',
                        subtitle: 'No low stock or out-of-stock alerts right now.',
                      ),
                    ],
                  );
                }

                final outOfStock =
                    items.where((item) => item.isOutOfStock).toList();
                final lowStock =
                    items.where((item) => !item.isOutOfStock).toList();

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppLayout.dashboardPadding),
                  children: [
                    if (outOfStock.isNotEmpty) ...[
                      const DashboardSectionHeader(title: 'Out of stock'),
                      const SizedBox(height: 8),
                      ...outOfStock.map(
                        (alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _NotificationTile(
                            alert: alert,
                            onTap: () => context.push(
                              '/products/${alert.product.product.id}',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (lowStock.isNotEmpty) ...[
                      DashboardSectionHeader(
                        title: 'Low stock (≤ ${shopSettings.lowStockThreshold})',
                      ),
                      const SizedBox(height: 8),
                      ...lowStock.map(
                        (alert) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _NotificationTile(
                            alert: alert,
                            onTap: () => context.push(
                              '/products/${alert.product.product.id}',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
              loading: () => const KLoadingState(),
              error: (e, _) => KErrorState(
                message: 'Could not load alerts: $e',
                onRetry: () => ref.invalidate(stockAlertsProvider),
              ),
            );
          },
          loading: () => const KLoadingState(),
          error: (e, _) => KErrorState(message: 'Error: $e'),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.alert,
    required this.onTap,
  });

  final StockAlert alert;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final product = alert.product.product;
    final isOutOfStock = alert.isOutOfStock;
    final accent = isOutOfStock ? AppColors.negativeRed : AppColors.orangeAccent;
    final bg = isOutOfStock ? AppColors.redSubtle : AppColors.orangeSubtle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
            border: Border.all(color: AppColors.border),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(
                    isOutOfStock
                        ? Icons.inventory_2_outlined
                        : Icons.warning_amber_outlined,
                    color: accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: AppLayout.bodySize,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOutOfStock
                            ? 'Out of stock'
                            : 'Only ${product.stockQuantity} left in stock',
                        style: TextStyle(
                          fontSize: 12,
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.mutedText,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
