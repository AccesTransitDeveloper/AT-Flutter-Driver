import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../viewmodels/subscription_viewmodel.dart';
import '../../../widgets/app_text.dart';

class SubscriptionItemWidget extends StatefulWidget {
  final SubscriptionDetail item;
  final VoidCallback? onTap;
  final VoidCallback? onActionTap;

  const SubscriptionItemWidget({
    super.key,
    required this.item,
    this.onTap,
    this.onActionTap,
  });

  @override
  State<SubscriptionItemWidget> createState() =>
      _SubscriptionItemWidgetState();
}

class _SubscriptionItemWidgetState extends State<SubscriptionItemWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final item = widget.item;
    final isSelected = item.isSelected;

    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.padding),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.topCenter,
          child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isSelected
                ? colors.colorPrimary
                : colors.colorPrimary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(AppDimens.padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main row: left info + right price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column: title, subtitle, view benefits
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row with free trial badge
                        Row(
                          children: [
                            Flexible(
                              child: AppText.body(
                                item.title,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? colors.colorSelectedText
                                    : colors.colorText,
                              ),
                            ),
                            if (item.isFreeTrialActive) ...[
                              const SizedBox(width: 7),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: AppText.caption(
                                  getString(
                                      appStr.descriptionFreeTrial ?? '',
                                      'description_free_trial'),
                                  color: colors.colorSelectedText,
                                  fontSize: AppTypos.textXS,
                                ),
                              ),
                            ],
                          ],
                        ),

                        // Subtitle
                        if (item.subTitle.isNotEmpty)
                          AppText.caption(
                            item.subTitle,
                            color: isSelected
                                ? colors.colorSelectedText
                                : colors.colorText,
                            fontSize: AppTypos.textS,
                          ),

                        // View Benefits toggle
                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _isExpanded = !_isExpanded),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AppText.caption(
                                  getString(
                                      appStr.buttonViewBenefits ?? '',
                                      'button_view_benefits'),
                                  color: colors.colorSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                const SizedBox(width: 5),
                                AnimatedRotation(
                                  turns: _isExpanded ? 0.5 : 0,
                                  duration:
                                      const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 10,
                                    color: colors.colorSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Right column: price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText.body(
                        item.price,
                        color: isSelected ? colors.colorSelectedText : colors.colorText,
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                        decoration: item.upgradePrice != null &&
                                item.upgradePrice!.isNotEmpty
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                      if (item.upgradePrice != null &&
                          item.upgradePrice!.isNotEmpty)
                        AppText.body(
                          item.upgradePrice!,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected ? colors.colorSelectedText : colors.colorText,
                        ),
                    ],
                  ),
                ],
              ),

              // Expanded description
              if (_isExpanded && item.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                AppText.caption(
                  item.description,
                  color: isSelected
                      ? colors.colorSelectedText.withValues(alpha: 0.7)
                      : colors.colorTextHint,
                ),
              ],

              // Dashed divider
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: CustomPaint(
                  size: const Size(double.infinity, 1),
                  painter: _DashedLinePainter(
                    color: isSelected
                        ? colors.colorSelectedText.withValues(alpha: 0.7)
                        : colors.colorTextHint,
                  ),
                ),
              ),

              // Bottom row: tag + action button
              Row(
                children: [
                  Expanded(
                    child: AppText.caption(
                      item.tag ?? '',
                      color: isSelected ? colors.colorSelectedText : colors.colorText,
                      fontSize: AppTypos.textS,
                    ),
                  ),
                  if (item.strButtonAction != null &&
                      item.strButtonAction!.isNotEmpty)
                    SizedBox(
                      height: 32,
                      child: FilledButton(
                        onPressed: widget.onActionTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.colorSecondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimens.paddingM,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: AppText.caption(
                          item.strButtonAction!,
                          fontWeight: FontWeight.w500,
                          color: colors.colorSelectedText,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

/// Shimmer placeholder for subscription item (matches Kotlin ShimmerSubscriptionItem)
class ShimmerSubscriptionItem extends StatelessWidget {
  const ShimmerSubscriptionItem({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.padding),
      child: Container(
        width: double.infinity,
        height: 150,
        decoration: BoxDecoration(
          color: colors.colorBackgroundGray,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// Custom painter for dashed horizontal line
class _DashedLinePainter extends CustomPainter {
  final Color color;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 5.0;
    const dashGap = 5.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
