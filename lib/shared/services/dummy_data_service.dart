import 'package:drift/drift.dart';
import 'package:kapdakhata/database/app_database.dart';

class DummyDataService {
  DummyDataService(this._db);

  final AppDatabase _db;

  Future<bool> seedIfEmpty() async {
    final count = await _db.activeProductCount();
    if (count > 0) return false;
    await seed();
    return true;
  }

  Future<void> seed() async {
    await _db.transaction(() async {
      final categories = await _db.select(_db.productCategories).get();
      final expenseCats = await _db.select(_db.expenseCategories).get();

      int catId(String name) =>
          categories.firstWhere((c) => c.name == name).id;
      int expCatId(String name) =>
          expenseCats.firstWhere((c) => c.name == name).id;

      final settings = await _db.getSettings();
      await (_db.update(_db.shopSettings)
            ..where((t) => t.id.equals(settings.id)))
          .write(
        const ShopSettingsCompanion(
          shopName: Value('Rajesh Cloth Store'),
          ownerName: Value('Rajesh Kumar'),
          phone: Value('9876543210'),
          address: Value('Main Market, Jaipur'),
          themeMode: Value('light'),
        ),
      );

      final productIds = <int>[];

      final products = [
        _ProductSeed(
          name: 'Round Neck T-Shirt',
          category: 'T-Shirt',
          size: 'M',
          color: 'Black',
          costPaise: 30000,
          sellingPaise: 79900,
          stock: 25,
          sku: 'TS-001',
        ),
        _ProductSeed(
          name: 'Oversized T-Shirt',
          category: 'T-Shirt',
          size: 'L',
          color: 'White',
          costPaise: 35000,
          sellingPaise: 89900,
          stock: 18,
          sku: 'TS-002',
        ),
        _ProductSeed(
          name: 'Formal Cotton Shirt',
          category: 'Shirt',
          size: 'L',
          color: 'Blue',
          costPaise: 45000,
          sellingPaise: 129900,
          stock: 12,
          sku: 'SH-001',
        ),
        _ProductSeed(
          name: 'Slim Fit Jeans',
          category: 'Jeans',
          size: '32',
          color: 'Indigo',
          costPaise: 65000,
          sellingPaise: 189900,
          stock: 15,
          sku: 'JN-001',
        ),
        _ProductSeed(
          name: 'Casual Trousers',
          category: 'Trousers',
          size: 'M',
          color: 'Grey',
          costPaise: 55000,
          sellingPaise: 149900,
          stock: 10,
          sku: 'TR-001',
        ),
        _ProductSeed(
          name: 'Pullover Hoodie',
          category: 'Hoodie',
          size: 'XL',
          color: 'Black',
          costPaise: 70000,
          sellingPaise: 199900,
          stock: 8,
          sku: 'HD-001',
        ),
        _ProductSeed(
          name: 'Denim Jacket',
          category: 'Jacket',
          size: 'L',
          color: 'Blue',
          costPaise: 95000,
          sellingPaise: 249900,
          stock: 6,
          sku: 'JK-001',
        ),
        _ProductSeed(
          name: 'Printed T-Shirt',
          category: 'T-Shirt',
          size: 'S',
          color: 'Red',
          costPaise: 28000,
          sellingPaise: 69900,
          stock: 4,
          sku: 'TS-003',
        ),
      ];

      for (final p in products) {
        final id = await _db.into(_db.products).insert(
              ProductsCompanion.insert(
                name: p.name,
                typeId: catId(p.category),
                size: Value(p.size),
                color: Value(p.color),
                costPricePaise: p.costPaise,
                sellingPricePaise: p.sellingPaise,
                stockQuantity: Value(p.stock),
                sku: Value(p.sku),
              ),
            );
        productIds.add(id);
      }

      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);
      final lastMonth = DateTime(now.year, now.month - 1);

      final sales = [
        _SaleSeed(productIndex: 0, qty: 2, day: 2, month: currentMonth),
        _SaleSeed(productIndex: 0, qty: 1, day: 5, month: currentMonth),
        _SaleSeed(productIndex: 1, qty: 3, day: 7, month: currentMonth),
        _SaleSeed(productIndex: 2, qty: 1, day: 9, month: currentMonth),
        _SaleSeed(productIndex: 3, qty: 2, day: 11, month: currentMonth),
        _SaleSeed(productIndex: 4, qty: 1, day: 12, month: currentMonth),
        _SaleSeed(productIndex: 5, qty: 1, day: 13, month: currentMonth),
        _SaleSeed(productIndex: 7, qty: 1, day: 10, month: currentMonth),
        _SaleSeed(productIndex: 0, qty: 4, day: 15, month: lastMonth),
        _SaleSeed(productIndex: 2, qty: 2, day: 20, month: lastMonth),
        _SaleSeed(productIndex: 3, qty: 1, day: 25, month: lastMonth),
      ];

      for (final sale in sales) {
        final productId = productIds[sale.productIndex];
        final product = await (_db.select(_db.products)
              ..where((t) => t.id.equals(productId)))
            .getSingle();

        await _db.createSale(
          productId: productId,
          quantity: sale.qty,
          unitCostPaise: product.costPricePaise,
          unitSellingPricePaise: product.sellingPricePaise,
          saleDate: DateTime(
            sale.month.year,
            sale.month.month,
            sale.day,
            11,
            30,
          ),
          notes: 'Walk-in customer',
        );
      }

      final expenses = [
        _ExpenseSeed(
          title: 'Shop Rent',
          category: 'Shop',
          amountPaise: 300000,
          day: 1,
          month: currentMonth,
        ),
        _ExpenseSeed(
          title: 'Electricity Bill',
          category: 'Utilities',
          amountPaise: 120000,
          day: 5,
          month: currentMonth,
        ),
        _ExpenseSeed(
          title: 'Staff Salary',
          category: 'Salary',
          amountPaise: 800000,
          day: 1,
          month: currentMonth,
        ),
        _ExpenseSeed(
          title: 'Transport',
          category: 'Transport',
          amountPaise: 50000,
          day: 8,
          month: currentMonth,
        ),
        _ExpenseSeed(
          title: 'Packaging Supplies',
          category: 'Packaging',
          amountPaise: 35000,
          day: 10,
          month: currentMonth,
        ),
        _ExpenseSeed(
          title: 'Shop Rent',
          category: 'Shop',
          amountPaise: 300000,
          day: 1,
          month: lastMonth,
        ),
        _ExpenseSeed(
          title: 'Electricity Bill',
          category: 'Utilities',
          amountPaise: 110000,
          day: 5,
          month: lastMonth,
        ),
      ];

      for (final expense in expenses) {
        await _db.into(_db.expenses).insert(
              ExpensesCompanion.insert(
                title: expense.title,
                categoryId: expCatId(expense.category),
                amountPaise: expense.amountPaise,
                expenseDate: DateTime(
                  expense.month.year,
                  expense.month.month,
                  expense.day,
                ),
              ),
            );
      }
    });
  }
}

class _ProductSeed {
  const _ProductSeed({
    required this.name,
    required this.category,
    required this.size,
    required this.color,
    required this.costPaise,
    required this.sellingPaise,
    required this.stock,
    required this.sku,
  });

  final String name;
  final String category;
  final String size;
  final String color;
  final int costPaise;
  final int sellingPaise;
  final int stock;
  final String sku;
}

class _SaleSeed {
  const _SaleSeed({
    required this.productIndex,
    required this.qty,
    required this.day,
    required this.month,
  });

  final int productIndex;
  final int qty;
  final int day;
  final DateTime month;
}

class _ExpenseSeed {
  const _ExpenseSeed({
    required this.title,
    required this.category,
    required this.amountPaise,
    required this.day,
    required this.month,
  });

  final String title;
  final String category;
  final int amountPaise;
  final int day;
  final DateTime month;
}
