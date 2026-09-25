import 'package:flutter/material.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/app_text.dart';

/// Sticky date header delegate for use in CustomScrollView with SliverPersistentHeader
class StickyDateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String date;
  final AppColorPalette colors;

  StickyDateHeaderDelegate({
    required this.date,
    required this.colors,
  });

  @override
  double get minExtent => 32;

  @override
  double get maxExtent => 32;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 32,
      color: colors.colorBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 0.7,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  colors.colorPrimary,
                  colors.colorPrimary,
                  colors.colorPrimary,
                  Colors.transparent,
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.paddingM,
              vertical: AppDimens.paddingXS,
            ),
            decoration: BoxDecoration(
              color: colors.colorPrimary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: AppText.caption(
              date,
              color: colors.colorButtonText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickyDateHeaderDelegate oldDelegate) {
    return date != oldDelegate.date;
  }
}
