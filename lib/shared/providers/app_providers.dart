import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapdakhata/core/widgets/k_date_range_sheet.dart';
import 'package:kapdakhata/database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final settingsProvider = StreamProvider<ShopSetting>((ref) {
  return ref.watch(databaseProvider).watchSettings();
});

final selectedMonthProvider = StateProvider<DateTime>(
  (ref) {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  },
);

final monthlyMetricsProvider = FutureProvider<MonthlyMetrics>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  return ref.watch(databaseProvider).getMonthlyMetrics(month);
});

final previousMonthMetricsProvider = FutureProvider<MonthlyMetrics>((ref) async {
  final month = ref.watch(selectedMonthProvider);
  final previous = DateTime(month.year, month.month - 1);
  return ref.watch(databaseProvider).getMonthlyMetrics(previous);
});

final productCategoriesProvider = StreamProvider<List<ProductCategory>>((ref) {
  return ref.watch(databaseProvider).select(ref.watch(databaseProvider).productCategories).watch();
});

final expenseCategoriesProvider = StreamProvider<List<ExpenseCategory>>((ref) {
  return ref.watch(databaseProvider).select(ref.watch(databaseProvider).expenseCategories).watch();
});

final saleNameSuggestionsProvider = StreamProvider<List<SaleNameSuggestion>>((ref) {
  return ref.watch(databaseProvider).watchSaleNameSuggestions();
});

final productSearchProvider = StateProvider<String>((ref) => '');
final productCategoryFilterProvider = StateProvider<Set<int>>((ref) => {});

final productsStreamProvider = StreamProvider<List<ProductWithCategory>>((ref) {
  final db = ref.watch(databaseProvider);
  final search = ref.watch(productSearchProvider);
  final categoryIds = ref.watch(productCategoryFilterProvider);
  return db.watchActiveProductsStream(search: search, categoryIds: categoryIds);
});

final salesSearchProvider = StateProvider<String>((ref) => '');
final salesDateFilterProvider = StateProvider<SalesDateFilter>(
  (ref) => SalesDateFilter.thisMonth,
);

final salesCustomDateRangeProvider =
    StateProvider<DateRangeSelection?>((ref) => null);

enum SalesDateFilter { today, thisWeek, thisMonth, custom }

final salesStreamProvider = StreamProvider<List<SaleWithProduct>>((ref) {
  final db = ref.watch(databaseProvider);
  final search = ref.watch(salesSearchProvider);
  final filter = ref.watch(salesDateFilterProvider);
  final now = DateTime.now();
  DateTime? start;
  DateTime? end;

  switch (filter) {
    case SalesDateFilter.today:
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    case SalesDateFilter.thisWeek:
      final weekday = now.weekday;
      start = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: weekday - 1));
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    case SalesDateFilter.thisMonth:
      start = DateTime(now.year, now.month);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    case SalesDateFilter.custom:
      final customRange = ref.watch(salesCustomDateRangeProvider);
      if (customRange != null) {
        start = DateTime(
          customRange.start.year,
          customRange.start.month,
          customRange.start.day,
        );
        end = DateTime(
          customRange.end.year,
          customRange.end.month,
          customRange.end.day,
          23,
          59,
          59,
        );
      } else {
        start = DateTime(now.year, now.month);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      }
  }

  return db.watchSales(start: start, end: end, search: search);
});

final expenseSearchProvider = StateProvider<String>((ref) => '');

enum ExpenseDateFilterMode { month, custom }

final expenseDateFilterModeProvider =
    StateProvider<ExpenseDateFilterMode>((ref) => ExpenseDateFilterMode.month);

final expenseCustomDateRangeProvider =
    StateProvider<DateRangeSelection?>((ref) => null);

final expensesStreamProvider = StreamProvider<List<ExpenseWithCategory>>((ref) {
  final db = ref.watch(databaseProvider);
  final search = ref.watch(expenseSearchProvider);
  final mode = ref.watch(expenseDateFilterModeProvider);
  final customRange = ref.watch(expenseCustomDateRangeProvider);
  final month = ref.watch(selectedMonthProvider);

  late DateTime start;
  late DateTime end;

  if (mode == ExpenseDateFilterMode.custom && customRange != null) {
    start = DateTime(
      customRange.start.year,
      customRange.start.month,
      customRange.start.day,
    );
    end = DateTime(
      customRange.end.year,
      customRange.end.month,
      customRange.end.day,
      23,
      59,
      59,
    );
  } else {
    start = DateTime(month.year, month.month);
    end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
  }

  return db.watchExpenses(start: start, end: end, search: search);
});

final recentSalesProvider = StreamProvider<List<SaleWithProduct>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchSales(limit: 10);
});

final themeModeProvider = StateProvider<String>((ref) => 'light');

class StockAlert {
  const StockAlert({required this.product, required this.isOutOfStock});

  final ProductWithCategory product;
  final bool isOutOfStock;
}

final stockAlertsProvider = FutureProvider<List<StockAlert>>((ref) async {
  final db = ref.watch(databaseProvider);
  final settings = await db.getSettings();
  final products = await db.getLowStockProducts(settings.lowStockThreshold);
  return products
      .map(
        (item) => StockAlert(
          product: item,
          isOutOfStock: item.product.stockQuantity == 0,
        ),
      )
      .toList();
});

/// Reopens the database and refreshes cached data after a backup restore.
void reloadAppAfterRestore(WidgetRef ref) {
  ref.invalidate(databaseProvider);
  ref.invalidate(settingsProvider);
  ref.invalidate(monthlyMetricsProvider);
  ref.invalidate(previousMonthMetricsProvider);
  ref.invalidate(productCategoriesProvider);
  ref.invalidate(expenseCategoriesProvider);
  ref.invalidate(productsStreamProvider);
  ref.invalidate(salesStreamProvider);
  ref.invalidate(expensesStreamProvider);
  ref.invalidate(recentSalesProvider);
  ref.invalidate(reportsMetricsProvider);
}

final reportsRangeProvider = StateProvider<ReportsRange>(
  (ref) => ReportsRange.currentMonth,
);

enum ReportsRange {
  currentMonth,
  previousMonth,
  last3Months,
  last6Months,
  currentYear,
  custom,
}

final reportsMetricsProvider = FutureProvider<ReportsData>((ref) async {
  final db = ref.watch(databaseProvider);
  final range = ref.watch(reportsRangeProvider);
  final now = DateTime.now();
  late DateTime start;
  late DateTime end;

  switch (range) {
    case ReportsRange.currentMonth:
      start = DateTime(now.year, now.month);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    case ReportsRange.previousMonth:
      start = DateTime(now.year, now.month - 1);
      end = DateTime(now.year, now.month, 0, 23, 59, 59);
    case ReportsRange.last3Months:
      start = DateTime(now.year, now.month - 2);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    case ReportsRange.last6Months:
      start = DateTime(now.year, now.month - 5);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    case ReportsRange.currentYear:
      start = DateTime(now.year);
      end = DateTime(now.year, 12, 31, 23, 59, 59);
    case ReportsRange.custom:
      start = DateTime(now.year, now.month);
      end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  final metrics = await db.getMonthlyMetrics(DateTime(start.year, start.month));
  final monthlyTrend = await db.getMonthlyMetricsRange(
    DateTime(start.year, start.month),
    DateTime(end.year, end.month),
  );
  final expenseBreakdown = await db.getExpenseBreakdown(start, end);
  final topByQty = await db.getTopProductsByQuantity(start, end);
  final topByProfit = await db.getTopProductsByProfit(start, end);

  return ReportsData(
    metrics: metrics,
    monthlyTrend: monthlyTrend,
    expenseBreakdown: expenseBreakdown,
    topByQuantity: topByQty,
    topByProfit: topByProfit,
    start: start,
    end: end,
  );
});

class ReportsData {
  const ReportsData({
    required this.metrics,
    required this.monthlyTrend,
    required this.expenseBreakdown,
    required this.topByQuantity,
    required this.topByProfit,
    required this.start,
    required this.end,
  });

  final MonthlyMetrics metrics;
  final List<MonthlyMetrics> monthlyTrend;
  final List<CategoryExpenseBreakdown> expenseBreakdown;
  final List<TopProduct> topByQuantity;
  final List<TopProduct> topByProfit;
  final DateTime start;
  final DateTime end;
}
