import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;
  final bool obscureText;
  final double fieldWidth;
  final double fieldHeight;
  final TextEditingController? controller;

  const OtpInputField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.autoFocus = true,
    this.obscureText = false,
    this.fieldWidth = 56,
    this.fieldHeight = 56,
    this.controller,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );

    // Auto focus first field
    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }

    // Sync with external controller if provided
    if (widget.controller != null) {
      widget.controller!.addListener(_syncFromExternalController);
    }
  }

  void _syncFromExternalController() {
    final text = widget.controller!.text;
    for (int i = 0; i < widget.length; i++) {
      if (i < text.length) {
        _controllers[i].text = text[i];
      } else {
        _controllers[i].clear();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    widget.controller?.removeListener(_syncFromExternalController);
    super.dispose();
  }

  String get _otpValue {
    return _controllers.map((c) => c.text).join();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      _handlePaste(value);
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      // Move to next field
      _focusNodes[index + 1].requestFocus();
    }

    _notifyChange();
  }

  void _handlePaste(String value) {
    // Clean the value to only contain digits
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    for (int i = 0; i < widget.length && i < digits.length; i++) {
      _controllers[i].text = digits[i];
    }

    // Focus last filled field or first empty
    final filledCount = digits.length.clamp(0, widget.length);
    if (filledCount < widget.length) {
      _focusNodes[filledCount].requestFocus();
    } else {
      _focusNodes[widget.length - 1].requestFocus();
    }

    _notifyChange();
  }

  void _onKeyPressed(int index, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          // Move to previous field and clear it
          _controllers[index - 1].clear();
          _focusNodes[index - 1].requestFocus();
          _notifyChange();
        }
      }
    }
  }

  void _notifyChange() {
    final otp = _otpValue;
    widget.onChanged?.call(otp);

    // Sync with external controller
    if (widget.controller != null) {
      widget.controller!.text = otp;
    }

    if (otp.length == widget.length) {
      widget.onCompleted?.call(otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate field width based on available space
        final totalSpacing = AppDimens.paddingS * (widget.length - 1);
        final availableWidth = constraints.maxWidth - totalSpacing;
        final calculatedFieldWidth = (availableWidth / widget.length).clamp(40.0, widget.fieldWidth);

        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index < widget.length - 1 ? AppDimens.paddingS : 0,
              ),
              child: SizedBox(
                width: calculatedFieldWidth,
                height: widget.fieldHeight,
                child: KeyboardListener(
                  focusNode: FocusNode(),
                  onKeyEvent: (event) => _onKeyPressed(index, event),
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: widget.length,
                    obscureText: widget.obscureText,
                    style: TextStyle(
                      fontSize: AppTypos.textXL,
                      fontWeight: FontWeight.w600,
                      color: colors.colorText,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration: InputDecoration(
                      counterText: '',
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                        borderSide: BorderSide(
                          color: colors.colorText,
                          width: AppDimens.borderWidth,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                        borderSide: BorderSide(
                          color: colors.colorText,
                          width: _controllers[index].text.isNotEmpty
                              ? AppDimens.borderWidthThick
                              : AppDimens.borderWidth,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                        borderSide: BorderSide(
                          color: colors.colorText,
                          width: AppDimens.borderWidthThick,
                        ),
                      ),
                    ),
                    onChanged: (value) => _onChanged(index, value),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
