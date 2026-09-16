import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/utils/date_utils.dart';
import 'package:kapdakhata/core/widgets/k_buttons.dart';

class DateRangeSelection {
  const DateRangeSelection({required this.start, required this.end});

  final DateTime start;
  final DateTime end;
}

Future<DateRangeSelection?> showDateRangeBottomSheet(
  BuildContext context, {
  required DateTime initialStart,
  required DateTime initialEnd,
  String title = 'Select date range',
}) {
  return showModalBottomSheet<DateRangeSelection>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _DateRangeSheet(
      title: title,
      initialStart: initialStart,
      initialEnd: initialEnd,
    ),
  );
}

class _DateRangeSheet extends StatefulWidget {
  const _DateRangeSheet({
    required this.title,
    required this.initialStart,
    required this.initialEnd,
  });

  final String title;
  final DateTime initialStart;
  final DateTime initialEnd;

  @override
  State<_DateRangeSheet> createState() => _DateRangeSheetState();
}

class _DateRangeSheetState extends State<_DateRangeSheet> {
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  Future<void> _pickDate({required bool isStart}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;

    setState(() {
      if (isStart) {
        _start = DateTime(picked.year, picked.month, picked.day);
        if (_start.isAfter(_end)) {
          _end = DateTime(_start.year, _start.month, _start.day, 23, 59, 59);
        }
      } else {
        _end = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        if (_end.isBefore(_start)) {
          _start = DateTime(_end.year, _end.month, _end.day);
        }
      }
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      DateRangeSelection(start: _start, end: _end),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: AppLayout.titleSize,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _DateField(
              label: 'From',
              value: AppDateUtils.formatDate(_start),
              onTap: () => _pickDate(isStart: true),
            ),
            const SizedBox(height: 10),
            _DateField(
              label: 'To',
              value: AppDateUtils.formatDate(_end),
              onTap: () => _pickDate(isStart: false),
            ),
            const SizedBox(height: 16),
            KPrimaryButton(label: 'Apply', onPressed: _apply),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppLayout.dashboardCardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.neutralText,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
