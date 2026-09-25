import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/app_repository.dart';
import '../../data/api/response_state.dart';
import '../../models/requests/generate_otp_request.dart';
import '../../models/requests/verify_otp_request.dart';
import '../../models/requests/change_password_request.dart';
import '../../models/responses/auth/verify_otp_response.dart';
import '../../core/constants/app_constants.dart' as constants;
import '../../core/localization/app_strings.dart';

/// Login type for forgot password flow
enum ForgotPasswordLoginType { phone, email }

/// Steps in the forgot password flow
enum ForgotPasswordStep { otp, newPassword }

class ForgotPasswordState {
  final bool isLoading;
  final String? error;
  final ForgotPasswordLoginType loginType;
  final ForgotPasswordStep currentStep;

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
  final String confirmPassword;

  // Resend timer
  final int resendSeconds;

  // Verification token from OTP verification
  final String? verificationToken;

  // Success flag
  final bool isPasswordChangeSuccess;

  ForgotPasswordState({
    this.isLoading = false,
    this.error,
    this.loginType = ForgotPasswordLoginType.phone,
    this.currentStep = ForgotPasswordStep.otp,
    this.phoneNumber = '',
    this.countryPhoneCode = '',
    this.email = '',
    this.otp = '',
    this.otpLength = 6,
    this.password = '',
    this.confirmPassword = '',
    this.resendSeconds = 0,
    this.verificationToken,
    this.isPasswordChangeSuccess = false,
  });

  bool get isOtpComplete => otp.length == otpLength;

  bool get isPasswordValid => password.isNotEmpty;

  bool get isConfirmPasswordValid => confirmPassword.isNotEmpty;

  bool get passwordsMatch => password == confirmPassword;

  bool get canProceedOtp => isOtpComplete;

  bool get canProceedPassword => isPasswordValid && isConfirmPasswordValid && passwordsMatch;

  int get sendTo => loginType == ForgotPasswordLoginType.phone
      ? constants.OtpSendMode.sms
      : constants.OtpSendMode.email;

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? error,
    ForgotPasswordLoginType? loginType,
    ForgotPasswordStep? currentStep,
    String? phoneNumber,
    String? countryPhoneCode,
    String? email,
    String? otp,
    int? otpLength,
    String? password,
    String? confirmPassword,
    int? resendSeconds,
    String? verificationToken,
    bool? isPasswordChangeSuccess,
    bool clearError = false,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      loginType: loginType ?? this.loginType,
      currentStep: currentStep ?? this.currentStep,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryPhoneCode: countryPhoneCode ?? this.countryPhoneCode,
      email: email ?? this.email,
      otp: otp ?? this.otp,
      otpLength: otpLength ?? this.otpLength,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      verificationToken: verificationToken ?? this.verificationToken,
      isPasswordChangeSuccess: isPasswordChangeSuccess ?? this.isPasswordChangeSuccess,
    );
  }
}

class ForgotPasswordViewModel extends StateNotifier<ForgotPasswordState> {
  final AppRepository _appRepository;

  ForgotPasswordViewModel(this._appRepository) : super(ForgotPasswordState());

  /// Initialize for phone forgot password
  void initPhoneForgotPassword({
    required String phoneNumber,
    required String countryPhoneCode,
    int otpLength = 6,
  }) {
    state = state.copyWith(
      loginType: ForgotPasswordLoginType.phone,
      phoneNumber: phoneNumber,
      countryPhoneCode: countryPhoneCode,
      otpLength: otpLength,
      currentStep: ForgotPasswordStep.otp,
    );
    generateOtp();
  }

  /// Initialize for email forgot password
  void initEmailForgotPassword({
    required String email,
    int otpLength = 6,
  }) {
    state = state.copyWith(
      loginType: ForgotPasswordLoginType.email,
      email: email,
      otpLength: otpLength,
      currentStep: ForgotPasswordStep.otp,
    );
    generateOtp();
  }

  void setOtp(String otp) {
    state = state.copyWith(otp: otp, clearError: true);
  }

  void setPassword(String password) {
    state = state.copyWith(password: password, clearError: true);
  }

  void setConfirmPassword(String confirmPassword) {
    state = state.copyWith(confirmPassword: confirmPassword, clearError: true);
  }

  void updateResendSeconds(int seconds) {
    state = state.copyWith(resendSeconds: seconds);
  }

  /// Generate OTP
  Future<bool> generateOtp() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final request = GenerateOtpRequest(
      sendTo: state.sendTo,
      countryPhoneCode: state.loginType == ForgotPasswordLoginType.phone ? state.countryPhoneCode : null,
      phone: state.loginType == ForgotPasswordLoginType.phone ? state.phoneNumber : null,
      email: state.loginType == ForgotPasswordLoginType.email ? state.email : null,
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

  /// Verify OTP and get verification token
  Future<bool> verifyOtp() async {
    if (!state.canProceedOtp) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    final request = VerifyOtpRequest(
      sendTo: state.sendTo,
      countryPhoneCode: state.loginType == ForgotPasswordLoginType.phone ? state.countryPhoneCode : null,
      phone: state.loginType == ForgotPasswordLoginType.phone ? state.phoneNumber : null,
      email: state.loginType == ForgotPasswordLoginType.email ? state.email : null,
      enteredOTP: state.otp,
    );

    final response = await _appRepository.verifyOtp(request);

    switch (response) {
      case Success<VerifyOtpResponse>():
        final token = response.data?.verificationToken;
        state = state.copyWith(
          isLoading: false,
          verificationToken: token,
          currentStep: ForgotPasswordStep.newPassword,
        );
        return true;
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message ?? 'Invalid OTP',
        );
        return false;
      case Loading():
        return false;
    }
  }

  /// Change password
  Future<bool> changePassword() async {
    if (!state.isPasswordValid) {
      state = state.copyWith(
        error: getString(appStr.errorPleaseEnterPassword, 'error_please_enter_password'),
      );
      return false;
    }

    if (!state.passwordsMatch) {
      state = state.copyWith(
        error: getString(appStr.errorPasswordConfirmMismatch, 'error_password_confirm_mismatch'),
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final request = ChangePasswordRequest(
      sendTo: state.sendTo,
      countryPhoneCode: state.loginType == ForgotPasswordLoginType.phone ? state.countryPhoneCode : null,
      phone: state.loginType == ForgotPasswordLoginType.phone ? state.phoneNumber : null,
      email: state.loginType == ForgotPasswordLoginType.email ? state.email : null,
      password: state.password,
      verificationToken: state.verificationToken,
    );

    final response = await _appRepository.changePassword(request);

    switch (response) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          isPasswordChangeSuccess: true,
        );
        return true;
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message ?? 'Failed to change password',
        );
        return false;
      case Loading():
        return false;
    }
  }

  /// Resend OTP
  Future<bool> resendOtp() async {
    if (state.resendSeconds > 0) return false;
    return generateOtp();
  }
}

final forgotPasswordViewModelProvider =
    StateNotifierProvider.autoDispose<ForgotPasswordViewModel, ForgotPasswordState>(
        (ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  return ForgotPasswordViewModel(appRepository);
});
