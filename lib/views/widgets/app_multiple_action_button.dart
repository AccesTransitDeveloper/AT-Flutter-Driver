import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';

enum MultipleActionButtonType { click, doubleTap, swipe }

class AppMultipleActionButton extends StatefulWidget {
  final String text;
  final MultipleActionButtonType type;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onActionEnd;

  const AppMultipleActionButton({
    super.key,
    required this.text,
    this.type = MultipleActionButtonType.click,
    this.isLoading = false,
    this.isEnabled = true,
    this.onActionEnd,
  });

  @override
  State<AppMultipleActionButton> createState() =>
      _AppMultipleActionButtonState();
}

class _AppMultipleActionButtonState extends State<AppMultipleActionButton>
    with SingleTickerProviderStateMixin {
  double _offsetX = 0;
  double _buttonWidth = 0;
  static const double _iconSize = 25;
  static const double _horizontalPadding = 12;

  double get _swipeThreshold =>
      _buttonWidth - _iconSize - (_horizontalPadding * 2);

  double get _textOpacity {
    if (widget.type != MultipleActionButtonType.swipe || _swipeThreshold <= 0) {
      return 1.0;
    }
    return (1 - (_offsetX / _swipeThreshold)).clamp(0.0, 1.0);
  }

  void _resetSwipe() {
    setState(() {
      _offsetX = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = widget.isEnabled
        ? colors.colorButtonBackground
        : colors.colorButtonBackground.withValues(alpha: 0.5);
    final textColor = colors.colorButtonText;

    return LayoutBuilder(
      builder: (context, constraints) {
        _buttonWidth = constraints.maxWidth;

        return GestureDetector(
          onTap: _buildOnTap(),
          onDoubleTap: _buildOnDoubleTap(),
          onHorizontalDragUpdate:
              widget.type == MultipleActionButtonType.swipe
                  ? _onDragUpdate
                  : null,
          onHorizontalDragEnd:
              widget.type == MultipleActionButtonType.swipe
                  ? _onDragEnd
                  : null,
          child: Container(
            height: AppDimens.buttonHeight,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Text + optional double-tap icon
                if (!widget.isLoading)
                  Opacity(
                    opacity: _textOpacity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.type ==
                            MultipleActionButtonType.doubleTap) ...[
                          Icon(
                            Icons.touch_app,
                            color: textColor,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            widget.text,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Swipe arrow icon
                if (widget.type == MultipleActionButtonType.swipe &&
                    !widget.isLoading)
                  Positioned(
                    left: _horizontalPadding + _offsetX,
                    child: Icon(
                      Icons.double_arrow,
                      color: textColor,
                      size: _iconSize,
                    ),
                  ),

                // Loading indicator
                if (widget.isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: textColor,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  VoidCallback? _buildOnTap() {
    if (widget.type != MultipleActionButtonType.click ||
        widget.isLoading ||
        !widget.isEnabled) {
      return null;
    }
    return widget.onActionEnd;
  }

  VoidCallback? _buildOnDoubleTap() {
    if (widget.type != MultipleActionButtonType.doubleTap ||
        widget.isLoading ||
        !widget.isEnabled) {
      return null;
    }
    return widget.onActionEnd;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.isLoading || !widget.isEnabled) return;
    setState(() {
      _offsetX = (_offsetX + details.delta.dx).clamp(0, _swipeThreshold);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.isLoading &&
        _offsetX > _swipeThreshold * 0.8 &&
        widget.isEnabled) {
      widget.onActionEnd?.call();
    }
    _resetSwipe();
  }
}
