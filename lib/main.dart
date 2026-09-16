import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapdakhata/app.dart';
import 'package:kapdakhata/database/app_database.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:kapdakhata/shared/services/backup_service.dart';
import 'package:kapdakhata/shared/services/dummy_data_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  final settings = await db.getSettings();
  final themeMode = settings.themeMode == 'system' ? 'light' : settings.themeMode;

  if (settings.themeMode == 'system') {
    await (db.update(db.shopSettings)..where((t) => t.id.equals(settings.id)))
        .write(const ShopSettingsCompanion(themeMode: Value('light')));
  }

  await DummyDataService(db).seedIfEmpty();
  await BackupService(db).runDailyBackupIfNeeded();
  await db.close();

  runApp(
    ProviderScope(
      overrides: [
        themeModeProvider.overrideWith((ref) => themeMode),
      ],
      child: const KapdaKhataApp(),
    ),
  );
}
