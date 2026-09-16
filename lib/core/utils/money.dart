import 'package:intl/intl.dart';

class Money {
  const Money(this.paise);

  final int paise;

  double get rupees => paise / 100;

  static Money fromRupees(double value) => Money((value * 100).round());

  static Money fromRupeesString(String value) {
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return const Money(0);
    return fromRupees(parsed);
  }

  Money operator +(Money other) => Money(paise + other.paise);
  Money operator -(Money other) => Money(paise - other.paise);
  Money operator *(int quantity) => Money(paise * quantity);

  String format({String symbol = '₹'}) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: symbol,
      decimalDigits: paise % 100 == 0 ? 0 : 2,
    );
    return formatter.format(rupees);
  }

  @override
  String toString() => format();
}

abstract final class MoneyFormatter {
  static String format(int paise) => Money(paise).format();

  static String formatChangePercent(int current, int previous) {
    if (previous == 0) return 'No previous data';
    final change = ((current - previous) / previous * 100).round();
    if (change >= 0) return '↑ $change% from last month';
    return '↓ ${change.abs()}% from last month';
  }
}
