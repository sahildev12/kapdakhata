import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';

class ProductsSoldCard extends StatelessWidget {
  const ProductsSoldCard({
    super.key,
    required this.count,
    this.onTap,
  });

  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.blueSubtle,
            borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
            border: Border.all(color: AppColors.border),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.blueAccent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_outlined,
                    color: AppColors.blueAccent,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: AppLayout.bodySize,
                        color: AppColors.primaryText,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Product Sold',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.neutralText,
                          ),
                        ),
                        TextSpan(
                          text: ': $count',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.mutedText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
