abstract final class Validators {
  static String? required(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? positiveAmount(String? value, {String field = 'Amount'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed <= 0) return '$field must be greater than zero';
    return null;
  }

  static String? nonNegativeAmount(String? value, {String field = 'Price'}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Enter a valid number';
    if (parsed < 0) return '$field cannot be negative';
    return null;
  }
}
