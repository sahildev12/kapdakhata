import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class ProductCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ExpenseCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get typeId => integer().references(ProductCategories, #id)();
  TextColumn get size => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  IntColumn get costPricePaise => integer()();
  IntColumn get sellingPricePaise => integer()();
  IntColumn get stockQuantity => integer().withDefault(const Constant(0))();
  TextColumn get sku => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
}

class Sales extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().references(Products, #id)();
  IntColumn get quantity => integer()();
  IntColumn get unitCostPaise => integer()();
  IntColumn get unitSellingPricePaise => integer()();
  IntColumn get totalCostPaise => integer()();
  IntColumn get totalSellingAmountPaise => integer()();
  IntColumn get profitPaise => integer()();
  DateTimeColumn get saleDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get categoryId => integer().references(ExpenseCategories, #id)();
  IntColumn get amountPaise => integer()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class ShopSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get shopName =>
      text().withDefault(const Constant('My Clothing Shop'))();
  TextColumn get ownerName => text().withDefault(const Constant('Shop Owner'))();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('INR'))();
  IntColumn get lowStockThreshold => integer().withDefault(const Constant(5))();
  TextColumn get themeMode =>
      text().withDefault(const Constant('light'))();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(true))();
}

class SaleNameSuggestions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(
  tables: [
    ProductCategories,
    ExpenseCategories,
    Products,
    Sales,
    Expenses,
    ShopSettings,
    SaleNameSuggestions,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _seedDefaults();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(saleNameSuggestions);
          }
        },
      );

  Future<void> _seedDefaults() async {
    const defaultProductCategories = [
      'T-Shirt',
      'Shirt',
      'Jeans',
      'Trousers',
      'Hoodie',
      'Jacket',
      'Other',
    ];
    for (final name in defaultProductCategories) {
      await into(productCategories).insert(
        ProductCategoriesCompanion.insert(name: name),
        mode: InsertMode.insertOrIgnore,
      );
    }

    const defaultExpenseCategories = [
      'Shop',
      'Utilities',
      'Salary',
      'Transport',
      'Packaging',
      'Marketing',
      'Maintenance',
      'Other',
    ];
    for (final name in defaultExpenseCategories) {
      await into(expenseCategories).insert(
        ExpenseCategoriesCompanion.insert(name: name),
        mode: InsertMode.insertOrIgnore,
      );
    }

    await into(shopSettings).insert(const ShopSettingsCompanion());
  }

  // --- Products ---

  Future<List<ProductWithCategory>> watchActiveProducts({
    String? search,
    Set<int> categoryIds = const {},
    int limit = 50,
    int offset = 0,
  }) {
    final query = select(products).join([
      innerJoin(
        productCategories,
        productCategories.id.equalsExp(products.typeId),
      ),
    ])
      ..where(products.isDeleted.equals(false));

    if (search != null && search.isNotEmpty) {
      final pattern = '%${search.toLowerCase()}%';
      query.where(
        products.name.lower().like(pattern) |
            products.sku.lower().like(pattern) |
            products.size.lower().like(pattern) |
            productCategories.name.lower().like(pattern),
      );
    }

    if (categoryIds.isNotEmpty) {
      query.where(products.typeId.isIn(categoryIds.toList()));
    }

    query
      ..orderBy([OrderingTerm.desc(products.updatedAt)])
      ..limit(limit, offset: offset);

    return query.map((row) {
      return ProductWithCategory(
        product: row.readTable(products),
        category: row.readTable(productCategories),
      );
    }).get();
  }

  Stream<List<ProductWithCategory>> watchActiveProductsStream({
    String search = '',
    Set<int> categoryIds = const {},
  }) {
    final query = select(products).join([
      innerJoin(
        productCategories,
        productCategories.id.equalsExp(products.typeId),
      ),
    ])
      ..where(products.isDeleted.equals(false));

    if (search.isNotEmpty) {
      final pattern = '%${search.toLowerCase()}%';
      query.where(
        products.name.lower().like(pattern) |
            products.sku.lower().like(pattern) |
            products.size.lower().like(pattern) |
            productCategories.name.lower().like(pattern),
      );
    }

    if (categoryIds.isNotEmpty) {
      query.where(products.typeId.isIn(categoryIds.toList()));
    }

    query.orderBy([OrderingTerm.desc(products.updatedAt)]);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => ProductWithCategory(
              product: row.readTable(products),
              category: row.readTable(productCategories),
            ),
          )
          .toList();
    });
  }

  Future<ProductWithCategory?> getProductWithCategory(int id) async {
    final query = select(products).join([
      innerJoin(
        productCategories,
        productCategories.id.equalsExp(products.typeId),
      ),
    ])
      ..where(products.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return ProductWithCategory(
      product: row.readTable(products),
      category: row.readTable(productCategories),
    );
  }

  Future<List<ProductWithCategory>> getLowStockProducts(int threshold) {
    final query = select(products).join([
      innerJoin(
        productCategories,
        productCategories.id.equalsExp(products.typeId),
      ),
    ])
      ..where(products.isDeleted.equals(false))
      ..where(products.stockQuantity.isSmallerOrEqualValue(threshold))
      ..orderBy([
        OrderingTerm.asc(products.stockQuantity),
        OrderingTerm.asc(products.name),
      ]);

    return query.map((row) {
      return ProductWithCategory(
        product: row.readTable(products),
        category: row.readTable(productCategories),
      );
    }).get();
  }

  Future<ProductStats> getProductStats(int productId) async {
    final salesQuery = selectOnly(sales)
      ..addColumns([
        sales.quantity.sum(),
        sales.totalSellingAmountPaise.sum(),
        sales.profitPaise.sum(),
      ])
      ..where(sales.productId.equals(productId));

    final row = await salesQuery.getSingle();
    return ProductStats(
      quantitySold: row.read(sales.quantity.sum()) ?? 0,
      totalRevenuePaise: row.read(sales.totalSellingAmountPaise.sum()) ?? 0,
      totalProfitPaise: row.read(sales.profitPaise.sum()) ?? 0,
    );
  }

  // --- Sales ---

  Stream<List<SaleWithProduct>> watchSales({
    DateTime? start,
    DateTime? end,
    String search = '',
    int limit = 50,
    int offset = 0,
  }) {
    final query = select(sales).join([
      innerJoin(products, products.id.equalsExp(sales.productId)),
    ]);

    if (start != null) {
      query.where(sales.saleDate.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      query.where(sales.saleDate.isSmallerOrEqualValue(end));
    }
    if (search.isNotEmpty) {
      query.where(products.name.lower().like('%${search.toLowerCase()}%'));
    }

    query
      ..orderBy([OrderingTerm.desc(sales.saleDate)])
      ..limit(limit, offset: offset);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => SaleWithProduct(
              sale: row.readTable(sales),
              product: row.readTable(products),
            ),
          )
          .toList();
    });
  }

  Future<SaleWithProduct?> getSaleWithProduct(int id) async {
    final query = select(sales).join([
      innerJoin(products, products.id.equalsExp(sales.productId)),
    ])
      ..where(sales.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return SaleWithProduct(
      sale: row.readTable(sales),
      product: row.readTable(products),
    );
  }

  Future<int> createSale({
    required int productId,
    required int quantity,
    required int unitCostPaise,
    required int unitSellingPricePaise,
    required DateTime saleDate,
    String? notes,
  }) async {
    return transaction(() async {
      final product = await (select(products)..where((t) => t.id.equals(productId)))
          .getSingle();
      if (product.stockQuantity < quantity) {
        throw StateError('Insufficient stock');
      }

      final totalCost = unitCostPaise * quantity;
      final totalSelling = unitSellingPricePaise * quantity;
      final profit = totalSelling - totalCost;

      final saleId = await into(sales).insert(
        SalesCompanion.insert(
          productId: productId,
          quantity: quantity,
          unitCostPaise: unitCostPaise,
          unitSellingPricePaise: unitSellingPricePaise,
          totalCostPaise: totalCost,
          totalSellingAmountPaise: totalSelling,
          profitPaise: profit,
          saleDate: saleDate,
          notes: Value(notes),
        ),
      );

      await (update(products)..where((t) => t.id.equals(productId))).write(
        ProductsCompanion(
          stockQuantity: Value(product.stockQuantity - quantity),
          updatedAt: Value(DateTime.now()),
        ),
      );

      return saleId;
    });
  }

  /// Records a sale without requiring a pre-added product.
  Future<int> createQuickSale({
    required String itemName,
    required int unitCostPaise,
    required int unitSellingPricePaise,
    required int quantity,
    required DateTime saleDate,
    String? notes,
  }) async {
    final ids = await createQuickSaleBatch(
      lines: [
        QuickSaleLine(
          itemName: itemName,
          unitCostPaise: unitCostPaise,
          totalSellingPaise: unitSellingPricePaise * quantity,
          quantity: quantity,
        ),
      ],
      saleDate: saleDate,
      notes: notes,
    );
    return ids.first;
  }

  Future<List<int>> createQuickSaleBatch({
    required List<QuickSaleLine> lines,
    required DateTime saleDate,
    String? notes,
  }) async {
    if (lines.isEmpty) return [];

    return transaction(() async {
      final otherCategory = await (select(productCategories)
            ..where((t) => t.name.equals('Other')))
          .getSingle();

      final ids = <int>[];
      for (final line in lines) {
        final productId = await into(products).insert(
          ProductsCompanion.insert(
            name: line.itemName.trim().isEmpty
                ? 'Quick Sale Item'
                : line.itemName.trim(),
            typeId: otherCategory.id,
            costPricePaise: line.unitCostPaise,
            sellingPricePaise: line.unitSellingPricePaise,
            stockQuantity: Value(line.quantity),
          ),
        );

        final totalCost = line.totalCostPaise;
        final totalSelling = line.totalSellingPaise;
        final profit = line.profitPaise;

        final saleId = await into(sales).insert(
          SalesCompanion.insert(
            productId: productId,
            quantity: line.quantity,
            unitCostPaise: line.unitCostPaise,
            unitSellingPricePaise: line.unitSellingPricePaise,
            totalCostPaise: totalCost,
            totalSellingAmountPaise: totalSelling,
            profitPaise: profit,
            saleDate: saleDate,
            notes: Value(notes),
          ),
        );

        await (update(products)..where((t) => t.id.equals(productId))).write(
          ProductsCompanion(
            stockQuantity: const Value(0),
            updatedAt: Value(DateTime.now()),
          ),
        );

        ids.add(saleId);
      }
      return ids;
    });
  }

  // --- Expenses ---

  Stream<List<ExpenseWithCategory>> watchExpenses({
    DateTime? start,
    DateTime? end,
    String search = '',
    int limit = 50,
    int offset = 0,
  }) {
    final query = select(expenses).join([
      innerJoin(
        expenseCategories,
        expenseCategories.id.equalsExp(expenses.categoryId),
      ),
    ]);

    if (start != null) {
      query.where(expenses.expenseDate.isBiggerOrEqualValue(start));
    }
    if (end != null) {
      query.where(expenses.expenseDate.isSmallerOrEqualValue(end));
    }
    if (search.isNotEmpty) {
      final pattern = '%${search.toLowerCase()}%';
      query.where(
        expenses.title.lower().like(pattern) |
            expenseCategories.name.lower().like(pattern),
      );
    }

    query
      ..orderBy([OrderingTerm.desc(expenses.expenseDate)])
      ..limit(limit, offset: offset);

    return query.watch().map((rows) {
      return rows
          .map(
            (row) => ExpenseWithCategory(
              expense: row.readTable(expenses),
              category: row.readTable(expenseCategories),
            ),
          )
          .toList();
    });
  }

  Future<ExpenseWithCategory?> getExpenseWithCategory(int id) async {
    final query = select(expenses).join([
      innerJoin(
        expenseCategories,
        expenseCategories.id.equalsExp(expenses.categoryId),
      ),
    ])
      ..where(expenses.id.equals(id));

    final row = await query.getSingleOrNull();
    if (row == null) return null;
    return ExpenseWithCategory(
      expense: row.readTable(expenses),
      category: row.readTable(expenseCategories),
    );
  }

  // --- Dashboard / Reports ---

  Future<MonthlyMetrics> getMonthlyMetrics(DateTime month) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59, 999);

    final salesQuery = selectOnly(sales)
      ..addColumns([
        sales.totalSellingAmountPaise.sum(),
        sales.totalCostPaise.sum(),
        sales.profitPaise.sum(),
        sales.quantity.sum(),
      ])
      ..where(sales.saleDate.isBetweenValues(start, end));

    final salesRow = await salesQuery.getSingle();
    final totalSales = salesRow.read(sales.totalSellingAmountPaise.sum()) ?? 0;
    final totalCost = salesRow.read(sales.totalCostPaise.sum()) ?? 0;
    final grossProfit = salesRow.read(sales.profitPaise.sum()) ?? 0;
    final productsSold = salesRow.read(sales.quantity.sum()) ?? 0;

    final expenseQuery = selectOnly(expenses)
      ..addColumns([expenses.amountPaise.sum()])
      ..where(expenses.expenseDate.isBetweenValues(start, end));

    final expenseRow = await expenseQuery.getSingle();
    final totalExpenses = expenseRow.read(expenses.amountPaise.sum()) ?? 0;

    return MonthlyMetrics(
      totalSalesPaise: totalSales,
      totalCostPaise: totalCost,
      grossProfitPaise: grossProfit,
      totalExpensesPaise: totalExpenses,
      netProfitPaise: grossProfit - totalExpenses,
      productsSold: productsSold,
    );
  }

  Future<List<MonthlyMetrics>> getMonthlyMetricsRange(
    DateTime startMonth,
    DateTime endMonth,
  ) async {
    final results = <MonthlyMetrics>[];
    var current = DateTime(startMonth.year, startMonth.month);
    final end = DateTime(endMonth.year, endMonth.month);

    while (!current.isAfter(end)) {
      results.add(await getMonthlyMetrics(current));
      current = DateTime(current.year, current.month + 1);
    }
    return results;
  }

  Future<List<CategoryExpenseBreakdown>> getExpenseBreakdown(
    DateTime start,
    DateTime end,
  ) async {
    final query = select(expenses).join([
      innerJoin(
        expenseCategories,
        expenseCategories.id.equalsExp(expenses.categoryId),
      ),
    ])
      ..where(expenses.expenseDate.isBetweenValues(start, end));

    final rows = await query.get();
    final map = <String, int>{};
    for (final row in rows) {
      final category = row.readTable(expenseCategories);
      final expense = row.readTable(expenses);
      map[category.name] = (map[category.name] ?? 0) + expense.amountPaise;
    }

    return map.entries
        .map(
          (e) => CategoryExpenseBreakdown(
            categoryName: e.key,
            amountPaise: e.value,
          ),
        )
        .toList()
      ..sort((a, b) => b.amountPaise.compareTo(a.amountPaise));
  }

  Future<List<TopProduct>> getTopProductsByQuantity(
    DateTime start,
    DateTime end, {
    int limit = 5,
  }) async {
    final query = selectOnly(sales)
      ..addColumns([
        sales.productId,
        sales.quantity.sum(),
        sales.profitPaise.sum(),
      ])
      ..where(sales.saleDate.isBetweenValues(start, end))
      ..groupBy([sales.productId])
      ..orderBy([OrderingTerm.desc(sales.quantity.sum())])
      ..limit(limit);

    final rows = await query.get();
    final results = <TopProduct>[];
    for (final row in rows) {
      final productId = row.read(sales.productId)!;
      final product = await (select(products)..where((t) => t.id.equals(productId)))
          .getSingleOrNull();
      if (product == null) continue;
      results.add(
        TopProduct(
          productName: product.name,
          quantity: row.read(sales.quantity.sum()) ?? 0,
          profitPaise: row.read(sales.profitPaise.sum()) ?? 0,
        ),
      );
    }
    return results;
  }

  Future<List<TopProduct>> getTopProductsByProfit(
    DateTime start,
    DateTime end, {
    int limit = 5,
  }) async {
    final query = selectOnly(sales)
      ..addColumns([
        sales.productId,
        sales.quantity.sum(),
        sales.profitPaise.sum(),
      ])
      ..where(sales.saleDate.isBetweenValues(start, end))
      ..groupBy([sales.productId])
      ..orderBy([OrderingTerm.desc(sales.profitPaise.sum())])
      ..limit(limit);

    final rows = await query.get();
    final results = <TopProduct>[];
    for (final row in rows) {
      final productId = row.read(sales.productId)!;
      final product = await (select(products)..where((t) => t.id.equals(productId)))
          .getSingleOrNull();
      if (product == null) continue;
      results.add(
        TopProduct(
          productName: product.name,
          quantity: row.read(sales.quantity.sum()) ?? 0,
          profitPaise: row.read(sales.profitPaise.sum()) ?? 0,
        ),
      );
    }
    return results;
  }

  Future<ShopSetting> getSettings() async {
    final settings = await select(shopSettings).get();
    if (settings.isEmpty) {
      await into(shopSettings).insert(const ShopSettingsCompanion());
      return (await select(shopSettings).getSingle());
    }
    return settings.first;
  }

  Stream<List<SaleNameSuggestion>> watchSaleNameSuggestions() {
    return (select(saleNameSuggestions)
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<int> addSaleNameSuggestion(String name) {
    return into(saleNameSuggestions).insert(
      SaleNameSuggestionsCompanion.insert(name: name.trim()),
    );
  }

  Future<void> deleteSaleNameSuggestion(int id) async {
    await (delete(saleNameSuggestions)..where((t) => t.id.equals(id))).go();
  }

  Stream<ShopSetting> watchSettings() {
    return select(shopSettings).watchSingleOrNull().map((s) {
      if (s == null) {
        return ShopSetting(
          id: 0,
          shopName: 'My Clothing Shop',
          ownerName: 'Shop Owner',
          phone: null,
          address: null,
          currency: 'INR',
          lowStockThreshold: 5,
          themeMode: 'system',
          notificationsEnabled: true,
        );
      }
      return s;
    });
  }

  Future<void> clearAllData() async {
    await delete(sales).go();
    await delete(expenses).go();
    await delete(products).go();
  }

  Future<int> activeProductCount() async {
    final countExpr = products.id.count();
    final query = selectOnly(products)
      ..addColumns([countExpr])
      ..where(products.isDeleted.equals(false));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'kapdakhata.db'));
    return NativeDatabase.createInBackground(file);
  });
}

class ProductWithCategory {
  const ProductWithCategory({required this.product, required this.category});
  final Product product;
  final ProductCategory category;
}

class SaleWithProduct {
  const SaleWithProduct({required this.sale, required this.product});
  final Sale sale;
  final Product product;
}

class ExpenseWithCategory {
  const ExpenseWithCategory({required this.expense, required this.category});
  final Expense expense;
  final ExpenseCategory category;
}

class ProductStats {
  const ProductStats({
    required this.quantitySold,
    required this.totalRevenuePaise,
    required this.totalProfitPaise,
  });
  final int quantitySold;
  final int totalRevenuePaise;
  final int totalProfitPaise;
}

class MonthlyMetrics {
  const MonthlyMetrics({
    required this.totalSalesPaise,
    required this.totalCostPaise,
    required this.grossProfitPaise,
    required this.totalExpensesPaise,
    required this.netProfitPaise,
    required this.productsSold,
  });
  final int totalSalesPaise;
  final int totalCostPaise;
  final int grossProfitPaise;
  final int totalExpensesPaise;
  final int netProfitPaise;
  final int productsSold;
}

class CategoryExpenseBreakdown {
  const CategoryExpenseBreakdown({
    required this.categoryName,
    required this.amountPaise,
  });
  final String categoryName;
  final int amountPaise;
}

class TopProduct {
  const TopProduct({
    required this.productName,
    required this.quantity,
    required this.profitPaise,
  });
  final String productName;
  final int quantity;
  final int profitPaise;
}

class QuickSaleLine {
  const QuickSaleLine({
    required this.itemName,
    required this.unitCostPaise,
    required this.totalSellingPaise,
    required this.quantity,
  });

  final String itemName;
  /// Cost paid for one piece.
  final int unitCostPaise;
  /// Total amount received for all pieces in this line.
  final int totalSellingPaise;
  final int quantity;

  int get totalCostPaise => unitCostPaise * quantity;

  int get profitPaise => totalSellingPaise - totalCostPaise;

  int get unitSellingPricePaise =>
      quantity > 0 ? (totalSellingPaise / quantity).round() : 0;
}
