import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kapdakhata/database/app_database.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(databaseProvider));
});

class BackupEntry {
  const BackupEntry({
    required this.dbPath,
    required this.metaPath,
    required this.createdAt,
    required this.isAutomatic,
    required this.sizeBytes,
  });

  final String dbPath;
  final String metaPath;
  final DateTime createdAt;
  final bool isAutomatic;
  final int sizeBytes;

  String get displayLabel =>
      DateFormat('d MMM yyyy, h:mm a').format(createdAt);

  String get sizeLabel {
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class BackupService {
  BackupService(this._db);

  final AppDatabase _db;
  static const _maxStoredBackups = 30;
  static const _autoBackupMarker = 'last_auto_backup.txt';

  Future<Directory> _backupDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(dir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  Future<File> _databaseFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'kapdakhata.db'));
  }

  Future<BackupEntry> createLocalBackup({required bool automatic}) async {
    final dbFile = await _databaseFile();
    if (!await dbFile.exists()) {
      throw StateError('Database file not found');
    }

    final settings = await _db.getSettings();
    final now = DateTime.now();
    final stamp = DateFormat('yyyyMMdd_HHmmss').format(now);
    final backupDir = await _backupDirectory();
    final baseName = 'kapdakhata_backup_$stamp';
    final dbPath = p.join(backupDir.path, '$baseName.db');
    final metaPath = p.join(backupDir.path, '$baseName.json');

    await dbFile.copy(dbPath);
    final metadata = {
      'version': 1,
      'exportedAt': now.toIso8601String(),
      'automatic': automatic,
      'settings': {
        'shopName': settings.shopName,
        'ownerName': settings.ownerName,
        'phone': settings.phone,
        'address': settings.address,
        'currency': settings.currency,
        'lowStockThreshold': settings.lowStockThreshold,
      },
    };
    await File(metaPath).writeAsString(jsonEncode(metadata));

    await _trimOldBackups();
    return BackupEntry(
      dbPath: dbPath,
      metaPath: metaPath,
      createdAt: now,
      isAutomatic: automatic,
      sizeBytes: await File(dbPath).length(),
    );
  }

  Future<void> runDailyBackupIfNeeded() async {
    final backupDir = await _backupDirectory();
    final marker = File(p.join(backupDir.path, _autoBackupMarker));
    final now = DateTime.now();

    if (await marker.exists()) {
      final lastText = (await marker.readAsString()).trim();
      final last = DateTime.tryParse(lastText);
      if (last != null && now.difference(last) < const Duration(hours: 24)) {
        return;
      }
    }

    await createLocalBackup(automatic: true);
    await marker.writeAsString(now.toIso8601String());
  }

  Future<List<BackupEntry>> listLocalBackups() async {
    final backupDir = await _backupDirectory();
    final files = backupDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.db'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));

    final entries = <BackupEntry>[];
    for (final db in files) {
      final metaPath = db.path.replaceAll('.db', '.json');
      final metaFile = File(metaPath);
      DateTime createdAt = db.lastModifiedSync();
      var automatic = db.path.contains('_backup_');

      if (await metaFile.exists()) {
        try {
          final json =
              jsonDecode(await metaFile.readAsString()) as Map<String, dynamic>;
          createdAt =
              DateTime.tryParse(json['exportedAt'] as String? ?? '') ?? createdAt;
          automatic = json['automatic'] as bool? ?? automatic;
        } catch (_) {}
      }

      entries.add(
        BackupEntry(
          dbPath: db.path,
          metaPath: metaPath,
          createdAt: createdAt,
          isAutomatic: automatic,
          sizeBytes: await db.length(),
        ),
      );
    }

    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<void> exportBackup() async {
    final entry = await createLocalBackup(automatic: false);
    await Share.shareXFiles(
      [XFile(entry.dbPath), XFile(entry.metaPath)],
      text: 'KapdaKhata Backup',
    );
  }

  Future<void> restoreFromPath(String dbPath) async {
    final source = File(dbPath);
    if (!await source.exists()) {
      throw StateError('Backup file not found');
    }

    final dbFile = await _databaseFile();
    await _db.close();

    if (await dbFile.exists()) {
      await dbFile.delete();
    }
    await source.copy(dbFile.path);
  }

  Future<String?> pickBackupFilePath() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['db'],
    );
    if (result == null || result.files.isEmpty) return null;

    return result.files.single.path;
  }

  Future<void> _trimOldBackups() async {
    final backups = await listLocalBackups();
    if (backups.length <= _maxStoredBackups) return;

    for (final entry in backups.skip(_maxStoredBackups)) {
      final db = File(entry.dbPath);
      final meta = File(entry.metaPath);
      if (await db.exists()) await db.delete();
      if (await meta.exists()) await meta.delete();
    }
  }

  Future<void> exportProductsCsv() async {
    final products = await _db.watchActiveProducts();
    final csv = StringBuffer('Name,Category,Size,Color,Cost,Selling,Stock,SKU\n');
    for (final item in products) {
      csv.writeln(
        '"${item.product.name}","${item.category.name}","${item.product.size ?? ''}","${item.product.color ?? ''}",${item.product.costPricePaise / 100},${item.product.sellingPricePaise / 100},${item.product.stockQuantity},"${item.product.sku ?? ''}"',
      );
    }
    await _shareCsv('products', csv.toString());
  }

  Future<void> exportSalesCsv() async {
    final sales = await _db.select(_db.sales).join([
      innerJoin(_db.products, _db.products.id.equalsExp(_db.sales.productId)),
    ]).get();

    final csv = StringBuffer(
      'Product,Quantity,Total Sale,Total Cost,Profit,Date\n',
    );
    for (final row in sales) {
      final sale = row.readTable(_db.sales);
      final product = row.readTable(_db.products);
      csv.writeln(
        '"${product.name}",${sale.quantity},${sale.totalSellingAmountPaise / 100},${sale.totalCostPaise / 100},${sale.profitPaise / 100},"${sale.saleDate.toIso8601String()}"',
      );
    }
    await _shareCsv('sales', csv.toString());
  }

  Future<void> exportExpensesCsv() async {
    final expenses = await _db.select(_db.expenses).join([
      innerJoin(
        _db.expenseCategories,
        _db.expenseCategories.id.equalsExp(_db.expenses.categoryId),
      ),
    ]).get();

    final csv = StringBuffer('Title,Category,Amount,Date,Notes\n');
    for (final row in expenses) {
      final expense = row.readTable(_db.expenses);
      final category = row.readTable(_db.expenseCategories);
      csv.writeln(
        '"${expense.title}","${category.name}",${expense.amountPaise / 100},"${expense.expenseDate.toIso8601String()}","${expense.notes ?? ''}"',
      );
    }
    await _shareCsv('expenses', csv.toString());
  }

  Future<void> _shareCsv(String name, String content) async {
    final dir = await getTemporaryDirectory();
    final path = p.join(
      dir.path,
      'kapdakhata_${name}_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await File(path).writeAsString(content);
    await Share.shareXFiles([XFile(path)], text: 'KapdaKhata $name export');
  }
}
