import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/widgets/app_logo.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({
    super.key,
    required this.greeting,
    required this.ownerName,
    this.isLoading = false,
    this.onNotificationTap,
  });

  final String greeting;
  final String ownerName;
  final bool isLoading;
  final VoidCallback? onNotificationTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const AppLogo(size: 44, borderRadius: 12),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: AppLayout.bodySize,
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isLoading ? '...' : ownerName,
                style: const TextStyle(
                  fontSize: AppLayout.headlineSize,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          style: IconButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.primaryText,
            padding: const EdgeInsets.all(8),
            minimumSize: const Size(40, 40),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          icon: const Icon(Icons.notifications_outlined, size: 20),
          onPressed: onNotificationTap ?? () {},
        ),
      ],
    );
  }
}
