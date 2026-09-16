import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AppLogo(size: 80, borderRadius: 18),
            const SizedBox(height: 12),
            const Text(
              'KapdaKhata',
              style: TextStyle(
                fontSize: AppLayout.headlineSize,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Manage • Sell • Grow',
              style: TextStyle(
                fontSize: AppLayout.bodySize,
                color: AppColors.mutedText,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
