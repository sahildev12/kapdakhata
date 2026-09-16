import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/widgets/k_buttons.dart';
import 'package:kapdakhata/core/widgets/k_empty_state.dart';
import 'package:kapdakhata/core/widgets/k_inputs.dart';
import 'package:kapdakhata/database/app_database.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:kapdakhata/shared/repositories/repositories.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _thresholdController = TextEditingController();
  String _themeMode = 'light';
  bool _notifications = true;
  bool _loaded = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  void _applySettings(ShopSetting settings) {
    _shopNameController.text = settings.shopName;
    _ownerNameController.text = settings.ownerName;
    _phoneController.text = settings.phone ?? '';
    _addressController.text = settings.address ?? '';
    _thresholdController.text = settings.lowStockThreshold.toString();
    _themeMode = _normalizeThemeMode(settings.themeMode);
    _notifications = settings.notificationsEnabled;
    ref.read(themeModeProvider.notifier).state = _themeMode;
    _loaded = true;
  }

  String _normalizeThemeMode(String mode) {
    if (mode == 'dark' || mode == 'system') return mode;
    return 'light';
  }

  void _setThemeMode(String mode) {
    final normalized = _normalizeThemeMode(mode);
    setState(() => _themeMode = normalized);
    ref.read(themeModeProvider.notifier).state = normalized;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(settingsRepositoryProvider).updateSettings(
            shopName: _shopNameController.text.trim(),
            ownerName: _ownerNameController.text.trim(),
            phone: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
            address: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            currency: 'INR',
            lowStockThreshold:
                int.tryParse(_thresholdController.text.trim()) ?? 5,
            themeMode: _themeMode,
            notificationsEnabled: _notifications,
          );
      ref.read(themeModeProvider.notifier).state = _themeMode;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _clearData() async {
    final confirmed = await KConfirmDialog.show(
      context,
      title: 'Clear all data?',
      message: 'This will permanently delete all products, sales, and expenses.',
      confirmLabel: 'Clear',
    );
    if (confirmed) {
      await ref.read(settingsRepositoryProvider).clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data cleared')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    ref.listen(settingsProvider, (previous, next) {
      next.whenData((value) {
        if (!_loaded && mounted) {
          setState(() => _applySettings(value));
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: AppLayout.titleSize,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: settings.when(
        data: (s) {
          if (!_loaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_loaded) {
                setState(() => _applySettings(s));
              }
            });
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              const _SectionHeader('Shop Profile'),
              _SettingsCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _shopNameController,
                      decoration: const InputDecoration(
                        labelText: 'Shop Name',
                        prefixIcon: Icon(Icons.storefront_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Owner Name',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        prefixIcon: Icon(Icons.phone_outlined, size: 20),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const _SectionHeader('Business Setup'),
              _SettingsCard(
                child: Column(
                  children: [
                    _SettingsLinkTile(
                      icon: Icons.lightbulb_outline,
                      iconColor: AppColors.primaryPurple,
                      iconBackground: AppColors.lavenderSubtle,
                      title: 'Item Name Suggestions',
                      subtitle: 'Custom names for the Sell page',
                      onTap: () => context.push('/settings/sale-suggestions'),
                    ),
                    const _SettingsDivider(),
                    _SettingsLinkTile(
                      icon: Icons.category_outlined,
                      iconColor: AppColors.primaryPurple,
                      iconBackground: AppColors.purpleSubtle,
                      title: 'Product Categories',
                      subtitle: 'Manage product types',
                      onTap: () => context.push('/settings/categories/products'),
                    ),
                    const _SettingsDivider(),
                    _SettingsLinkTile(
                      icon: Icons.receipt_long_outlined,
                      iconColor: AppColors.pinkAccent,
                      iconBackground: AppColors.pinkSubtle,
                      title: 'Expense Categories',
                      subtitle: 'Manage expense types',
                      onTap: () => context.push('/settings/categories/expenses'),
                    ),
                    const _SettingsDivider(),
                    TextField(
                      controller: _thresholdController,
                      decoration: const InputDecoration(
                        labelText: 'Low Stock Threshold',
                        prefixIcon: Icon(Icons.inventory_2_outlined, size: 20),
                        helperText: 'Alert when stock falls to this level or below',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              const _SectionHeader('App Preferences'),
              _SettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: AppLayout.bodySize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _ThemeSelector(
                      selectedMode: _themeMode,
                      onChanged: _setThemeMode,
                    ),
                    const SizedBox(height: 8),
                    const _SettingsDivider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Notifications',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppLayout.bodySize,
                        ),
                      ),
                      subtitle: const Text(
                        'Low stock alerts on the home screen',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.mutedText,
                        ),
                      ),
                      value: _notifications,
                      activeTrackColor: AppColors.primaryPurple,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                  ],
                ),
              ),
              const _SectionHeader('Danger Zone'),
              _SettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Clear all local data',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppLayout.bodySize,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Removes all products, sales, and expenses from this device.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _clearData,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.negativeRed,
                        side: const BorderSide(color: AppColors.negativeRed),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppLayout.buttonRadius),
                        ),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text(
                        'Clear All Local Data',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              KPrimaryButton(
                label: 'Save Settings',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          );
        },
        loading: () => const KLoadingState(),
        error: (e, _) => KErrorState(message: 'Error: $e'),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
          color: AppColors.mutedText,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: child,
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}

class _SettingsLinkTile extends StatelessWidget {
  const _SettingsLinkTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppLayout.bodySize,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedText,
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
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({
    required this.selectedMode,
    required this.onChanged,
  });

  final String selectedMode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.purpleSubtle,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ThemeOption(
            label: 'Light',
            icon: Icons.light_mode,
            selected: selectedMode == 'light',
            onTap: () => onChanged('light'),
          ),
          _ThemeOption(
            label: 'Dark',
            icon: Icons.dark_mode,
            selected: selectedMode == 'dark',
            onTap: () => onChanged('dark'),
          ),
          _ThemeOption(
            label: 'System',
            icon: Icons.brightness_auto,
            selected: selectedMode == 'system',
            onTap: () => onChanged('system'),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? AppColors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: selected
                      ? AppColors.primaryPurple
                      : AppColors.mutedText,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? AppColors.primaryPurple
                        : AppColors.mutedText,
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
