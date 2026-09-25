import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/utils/resend_timer_helper.dart';
import '../../../core/utils/validator/validator.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/otp_input_field.dart';
import '../../../viewmodels/auth/forgot_password_viewmodel.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  final ForgotPasswordLoginType loginType;

  // Phone login params
  final String? phoneNumber;
  final String? countryPhoneCode;

  // Email params
  final String? email;

  // Common params
  final int otpLength;

  const ForgotPasswordScreen.phone({
    super.key,
    required String phoneNumber,
    required String countryPhoneCode,
    this.otpLength = 6,
  })  : loginType = ForgotPasswordLoginType.phone,
        phoneNumber = phoneNumber,
        countryPhoneCode = countryPhoneCode,
        email = null;

  const ForgotPasswordScreen.email({
    super.key,
    required String email,
    this.otpLength = 6,
  })  : loginType = ForgotPasswordLoginType.email,
        phoneNumber = null,
        countryPhoneCode = null,
        email = email;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Timer? _resendTimer;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFlow();
    });
  }

  void _initializeFlow() {
    final notifier = ref.read(forgotPasswordViewModelProvider.notifier);

    if (widget.loginType == ForgotPasswordLoginType.phone) {
      notifier.initPhoneForgotPassword(
        phoneNumber: widget.phoneNumber!,
        countryPhoneCode: widget.countryPhoneCode!,
        otpLength: widget.otpLength,
      );
    } else {
      notifier.initEmailForgotPassword(
        email: widget.email!,
        otpLength: widget.otpLength,
      );
    }
    _startResendTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    final notifier = ref.read(forgotPasswordViewModelProvider.notifier);
    notifier.updateResendSeconds(ValidatorConfig.resendOtpTime);

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentSeconds = ref.read(forgotPasswordViewModelProvider).resendSeconds;
      if (currentSeconds > 0) {
        notifier.updateResendSeconds(currentSeconds - 1);
      } else {
        timer.cancel();
      }
    });
  }

  String _formattedPhoneNumber(ForgotPasswordState state) {
    final phone = state.phoneNumber;
    if (phone.length >= 10) {
      final areaCode = phone.substring(0, 3);
      final middle = phone.substring(3, 6);
      final last = phone.substring(6);
      return '(${state.countryPhoneCode}) $areaCode-$middle-$last';
    }
    return '(${state.countryPhoneCode}) $phone';
  }

  String _formattedResendTime(int seconds) {
    return ResendTimerHelper.formatTime(seconds);
  }

  void _onOtpChanged(String otp) {
    ref.read(forgotPasswordViewModelProvider.notifier).setOtp(otp);
  }

  void _onPasswordChanged(String password) {
    ref.read(forgotPasswordViewModelProvider.notifier).setPassword(password);
  }

  void _onConfirmPasswordChanged(String confirmPassword) {
    ref.read(forgotPasswordViewModelProvider.notifier).setConfirmPassword(confirmPassword);
  }

  Future<void> _onNextPressed() async {
    final state = ref.read(forgotPasswordViewModelProvider);
    final notifier = ref.read(forgotPasswordViewModelProvider.notifier);

    switch (state.currentStep) {
      case ForgotPasswordStep.otp:
        if (!state.canProceedOtp) return;
        final success = await notifier.verifyOtp();
        if (success && mounted) {
          _resendTimer?.cancel();
        }
        break;
      case ForgotPasswordStep.newPassword:
        if (!state.canProceedPassword) return;
        final success = await notifier.changePassword();
        if (success && mounted) {
          context.goBack(true);
        }
        break;
    }
  }

  Future<void> _resendOtp() async {
    final state = ref.read(forgotPasswordViewModelProvider);
    if (state.resendSeconds > 0) return;

    final notifier = ref.read(forgotPasswordViewModelProvider.notifier);
    final success = await notifier.resendOtp();
    if (success) {
      _startResendTimer();
    }
  }

  void _onBackPressed() {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (isKeyboardOpen) {
      FocusScope.of(context).unfocus();
    } else {
      FocusScope.of(context).unfocus();
      context.goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordViewModelProvider);
    final colors = context.colors;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppDimens.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimens.paddingXL),
                    _buildHeader(state, colors),
                    const SizedBox(height: AppDimens.paddingM),
                    _buildChangeLink(state, colors),
                    const SizedBox(height: AppDimens.paddingXXL),
                    _buildInputField(state, colors),
                    const SizedBox(height: AppDimens.paddingXXL),
                    _buildActionButtons(state, colors),
                  ],
                ),
              ),
            ),
            _buildBottomBar(state, colors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ForgotPasswordState state, AppColorPalette colors) {
    String title;
    switch (state.currentStep) {
      case ForgotPasswordStep.otp:
        final target = state.loginType == ForgotPasswordLoginType.phone
            ? _formattedPhoneNumber(state)
            : state.email;
        title = '${getString(appStr.headingVerifyAccount, 'heading_verify_account')}\n$target';
        break;
      case ForgotPasswordStep.newPassword:
        title = getString(appStr.headingResetPassword, 'heading_reset_password');
        break;
    }

    return AppText.title(title);
  }

  Widget _buildChangeLink(ForgotPasswordState state, AppColorPalette colors) {
    if (state.currentStep != ForgotPasswordStep.otp) {
      return const SizedBox.shrink();
    }

    final linkText = state.loginType == ForgotPasswordLoginType.phone
        ? getString(appStr.buttonChangeMobileNumber, 'button_change_mobile_number')
        : getString(appStr.buttonChangeEmailAddress, 'button_change_email_address');

    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        context.goBack();
      },
      child: AppText.body(
        linkText,
        color: colors.colorText,
        fontWeight: FontWeight.w500,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _buildInputField(ForgotPasswordState state, AppColorPalette colors) {
    switch (state.currentStep) {
      case ForgotPasswordStep.otp:
        return _buildOtpInput(state, colors);
      case ForgotPasswordStep.newPassword:
        return _buildPasswordInputs(state, colors);
    }
  }

  Widget _buildOtpInput(ForgotPasswordState state, AppColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OtpInputField(
          length: state.otpLength,
          controller: _otpController,
          onChanged: _onOtpChanged,
        ),
        if (state.error != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(
            state.error!,
            color: colors.colorWarning,
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordInputs(ForgotPasswordState state, AppColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _passwordController,
          hintText: getString(appStr.hintEnterPassword, 'hint_enter_password'),
          obscureText: _obscurePassword,
          onChanged: _onPasswordChanged,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: colors.colorText,
            ),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: AppDimens.paddingM),
        AppTextField(
          controller: _confirmPasswordController,
          hintText: getString(appStr.hintConfirmPassword, 'hint_confirm_password'),
          obscureText: _obscureConfirmPassword,
          onChanged: _onConfirmPasswordChanged,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: colors.colorText,
            ),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
        if (state.error != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(
            state.error!,
            color: colors.colorWarning,
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(ForgotPasswordState state, AppColorPalette colors) {
    if (state.currentStep != ForgotPasswordStep.otp) {
      return const SizedBox.shrink();
    }

    final resendText = getString(appStr.buttonResendOtp, 'button_resend_otp');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextButton(
          text: state.resendSeconds > 0
              ? '$resendText (${_formattedResendTime(state.resendSeconds)})'
              : resendText,
          onTap: state.resendSeconds > 0 ? null : _resendOtp,
          colors: colors,
        ),
      ],
    );
  }

  Widget _buildBottomBar(ForgotPasswordState state, AppColorPalette colors) {
    final canProceed = state.currentStep == ForgotPasswordStep.otp
        ? state.canProceedOtp
        : state.canProceedPassword;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppCircleButton(
            icon: Icons.arrow_back,
            onPressed: _onBackPressed,
          ),
          AppNextButton(
            text: getString(appStr.buttonNext, 'button_next'),
            onPressed: _onNextPressed,
            isLoading: state.isLoading,
            enabled: canProceed,
          ),
        ],
      ),
    );
  }

  Widget _buildTextButton({
    required String text,
    required VoidCallback? onTap,
    required AppColorPalette colors,
  }) {
    final isEnabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.buttonHeight / 2),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding,
          vertical: AppDimens.paddingM,
        ),
        decoration: BoxDecoration(
          color: isEnabled
              ? colors.colorBackgroundGray
              : colors.colorBackgroundGray.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppDimens.buttonHeight / 2),
        ),
        child: AppText.body(
          text,
          color: isEnabled
              ? colors.colorText
              : colors.colorText.withValues(alpha: 0.5),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
