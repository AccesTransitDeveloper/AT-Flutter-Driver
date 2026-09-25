import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;

  const AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.focusNode,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
    this.contentPadding,
    this.textStyle,
    this.hintStyle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = borderRadius ?? AppDimens.textFieldRadius;

    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters,
      enabled: enabled,
      readOnly: readOnly,
      maxLines: maxLines,
      maxLength: maxLength,
      style: textStyle ??
          TextStyle(
            fontSize: AppTypos.textM,
            color: colors.colorText,
          ),
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? colors.colorBackgroundGray,
        hintStyle: hintStyle ??
            TextStyle(
              fontSize: AppTypos.textM,
              color: colors.colorTextHint,
            ),
        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: AppDimens.padding,
              vertical: AppDimens.paddingM,
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: borderColor ?? colors.colorText,
            width: AppDimens.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: borderColor ?? colors.colorText,
            width: AppDimens.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: colors.colorPrimary,
            width: AppDimens.borderWidthThick,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: colors.colorWarning,
            width: AppDimens.borderWidth,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: colors.colorWarning,
            width: AppDimens.borderWidthThick,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: colors.colorTextHint,
            width: AppDimens.borderWidth,
          ),
        ),
      ),
    );
  }
}

/// Phone number text field with country code picker
class AppPhoneTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget countryCodeWidget;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final FocusNode? focusNode;
  final Color? fillColor;
  final Color? borderColor;
  final bool showPrefixInTextField;
  final String? selectedCountryPhoneCode;

  const AppPhoneTextField({
    super.key,
    this.controller,
    this.hintText,
    required this.countryCodeWidget,
    this.suffixIcon,
    this.onChanged,
    this.focusNode,
    this.fillColor,
    this.borderColor,
    this.showPrefixInTextField = true,
    this.selectedCountryPhoneCode,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Country code selector
          Container(
            decoration: BoxDecoration(
              color: fillColor ?? colors.colorBackgroundGray,
              borderRadius: BorderRadius.circular(AppDimens.textFieldRadius),
              border: Border.all(
                color: borderColor ?? colors.colorText,
                width: AppDimens.borderWidth,
              ),
            ),
            child: countryCodeWidget,
          ),
          const SizedBox(width: AppDimens.paddingS),
          // Phone number field
          Expanded(
            child: AppTextField(
              controller: controller,
              hintText: hintText,
              keyboardType: TextInputType.phone,
              onChanged: onChanged,
              focusNode: focusNode,
              fillColor: fillColor,
              borderColor: borderColor,
              suffixIcon: suffixIcon,
              prefixIcon: showPrefixInTextField && selectedCountryPhoneCode != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: AppDimens.padding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedCountryPhoneCode!,
                            style: TextStyle(
                              fontSize: AppTypos.textM,
                              fontWeight: FontWeight.w500,
                              color: colors.colorText,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
