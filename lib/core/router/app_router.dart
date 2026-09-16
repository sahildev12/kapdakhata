import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kapdakhata/features/expenses/presentation/add_expense_screen.dart';
import 'package:kapdakhata/features/expenses/presentation/expense_detail_screen.dart';
import 'package:kapdakhata/features/expenses/presentation/expenses_screen.dart';
import 'package:kapdakhata/features/home/presentation/home_screen.dart';
import 'package:kapdakhata/features/more/presentation/more_screen.dart';
import 'package:kapdakhata/features/notifications/presentation/notifications_screen.dart';
import 'package:kapdakhata/features/products/presentation/add_product_screen.dart';
import 'package:kapdakhata/features/products/presentation/product_detail_screen.dart';
import 'package:kapdakhata/features/products/presentation/products_screen.dart';
import 'package:kapdakhata/features/reports/presentation/reports_screen.dart';
import 'package:kapdakhata/features/sales/presentation/add_sale_screen.dart';
import 'package:kapdakhata/features/sales/presentation/sale_detail_screen.dart';
import 'package:kapdakhata/features/sales/presentation/sales_screen.dart';
import 'package:kapdakhata/features/settings/presentation/expense_categories_screen.dart';
import 'package:kapdakhata/features/settings/presentation/product_categories_screen.dart';
import 'package:kapdakhata/features/settings/presentation/sale_suggestions_screen.dart';
import 'package:kapdakhata/features/settings/presentation/settings_screen.dart';
import 'package:kapdakhata/features/splash/presentation/splash_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SplashScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/products',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProductsScreen()),
          routes: [
            GoRoute(
              path: 'add',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const AddProductScreen(),
            ),
            GoRoute(
              path: ':id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ProductDetailScreen(productId: id);
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return AddProductScreen(productId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/sales',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SalesScreen()),
          routes: [
            GoRoute(
              path: 'add',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final productId = state.uri.queryParameters['productId'];
                return AddSaleScreen(
                  preselectedProductId:
                      productId != null ? int.tryParse(productId) : null,
                );
              },
            ),
            GoRoute(
              path: ':id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return SaleDetailScreen(saleId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: '/expenses',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ExpensesScreen()),
          routes: [
            GoRoute(
              path: 'add',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) => const AddExpenseScreen(),
            ),
            GoRoute(
              path: ':id',
              parentNavigatorKey: _rootNavigatorKey,
              builder: (context, state) {
                final id = int.parse(state.pathParameters['id']!);
                return ExpenseDetailScreen(expenseId: id);
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  parentNavigatorKey: _rootNavigatorKey,
                  builder: (context, state) {
                    final id = int.parse(state.pathParameters['id']!);
                    return AddExpenseScreen(expenseId: id);
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/more',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MoreScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/notifications',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/reports',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'categories/products',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ProductCategoriesScreen(),
        ),
        GoRoute(
          path: 'categories/expenses',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ExpenseCategoriesScreen(),
        ),
        GoRoute(
          path: 'sale-suggestions',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SaleSuggestionsScreen(),
        ),
      ],
    ),
  ],
);

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/products')) return 1;
    if (location.startsWith('/sales')) return 2;
    if (location.startsWith('/expenses')) return 3;
    if (location.startsWith('/more')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
            case 1:
              context.go('/products');
            case 2:
              context.go('/sales');
            case 3:
              context.go('/expenses');
            case 4:
              context.go('/more');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale),
            label: 'Sell',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
