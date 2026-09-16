import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kapdakhata/core/theme/app_colors.dart';

class PageSearchBar extends StatefulWidget {
  const PageSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.onFilterTap,
    this.debounceMs = 300,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onFilterTap;
  final int debounceMs;

  @override
  State<PageSearchBar> createState() => _PageSearchBarState();
}

class _PageSearchBarState extends State<PageSearchBar>
    with WidgetsBindingObserver {
  Timer? _debounce;
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  double _lastBottomInset = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _focusNode.addListener(() => setState(() {}));
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
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onTapOutside: (_) => _unfocus(),
            onSubmitted: (_) => _unfocus(),
            onChanged: (v) {
              setState(() {});
              _onChanged(v);
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.primaryPurple,
                size: 20,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _controller.clear();
                        widget.onChanged('');
                        _unfocus();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: _focusNode.hasFocus
                  ? AppColors.white
                  : AppColors.lavenderSubtle,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primaryPurple,
                  width: 1.5,
                ),
              ),
              isDense: true,
            ),
          ),
        ),
        if (widget.onFilterTap != null) ...[
          const SizedBox(width: 8),
          Material(
            color: AppColors.primaryPurple,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () {
                _unfocus();
                widget.onFilterTap?.call();
              },
              borderRadius: BorderRadius.circular(10),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.tune_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
