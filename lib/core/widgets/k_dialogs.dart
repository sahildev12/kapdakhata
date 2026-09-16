import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';

/// Themed dialogs matching KapdaKhata design.
abstract final class KAppDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    Widget? content,
    Widget Function(BuildContext dialogContext)? contentBuilder,
    String? message,
    List<Widget> Function(BuildContext dialogContext)? actionsBuilder,
    bool scrollable = false,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) {
        final body = message != null
            ? Text(
                message,
                style: const TextStyle(
                  fontSize: AppLayout.bodySize,
                  height: 1.45,
                  color: AppColors.neutralText,
                ),
              )
            : contentBuilder?.call(dialogContext) ?? content;

        return AlertDialog(
          backgroundColor: Theme.of(dialogContext).cardTheme.color,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
            side: const BorderSide(color: AppColors.border),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: AppLayout.titleSize,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: body == null
              ? null
              : scrollable
                  ? SingleChildScrollView(child: body)
                  : body,
          actions: actionsBuilder?.call(dialogContext),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        );
      },
    );
  }

  static Future<bool> confirm({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).cardTheme.color,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: AppLayout.titleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: AppLayout.bodySize,
            height: 1.45,
            color: AppColors.neutralText,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: isDanger
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Future<void> info({
    required BuildContext context,
    required String title,
    required String message,
    String actionLabel = 'Got it',
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).cardTheme.color,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: AppLayout.titleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: AppLayout.bodySize,
            height: 1.45,
            color: AppColors.neutralText,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }

  static Future<void> about({
    required BuildContext context,
    required String appName,
    required String version,
    required String description,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(dialogContext).cardTheme.color,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          appName,
          style: const TextStyle(
            fontSize: AppLayout.titleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version $version',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.mutedText,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: const TextStyle(
                fontSize: AppLayout.bodySize,
                height: 1.45,
                color: AppColors.neutralText,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
