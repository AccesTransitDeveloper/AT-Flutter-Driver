import 'package:flutter/material.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';

/// Primary filled button with loading state and click delay
class AppFilledButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final int clickDelayMs;
  final IconData? icon;
  /// When true, button sizes to fit content instead of full width
  final bool shrinkWrap;

  const AppFilledButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.clickDelayMs = 500,
    this.icon,
    this.shrinkWrap = false,
  });

  @override
  State<AppFilledButton> createState() => _AppFilledButtonState();
}

class _AppFilledButtonState extends State<AppFilledButton> {
  bool _isClickAllowed = true;

  void _handleClick() {
    if (!_isClickAllowed || widget.isLoading || !widget.enabled) return;

    _isClickAllowed = false;
    widget.onPressed?.call();

    Future.delayed(Duration(milliseconds: widget.clickDelayMs), () {
      if (mounted) {
        _isClickAllowed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = widget.borderRadius ?? AppDimens.buttonRadius;
    final bgColor = widget.backgroundColor ?? colors.colorButtonBackground;
    final txtColor = widget.textColor ?? colors.colorButtonText;

    final button = FilledButton(
      onPressed: widget.enabled && !widget.isLoading ? _handleClick : null,
      style: FilledButton.styleFrom(
        backgroundColor: bgColor,
        disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: widget.isLoading
          ? SizedBox(
              width: AppDimens.iconSize,
              height: AppDimens.iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(txtColor),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    color: widget.enabled ? txtColor : txtColor.withValues(alpha: 0.7),
                    size: AppDimens.iconSize,
                  ),
                  const SizedBox(width: AppDimens.paddingS),
                ],
                Flexible(
                  child: Text(
                    widget.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppTypos.textM,
                      fontWeight: FontWeight.w600,
                      color: widget.enabled ? txtColor : txtColor.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
    );

    if (widget.shrinkWrap) {
      return SizedBox(
        height: widget.height ?? AppDimens.buttonHeight,
        child: button,
      );
    }

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? AppDimens.buttonHeight,
      child: button,
    );
  }
}

/// Filled button with icon (like social login buttons)
class AppFilledIconButton extends StatefulWidget {
  final String text;
  final Widget icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final int clickDelayMs;

  const AppFilledIconButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.width,
    this.height,
    this.borderRadius,
    this.clickDelayMs = 500,
  });

  @override
  State<AppFilledIconButton> createState() => _AppFilledIconButtonState();
}

class _AppFilledIconButtonState extends State<AppFilledIconButton> {
  bool _isClickAllowed = true;

  void _handleClick() {
    if (!_isClickAllowed || widget.isLoading || !widget.enabled) return;

    _isClickAllowed = false;
    widget.onPressed?.call();

    Future.delayed(Duration(milliseconds: widget.clickDelayMs), () {
      if (mounted) {
        _isClickAllowed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bgColor = widget.backgroundColor ??
        colors.colorPrimary.withValues(alpha: 0.05);
    final txtColor = widget.textColor ?? colors.colorText;
    final brdColor = widget.borderColor ?? colors.colorText;
    final radius = widget.borderRadius ?? AppDimens.buttonRadius;

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? AppDimens.buttonHeight,
      child: OutlinedButton(
        onPressed: widget.enabled && !widget.isLoading ? _handleClick : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: bgColor,
          disabledBackgroundColor: bgColor.withValues(alpha: 0.5),
          side: BorderSide(
            color: widget.enabled ? brdColor : brdColor.withValues(alpha: 0.5),
            width: AppDimens.borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.padding),
        ),
        child: widget.isLoading
            ? SizedBox(
                width: AppDimens.iconSize,
                height: AppDimens.iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(txtColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.icon,
                  const SizedBox(width: AppDimens.paddingS),
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: AppTypos.textM,
                      fontWeight: FontWeight.w500,
                      color: widget.enabled
                          ? txtColor
                          : txtColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Outlined button (transparent background with border)
class AppOutlinedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? borderColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final int clickDelayMs;

  const AppOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.borderColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.clickDelayMs = 500,
  });

  @override
  State<AppOutlinedButton> createState() => _AppOutlinedButtonState();
}

class _AppOutlinedButtonState extends State<AppOutlinedButton> {
  bool _isClickAllowed = true;

  void _handleClick() {
    if (!_isClickAllowed || widget.isLoading || !widget.enabled) return;

    _isClickAllowed = false;
    widget.onPressed?.call();

    Future.delayed(Duration(milliseconds: widget.clickDelayMs), () {
      if (mounted) {
        _isClickAllowed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brdColor = widget.borderColor ?? colors.colorButtonBackground;
    final txtColor = widget.textColor ?? colors.colorText;
    final radius = widget.borderRadius ?? AppDimens.buttonRadius;
    final isEnabled = widget.enabled && widget.onPressed != null;

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? AppDimens.buttonHeight,
      child: OutlinedButton(
        onPressed: isEnabled && !widget.isLoading ? _handleClick : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: BorderSide(
            color: isEnabled ? brdColor : brdColor.withValues(alpha: 0.5),
            width: AppDimens.borderWidth,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: widget.isLoading
            ? SizedBox(
                width: AppDimens.iconSize,
                height: AppDimens.iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(txtColor),
                ),
              )
            : Text(
                widget.text,
                style: TextStyle(
                  fontSize: AppTypos.textM,
                  fontWeight: FontWeight.w500,
                  color: isEnabled ? txtColor : txtColor.withValues(alpha: 0.5),
                ),
              ),
      ),
    );
  }
}

/// Text button (no background)
class AppTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingS,
          vertical: AppDimens.paddingXS,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize ?? AppTypos.text,
          fontWeight: fontWeight ?? FontWeight.w500,
          color: textColor ?? colors.colorPrimary,
        ),
      ),
    );
  }
}

/// Circle button with icon (back button style)
class AppCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  const AppCircleButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 56,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.colorBackgroundGray,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: colors.colorText,
          size: AppDimens.iconSize,
        ),
      ),
    );
  }
}

/// Round back button with shadow (for map overlays)
class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  final bool hasShadow;
  final Color? iconColor;

  const AppBackButton({
    super.key,
    this.onPressed,
    this.size = 48,
    this.hasShadow = true,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: colors.colorBackground,
          shape: BoxShape.circle,
          boxShadow: hasShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.arrow_back,
          color: iconColor ?? colors.colorPrimary,
          size: AppDimens.iconSize,
        ),
      ),
    );
  }
}

/// Next button with arrow and loading state
class AppNextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;

  const AppNextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isEnabled = enabled && !isLoading;

    return InkWell(
      onTap: isEnabled ? onPressed : null,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingXL,
          vertical: AppDimens.padding,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? colors.colorButtonBackground
              : colors.colorText.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isEnabled ? colors.colorButtonText : colors.colorText,
                  ),
                ),
              )
            else ...[
              Text(
                text,
                style: TextStyle(
                  fontSize: AppTypos.textM,
                  fontWeight: FontWeight.w500,
                  color: isEnabled
                      ? colors.colorButtonText
                      : colors.colorText.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(width: AppDimens.paddingS),
              Icon(
                Icons.arrow_forward,
                color: isEnabled
                    ? colors.colorButtonText
                    : colors.colorText.withValues(alpha: 0.5),
                size: AppDimens.iconSize,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
