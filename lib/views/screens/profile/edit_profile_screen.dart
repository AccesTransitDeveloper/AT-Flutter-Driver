import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/resend_timer_helper.dart';
import '../../../core/utils/validator/validator.dart';
import '../../../models/responses/auth/country_response.dart';
import '../../../viewmodels/edit_profile_viewmodel.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_toolbar.dart';
import '../../widgets/country_picker_overlay.dart';
import '../../widgets/otp_input_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final EditProfileField field;

  const EditProfileScreen({
    super.key,
    required this.field,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _drivingLicenseController = TextEditingController();
  final _otpController = TextEditingController();

  final _countryCodeKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late final ResendTimerHelper _resendTimer;

  @override
  void initState() {
    super.initState();
    _resendTimer = ResendTimerHelper(
      onTick: (seconds) =>
          ref.read(editProfileViewModelProvider.notifier).updateResendSeconds(seconds),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeField());
  }

  void _initializeField() {
    final notifier = ref.read(editProfileViewModelProvider.notifier);
    notifier.init(widget.field);

    final state = ref.read(editProfileViewModelProvider);
    _firstNameController.text = state.firstName;
    _lastNameController.text = state.lastName;
    _phoneController.text = state.phoneNumber;
    _emailController.text = state.email;
    _drivingLicenseController.text = state.drivingLicense;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _drivingLicenseController.dispose();
    _otpController.dispose();
    _resendTimer.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showCountryPicker(
    List<Country> countries,
    Country? selectedCountry,
    EditProfileViewModel notifier,
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

  void _startResendTimer() {
    _resendTimer.start(ValidatorConfig.resendOtpTime);
  }

  // ── Event handlers ──────────────────────────────────────────────────────

  void _onFirstNameChanged(String v) =>
      ref.read(editProfileViewModelProvider.notifier).setFirstName(v);

  void _onLastNameChanged(String v) =>
      ref.read(editProfileViewModelProvider.notifier).setLastName(v);

  void _onPhoneChanged(String v) =>
      ref.read(editProfileViewModelProvider.notifier).setPhoneNumber(v);

  void _onEmailChanged(String v) =>
      ref.read(editProfileViewModelProvider.notifier).setEmail(v);

  void _onDrivingLicenseChanged(String v) =>
      ref.read(editProfileViewModelProvider.notifier).setDrivingLicense(v);

  void _onOtpChanged(String v) =>
      ref.read(editProfileViewModelProvider.notifier).setOtp(v);

  Future<void> _onUpdatePressed() async {
    final state = ref.read(editProfileViewModelProvider);
    if (!state.canProceed) return;
    FocusScope.of(context).unfocus();

    final wasInput = state.step == EditProfileStep.input;
    final success =
        await ref.read(editProfileViewModelProvider.notifier).validateAndProceed();

    if (success && wasInput &&
        (state.field == EditProfileField.phone ||
            state.field == EditProfileField.email)) {
      final newState = ref.read(editProfileViewModelProvider);
      if (newState.step == EditProfileStep.otp) _startResendTimer();
    }
  }

  Future<void> _resendOtp() async {
    final state = ref.read(editProfileViewModelProvider);
    if (state.resendSeconds > 0) return;
    final success =
        await ref.read(editProfileViewModelProvider.notifier).resendOtp();
    if (success) _startResendTimer();
  }

  void _onBackPressed() {
    final state = ref.read(editProfileViewModelProvider);
    FocusScope.of(context).unfocus();
    if (state.step == EditProfileStep.otp) {
      _resendTimer.cancel();
      _otpController.clear();
      ref.read(editProfileViewModelProvider.notifier).goBack();
    } else {
      context.goBack();
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileViewModelProvider);
    final colors = context.colors;

    ref.listen<EditProfileState>(editProfileViewModelProvider, (_, next) {
      if (next.isUpdateSuccess && mounted) context.goBack(true);
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: _appBarTitle(state),
              onBack: _onBackPressed,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: AppDimens.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppDimens.paddingXL),
                    if (state.step == EditProfileStep.otp) ...[
                      AppText.heading(
                        getString(appStr.headingVerifyAccount,
                            'heading_verify_account'),
                      ),
                      const SizedBox(height: AppDimens.paddingM),
                      _buildOtpSubtitle(state, colors),
                    ] else
                      _buildInputSubtitle(state, colors),
                    const SizedBox(height: AppDimens.paddingXXL),
                    _buildInputField(state, colors),
                  ],
                ),
              ),
            ),
            _buildBottomBar(state),
          ],
        ),
      ),
    );
  }

  String _appBarTitle(EditProfileState state) {
    switch (state.field) {
      case EditProfileField.name:
        return getString(appStr.headingName, 'heading_name');
      case EditProfileField.phone:
        return getString(appStr.hintPhoneNumber, 'hint_phone_number');
      case EditProfileField.email:
        return getString(appStr.descriptionEmail, 'description_email');
      case EditProfileField.license:
        return getString(appStr.hintDrivingLicense, 'hint_driving_license');
    }
  }

  Widget _buildInputSubtitle(EditProfileState state, AppColorPalette colors) {
    String? subtitle;
    switch (state.field) {
      case EditProfileField.name:
        subtitle =
            getString(appStr.descriptionProfileName, 'description_profile_name');
        break;
      case EditProfileField.phone:
        subtitle = getString(appStr.descriptionYouWillUseThisNumber,
            'description_you_will_use_this_number');
        break;
      case EditProfileField.email:
        subtitle = getString(appStr.descriptionYouWillUseThisEmail,
            'description_you_will_use_this_email');
        break;
      case EditProfileField.license:
        subtitle = getString(
            appStr.descriptionDrivingLicense, 'description_driving_license');
        break;
    }
    return AppText.body(subtitle, color: colors.colorText);
  }

  Widget _buildOtpSubtitle(EditProfileState state, AppColorPalette colors) {
    final target = state.field == EditProfileField.phone
        ? state.phoneNumber
        : state.email;
    final text = getString(appStr.descriptionEnterOtpSentTo,
            'description_enter_otp_sent_to')
        .replacePlaceholders({
      StringConstant.leftParam: state.otpLength.toString(),
      StringConstant.rightParam: target,
    });
    return AppText.body(text, color: colors.colorText);
  }

  Widget _buildInputField(EditProfileState state, AppColorPalette colors) {
    if (state.step == EditProfileStep.otp) return _buildOtpInput(state, colors);
    switch (state.field) {
      case EditProfileField.name:
        return _buildNameInput(state, colors);
      case EditProfileField.phone:
        return _buildPhoneInput(state, colors);
      case EditProfileField.email:
        return _buildEmailInput(state, colors);
      case EditProfileField.license:
        return _buildDrivingLicenseInput(state, colors);
    }
  }

  Widget _buildDrivingLicenseInput(
      EditProfileState state, AppColorPalette colors) {
    final licenseLabel =
        getString(appStr.hintDrivingLicense, 'hint_driving_license');

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
          AppText.caption(state.drivingLicenseError!,
              color: colors.colorWarning),
        ],
        if (state.error != null) ...[
          const SizedBox(height: AppDimens.paddingM),
          AppText.caption(state.error!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildNameInput(EditProfileState state, AppColorPalette colors) {
    final firstNameStr =
        getString(appStr.hintFirstName, 'hint_first_name');
    final lastNameStr =
        getString(appStr.hintLastName, 'hint_last_name');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(firstNameStr, fontWeight: FontWeight.w500),
        const SizedBox(height: AppDimens.paddingS),
        AppTextField(
            controller: _firstNameController,
            hintText: firstNameStr,
            onChanged: _onFirstNameChanged),
        if (state.firstNameError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.firstNameError!, color: colors.colorWarning),
        ],
        const SizedBox(height: AppDimens.paddingL),
        AppText.body(lastNameStr, fontWeight: FontWeight.w500),
        const SizedBox(height: AppDimens.paddingS),
        AppTextField(
            controller: _lastNameController,
            hintText: lastNameStr,
            onChanged: _onLastNameChanged),
        if (state.lastNameError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.lastNameError!, color: colors.colorWarning),
        ],
        if (state.error != null) ...[
          const SizedBox(height: AppDimens.paddingM),
          AppText.caption(state.error!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildPhoneInput(EditProfileState state, AppColorPalette colors) {
    final phoneLabel =
        getString(appStr.hintPhoneNumber, 'hint_phone_number');
    final notifier = ref.read(editProfileViewModelProvider.notifier);
    final phoneCode =
        state.selectedCountry?.displayPhoneCode ?? state.countryPhoneCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.body(phoneLabel, fontWeight: FontWeight.w500),
        const SizedBox(height: AppDimens.paddingS),
        AppPhoneTextField(
          controller: _phoneController,
          hintText: phoneLabel,
          countryCodeWidget: _buildCountryCodeSelector(colors, state, notifier),
          onChanged: _onPhoneChanged,
          showPrefixInTextField: true,
          selectedCountryPhoneCode: phoneCode,
        ),
        if (state.isPhoneVerificationEnabled) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(
            getString(appStr.descriptionVerificationCodeSendToNumber,
                'description_verification_code_send_to_number'),
            color: colors.colorText,
          ),
        ],
        if (state.phoneError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.phoneError!, color: colors.colorWarning),
        ],
        if (state.error != null) ...[
          const SizedBox(height: AppDimens.paddingM),
          AppText.caption(state.error!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildCountryCodeSelector(
    AppColorPalette colors,
    EditProfileState state,
    EditProfileViewModel notifier,
  ) {
    final selectedCountry = state.selectedCountry;
    final countryCode = selectedCountry?.alpha2 ?? '';
    final phoneCode =
        selectedCountry?.displayPhoneCode ?? state.countryPhoneCode;

    return InkWell(
      key: _countryCodeKey,
      onTap: () {
        if (state.countries.isEmpty) return;
        _showCountryPicker(state.countries, selectedCountry, notifier);
      },
      child: Center(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (countryCode.isNotEmpty) ...[
                AppText.body(countryCode,
                    fontSize: AppTypos.textS, fontWeight: FontWeight.w600),
                const SizedBox(width: AppDimens.paddingS),
              ],
              AppText.body(phoneCode, fontWeight: FontWeight.w500),
              const SizedBox(width: AppDimens.paddingXS),
              Icon(Icons.keyboard_arrow_down,
                  size: AppDimens.iconSizeSmall, color: colors.colorText),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInput(EditProfileState state, AppColorPalette colors) {
    final emailLabel =
        getString(appStr.descriptionEmail, 'description_email');
    final emailHint =
        getString(appStr.hintEmailExample, 'hint_email_example');

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
        if (state.isEmailVerificationEnabled) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(
            getString(appStr.descriptionProfileEmail,
                'description_profile_email'),
            color: colors.colorText,
          ),
        ],
        if (state.emailError != null) ...[
          const SizedBox(height: AppDimens.paddingS),
          AppText.caption(state.emailError!, color: colors.colorWarning),
        ],
        if (state.error != null) ...[
          const SizedBox(height: AppDimens.paddingM),
          AppText.caption(state.error!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildOtpInput(EditProfileState state, AppColorPalette colors) {
    final resendText = state.field == EditProfileField.phone
        ? getString(appStr.descriptionResendPhoneCode,
            'description_resend_phone_code')
        : getString(appStr.descriptionResendEmailCode,
            'description_resend_email_code');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OtpInputField(
          length: state.otpLength,
          controller: _otpController,
          onChanged: _onOtpChanged,
        ),
        const SizedBox(height: AppDimens.paddingM),
        _buildResendButton(
          text: state.resendSeconds > 0
              ? '$resendText (${ResendTimerHelper.formatTime(state.resendSeconds)})'
              : resendText,
          onTap: state.resendSeconds > 0 ? null : _resendOtp,
          colors: colors,
        ),
        if (state.error != null) ...[
          const SizedBox(height: AppDimens.paddingM),
          AppText.caption(state.error!, color: colors.colorWarning),
        ],
      ],
    );
  }

  Widget _buildBottomBar(EditProfileState state) {
    return Padding(
      padding: const EdgeInsets.all(AppDimens.padding),
      child: AppFilledButton(
        text: getString(appStr.buttonUpdate, 'button_update'),
        onPressed: state.canProceed ? _onUpdatePressed : null,
        isLoading: state.isLoading,
        enabled: state.canProceed,
      ),
    );
  }

  Widget _buildResendButton({
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
