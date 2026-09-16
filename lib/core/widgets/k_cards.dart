import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/money.dart';

class KCard extends StatelessWidget {
  const KCard({
    super.key,
    required this.child,
    this.padding = AppLayout.cardPadding,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2A2A30)
              : AppColors.border,
        ),
        boxShadow: const [AppColors.cardShadow],
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppLayout.cardRadius),
          child: card,
        ),
      );
    }
    return card;
  }
}

class KFinancialSummaryCard extends StatelessWidget {
  const KFinancialSummaryCard({
    super.key,
    required this.label,
    required this.amountPaise,
    this.isHighlighted = false,
    this.subtitle,
    this.compact = false,
  });

  final String label;
  final int amountPaise;
  final bool isHighlighted;
  final String? subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isPositive = amountPaise >= 0;
    return KCard(
      padding: compact ? AppLayout.compactCardPadding : AppLayout.cardPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: compact ? 10 : AppLayout.labelSize,
              color: AppColors.mutedText,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: compact ? 2 : 4),
          Text(
            MoneyFormatter.format(amountPaise),
            style: TextStyle(
              fontSize: isHighlighted
                  ? AppLayout.amountLargeSize
                  : (compact ? 14 : AppLayout.amountSize),
              fontWeight: FontWeight.w700,
              color: isHighlighted
                  ? (isPositive ? AppColors.positiveGreen : Colors.red)
                  : AppColors.primaryText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.mutedText,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class KProfitCard extends StatelessWidget {
  const KProfitCard({
    super.key,
    required this.profitPaise,
    this.compact = true,
  });

  final int profitPaise;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isLoss = profitPaise < 0;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 16),
      decoration: BoxDecoration(
        color: isLoss ? Colors.red.withValues(alpha: 0.08) : AppColors.greenSubtle,
        borderRadius: BorderRadius.circular(AppLayout.cardRadius),
        border: Border.all(
          color: isLoss
              ? Colors.red.withValues(alpha: 0.3)
              : AppColors.positiveGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isLoss ? Icons.trending_down : Icons.trending_up,
            size: compact ? 16 : 20,
            color: isLoss ? Colors.red : AppColors.positiveGreen,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLoss ? 'Loss per unit' : 'Profit per unit',
                  style: TextStyle(
                    fontSize: AppLayout.labelSize,
                    color: isLoss ? Colors.red.shade700 : AppColors.darkGreen,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  MoneyFormatter.format(profitPaise.abs()),
                  style: TextStyle(
                    fontSize: compact ? 16 : 22,
                    fontWeight: FontWeight.w700,
                    color: isLoss ? Colors.red.shade700 : AppColors.darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class KDetailRow extends StatelessWidget {
  const KDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: AppLayout.bodySize,
                color: AppColors.mutedText,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize:
                    emphasize ? AppLayout.amountSize : AppLayout.bodySize,
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KBadge extends StatelessWidget {
  const KBadge({
    super.key,
    required this.label,
    this.isSuccess = false,
    this.isWarning = false,
  });

  final String label;
  final bool isSuccess;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    if (isSuccess) {
      bg = AppColors.greenSubtle;
      fg = AppColors.darkGreen;
    } else if (isWarning) {
      bg = Colors.orange.withValues(alpha: 0.16);
      fg = Colors.orange.shade800;
    } else {
      bg = AppColors.graySubtle;
      fg = AppColors.neutralText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
