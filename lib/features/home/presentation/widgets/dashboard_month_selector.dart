import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';

class DashboardMonthSelector extends StatelessWidget {
  const DashboardMonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final label = '${_monthName(selectedMonth.month)} ${selectedMonth.year}';

    return Material(
      color: AppColors.purpleSubtle,
      borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedMonth,
            firstDate: DateTime(2020),
            lastDate: DateTime(2030),
            initialDatePickerMode: DatePickerMode.year,
          );
          if (picked != null) {
            onChanged(DateTime(picked.year, picked.month));
          }
        },
        borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppLayout.bodySize,
                    color: AppColors.primaryPurple,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: AppColors.primaryPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _monthName(int month) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[month - 1];
  }
}
