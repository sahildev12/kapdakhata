import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';
import 'package:kapdakhata/core/theme/app_layout.dart';
import 'package:kapdakhata/core/widgets/k_dialogs.dart';

class KSearchBar extends StatefulWidget {
  const KSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.debounceMs = 300,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final int debounceMs;

  @override
  State<KSearchBar> createState() => _KSearchBarState();
}

class _KSearchBarState extends State<KSearchBar> with WidgetsBindingObserver {
  Timer? _debounce;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  double _lastBottomInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset =
        WidgetsBinding.instance.platformDispatcher.views.first.viewInsets.bottom;
    if (_lastBottomInset > 0 && bottomInset == 0 && _focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    _lastBottomInset = bottomInset;
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: widget.debounceMs), () {
      widget.onChanged(value);
    });
  }

  void _unfocus() => _focusNode.unfocus();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onTapOutside: (_) => _unfocus(),
      onSubmitted: (_) => _unfocus(),
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search, color: AppColors.mutedText),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () {
                  _controller.clear();
                  widget.onChanged('');
                  _unfocus();
                  setState(() {});
                },
              )
            : null,
        isDense: true,
      ),
      onChanged: (v) {
        setState(() {});
        _onChanged(v);
      },
    );
  }
}

class KMonthSelector extends StatelessWidget {
  const KMonthSelector({
    super.key,
    required this.selectedMonth,
    required this.onChanged,
  });

  final DateTime selectedMonth;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final label =
        '${_monthName(selectedMonth.month)} ${selectedMonth.year}';
    return Material(
      color: AppColors.purpleSubtle,
      borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: AppColors.primaryPurple,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryPurple,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
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

class KQuantityStepper extends StatelessWidget {
  const KQuantityStepper({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;
  final int? max;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepperButton(
          icon: Icons.remove,
          onPressed: quantity > min ? () => onChanged(quantity - 1) : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          onPressed: max != null && quantity >= max!
              ? null
              : () => onChanged(quantity + 1),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.purpleSubtle,
      borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppLayout.buttonRadius),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: AppColors.primaryPurple),
        ),
      ),
    );
  }
}

class KConfirmDialog extends StatelessWidget {
  const KConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Delete',
    this.isDanger = true,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final bool isDanger;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    bool isDanger = true,
  }) {
    return KAppDialog.confirm(
      context: context,
      title: title,
      message: message,
      confirmLabel: confirmLabel,
      isDanger: isDanger,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: isDanger
              ? TextButton.styleFrom(foregroundColor: Colors.red)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
