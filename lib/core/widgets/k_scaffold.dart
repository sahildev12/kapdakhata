import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';

/// App bar for bottom-nav shell screens with a back action to Home.
class KShellAppBar extends StatelessWidget implements PreferredSizeWidget {
  const KShellAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Size get preferredSize => Size.fromHeight(subtitle != null ? 64 : kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 40,
      titleSpacing: 0,
      toolbarHeight: subtitle != null ? 64 : kToolbarHeight,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, size: 22),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: () => context.go('/home'),
      ),
      title: subtitle == null
          ? Text(
              title,
              style: const TextStyle(
                fontSize: AppLayout.titleSize,
                fontWeight: FontWeight.w700,
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: AppLayout.titleSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
      actions: actions,
    );
  }
}

/// Purple square add button used in page headers.
class KHeaderAddButton extends StatelessWidget {
  const KHeaderAddButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          child: const SizedBox(
            width: 36,
            height: 36,
            child: Icon(Icons.add, color: AppColors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

/// Wrap screen bodies so tapping outside inputs clears focus.
class KDismissKeyboard extends StatelessWidget {
  const KDismissKeyboard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

/// Extended FAB with consistent KapdaKhata colors.
class KExtendedFab extends StatelessWidget {
  const KExtendedFab({
    super.key,
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: AppLayout.bodySize)),
    );
  }
}
