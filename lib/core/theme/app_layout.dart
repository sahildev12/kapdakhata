import 'package:flutter/material.dart';

/// Compact layout tokens used across the app.
abstract final class AppLayout {
  static const pagePadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const cardPadding = EdgeInsets.all(10);
  static const compactCardPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 6);
  static const gridSpacing = 6.0;
  static const cardRadius = 10.0;
  static const dashboardCardRadius = 12.0;
  static const dashboardPadding = 16.0;
  static const buttonRadius = 10.0;
  static const filterRowHeight = 34.0;
  static const filterSectionGap = 8.0;
  static const sectionGap = 8.0;
  static const itemGap = 6.0;

  static const labelSize = 11.0;
  static const bodySize = 13.0;
  static const titleSize = 15.0;
  static const headlineSize = 18.0;
  static const amountSize = 16.0;
  static const amountLargeSize = 20.0;
}
