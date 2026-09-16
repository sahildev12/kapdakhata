import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kapdakhata/database/app_database.dart';
import 'package:kapdakhata/shared/providers/app_providers.dart';
import 'package:kapdakhata/shared/services/permission_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

final imageServiceProvider = Provider<ImageService>((ref) => ImageService());

class ImageService {
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  Future<String?> pickImage(
    ImageSource source, {
    BuildContext? context,
  }) async {
    if (context != null) {
      final allowed = await PermissionService.ensureSourceAccess(context, source);
      if (!allowed) return null;
    }

    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (picked == null) return null;

    final dir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(dir.path, 'product_photos'));
    if (!await photosDir.exists()) {
      await photosDir.create(recursive: true);
    }

    final ext = p.extension(picked.path);
    final destPath = p.join(photosDir.path, '${_uuid.v4()}$ext');
    await File(picked.path).copy(destPath);
    return destPath;
  }

  Future<void> deleteImage(String? path) async {
    if (path == null) return;
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(
    ref.watch(databaseProvider),
    ref.watch(imageServiceProvider),
  );
});

class ProductRepository {
  ProductRepository(this._db, this._imageService);

  final AppDatabase _db;
  final ImageService _imageService;

  Future<int> createProduct({
    required String name,
    required int typeId,
    String? size,
    String? color,
    String? photoPath,
    required int costPricePaise,
    required int sellingPricePaise,
    int stockQuantity = 0,
    String? sku,
    String? notes,
  }) {
    return _db.into(_db.products).insert(
          ProductsCompanion.insert(
            name: name,
            typeId: typeId,
            size: Value(size),
            color: Value(color),
            photoPath: Value(photoPath),
            costPricePaise: costPricePaise,
            sellingPricePaise: sellingPricePaise,
            stockQuantity: Value(stockQuantity),
            sku: Value(sku),
            notes: Value(notes),
          ),
        );
  }

  Future<void> updateProduct({
    required int id,
    required String name,
    required int typeId,
    String? size,
    String? color,
    String? photoPath,
    required int costPricePaise,
    required int sellingPricePaise,
    int? stockQuantity,
    String? sku,
    String? notes,
  }) async {
    await (_db.update(_db.products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion(
        name: Value(name),
        typeId: Value(typeId),
        size: Value(size),
        color: Value(color),
        photoPath: Value(photoPath),
        costPricePaise: Value(costPricePaise),
        sellingPricePaise: Value(sellingPricePaise),
        stockQuantity:
            stockQuantity != null ? Value(stockQuantity) : const Value.absent(),
        sku: Value(sku),
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> addStock(int productId, int quantity) async {
    final product = await (_db.select(_db.products)
          ..where((t) => t.id.equals(productId)))
        .getSingle();
    await (_db.update(_db.products)..where((t) => t.id.equals(productId))).write(
      ProductsCompanion(
        stockQuantity: Value(product.stockQuantity + quantity),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> softDeleteProduct(int id) async {
    await (_db.update(_db.products)..where((t) => t.id.equals(id))).write(
      ProductsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deletePhoto(String? oldPath) => _imageService.deleteImage(oldPath);
}

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepository(ref.watch(databaseProvider));
});

class SalesRepository {
  SalesRepository(this._db);
  final AppDatabase _db;

  Future<int> createSale({
    required int productId,
    required int quantity,
    required DateTime saleDate,
    String? notes,
  }) async {
    final product = await (_db.select(_db.products)
          ..where((t) => t.id.equals(productId)))
        .getSingle();
    return _db.createSale(
      productId: productId,
      quantity: quantity,
      unitCostPaise: product.costPricePaise,
      unitSellingPricePaise: product.sellingPricePaise,
      saleDate: saleDate,
      notes: notes,
    );
  }

  Future<List<int>> createQuickSaleBatch({
    required List<QuickSaleLine> lines,
    required DateTime saleDate,
    String? notes,
  }) {
    return _db.createQuickSaleBatch(
      lines: lines,
      saleDate: saleDate,
      notes: notes,
    );
  }
}

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository(ref.watch(databaseProvider));
});

class ExpenseRepository {
  ExpenseRepository(this._db);
  final AppDatabase _db;

  Future<int> createExpense({
    required String title,
    required int categoryId,
    required int amountPaise,
    required DateTime expenseDate,
    String? notes,
  }) {
    return _db.into(_db.expenses).insert(
          ExpensesCompanion.insert(
            title: title,
            categoryId: categoryId,
            amountPaise: amountPaise,
            expenseDate: expenseDate,
            notes: Value(notes),
          ),
        );
  }

  Future<void> deleteExpense(int id) async {
    await (_db.delete(_db.expenses)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateExpense({
    required int id,
    required String title,
    required int categoryId,
    required int amountPaise,
    required DateTime expenseDate,
    String? notes,
  }) async {
    await (_db.update(_db.expenses)..where((t) => t.id.equals(id))).write(
      ExpensesCompanion(
        title: Value(title),
        categoryId: Value(categoryId),
        amountPaise: Value(amountPaise),
        expenseDate: Value(expenseDate),
        notes: Value(notes),
      ),
    );
  }
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository(ref.watch(databaseProvider));
});

class SettingsRepository {
  SettingsRepository(this._db);
  final AppDatabase _db;

  Future<void> updateSettings({
    required String shopName,
    required String ownerName,
    String? phone,
    String? address,
    required String currency,
    required int lowStockThreshold,
    required String themeMode,
    required bool notificationsEnabled,
  }) async {
    final settings = await _db.getSettings();
    await (_db.update(_db.shopSettings)..where((t) => t.id.equals(settings.id)))
        .write(
      ShopSettingsCompanion(
        shopName: Value(shopName),
        ownerName: Value(ownerName),
        phone: Value(phone),
        address: Value(address),
        currency: Value(currency),
        lowStockThreshold: Value(lowStockThreshold),
        themeMode: Value(themeMode),
        notificationsEnabled: Value(notificationsEnabled),
      ),
    );
  }

  Future<void> addProductCategory(String name) async {
    await _db.into(_db.productCategories).insert(
          ProductCategoriesCompanion.insert(name: name),
        );
  }

  Future<void> deleteProductCategory(int id) async {
    await (_db.delete(_db.productCategories)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> addExpenseCategory(String name) async {
    await _db.into(_db.expenseCategories).insert(
          ExpenseCategoriesCompanion.insert(name: name),
        );
  }

  Future<void> deleteExpenseCategory(int id) async {
    await (_db.delete(_db.expenseCategories)..where((t) => t.id.equals(id)))
        .go();
  }

  Future<void> addSaleNameSuggestion(String name) async {
    await _db.addSaleNameSuggestion(name);
  }

  Future<void> deleteSaleNameSuggestion(int id) async {
    await _db.deleteSaleNameSuggestion(id);
  }

  Future<void> clearAllData() => _db.clearAllData();
}
