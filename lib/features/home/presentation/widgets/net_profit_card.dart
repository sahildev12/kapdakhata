import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/money.dart';

class NetProfitCard extends StatelessWidget {
  const NetProfitCard({
    super.key,
    required this.amountPaise,
    this.changeLabel,
    this.onTap,
  });

  final int amountPaise;
  final String? changeLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isPositive = amountPaise >= 0;
    final accent = isPositive ? AppColors.positiveGreen : AppColors.negativeRed;
    final bg = isPositive ? AppColors.greenSubtle : AppColors.redSubtle;
    final border = accent.withValues(alpha: 0.25);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
            border: Border.all(color: border),
            boxShadow: const [AppColors.cardShadow],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isPositive
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    color: accent,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Net Profit',
                            style: TextStyle(
                              fontSize: 11,
                              color: accent.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              MoneyFormatter.format(amountPaise),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: accent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (changeLabel != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          changeLabel!,
                          style: TextStyle(
                            fontSize: 10,
                            color: accent.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
