import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapdakhata/core/navigation/app_back_handler.dart';
import 'package:kapdakhata/core/router/app_router.dart';
import 'package:kapdakhata/core/theme/app_theme.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';

class KapdaKhataApp extends ConsumerWidget {
  const KapdaKhataApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeModeStr = ref.watch(themeModeProvider);

    ThemeMode themeMode;
    switch (themeModeStr) {
      case 'light':
        themeMode = ThemeMode.light;
      case 'dark':
        themeMode = ThemeMode.dark;
      default:
        themeMode = ThemeMode.system;
    }

    return MaterialApp.router(
      title: 'KapdaKhata',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        return AppBackHandler(
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.translucent,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
