import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repository/app_repository.dart';
import '../../data/api/response_state.dart';
import '../../models/requests/check_registered_request.dart';
import '../../models/requests/entity_detail_request.dart';
import '../../models/requests/generate_otp_request.dart';
import '../../models/requests/verify_otp_request.dart';
import '../../models/requests/sign_up_request.dart';
import '../../models/responses/auth/country_response.dart';
import '../../models/responses/auth/city_response.dart';
import '../../models/responses/auth/entity_detail_response.dart';
import '../../core/constants/app_constants.dart' as constants;
import '../../core/providers/app_providers.dart';
import '../../core/preferences/shared_preference_manager.dart';
import '../../core/utils/validator/validator.dart';
import '../../core/utils/parse_response.dart';
import '../../core/localization/app_strings.dart';
import '../../core/managers/firebase_topic_manager.dart';

/// Origin login type - where user started registration from
enum RegisterOrigin { phone, email }

/// Registration steps
enum RegisterStep { name, terms, contact, password, license, otp, referral }

class ConfirmedRegistrationPrefill {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? drivingLicense;

  const ConfirmedRegistrationPrefill({
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.drivingLicense,
  });
}

class RegisterState {
  final bool isLoading;
  final String? error;
  final RegisterOrigin origin;
  final RegisterStep currentStep;

  // Name step
  final String firstName;
  final String lastName;
  final String? firstNameError;
  final String? lastNameError;

  // Terms step
  final bool termsAccepted;
  final String? termsAndConditionsUrl;
  final String? privacyPolicyUrl;

  // Contact step - phone (if origin is email)
  final String phoneNumber;
  final String countryPhoneCode;
  final String? phoneError;
  final List<Country> countries;
  final Country? selectedCountry;

  // Contact step - city
  final City? selectedCity;
  final List<City> cityList;
  final bool isCityLoading;
  final String? cityError;

  // Contact step - email (if origin is phone)
  final String email;
  final String? emailError;

  // Password step
  final String password;
  final String? passwordError;

  // Driving license step
  final String drivingLicense;
  final String? drivingLicenseError;

  // OTP step
  final String phoneOtp;
  final String emailOtp;
  final int otpLength;

  /// Separate countdowns: resending the phone code must not lock out the email
  /// resend (and vice versa). Native tracks them independently too.
  /// Which OTP mode was requested (sms / email / smsEmail). Native decides it
  /// once in generateOtp and reuses the stored value when verifying, so the
  /// verify call reports the same mode the codes were sent under.
  final int otpSendMode;
  final int resendSeconds;
  final int resendEmailSeconds;
  final bool isPhoneOtpVerified;
  final bool isEmailOtpVerified;

  // Verification flags from entity settings
  final bool isPhoneVerificationEnabled;
  final bool isEmailVerificationEnabled;

  // Referral
  final bool isReferralActive;
  final String referralCode;
  final String? referralError;

  // Success flag
  final bool isSignUpSuccess;

  RegisterState({
    this.isLoading = false,
    this.error,
    this.origin = RegisterOrigin.phone,
    this.currentStep = RegisterStep.name,
    this.firstName = '',
    this.lastName = '',
    this.firstNameError,
    this.lastNameError,
    this.termsAccepted = false,
    this.termsAndConditionsUrl,
    this.privacyPolicyUrl,
    this.phoneNumber = '',
    this.countryPhoneCode = '',
    this.phoneError,
    this.countries = const [],
    this.selectedCountry,
    this.selectedCity,
    this.cityList = const [],
    this.isCityLoading = false,
    this.cityError,
    this.email = '',
    this.emailError,
    this.password = '',
    this.passwordError,
    this.drivingLicense = '',
    this.drivingLicenseError,
    this.phoneOtp = '',
    this.emailOtp = '',
    this.otpLength = 6,
    this.otpSendMode = 0,
    this.resendSeconds = 0,
    this.resendEmailSeconds = 0,
    this.isPhoneOtpVerified = false,
    this.isEmailOtpVerified = false,
    this.isPhoneVerificationEnabled = false,
    this.isEmailVerificationEnabled = false,
    this.isReferralActive = false,
    this.referralCode = '',
    this.referralError,
    this.isSignUpSuccess = false,
  });

  bool get isFirstNameValid => firstName.isNotEmpty;
  bool get isLastNameValid => lastName.isNotEmpty;
  bool get isNameValid => isFirstNameValid && isLastNameValid;

  bool get isPhoneValid => phoneNumber.isNotEmpty && phoneNumber.length >= 6;

  bool get isPasswordValid => password.isNotEmpty;

  bool get isDrivingLicenseValid => drivingLicense.trim().isNotEmpty;

  bool get isPhoneOtpComplete => phoneOtp.length == otpLength;
  bool get isEmailOtpComplete => emailOtp.length == otpLength;

  bool get canProceed {
    switch (currentStep) {
      case RegisterStep.name:
        return isFirstNameValid && isLastNameValid;
      case RegisterStep.terms:
        return termsAccepted;
      case RegisterStep.contact:
        if (origin == RegisterOrigin.phone)
          return email.isNotEmpty && selectedCity != null;
        return phoneNumber.isNotEmpty && selectedCity != null;
      case RegisterStep.password:
        return isPasswordValid;
      case RegisterStep.license:
        return isDrivingLicenseValid;
      case RegisterStep.otp:
        final phoneOtpOk = !isPhoneVerificationEnabled || isPhoneOtpComplete;
        final emailOtpOk = !isEmailVerificationEnabled || isEmailOtpComplete;
        return phoneOtpOk && emailOtpOk;
      case RegisterStep.referral:
        return true;
    }
  }

  bool get hasSignUpVerification =>
      isPhoneVerificationEnabled || isEmailVerificationEnabled;

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    RegisterOrigin? origin,
    RegisterStep? currentStep,
    String? firstName,
    String? lastName,
    String? firstNameError,
    String? lastNameError,
    bool? termsAccepted,
    String? termsAndConditionsUrl,
    String? privacyPolicyUrl,
    String? phoneNumber,
    String? countryPhoneCode,
    String? phoneError,
    List<Country>? countries,
    Country? Function()? selectedCountry,
    City? Function()? selectedCity,
    List<City>? cityList,
    bool? isCityLoading,
    String? cityError,
    bool clearCityError = false,
    bool clearSelectedCity = false,
    String? email,
    String? emailError,
    String? password,
    String? passwordError,
    String? drivingLicense,
    String? drivingLicenseError,
    String? phoneOtp,
    String? emailOtp,
    int? otpLength,
    int? otpSendMode,
    int? resendSeconds,
    int? resendEmailSeconds,
    bool? isPhoneOtpVerified,
    bool? isEmailOtpVerified,
    bool? isPhoneVerificationEnabled,
    bool? isEmailVerificationEnabled,
    bool? isReferralActive,
    String? referralCode,
    String? referralError,
    bool? isSignUpSuccess,
    bool clearError = false,
    bool clearFirstNameError = false,
    bool clearLastNameError = false,
    bool clearPhoneError = false,
    bool clearEmailError = false,
    bool clearPasswordError = false,
    bool clearDrivingLicenseError = false,
    bool clearReferralError = false,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      origin: origin ?? this.origin,
      currentStep: currentStep ?? this.currentStep,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      firstNameError: clearFirstNameError
          ? null
          : (firstNameError ?? this.firstNameError),
      lastNameError: clearLastNameError
          ? null
          : (lastNameError ?? this.lastNameError),
      termsAccepted: termsAccepted ?? this.termsAccepted,
      termsAndConditionsUrl:
          termsAndConditionsUrl ?? this.termsAndConditionsUrl,
      privacyPolicyUrl: privacyPolicyUrl ?? this.privacyPolicyUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryPhoneCode: countryPhoneCode ?? this.countryPhoneCode,
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      countries: countries ?? this.countries,
      selectedCountry: selectedCountry != null
          ? selectedCountry()
          : this.selectedCountry,
      selectedCity: clearSelectedCity
          ? null
          : (selectedCity != null ? selectedCity() : this.selectedCity),
      cityList: cityList ?? this.cityList,
      isCityLoading: isCityLoading ?? this.isCityLoading,
      cityError: clearCityError ? null : (cityError ?? this.cityError),
      email: email ?? this.email,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      password: password ?? this.password,
      passwordError: clearPasswordError
          ? null
          : (passwordError ?? this.passwordError),
      drivingLicense: drivingLicense ?? this.drivingLicense,
      drivingLicenseError: clearDrivingLicenseError
          ? null
          : (drivingLicenseError ?? this.drivingLicenseError),
      phoneOtp: phoneOtp ?? this.phoneOtp,
      emailOtp: emailOtp ?? this.emailOtp,
      otpLength: otpLength ?? this.otpLength,
      otpSendMode: otpSendMode ?? this.otpSendMode,
      resendSeconds: resendSeconds ?? this.resendSeconds,
      resendEmailSeconds: resendEmailSeconds ?? this.resendEmailSeconds,
      isPhoneOtpVerified: isPhoneOtpVerified ?? this.isPhoneOtpVerified,
      isEmailOtpVerified: isEmailOtpVerified ?? this.isEmailOtpVerified,
      isPhoneVerificationEnabled:
          isPhoneVerificationEnabled ?? this.isPhoneVerificationEnabled,
      isEmailVerificationEnabled:
          isEmailVerificationEnabled ?? this.isEmailVerificationEnabled,
      isReferralActive: isReferralActive ?? this.isReferralActive,
      referralCode: referralCode ?? this.referralCode,
      referralError: clearReferralError
          ? null
          : (referralError ?? this.referralError),
      isSignUpSuccess: isSignUpSuccess ?? this.isSignUpSuccess,
    );
  }
}

class RegisterViewModel extends StateNotifier<RegisterState> {
  final AppRepository _appRepository;
  final SharedPreferenceManager _sharedPref;

  /// ViewModel-local setting — mirrors Kotlin's `private var setting`.
  /// Updated when entity detail is fetched for the selected country.
  /// Isolated from other ViewModels writing to sharedPref simultaneously.
  Setting? _setting;

  RegisterViewModel(this._appRepository, this._sharedPref)
    : super(RegisterState()) {
    _setting = _sharedPref.getSetting();
  }

  /// Initialize for phone registration (user came from phone login)
  void initPhoneRegistration({
    required String phoneNumber,
    required String countryPhoneCode,
    required List<Country> countries,
    Country? selectedCountry,
  }) {
    state = state.copyWith(
      origin: RegisterOrigin.phone,
      currentStep: RegisterStep.name,
      phoneNumber: phoneNumber,
      countryPhoneCode: countryPhoneCode,
      countries: countries,
      selectedCountry: () => selectedCountry,
    );
    _updateVerificationFlagsFromSettings();
    if (selectedCountry?.id != null) {
      _fetchCities(selectedCountry!.id!);
    }
  }

  /// Initialize for email registration (user came from email login)
  void initEmailRegistration({
    required String email,
    required List<Country> countries,
    Country? selectedCountry,
  }) {
    state = state.copyWith(
      origin: RegisterOrigin.email,
      currentStep: RegisterStep.name,
      email: email,
      countries: countries,
      selectedCountry: () => selectedCountry,
      countryPhoneCode: selectedCountry?.displayPhoneCode ?? '',
    );
    _updateVerificationFlagsFromSettings();

    if (selectedCountry?.id != null) {
      _fetchCities(selectedCountry!.id!);
    }
  }

  /// Applies only values explicitly confirmed in the local AI handoff.
  /// Route identity and all normal registration validation remain authoritative.
  void applyConfirmedPrefill(ConfirmedRegistrationPrefill? prefill) {
    if (prefill == null) return;

    final confirmedFirstName = prefill.firstName?.trim() ?? '';
    final confirmedLastName = prefill.lastName?.trim() ?? '';
    final hasConfirmedName =
        confirmedFirstName.isNotEmpty && confirmedLastName.isNotEmpty;

    state = state.copyWith(
      firstName: confirmedFirstName.isNotEmpty ? confirmedFirstName : null,
      lastName: confirmedLastName.isNotEmpty ? confirmedLastName : null,
      drivingLicense: prefill.drivingLicense?.trim().isNotEmpty == true
          ? prefill.drivingLicense!.trim()
          : null,
      email:
          state.origin == RegisterOrigin.phone &&
              prefill.email?.trim().isNotEmpty == true
          ? prefill.email!.trim()
          : null,
      phoneNumber:
          state.origin == RegisterOrigin.email &&
              prefill.phone?.trim().isNotEmpty == true
          ? prefill.phone!.trim()
          : null,
      currentStep: hasConfirmedName ? RegisterStep.terms : null,
      clearError: true,
    );
  }

  /// Update verification flags from the ViewModel-local setting.
  /// Uses [_setting] (set from entity detail response on country change),
  /// falling back to sharedPref if not yet fetched — mirrors Kotlin's approach.
  void _updateVerificationFlagsFromSettings() {
    final setting = _setting ?? _sharedPref.getSetting();
    final isVerification = setting?.entitySetting?.isVerification ?? [];

    // For email verification: check if enabled in settings AND email is provided
    final isEmailVerification =
        isVerification.contains(constants.LoginBy.email) &&
        state.email.isNotEmpty;

    // For phone verification: check if enabled in settings
    final isPhoneVerification = isVerification.contains(
      constants.LoginBy.phone,
    );

    // Check if referral is active for driver
    final isReferralActive =
        (setting?.referralConfiguration?.customer?.isActive == true) ||
        (setting?.referralConfiguration?.driver?.isActive == true);

    // Load terms URLs from settings
    final termsUrl = setting?.termsAndConditionsURL;
    final privacyUrl = setting?.privacyPolicyURL;

    state = state.copyWith(
      isEmailVerificationEnabled: isEmailVerification,
      isPhoneVerificationEnabled: isPhoneVerification,
      isReferralActive: isReferralActive,
      termsAndConditionsUrl: termsUrl,
      privacyPolicyUrl: privacyUrl,
    );
  }

  /// Fetch entity detail for a specific country and update settings.
  /// Sets the ViewModel-local [_setting] (mirrors Kotlin's isSetSetting=true path).
  Future<void> _fetchEntityDetail(String countryCode) async {
    if (countryCode.isEmpty) return;
    final request = EntityDetailRequest(countryCode: countryCode);
    final response = await _appRepository.getEntityDetail(request);

    switch (response) {
      case Success<EntityDetailResponse>():
        final data = response.data;
        if (data != null) {
          parseEntityDetailResponse(data, _sharedPref);
          _setting = data.setting; // store locally, not just in sharedPref
          _updateVerificationFlagsFromSettings();
        }
      case Error():
      case Loading():
        break;
    }
  }

  // Setters
  void setFirstName(String firstName) {
    state = state.copyWith(
      firstName: firstName,
      clearFirstNameError: true,
      clearError: true,
    );
  }

  void setLastName(String lastName) {
    state = state.copyWith(
      lastName: lastName,
      clearLastNameError: true,
      clearError: true,
    );
  }

  void setTermsAccepted(bool accepted) {
    state = state.copyWith(termsAccepted: accepted, clearError: true);
  }

  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(
      phoneNumber: phoneNumber,
      clearPhoneError: true,
      clearError: true,
    );
  }

  void setSelectedCountry(Country country) {
    state = state.copyWith(
      selectedCountry: () => country,
      countryPhoneCode: country.displayPhoneCode,
      clearSelectedCity: true,
      cityList: [],
    );

    // Always fetch entity detail on country change (mirrors Kotlin's CountryChange handler)
    final countryCode = country.alpha2 ?? country.code2 ?? country.code ?? '';
    _fetchEntityDetail(countryCode);

    if (country.id != null) {
      _fetchCities(country.id!);
    }
  }

  void setSelectedCity(City city) {
    state = state.copyWith(selectedCity: () => city, clearCityError: true);
  }

  Future<void> _fetchCities(String countryId) async {
    state = state.copyWith(isCityLoading: true, clearCityError: true);
    final response = await _appRepository.getCities(countryId: countryId);

    switch (response) {
      case Success<CityResponse>():
        state = state.copyWith(
          isCityLoading: false,
          cityList: response.data?.cities ?? [],
        );
      case Error():
        state = state.copyWith(
          isCityLoading: false,
          cityError: response.error?.message ?? 'Failed to load cities',
        );
      case Loading():
        break;
    }
  }

  void setEmail(String email) {
    state = state.copyWith(
      email: email,
      clearEmailError: true,
      clearError: true,
    );
  }

  void setPassword(String password) {
    state = state.copyWith(
      password: password,
      clearPasswordError: true,
      clearError: true,
    );
  }

  void setPhoneOtp(String otp) {
    state = state.copyWith(phoneOtp: otp, clearError: true);
  }

  void setEmailOtp(String otp) {
    state = state.copyWith(emailOtp: otp, clearError: true);
  }

  void setReferralCode(String code) {
    state = state.copyWith(
      referralCode: code,
      clearReferralError: true,
      clearError: true,
    );
  }

  void setDrivingLicense(String license) {
    state = state.copyWith(
      drivingLicense: license,
      clearDrivingLicenseError: true,
      clearError: true,
    );
  }

  void updateResendEmailSeconds(int seconds) {
    state = state.copyWith(resendEmailSeconds: seconds);
  }

  void updateResendSeconds(int seconds) {
    state = state.copyWith(resendSeconds: seconds);
  }

  // Navigation
  void goBack() {
    final currentIndex = RegisterStep.values.indexOf(state.currentStep);
    if (currentIndex > 0) {
      state = state.copyWith(
        currentStep: RegisterStep.values[currentIndex - 1],
        clearError: true,
      );
    }
  }

  /// Validate and proceed to next step
  Future<bool> validateAndProceed() async {
    switch (state.currentStep) {
      case RegisterStep.name:
        return _validateName();
      case RegisterStep.terms:
        return _validateTerms();
      case RegisterStep.contact:
        return await _validateContact();
      case RegisterStep.password:
        return await _validatePassword();
      case RegisterStep.license:
        return await _validateDrivingLicense();
      case RegisterStep.otp:
        return await _verifyOtpAndProceed();
      case RegisterStep.referral:
        return await _validateReferralAndSignUp();
    }
  }

  bool _validateName() {
    bool isValid = true;

    if (!Validator.validFirstName(state.firstName).status) {
      state = state.copyWith(
        firstNameError: getString(
          appStr.errorPleaseEnterValidFirstName,
          'error_please_enter_valid_first_name',
        ),
      );
      isValid = false;
    }

    if (!Validator.validLastName(state.lastName).status) {
      state = state.copyWith(
        lastNameError: getString(
          appStr.errorPleaseEnterValidLastName,
          'error_please_enter_valid_last_name',
        ),
      );
      isValid = false;
    }

    if (isValid) {
      state = state.copyWith(currentStep: RegisterStep.terms);
    }
    return isValid;
  }

  bool _validateTerms() {
    if (!state.termsAccepted) {
      state = state.copyWith(
        error: getString(
          appStr.errorPleaseAcceptTerms,
          'error_please_accept_terms',
        ),
      );
      return false;
    }
    state = state.copyWith(currentStep: RegisterStep.contact);
    return true;
  }

  Future<bool> _validateContact() async {
    if (state.origin == RegisterOrigin.phone) {
      if (!Validator.validEmail(state.email).status) {
        state = state.copyWith(
          emailError: getString(
            appStr.errorPleaseEnterEmail,
            'error_please_enter_email',
          ),
        );
        return false;
      }
      if (!Validator.validEmailFormat(state.email).status) {
        state = state.copyWith(
          emailError: getString(
            appStr.errorPleaseEnterValidEmail,
            'error_please_enter_valid_email',
          ),
        );
        return false;
      }

      final isAvailable = await _checkEmailNotRegistered();
      if (!isAvailable) return false;
    } else {
      if (!Validator.validPhoneNumber(state.phoneNumber).status) {
        state = state.copyWith(
          phoneError: getString(
            appStr.errorPleaseEnterPhoneNumber,
            'error_please_enter_phone_number',
          ),
        );
        return false;
      }
      if (!Validator.validPhoneNumberFormatForLogin(state.phoneNumber).status) {
        state = state.copyWith(
          phoneError: getString(
            appStr.errorPleaseEnterValidPhoneNumber,
            'error_please_enter_valid_phone_number',
          ),
        );
        return false;
      }

      final isAvailable = await _checkPhoneNotRegistered();
      if (!isAvailable) return false;
    }

    state = state.copyWith(currentStep: RegisterStep.password);
    return true;
  }

  Future<bool> _checkEmailNotRegistered() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final request = CheckRegisteredRequest(
      loginBy: constants.LoginBy.email,
      email: state.email,
    );

    final response = await _appRepository.checkRegistered(request);

    switch (response) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          emailError: response.message ?? '',
        );
        return false;
      case Error():
        state = state.copyWith(isLoading: false);
        return true;
      case Loading():
        return false;
    }
  }

  Future<bool> _checkPhoneNotRegistered() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final request = CheckRegisteredRequest(
      loginBy: constants.LoginBy.phone,
      countryPhoneCode:
          state.selectedCountry?.displayPhoneCode ?? state.countryPhoneCode,
      phone: state.phoneNumber,
    );

    final response = await _appRepository.checkRegistered(request);

    switch (response) {
      case Success():
        state = state.copyWith(
          isLoading: false,
          phoneError: response.message ?? '',
        );
        return false;
      case Error():
        state = state.copyWith(isLoading: false);
        return true;
      case Loading():
        return false;
    }
  }

  Future<bool> _validatePassword() async {
    if (!Validator.validPassword(state.password).status) {
      state = state.copyWith(
        passwordError: getString(
          appStr.errorPleaseEnterPassword,
          'error_please_enter_password',
        ),
      );
      return false;
    }

    if (!Validator.validPasswordFormat(state.password).status) {
      state = state.copyWith(
        passwordError: state.password.passwordValidationMessage(),
      );
      return false;
    }

    state = state.copyWith(currentStep: RegisterStep.license);
    return true;
  }

  /// Driving license is mandatory for drivers (matches native `Validator.validLicense`).
  Future<bool> _validateDrivingLicense() async {
    if (!Validator.validLicense(state.drivingLicense).status) {
      state = state.copyWith(
        drivingLicenseError: getString(
          appStr.errorPleaseAddLicense,
          'error_please_add_license',
        ),
      );
      return false;
    }

    return _proceedAfterLicense();
  }

  Future<bool> _proceedAfterLicense() async {
    if (state.hasSignUpVerification) {
      state = state.copyWith(currentStep: RegisterStep.otp);
      await _generateOtps();
      return true;
    }

    if (state.isReferralActive) {
      state = state.copyWith(currentStep: RegisterStep.referral);
      return true;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    return await _signUp();
  }

  /// Requests the codes in a single call, as native does: when both
  /// verifications are on it sends `smsEmail` rather than firing one request
  /// per channel (RegisterViewModel.generateOtp).
  Future<void> _generateOtps() async {
    final mode =
        state.isPhoneVerificationEnabled && state.isEmailVerificationEnabled
        ? constants.OtpSendMode.smsEmail
        : state.isPhoneVerificationEnabled
        ? constants.OtpSendMode.sms
        : state.isEmailVerificationEnabled
        ? constants.OtpSendMode.email
        : 0;

    if (mode == 0) return;
    state = state.copyWith(otpSendMode: mode);
    await _generateOtp(mode);
  }

  /// Sends the OTP(s) for [mode] — sms, email, or both in one request.
  Future<bool> _generateOtp(int mode) async {
    final phoneCode = state.origin == RegisterOrigin.phone
        ? state.countryPhoneCode
        : (state.selectedCountry?.displayPhoneCode ?? state.countryPhoneCode);

    final needsPhone =
        mode == constants.OtpSendMode.sms ||
        mode == constants.OtpSendMode.smsEmail;
    final needsEmail =
        mode == constants.OtpSendMode.email ||
        mode == constants.OtpSendMode.smsEmail;

    final request = GenerateOtpRequest(
      sendTo: mode,
      countryPhoneCode: needsPhone ? phoneCode : null,
      phone: needsPhone ? state.phoneNumber : null,
      email: needsEmail ? state.email : null,
    );

    final response = await _appRepository.generateOtp(request);

    switch (response) {
      case Success():
        return true;
      case Error():
        state = state.copyWith(
          error: response.error?.message ?? 'Failed to send OTP',
        );
        return false;
      case Loading():
        return false;
    }
  }

  Future<bool> resendPhoneOtp() async {
    if (state.resendSeconds > 0) return false;
    // Native clears only the field it resent (ResendPhoneNumberOTPClick).
    state = state.copyWith(phoneOtp: '', clearError: true);
    return _generateOtp(constants.OtpSendMode.sms);
  }

  Future<bool> resendEmailOtp() async {
    if (state.resendEmailSeconds > 0) return false;
    // Native clears only the field it resent (ResendEmailOTPClick).
    state = state.copyWith(emailOtp: '', clearError: true);
    return _generateOtp(constants.OtpSendMode.email);
  }

  Future<bool> _verifyOtpAndProceed() async {
    state = state.copyWith(isLoading: true, clearError: true);

    // One request carrying both codes, as native does — two separate calls
    // meant the server only ever verified the first one.
    final verified = await _verifyOtp();
    if (!verified) {
      state = state.copyWith(isLoading: false);
      return false;
    }

    state = state.copyWith(isLoading: false);

    if (state.isReferralActive) {
      state = state.copyWith(currentStep: RegisterStep.referral);
      return true;
    }

    state = state.copyWith(isLoading: true);
    return await _signUp();
  }

  Future<bool> _validateReferralAndSignUp() async {
    if (state.referralCode.isNotEmpty) {
      if (!Validator.validReferralCode(state.referralCode).status) {
        state = state.copyWith(
          referralError: getString(
            appStr.errorInvalidReferralCode,
            'error_invalid_referral_code',
          ),
        );
        return false;
      }
    }

    state = state.copyWith(isLoading: true, clearError: true);
    return await _signUp();
  }

  /// Verifies whichever codes are required in a single call.
  ///
  /// Mirrors native's RegisterViewModel.verifyOtp: `enteredOTP` carries the
  /// phone code when phone verification is on (falling back to the email code
  /// when only email is), and `enteredOTPMail` always carries the email code.
  Future<bool> _verifyOtp() async {
    final phoneCode = state.origin == RegisterOrigin.phone
        ? state.countryPhoneCode
        : (state.selectedCountry?.displayPhoneCode ?? state.countryPhoneCode);

    final request = VerifyOtpRequest(
      sendTo: state.otpSendMode,
      countryPhoneCode: phoneCode,
      phone: state.phoneNumber,
      email: state.email,
      enteredOTP: state.isPhoneVerificationEnabled
          ? state.phoneOtp
          : state.emailOtp,
      enteredOTPMail: state.isEmailVerificationEnabled ? state.emailOtp : null,
    );

    final response = await _appRepository.verifyOtp(request);

    switch (response) {
      case Success():
        state = state.copyWith(
          isPhoneOtpVerified: state.isPhoneVerificationEnabled,
          isEmailOtpVerified: state.isEmailVerificationEnabled,
        );
        return true;
      case Error():
        state = state.copyWith(error: response.error?.message ?? 'Invalid OTP');
        return false;
      case Loading():
        return false;
    }
  }

  Future<bool> _signUp() async {
    final phoneCode = state.origin == RegisterOrigin.phone
        ? state.countryPhoneCode
        : (state.selectedCountry?.displayPhoneCode ?? state.countryPhoneCode);

    final countryCode = state.selectedCountry?.code;

    final int authMethod;
    if (state.origin == RegisterOrigin.email) {
      authMethod = constants.LoginBy.email;
    } else {
      authMethod = constants.LoginBy.phone;
    }

    final request = SignUpRequest(
      authMethod: authMethod,
      firstName: state.firstName,
      lastName: state.lastName,
      countryPhoneCode: phoneCode,
      phone: state.phoneNumber,
      email: state.email,
      countryCode: countryCode,
      password: state.password,
      referralCode: state.referralCode.isNotEmpty ? state.referralCode : null,
      // Driver-specific fields
      countryId: state.selectedCountry?.id,
      cityId: state.selectedCity?.id,
      drivingLicense: state.drivingLicense.trim(),
    );

    final response = await _appRepository.signUp(request);

    switch (response) {
      case Success():
        await _sharedPref.setLoggedIn(true);
        if (countryCode != null) {
          await _fetchEntityDetailAfterSignUp(countryCode);
        }
        _subscribeMassNotificationTopics();
        state = state.copyWith(isLoading: false, isSignUpSuccess: true);
        return true;
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: response.error?.message ?? 'Sign up failed',
        );
        return false;
      case Loading():
        return false;
    }
  }

  Future<void> _fetchEntityDetailAfterSignUp(String countryCode) async {
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

  void _subscribeMassNotificationTopics() {
    final entity = _sharedPref.getEntity();
    FirebaseTopicManager.instance.subscribeToLoginTopics(
      cityId: entity?.cityId,
      countryId: entity?.countryId,
    );
  }
}

final registerViewModelProvider =
    StateNotifierProvider.autoDispose<RegisterViewModel, RegisterState>((ref) {
      final appRepository = ref.watch(appRepositoryProvider);
      final sharedPref = ref
          .watch(sharedPreferenceManagerProvider)
          .maybeWhen(
            data: (data) => data,
            orElse: () => throw Exception('SharedPreferences not initialized'),
          );
      return RegisterViewModel(appRepository, sharedPref);
    });
