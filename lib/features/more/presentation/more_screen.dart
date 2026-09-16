import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/widgets/k_dialogs.dart';
import 'package:kapdakhata/core/widgets/k_scaffold.dart';
import 'package:kapdakhata/database/app_database.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:kapdakhata/shared/repositories/repositories.dart';
import 'package:kapdakhata/shared/services/backup_service.dart';
import 'package:kapdakhata/shared/services/dummy_data_service.dart';
import 'package:path/path.dart' as p;

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const KShellAppBar(title: 'More'),
      body: ListView(
        children: [
          const _SectionHeader('Appearance'),
          _ThemeSelector(),
          const _SectionHeader('Business'),
          _MenuTile(
            icon: Icons.bar_chart,
            title: 'Reports',
            onTap: () => context.push('/reports'),
          ),
          _MenuTile(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () => context.push('/settings'),
          ),
          const _SectionHeader('Data'),
          _MenuTile(
            icon: Icons.dataset,
            title: 'Load Sample Data',
            onTap: () => _loadSampleData(context, ref),
          ),
          _MenuTile(
            icon: Icons.backup,
            title: 'Backup Data',
            onTap: () async {
              try {
                await ref.read(backupServiceProvider).exportBackup();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup saved and ready to share')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backup failed: $e')),
                  );
                }
              }
            },
          ),
          _MenuTile(
            icon: Icons.restore,
            title: 'Restore Backup',
            onTap: () => _showRestoreBackupSheet(context, ref),
          ),
          _MenuTile(
            icon: Icons.file_download,
            title: 'Export Products (CSV)',
            onTap: () => ref.read(backupServiceProvider).exportProductsCsv(),
          ),
          _MenuTile(
            icon: Icons.file_download,
            title: 'Export Sales (CSV)',
            onTap: () => ref.read(backupServiceProvider).exportSalesCsv(),
          ),
          _MenuTile(
            icon: Icons.file_download,
            title: 'Export Expenses (CSV)',
            onTap: () => ref.read(backupServiceProvider).exportExpensesCsv(),
          ),
          const _SectionHeader('Support'),
          _MenuTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () => KAppDialog.info(
              context: context,
              title: 'Help',
              message:
                  'KapdaKhata helps you manage products, record sales, track expenses, and view monthly profit/loss.\n\n'
                  '1. Add products with cost and selling prices\n'
                  '2. Record sales to auto-calculate profit\n'
                  '3. Add business expenses separately\n'
                  '4. View dashboard and reports for insights',
            ),
          ),
          _MenuTile(
            icon: Icons.info_outline,
            title: 'About',
            onTap: () => KAppDialog.about(
              context: context,
              appName: 'KapdaKhata',
              version: '1.0.0',
              description:
                  'A simple clothing business management app for shop owners. Manage • Sell • Grow',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadSampleData(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final count = await db.activeProductCount();
    if (!context.mounted) return;

    if (count > 0) {
      final confirmed = await KAppDialog.confirm(
        context: context,
        title: 'Replace with sample data?',
        message:
            'This clears existing products, sales, and expenses, then loads demo data.',
        confirmLabel: 'Load Sample',
        isDanger: true,
      );
      if (!confirmed) return;
      await ref.read(settingsRepositoryProvider).clearAllData();
    }

    await DummyDataService(db).seed();
    ref.invalidate(productsStreamProvider);
    ref.invalidate(salesStreamProvider);
    ref.invalidate(expensesStreamProvider);
    ref.invalidate(monthlyMetricsProvider);
    ref.invalidate(settingsProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sample data loaded')),
      );
    }
  }

  Future<void> _showRestoreBackupSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final backups = await ref.read(backupServiceProvider).listLocalBackups();
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _RestoreBackupDialog(backups: backups),
    );
  }
}

enum _RestorePhase { choose, restoring, restored, error }

class _RestoreBackupDialog extends ConsumerStatefulWidget {
  const _RestoreBackupDialog({required this.backups});

  final List<BackupEntry> backups;

  @override
  ConsumerState<_RestoreBackupDialog> createState() =>
      _RestoreBackupDialogState();
}

class _RestoreBackupDialogState extends ConsumerState<_RestoreBackupDialog> {
  _RestorePhase _phase = _RestorePhase.choose;
  String? _errorMessage;
  BackupEntry? _selectedEntry;
  String? _selectedFilePath;

  bool get _hasSelection =>
      _selectedEntry != null || _selectedFilePath != null;

  void _selectEntry(BackupEntry entry) {
    setState(() {
      _selectedEntry = entry;
      _selectedFilePath = null;
      _errorMessage = null;
    });
  }

  Future<void> _pickBackupFile() async {
    final path = await ref.read(backupServiceProvider).pickBackupFilePath();
    if (!mounted || path == null) return;
    setState(() {
      _selectedEntry = null;
      _selectedFilePath = path;
      _errorMessage = null;
    });
  }

  Future<void> _confirmRestore() async {
    final path = _selectedEntry?.dbPath ?? _selectedFilePath;
    if (path == null) return;

    setState(() {
      _phase = _RestorePhase.restoring;
      _errorMessage = null;
    });

    try {
      await ref.read(backupServiceProvider).restoreFromPath(path);
      if (!mounted) return;
      setState(() => _phase = _RestorePhase.restored);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _RestorePhase.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _restart() {
    reloadAppAfterRestore(ref);
    Navigator.pop(context);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final canDismiss = _phase != _RestorePhase.restoring &&
        _phase != _RestorePhase.restored;

    return PopScope(
      canPop: canDismiss,
      child: AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          _phase == _RestorePhase.restored ? 'Data imported' : 'Restore Backup',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: _buildContent(),
        actions: _buildActions(),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      ),
    );
  }

  Widget _buildContent() {
    switch (_phase) {
      case _RestorePhase.restoring:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator()),
        );
      case _RestorePhase.restored:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your backup has been restored successfully. Restart the app to apply changes.',
              style: TextStyle(
                fontSize: 15,
                height: 1.45,
                color: AppColors.neutralText,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _restart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.positiveGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Restart',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      case _RestorePhase.error:
        return Text(
          _errorMessage ?? 'Restore failed.',
          style: const TextStyle(color: AppColors.negativeRed),
        );
      case _RestorePhase.choose:
        return SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.backups.isEmpty)
                const Text(
                  'No local backups found on this device.',
                  style: TextStyle(color: AppColors.neutralText),
                )
              else ...[
                const Text(
                  'Choose a backup saved on this device:',
                  style: TextStyle(color: AppColors.neutralText),
                ),
                const SizedBox(height: 12),
                ...widget.backups.map(
                  (entry) {
                    final selected = _selectedEntry?.dbPath == entry.dbPath;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: selected
                              ? AppColors.primaryPurple
                              : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                      ),
                      child: ListTile(
                        title: Text(
                          entry.displayLabel,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(entry.sizeLabel),
                        onTap: () => _selectEntry(entry),
                      ),
                    );
                  },
                ),
              ],
              if (_selectedFilePath != null) ...[
                const SizedBox(height: 8),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(
                      color: AppColors.primaryPurple,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      p.basename(_selectedFilePath!),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: const Text('Selected from storage'),
                  ),
                ),
              ],
              if (_hasSelection) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _confirmRestore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Restore Backup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              TextButton(
                onPressed: _pickBackupFile,
                child: const Text('Pick backup file from storage'),
              ),
            ],
          ),
        );
    }
  }

  List<Widget>? _buildActions() {
    if (_phase == _RestorePhase.restored || _phase == _RestorePhase.restoring) {
      return null;
    }

    if (_phase == _RestorePhase.error) {
      return [
        TextButton(
          onPressed: () => setState(() {
            _phase = _RestorePhase.choose;
            _errorMessage = null;
          }),
          child: const Text('Back'),
        ),
      ];
    }

    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
    ];
  }
}

class _ThemeSelector extends ConsumerWidget {
  const _ThemeSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
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
              selected: themeMode == 'light',
              onTap: () => _setTheme(ref, 'light'),
            ),
            _ThemeOption(
              label: 'Dark',
              icon: Icons.dark_mode,
              selected: themeMode == 'dark',
              onTap: () => _setTheme(ref, 'dark'),
            ),
            _ThemeOption(
              label: 'System',
              icon: Icons.brightness_auto,
              selected: themeMode == 'system',
              onTap: () => _setTheme(ref, 'system'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setTheme(WidgetRef ref, String mode) async {
    ref.read(themeModeProvider.notifier).state = mode;
    final db = ref.read(databaseProvider);
    final settings = await db.getSettings();
    await (db.update(db.shopSettings)..where((t) => t.id.equals(settings.id)))
        .write(ShopSettingsCompanion(themeMode: Value(mode)));
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.mutedText,
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.purpleSubtle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryPurple, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.mutedText),
      onTap: onTap,
    );
  }
}
