import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/app_repository.dart';
import '../../data/api/response_state.dart';
import '../../models/requests/check_registered_request.dart';
import '../../models/requests/generate_otp_request.dart';
import '../../models/requests/sign_in_request.dart';
import '../../models/requests/entity_detail_request.dart';
import '../../core/constants/app_constants.dart' as constants;
import '../../core/providers/app_providers.dart';
import '../../models/responses/auth/entity_detail_response.dart';
import '../../models/responses/auth/country_response.dart';
import '../../core/preferences/shared_preference_manager.dart';
import '../../core/utils/validator/validator.dart';
import '../../core/utils/parse_response.dart';
import '../../core/localization/app_strings.dart';
import '../../core/utils/device_info_helper.dart';
import '../../core/managers/firebase_topic_manager.dart';

/// Login type for verification flow
enum LoginType { phone, email }

/// Verification step in the flow
enum VerificationStep { input, otp, password }

/// Authentication mode
enum AuthMode { otp, password }

/// Result of check registered API
enum CheckEmailResult { registered, notRegistered, validationError }

class VerificationState {
  final bool isLoading;
  final String? error;
  final LoginType loginType;
  final VerificationStep currentStep;
  final AuthMode authMode;

  // Phone params
  final String phoneNumber;
  final String countryPhoneCode;

  // Email params
  final String email;

  // OTP params
  final String otp;
  final int otpLength;

  // Password params
  final String password;

  // Auth method support flags
  final bool supportsOtp;
  final bool supportsPassword;

  // Resend timer
  final int resendSeconds;

  // Sign in success flag
  final bool isSignInSuccess;

  // Validation errors
  final String? emailError;
  final String? phoneError;

  // Countries list for phone input step
  final List<Country> countries;
  final Country? selectedCountry;

  VerificationState({
    this.isLoading = false,
    this.error,
    this.loginType = LoginType.phone,
    this.currentStep = VerificationStep.otp,
    this.isSignInSuccess = false,
    this.authMode = AuthMode.otp,
    this.phoneNumber = '',
    this.countryPhoneCode = '',
    this.email = '',
    this.otp = '',
    this.otpLength = 6,
    this.password = '',
    this.supportsOtp = true,
    this.supportsPassword = false,
    this.resendSeconds = 0,
    this.emailError,
    this.phoneError,
    this.countries = const [],
    this.selectedCountry,
  });

  bool get supportsBoth => supportsOtp && supportsPassword;

  bool get canSwitchToPassword => supportsPassword && authMode == AuthMode.otp;
  bool get canSwitchToOtp => supportsOtp && authMode == AuthMode.password;

  bool get isOtpComplete => otp.length == otpLength;

  bool get isPasswordValid => password.isNotEmpty;

  bool get canProceed {
    switch (currentStep) {
      case VerificationStep.input:
        return loginType == LoginType.phone
            ? phoneNumber.isNotEmpty
            : email.isNotEmpty;
      case VerificationStep.otp:
        return isOtpComplete;
      case VerificationStep.password:
        return isPasswordValid;
    }
  }

  int get sendTo => loginType == LoginType.phone
      ? constants.OtpSendMode.sms
      : constants.OtpSendMode.email;

  VerificationState copyWith({
    bool? isLoading,
    String? error,
    LoginType? loginType,
    VerificationStep? currentStep,
    AuthMode? authMode,
    String? phoneNumber,
    String? countryPhoneCode,
    String? email,
    String? otp,
    int? otpLength,
    String? password,
    bool? supportsOtp,
    bool? supportsPassword,
    int? resendSeconds,
    bool? isSignInSuccess,
    String? emailError,
    String? phoneError,
    List<Country>? countries,
    Country? Function()? selectedCountry,
    bool clearEmailError = false,
    bool clearPhoneError = false,
    bool clearError = false,
  }) {
    return VerificationState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      loginType: loginType ?? this.loginType,
      currentStep: currentStep ?? this.currentStep,
      authMode: authMode ?? this.authMode,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryPhoneCode: countryPhoneCode ?? this.countryPhoneCode,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      otpLength: otpLength ?? this.otpLength,
      password: password ?? this.password,
      supportsOtp: supportsOtp ?? this.supportsOtp,
      supportsPassword: supportsPassword ?? this.supportsPassword,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      isSignInSuccess: isSignInSuccess ?? this.isSignInSuccess,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      countries: countries ?? this.countries,
      selectedCountry:
          selectedCountry != null ? selectedCountry() : this.selectedCountry,
    );
  }
}

class VerificationViewModel extends StateNotifier<VerificationState> {
  final AppRepository _appRepository;
  final SharedPreferenceManager _sharedPref;

  VerificationViewModel(this._appRepository, this._sharedPref)
      : super(VerificationState());

  /// Initialize for phone verification.
  /// When [phoneNumber] and [countryPhoneCode] are null, starts at input step.
  void initPhoneVerification({
    String? phoneNumber,
    String? countryPhoneCode,
    required int otpLength,
    required bool supportsOtp,
    required bool supportsPassword,
    List<Country> countries = const [],
    Country? selectedCountry,
  }) {
    final hasPhone =
        phoneNumber != null && phoneNumber.isNotEmpty;
    final initialStep = hasPhone
        ? (supportsOtp ? VerificationStep.otp : VerificationStep.password)
        : VerificationStep.input;
    final initialMode = supportsOtp ? AuthMode.otp : AuthMode.password;

    state = state.copyWith(
      loginType: LoginType.phone,
      phoneNumber: phoneNumber ?? '',
      countryPhoneCode: countryPhoneCode ?? '',
      otpLength: otpLength,
      supportsOtp: supportsOtp,
      supportsPassword: supportsPassword,
      currentStep: initialStep,
      authMode: initialMode,
      countries: countries,
      selectedCountry: () => selectedCountry,
    );

    if (initialStep == VerificationStep.otp) {
      generateOtp();
    }
  }

  /// Initialize for email verification
  void initEmailVerification({
    String? initialEmail,
    required int otpLength,
    required bool supportsOtp,
    required bool supportsPassword,
  }) {
    // When email is pre-filled (came from login screen after checkRegistered),
    // skip input step and go directly to OTP/password.
    final initialStep = (initialEmail != null && initialEmail.isNotEmpty)
        ? (supportsOtp ? VerificationStep.otp : VerificationStep.password)
        : VerificationStep.input;

    state = state.copyWith(
      loginType: LoginType.email,
      email: initialEmail ?? '',
      otpLength: otpLength,
      supportsOtp: supportsOtp,
      supportsPassword: supportsPassword,
      currentStep: initialStep,
      authMode: supportsOtp ? AuthMode.otp : AuthMode.password,
    );

    if (initialStep == VerificationStep.otp) {
      generateOtp();
    }
  }

  void setEmail(String email) {
    state = state.copyWith(email: email, clearError: true, clearEmailError: true);
  }

  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(
        phoneNumber: phoneNumber, clearError: true, clearPhoneError: true);
  }

  void setSelectedCountry(Country country) {
    state = state.copyWith(selectedCountry: () => country);
    final countryCode = country.alpha2 ?? country.code2 ?? country.code;
    if (countryCode != null) {
      _fetchEntityDetailForCountry(countryCode);
    }
  }

  Future<void> _fetchEntityDetailForCountry(String countryCode) async {
    final request = EntityDetailRequest(countryCode: countryCode);
    final response = await _appRepository.getEntityDetail(request);

    switch (response) {
      case Success<EntityDetailResponse>():
        final data = response.data;
        if (data != null) {
          parseEntityDetailResponse(data, _sharedPref);
        }
      case Error():
      case Loading():
        break;
    }
  }

  void setOtp(String otp) {
    state = state.copyWith(otp: otp, clearError: true);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, clearError: true);
  }

  void updateResendSeconds(int seconds) {
    state = state.copyWith(resendSeconds: seconds);
  }

  void toggleAuthMode() {
    if (state.authMode == AuthMode.otp) {
      state = state.copyWith(
        authMode: AuthMode.password,
        currentStep: VerificationStep.password,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        authMode: AuthMode.otp,
        currentStep: VerificationStep.otp,
        clearError: true,
      );
      generateOtp();
    }
  }

  void goBackToInput() {
    state = state.copyWith(
      currentStep: VerificationStep.input,
      otp: '',
      password: '',
      clearError: true,
      clearPhoneError: true,
      clearEmailError: true,
    );
  }

  /// Check if email is registered
  Future<CheckEmailResult> checkEmailRegistered() async {
    if (!Validator.validEmail(state.email).status) {
      state = state.copyWith(emailError: getString(appStr.errorPleaseEnterEmail, 'error_please_enter_email'));
      return CheckEmailResult.validationError;
    }
    if (!Validator.validEmailFormat(state.email).status) {
      state = state.copyWith(emailError: getString(appStr.errorPleaseEnterValidEmail, 'error_please_enter_valid_email'));
      return CheckEmailResult.validationError;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final request = CheckRegisteredRequest(
      loginBy: constants.LoginBy.email,
      email: state.email,
    );

    final response = await _appRepository.checkRegistered(request);

    switch (response) {
      case Success():
        final nextStep = state.supportsOtp
            ? VerificationStep.otp
            : VerificationStep.password;
        state = state.copyWith(currentStep: nextStep);
        if (nextStep == VerificationStep.otp) {
          await generateOtp();
        } else {
          state = state.copyWith(isLoading: false);
        }
        return CheckEmailResult.registered;
      case Error():
        state = state.copyWith(isLoading: false);
        return CheckEmailResult.notRegistered;
      case Loading():
        return CheckEmailResult.validationError;
    }
  }

  /// Check if phone is registered
  Future<CheckEmailResult> checkPhoneRegistered() async {
    if (!Validator.validPhoneNumber(state.phoneNumber).status) {
      state = state.copyWith(
          phoneError: getString(appStr.errorPleaseEnterPhoneNumber,
              'error_please_enter_phone_number'));
      return CheckEmailResult.validationError;
    }
    if (!Validator.validPhoneNumberFormatForLogin(state.phoneNumber).status) {
      state = state.copyWith(
          phoneError: getString(appStr.errorPleaseEnterValidPhoneNumber,
              'error_please_enter_valid_phone_number'));
      return CheckEmailResult.validationError;
    }

    state = state.copyWith(isLoading: true, clearError: true, clearPhoneError: true);

    final request = CheckRegisteredRequest(
      loginBy: constants.LoginBy.phone,
      countryPhoneCode: state.selectedCountry?.displayPhoneCode,
      phone: state.phoneNumber,
    );

    final response = await _appRepository.checkRegistered(request);

    switch (response) {
      case Success():
        final countryCode = state.selectedCountry?.displayPhoneCode ?? '';
        final nextStep =
            state.supportsOtp ? VerificationStep.otp : VerificationStep.password;
        state = state.copyWith(
          currentStep: nextStep,
          countryPhoneCode: countryCode,
        );
        if (nextStep == VerificationStep.otp) {
          await generateOtp();
        } else {
          state = state.copyWith(isLoading: false);
        }
        return CheckEmailResult.registered;
      case Error():
        state = state.copyWith(isLoading: false);
        return CheckEmailResult.notRegistered;
      case Loading():
        return CheckEmailResult.validationError;
    }
  }

  /// Generate OTP
  Future<bool> generateOtp() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final request = GenerateOtpRequest(
      sendTo: state.sendTo,
      countryPhoneCode: state.countryPhoneCode.isNotEmpty ? state.countryPhoneCode : null,
      phone: state.phoneNumber.isNotEmpty ? state.phoneNumber : null,
      email: state.email.isNotEmpty ? state.email : null,
    );

    final response = await _appRepository.generateOtp(request);

    switch (response) {
      case Success():
        state = state.copyWith(isLoading: false);
        return true;
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message ?? 'Failed to send OTP',
        );
        return false;
      case Loading():
        return false;
    }
  }

  /// Sign in (handles both OTP and password)
  Future<bool> signIn() async {
    final useOtp = state.authMode == AuthMode.otp;

    state = state.copyWith(isLoading: true, clearError: true);

    final int loginBy;
    if (useOtp) {
      loginBy = constants.LoginBy.otp;
    } else {
      loginBy = state.loginType == LoginType.email
          ? constants.LoginBy.email
          : constants.LoginBy.phone;
    }

    final request = SignInRequest(
      sendTo: state.sendTo,
      loginBy: loginBy,
      countryPhoneCode: state.countryPhoneCode.isNotEmpty ? state.countryPhoneCode : null,
      phone: state.phoneNumber.isNotEmpty ? state.phoneNumber : null,
      email: state.email.isNotEmpty ? state.email : null,
      password: useOtp ? null : state.password,
      enteredOTP: useOtp ? state.otp : null,
    );

    final response = await _appRepository.signIn(request);

    switch (response) {
      case Success():
        await _fetchEntityDetail();
        await _sharedPref.setLoggedIn(true);
        _subscribeMassNotificationTopics();
        state = state.copyWith(isLoading: false, isSignInSuccess: true);
        return true;
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message ?? 'Sign in failed',
        );
        return false;
      case Loading():
        return false;
    }
  }

  /// Fetch entity detail after sign in
  Future<void> _fetchEntityDetail() async {
    final countryCode = state.countryPhoneCode.isNotEmpty
        ? state.countryPhoneCode.replaceAll('+', '')
        : DeviceInfoHelper.getDeviceCountry();

    final request = EntityDetailRequest(countryCode: countryCode);
    final response = await _appRepository.getEntityDetail(request);

    switch (response) {
      case Success<EntityDetailResponse>():
        final data = response.data;
        if (data != null) {
          parseEntityDetailResponse(data, _sharedPref);
        }
      case Error():
      case Loading():
        break;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    if (state.resendSeconds > 0) return false;
    return generateOtp();
  }

  void _subscribeMassNotificationTopics() {
    final entity = _sharedPref.getEntity();
    FirebaseTopicManager.instance.subscribeToLoginTopics(
      cityId: entity?.cityId,
      countryId: entity?.countryId,
    );
  }
}

final verificationViewModelProvider =
    StateNotifierProvider.autoDispose<VerificationViewModel, VerificationState>(
        (ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => throw Exception('SharedPreferences not initialized'),
      );
  return VerificationViewModel(appRepository, sharedPref);
});
