import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/validator/validator.dart';
import '../../../core/utils/resend_timer_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_divider.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/otp_input_field.dart';
import '../../widgets/country_picker_overlay.dart';
import '../../../models/responses/auth/country_response.dart';
import '../../../models/webview_data_model.dart';
import '../../../viewmodels/auth/register_viewmodel.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final RegisterOrigin origin;

  // Phone registration params
  final String? phoneNumber;
  final String? countryPhoneCode;

  // Email registration params
  final String? email;

  // Common params
  final List<Country> countries;
  final Country? selectedCountry;
  final ConfirmedRegistrationPrefill? confirmedPrefill;

  const RegisterScreen.phone({
    super.key,
    required String phoneNumber,
    required String countryPhoneCode,
    required this.countries,
    this.selectedCountry,
    this.confirmedPrefill,
  }) : origin = RegisterOrigin.phone,
       phoneNumber = phoneNumber,
       countryPhoneCode = countryPhoneCode,
       email = null;

  const RegisterScreen.email({
    super.key,
    required String email,
    required this.countries,
    this.selectedCountry,
    this.confirmedPrefill,
  }) : origin = RegisterOrigin.email,
       email = email,
       phoneNumber = null,
       countryPhoneCode = null;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneOtpController = TextEditingController();
  final _emailOtpController = TextEditingController();
  final _referralController = TextEditingController();
  final _drivingLicenseController = TextEditingController();

  final _countryCodeKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  Timer? _resendTimer;
  Timer? _resendEmailTimer;
  bool _obscurePassword = true;

  TapGestureRecognizer? _termsRecognizer;
  TapGestureRecognizer? _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFlow();
    });
  }

  void _initializeFlow() {
    final notifier = ref.read(registerViewModelProvider.notifier);

    if (widget.origin == RegisterOrigin.phone) {
      notifier.initPhoneRegistration(
        phoneNumber: widget.phoneNumber!,
        countryPhoneCode: widget.countryPhoneCode!,
        countries: widget.countries,
        selectedCountry: widget.selectedCountry,
      );
    } else {
      notifier.initEmailRegistration(
        email: widget.email!,
        countries: widget.countries,
        selectedCountry: widget.selectedCountry,
      );
    }
    notifier.applyConfirmedPrefill(widget.confirmedPrefill);
    final state = ref.read(registerViewModelProvider);
    _firstNameController.text = state.firstName;
    _lastNameController.text = state.lastName;
    _emailController.text = state.email;
    _phoneController.text = state.phoneNumber;
    _drivingLicenseController.text = state.drivingLicense;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneOtpController.dispose();
    _emailOtpController.dispose();
    _referralController.dispose();
    _drivingLicenseController.dispose();
    _resendTimer?.cancel();
    _resendEmailTimer?.cancel();
    _removeOverlay();
    _termsRecognizer?.dispose();
    _privacyRecognizer?.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// Phone and email each get their own countdown — one shared timer meant
  /// resending either code restarted the other's cooldown.
  void _startResendEmailTimer() {
    final notifier = ref.read(registerViewModelProvider.notifier);
    notifier.updateResendEmailSeconds(ValidatorConfig.resendOtpTime);

    _resendEmailTimer?.cancel();
    _resendEmailTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentSeconds = ref
          .read(registerViewModelProvider)
          .resendEmailSeconds;
      if (currentSeconds > 0) {
        notifier.updateResendEmailSeconds(currentSeconds - 1);
      } else {
        timer.cancel();
      }
    });
  }

  void _startResendTimer() {
    final notifier = ref.read(registerViewModelProvider.notifier);
    notifier.updateResendSeconds(ValidatorConfig.resendOtpTime);

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentSeconds = ref.read(registerViewModelProvider).resendSeconds;
      if (currentSeconds > 0) {
        notifier.updateResendSeconds(currentSeconds - 1);
      } else {
        timer.cancel();
      }
    });
  }

  String _formattedResendTime(int seconds) {
    return ResendTimerHelper.formatTime(seconds);
  }

  void _showCountryPicker(
    List<Country> countries,
    Country? selectedCountry,
    RegisterViewModel notifier,
  ) {
    _removeOverlay();

    final renderBox =
        _countryCodeKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenWidth = MediaQuery.of(context).size.width;
    final dropdownWidth = screenWidth - (AppDimens.padding * 2);

    _overlayEntry = OverlayEntry(
      builder: (context) => CountryPickerOverlay(
        countries: countries,
        selectedCountry: selectedCountry,
        position: Offset(AppDimens.padding, position.dy + size.height + 4),
        width: dropdownWidth,
        onCountrySelected: (country) {
          notifier.setSelectedCountry(country);
          _removeOverlay();
        },
        onDismiss: _removeOverlay,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Event handlers
  void _onFirstNameChanged(String value) {
    ref.read(registerViewModelProvider.notifier).setFirstName(value);
  }

  void _onLastNameChanged(String value) {
    ref.read(registerViewModelProvider.notifier).setLastName(value);
  }

  void _onTermsChanged(bool? value) {
    ref
        .read(registerViewModelProvider.notifier)
        .setTermsAccepted(value ?? false);
  }

  void _onEmailChanged(String value) {
    ref.read(registerViewModelProvider.notifier).setEmail(value);
  }

  void _onPhoneChanged(String value) {
    ref.read(registerViewModelProvider.notifier).setPhoneNumber(value);
  }

  void _onPasswordChanged(String value) {
    ref.read(registerViewModelProvider.notifier).setPassword(value);
  }

  void _onDrivingLicenseChanged(String value) {
    ref.read(registerViewModelProvider.notifier).setDrivingLicense(value);
  }

  void _onPhoneOtpChanged(String value) {
    ref.read(registerViewModelProvider.notifier).setPhoneOtp(value);
  }

  void _onEmailOtpChanged(String value) {
    ref.read(registerViewModelProvider.notifier).setEmailOtp(value);
  }

  void _onReferralCodeChanged(String value) {
    ref.read(registerViewModelProvider.notifier).setReferralCode(value);
  }

  Future<void> _onNextPressed() async {
    final notifier = ref.read(registerViewModelProvider.notifier);
    final state = ref.read(registerViewModelProvider);

    if (!state.canProceed) return;

    FocusScope.of(context).unfocus();

    final success = await notifier.validateAndProceed();

    if (success) {
      final currentState = ref.read(registerViewModelProvider);
      if (currentState.currentStep == RegisterStep.otp) {
        _startResendTimer();
      }
    }

    final latestState = ref.read(registerViewModelProvider);
    if (latestState.isSignUpSuccess && mounted) {
      context.navigateToHome();
    }
  }

  Future<void> _resendPhoneOtp() async {
    final state = ref.read(registerViewModelProvider);
    if (state.resendSeconds > 0) return;

    final notifier = ref.read(registerViewModelProvider.notifier);
    final success = await notifier.resendPhoneOtp();
    if (success) {
      _phoneOtpController.clear();
      _startResendTimer();
    }
  }

  Future<void> _resendEmailOtp() async {
    final state = ref.read(registerViewModelProvider);
    if (state.resendEmailSeconds > 0) return;

    final notifier = ref.read(registerViewModelProvider.notifier);
    final success = await notifier.resendEmailOtp();
    if (success) {
      _emailOtpController.clear();
      _startResendEmailTimer();
    }
  }

  void _onBackPressed() {
    final state = ref.read(registerViewModelProvider);
    final notifier = ref.read(registerViewModelProvider.notifier);

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    if (isKeyboardOpen) {
      FocusScope.of(context).unfocus();
    } else {
      FocusScope.of(context).unfocus();
      if (state.currentStep == RegisterStep.name) {
        context.goBack();
      } else {
        _resendTimer?.cancel();
        _resendEmailTimer?.cancel();
        notifier.goBack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerViewModelProvider);
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
                    const SizedBox(height: AppDimens.paddingXXL),
                    _buildInputField(state, colors),
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

  Widget _buildHeader(RegisterState state, AppColorPalette colors) {
    String title;
    switch (state.currentStep) {
      case RegisterStep.name:
        title = getString(
          appStr.headingWhatIsYourName,
          'heading_what_is_your_name',
        );
        break;
      case RegisterStep.terms:
        title = getString(appStr.headingAcceptTerms, 'heading_accept_terms');
        break;
      case RegisterStep.contact:
        title = state.origin == RegisterOrigin.phone
            ? getString(appStr.descriptionEmail, 'description_email')
            : getString(appStr.hintPhoneNumber, 'hint_phone_number');
        break;
      case RegisterStep.password:
        title = getString(
          appStr.headingCreatePassword,
          'heading_create_password',
        );
        break;
      case RegisterStep.license:
        title = getString(appStr.hintDrivingLicense, 'hint_driving_license');
        break;
      case RegisterStep.otp:
        title = getString(
          appStr.headingVerifyAccount,
          'heading_verify_account',
        );
        break;
      case RegisterStep.referral:
        title = getString(
          appStr.headingHaveReferralCode,
          'heading_have_referral_code',
        );
        break;
    }

    return AppText.heading(title);
  }

  Widget _buildInputField(RegisterState state, AppColorPalette colors) {
    switch (state.currentStep) {
      case RegisterStep.name:
        return _buildNameInput(state, colors);
      case RegisterStep.terms:
        return _buildTermsInput(state, colors);
      case RegisterStep.contact:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            state.origin == RegisterOrigin.phone
                ? _buildEmailInput(state, colors)
                : _buildPhoneInput(state, colors),
            const SizedBox(height: AppDimens.paddingL),
            _buildCitySelector(state, colors),
          ],
        );
      case RegisterStep.password:
        return _buildPasswordInput(state, colors);
      case RegisterStep.license:
        return _buildDrivingLicenseInput(state, colors);
      case RegisterStep.otp:
        return _buildOtpInput(state, colors);
      case RegisterStep.referral:
        return _buildReferralInput(state, colors);
    }
  }

  Widget _buildNameInput(RegisterState state, AppColorPalette colors) {
    final firstNameString = getString(appStr.hintFirstName, 'hint_first_name');
    final lastNameString = getString(appStr.hintLastName, 'hint_last_name');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(firstNameString, fontWeight: FontWeight.w500),
        const SizedBox(height: AppDimens.paddingS),
        AppTextField(
          controller: _firstNameController,
          hintText: firstNameString,
          onChanged: _onFirstNameChanged,
        ),
        if (state.firstNameError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.firstNameError!, color: colors.colorWarning),
        ],
        const SizedBox(height: AppDimens.paddingL),
        AppText.body(lastNameString, fontWeight: FontWeight.w500),
        const SizedBox(height: AppDimens.paddingS),
        AppTextField(
          controller: _lastNameController,
          hintText: lastNameString,
          onChanged: _onLastNameChanged,
        ),
        if (state.lastNameError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.lastNameError!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildTermsInput(RegisterState state, AppColorPalette colors) {
    final termsText = getString(
      appStr.descriptionTermsOfUse,
      'description_terms_of_use',
    );
    final privacyText = getString(
      appStr.descriptionPrivacyNotice,
      'description_privacy_notice',
    );
    final fullTermsText = getString(
      appStr.descriptionAgreeTermsPrivacy,
      'description_agree_terms_privacy',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTermsRichText(
          fullText: fullTermsText,
          termsText: termsText,
          privacyText: privacyText,
          termsUrl: state.termsAndConditionsUrl,
          privacyUrl: state.privacyPolicyUrl,
          colors: colors,
        ),
        if (state.error != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.error!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildTermsRichText({
    required String fullText,
    required String termsText,
    required String privacyText,
    required AppColorPalette colors,
    String? termsUrl,
    String? privacyUrl,
  }) {
    final displayText = fullText.replacePlaceholders({
      StringConstant.terms: termsText,
      StringConstant.privacy: privacyText,
    });

    final termsStart = displayText.indexOf(termsText);
    final termsEnd = termsStart + termsText.length;
    final privacyStart = displayText.indexOf(privacyText);
    final privacyEnd = privacyStart + privacyText.length;

    _termsRecognizer ??= TapGestureRecognizer();
    _privacyRecognizer ??= TapGestureRecognizer();

    _termsRecognizer!.onTap = termsUrl != null
        ? () => context.navigateToWebView(
            webViewData: WebViewDataModel(webURL: termsUrl),
          )
        : null;
    _privacyRecognizer!.onTap = privacyUrl != null
        ? () => context.navigateToWebView(
            webViewData: WebViewDataModel(webURL: privacyUrl),
          )
        : null;

    final spans = <TextSpan>[];

    if (termsStart >= 0 && privacyStart >= 0) {
      if (termsStart > 0) {
        spans.add(TextSpan(text: displayText.substring(0, termsStart)));
      }

      spans.add(
        TextSpan(
          text: termsText,
          style: TextStyle(
            color: colors.colorPrimary,
            decoration: TextDecoration.underline,
          ),
          recognizer: _termsRecognizer,
        ),
      );

      if (privacyStart > termsEnd) {
        spans.add(
          TextSpan(text: displayText.substring(termsEnd, privacyStart)),
        );
      }

      spans.add(
        TextSpan(
          text: privacyText,
          style: TextStyle(
            color: colors.colorPrimary,
            decoration: TextDecoration.underline,
          ),
          recognizer: _privacyRecognizer,
        ),
      );

      if (privacyEnd < displayText.length) {
        spans.add(TextSpan(text: displayText.substring(privacyEnd)));
      }
    } else {
      spans.add(TextSpan(text: displayText));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: AppTypos.textM,
          color: colors.colorText,
          height: 1.5,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildEmailInput(RegisterState state, AppColorPalette colors) {
    final emailLabel = getString(appStr.descriptionEmail, 'description_email');
    final emailHint = getString(appStr.hintEmailExample, 'hint_email_example');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(emailLabel, fontWeight: FontWeight.w500),
        const SizedBox(height: AppDimens.paddingS),
        AppTextField(
          controller: _emailController,
          hintText: emailHint,
          keyboardType: TextInputType.emailAddress,
          onChanged: _onEmailChanged,
        ),
        if (state.emailError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.emailError!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildPhoneInput(RegisterState state, AppColorPalette colors) {
    final notifier = ref.read(registerViewModelProvider.notifier);
    final phoneLabel = getString(appStr.hintPhoneNumber, 'hint_phone_number');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(phoneLabel, fontWeight: FontWeight.w500),
        const SizedBox(height: AppDimens.paddingS),
        AppPhoneTextField(
          controller: _phoneController,
          hintText: getString(appStr.hintPhoneNumber, 'hint_phone_number'),
          countryCodeWidget: _buildCountryCodeSelector(colors, state, notifier),
          onChanged: _onPhoneChanged,
          showPrefixInTextField: true,
          selectedCountryPhoneCode:
              state.selectedCountry?.displayPhoneCode ?? '',
        ),
        if (state.phoneError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.phoneError!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildCountryCodeSelector(
    AppColorPalette colors,
    RegisterState state,
    RegisterViewModel notifier,
  ) {
    final selectedCountry = state.selectedCountry;
    final phoneCode = selectedCountry?.displayPhoneCode ?? '';
    final countryCode = selectedCountry?.alpha2 ?? '';

    return InkWell(
      key: _countryCodeKey,
      onTap: () {
        if (state.countries.isEmpty) return;
        _showCountryPicker(state.countries, selectedCountry, notifier);
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText.body(
                countryCode,
                fontSize: AppTypos.textS,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(width: AppDimens.paddingS),
              AppText.body(phoneCode, fontWeight: FontWeight.w500),
              const SizedBox(width: AppDimens.paddingXS),
              Icon(
                Icons.keyboard_arrow_down,
                size: AppDimens.iconSizeSmall,
                color: colors.colorText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCitySelector(RegisterState state, AppColorPalette colors) {
    final cityLabel = getString(appStr.textSelectCity, 'text_select_city');
    final hasCountry = state.selectedCountry?.id != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(cityLabel, fontWeight: FontWeight.w500),
        const SizedBox(height: AppDimens.paddingS),
        InkWell(
          onTap: hasCountry && !state.isCityLoading
              ? () async {
                  final city = await context.navigateToCitySelection(
                    state.selectedCountry!.id!,
                  );
                  if (city != null) {
                    ref
                        .read(registerViewModelProvider.notifier)
                        .setSelectedCity(city);
                  }
                }
              : null,
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.padding,
              vertical: AppDimens.paddingL,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: colors.colorTextHint.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
              color: hasCountry
                  ? null
                  : colors.colorBackgroundGray.withValues(alpha: 0.5),
            ),
            child: state.isCityLoading
                ? SizedBox(
                    height: AppDimens.iconSize,
                    width: AppDimens.iconSize,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.colorPrimary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.body(
                        state.selectedCity?.name ??
                            getString(
                              appStr.textSelectCity,
                              'text_select_city',
                            ),
                        color: state.selectedCity != null
                            ? colors.colorText
                            : colors.colorTextHint,
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: AppDimens.iconSizeSmall,
                        color: colors.colorText,
                      ),
                    ],
                  ),
          ),
        ),
        if (state.cityError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.cityError!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildPasswordInput(RegisterState state, AppColorPalette colors) {
    final passwordLabel = getString(
      appStr.descriptionPassword,
      'description_password',
    );
    final passwordHint = getString(appStr.hintPassword, 'hint_password');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(passwordLabel, fontWeight: FontWeight.w500),
        const SizedBox(height: AppDimens.paddingS),
        AppTextField(
          controller: _passwordController,
          hintText: passwordHint,
          obscureText: _obscurePassword,
          onChanged: _onPasswordChanged,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: colors.colorText,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        if (state.passwordError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.passwordError!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildDrivingLicenseInput(
    RegisterState state,
    AppColorPalette colors,
  ) {
    final licenseLabel = getString(
      appStr.hintDrivingLicense,
      'hint_driving_license',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(licenseLabel, fontWeight: FontWeight.w500),
        const SizedBox(height: AppDimens.paddingS),
        AppTextField(
          controller: _drivingLicenseController,
          hintText: licenseLabel,
          keyboardType: TextInputType.text,
          onChanged: _onDrivingLicenseChanged,
        ),
        if (state.drivingLicenseError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(
            state.drivingLicenseError!,
            color: colors.colorWarning,
          ),
        ],
        // Sign-up runs from this step when OTP and referral are both disabled,
        // so surface the API error here too.
        if (state.error != null) ...[
          const SizedBox(height: AppDimens.paddingM),
          AppText.caption(state.error!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildOtpInput(RegisterState state, AppColorPalette colors) {
    final resendPhoneText = getString(
      appStr.buttonResendPhoneOtp,
      'button_resend_phone_otp',
    );
    final resendEmailText = getString(
      appStr.buttonResendEmailOtp,
      'button_resend_email_otp',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.isPhoneVerificationEnabled) ...[
          AppText.body(
            getString(
              appStr.descriptionEnterOtpSentTo,
              'description_enter_otp_sent_to',
            ).replacePlaceholders({
              StringConstant.leftParam: state.otpLength.toString(),
              StringConstant.rightParam: state.phoneNumber,
            }),
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: AppDimens.paddingM),
          OtpInputField(
            length: state.otpLength,
            controller: _phoneOtpController,
            onChanged: _onPhoneOtpChanged,
          ),
          const SizedBox(height: AppDimens.paddingM),
          _buildTextButton(
            text: state.resendSeconds > 0
                ? '$resendPhoneText (${_formattedResendTime(state.resendSeconds)})'
                : resendPhoneText,
            onTap: state.resendSeconds > 0 ? null : _resendPhoneOtp,
            colors: colors,
          ),
        ],

        if (state.isPhoneVerificationEnabled &&
            state.isEmailVerificationEnabled)
          const SizedBox(height: AppDimens.paddingXXL),

        if (state.isEmailVerificationEnabled) ...[
          AppText.body(
            getString(
              appStr.descriptionEnterOtpSentTo,
              'description_enter_otp_sent_to',
            ).replacePlaceholders({
              StringConstant.leftParam: state.otpLength.toString(),
              StringConstant.rightParam: state.email,
            }),
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: AppDimens.paddingM),
          OtpInputField(
            length: state.otpLength,
            controller: _emailOtpController,
            onChanged: _onEmailOtpChanged,
          ),
          const SizedBox(height: AppDimens.paddingM),
          _buildTextButton(
            text: state.resendEmailSeconds > 0
                ? '$resendEmailText (${_formattedResendTime(state.resendEmailSeconds)})'
                : resendEmailText,
            onTap: state.resendEmailSeconds > 0 ? null : _resendEmailOtp,
            colors: colors,
          ),
        ],

        if (state.error != null) ...[
          const SizedBox(height: AppDimens.paddingM),
          AppText.caption(state.error!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildReferralInput(RegisterState state, AppColorPalette colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          controller: _referralController,
          hintText: getString(
            appStr.hintEnterReferralCode,
            'hint_enter_referral_code',
          ),
          onChanged: _onReferralCodeChanged,
        ),
        if (state.referralError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.referralError!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildBottomBar(RegisterState state, AppColorPalette colors) {
    final isTermsStep = state.currentStep == RegisterStep.terms;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTermsStep) ...[
            const AppDivider(),
            InkWell(
              onTap: () => _onTermsChanged(!state.termsAccepted),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimens.paddingM,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText.body(
                      getString(appStr.buttonIAgree, 'button_i_agree'),
                      fontWeight: FontWeight.w500,
                    ),
                    Checkbox(
                      value: state.termsAccepted,
                      onChanged: _onTermsChanged,
                      activeColor: colors.colorText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          Row(
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
                enabled: state.canProceed,
              ),
            ],
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
      borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding,
          vertical: AppDimens.paddingM,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: isEnabled
                ? colors.colorText
                : colors.colorText.withValues(alpha: 0.3),
            width: AppDimens.borderWidth,
          ),
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
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
