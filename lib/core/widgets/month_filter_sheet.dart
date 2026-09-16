import 'package:flutter/material.dart';

Future<DateTime?> pickMonthDirectly(
  BuildContext context, {
  required DateTime initialMonth,
}) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: initialMonth,
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    initialDatePickerMode: DatePickerMode.year,
  );
  if (picked == null) return null;
  return DateTime(picked.year, picked.month);
}
