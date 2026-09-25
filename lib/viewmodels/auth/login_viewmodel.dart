import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../data/repository/app_repository.dart';
import '../../data/api/response_state.dart';
import '../../models/responses/auth/country_response.dart';
import '../../models/responses/auth/entity_detail_response.dart';
import '../../models/requests/check_registered_request.dart';
import '../../models/requests/sign_in_request.dart';
import '../../models/requests/sign_up_request.dart';
import '../../models/requests/entity_detail_request.dart';
import '../../core/constants/app_constants.dart' as constants;
import '../../core/preferences/shared_preference_manager.dart';
import '../../core/providers/app_providers.dart';
import '../../core/utils/parse_response.dart';
import '../../core/managers/firebase_topic_manager.dart';
import '../../core/managers/notification_manager.dart';
import '../../core/utils/device_info_helper.dart';
import '../../core/utils/validator/validator.dart';
import '../../core/localization/app_strings.dart';
import '../../models/requests/firebase_device_token_request.dart';

enum LoginMethod { email, phone, social }

/// Available social login providers
enum SocialLoginProvider { google, apple }

/// Authentication method (OTP or Password)
enum AuthMethod { otp, password }

/// Result of check registered API
enum CheckRegisteredResult { registered, notRegistered, validationError }

class LoginState {
  final bool isLoading;

  /// Which action is in flight ('phone', 'email', 'google', 'apple').
  /// Every button on the login screen used to bind to [isLoading], so tapping
  /// one spun all of them.
  final String? loadingAction;
  final String? error;
  final String? phoneError;
  final LoginMethod currentMethod;
  final String phoneNumber;
  final List<Country> countries;
  final Country? selectedCountry;
  final bool isLoadingCountries;

  // Email field (for email-primary login)
  final String email;
  final String? emailError;

  // Login button visibility flags
  final bool showEmailLogin;
  final bool showPhoneLogin;
  final List<SocialLoginProvider> availableSocialLogins;

  // Phone auth methods (OTP/Password)
  final List<AuthMethod> phoneAuthMethods;

  // Email auth methods (OTP/Password)
  final List<AuthMethod> emailAuthMethods;

  // Social login result fields
  final bool isSocialLoginSuccess;
  final String? socialId;
  final int? socialLoginBy;
  final String? socialFirstName;
  final String? socialLastName;
  final String? socialEmail;

  LoginState({
    this.isLoading = false,
    this.loadingAction,
    this.error,
    this.phoneError,
    this.currentMethod = LoginMethod.email,
    this.phoneNumber = '',
    this.email = '',
    this.emailError,
    this.countries = const [],
    this.selectedCountry,
    this.isLoadingCountries = false,
    this.showEmailLogin = true,
    this.showPhoneLogin = true,
    this.availableSocialLogins = const [],
    this.phoneAuthMethods = const [AuthMethod.otp],
    this.emailAuthMethods = const [AuthMethod.otp],
    this.isSocialLoginSuccess = false,
    this.socialId,
    this.socialLoginBy,
    this.socialFirstName,
    this.socialLastName,
    this.socialEmail,
  });

  bool get showGoogleLogin =>
      availableSocialLogins.contains(SocialLoginProvider.google);

  bool get showAppleLogin =>
      availableSocialLogins.contains(SocialLoginProvider.apple);

  bool get phoneSupportsOtp => phoneAuthMethods.contains(AuthMethod.otp);

  bool get phoneSupportsPassword =>
      phoneAuthMethods.contains(AuthMethod.password);

  bool get emailSupportsOtp => emailAuthMethods.contains(AuthMethod.otp);

  bool get emailSupportsPassword =>
      emailAuthMethods.contains(AuthMethod.password);

  LoginState copyWith({
    bool? isLoading,
    String? loadingAction,
    String? error,
    String? phoneError,
    bool clearPhoneError = false,
    bool clearError = false,
    LoginMethod? currentMethod,
    String? phoneNumber,
    String? email,
    String? emailError,
    bool clearEmailError = false,
    List<Country>? countries,
    Country? Function()? selectedCountry,
    bool? isLoadingCountries,
    bool? showEmailLogin,
    bool? showPhoneLogin,
    List<SocialLoginProvider>? availableSocialLogins,
    List<AuthMethod>? phoneAuthMethods,
    List<AuthMethod>? emailAuthMethods,
    bool? isSocialLoginSuccess,
    String? socialId,
    int? socialLoginBy,
    String? socialFirstName,
    String? socialLastName,
    String? socialEmail,
    bool clearSocialData = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      loadingAction:
          (isLoading ?? this.isLoading) ? (loadingAction ?? this.loadingAction) : null,
      error: clearError ? null : (error ?? this.error),
      phoneError: clearPhoneError ? null : (phoneError ?? this.phoneError),
      currentMethod: currentMethod ?? this.currentMethod,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      countries: countries ?? this.countries,
      selectedCountry:
          selectedCountry != null ? selectedCountry() : this.selectedCountry,
      isLoadingCountries: isLoadingCountries ?? this.isLoadingCountries,
      showEmailLogin: showEmailLogin ?? this.showEmailLogin,
      showPhoneLogin: showPhoneLogin ?? this.showPhoneLogin,
      availableSocialLogins:
          availableSocialLogins ?? this.availableSocialLogins,
      phoneAuthMethods: phoneAuthMethods ?? this.phoneAuthMethods,
      emailAuthMethods: emailAuthMethods ?? this.emailAuthMethods,
      isSocialLoginSuccess: isSocialLoginSuccess ?? this.isSocialLoginSuccess,
      socialId: clearSocialData ? null : (socialId ?? this.socialId),
      socialLoginBy:
          clearSocialData ? null : (socialLoginBy ?? this.socialLoginBy),
      socialFirstName:
          clearSocialData ? null : (socialFirstName ?? this.socialFirstName),
      socialLastName:
          clearSocialData ? null : (socialLastName ?? this.socialLastName),
      socialEmail: clearSocialData ? null : (socialEmail ?? this.socialEmail),
    );
  }
}

class LoginViewModel extends StateNotifier<LoginState> {
  final AppRepository _appRepository;
  final SharedPreferenceManager _sharedPref;

  LoginViewModel(this._appRepository, this._sharedPref)
      : super(LoginState()) {
    _init();
  }

  Future<void> _init() async {
    final authToken = _sharedPref.getAuthorization();
    if (authToken == null || authToken.isEmpty) {
      await _getToken();
    } else {
      await _fetchEntityDetail(DeviceInfoHelper.getDeviceCountry());
    }
    fetchCountries();
  }

  Future<void> _getToken() async {
    final deviceTokenRequest =
        await DeviceInfoHelper.buildDeviceTokenRequest();
    final response = await _appRepository.getToken(deviceTokenRequest);

    switch (response) {
      case Success():
        await _fetchEntityDetail(DeviceInfoHelper.getDeviceCountry());
      case Error():
      case Loading():
        break;
    }
  }

  Future<void> fetchCountries() async {
    state = state.copyWith(isLoadingCountries: true);

    final response = await _appRepository.getCountries();

    switch (response) {
      case Success<CountryResponse>():
        final countries = response.data?.countries ?? [];
        Country? defaultCountry;
        if (countries.isNotEmpty) {
          // Default to the US rather than the device locale. The register
          // screen inherits whatever is picked here, so this is the single
          // place that decides it for both.
          defaultCountry = countries.firstWhere(
            (c) => c.alpha2 == 'US' || c.code2 == 'US' || c.code == 'US',
            orElse: () => countries.first,
          );
        }
        state = state.copyWith(
          countries: countries,
          selectedCountry: () => defaultCountry,
          isLoadingCountries: false,
        );

        final countryCode = defaultCountry?.alpha2 ?? defaultCountry?.code2 ?? defaultCountry?.code;
        if (countryCode != null) {
          _fetchEntityDetail(countryCode);
        }
      case Error():
      case Loading():
        state = state.copyWith(isLoadingCountries: false);
    }
  }

  void setSelectedCountry(Country country) {
    state = state.copyWith(selectedCountry: () => country);
    final countryCode = country.alpha2 ?? country.code2 ?? country.code;
    if (countryCode != null) {
      _fetchEntityDetail(countryCode);
    }
  }

  Future<void> _fetchEntityDetail(String countryCode) async {
    final request = EntityDetailRequest(countryCode: countryCode);
    final response = await _appRepository.getEntityDetail(request);

    switch (response) {
      case Success<EntityDetailResponse>():
        final data = response.data;
        if (data != null) {
          parseEntityDetailResponse(data, _sharedPref);
          _parseSetting(data.setting);
        }
      case Error():
      case Loading():
        break;
    }
  }

  void _parseSetting(Setting? setting) {
    if (setting == null) return;

    final loginBy = setting.entitySetting?.loginBy;
    if (loginBy == null) return;

    final showEmail = loginBy.email?.isNotEmpty == true;
    final showPhone = loginBy.phone?.isNotEmpty == true;

    final socialList = loginBy.social ?? [];
    final availableSocials = <SocialLoginProvider>[];
    if (socialList.contains(constants.LoginBy.google)) {
      availableSocials.add(SocialLoginProvider.google);
    }
    if (socialList.contains(constants.LoginBy.apple)) {
      availableSocials.add(SocialLoginProvider.apple);
    }

    final phoneList = loginBy.phone ?? [];
    final phoneAuths = <AuthMethod>[];
    if (phoneList.contains(constants.LoginBy.otp)) {
      phoneAuths.add(AuthMethod.otp);
    }
    if (phoneList.contains(constants.LoginBy.password)) {
      phoneAuths.add(AuthMethod.password);
    }

    final emailList = loginBy.email ?? [];
    final emailAuths = <AuthMethod>[];
    if (emailList.contains(constants.LoginBy.otp)) {
      emailAuths.add(AuthMethod.otp);
    }
    if (emailList.contains(constants.LoginBy.password)) {
      emailAuths.add(AuthMethod.password);
    }

    state = state.copyWith(
      showEmailLogin: showEmail,
      showPhoneLogin: showPhone,
      availableSocialLogins: availableSocials,
      phoneAuthMethods: phoneAuths.isNotEmpty ? phoneAuths : [AuthMethod.otp],
      emailAuthMethods: emailAuths.isNotEmpty ? emailAuths : [AuthMethod.otp],
    );
  }

  void setCurrentMethod(LoginMethod method) {
    state = state.copyWith(currentMethod: method, clearError: true, clearPhoneError: true, clearEmailError: true);
  }

  void setEmail(String email) {
    state = state.copyWith(email: email, clearError: true, clearEmailError: true);
  }

  void setPhoneNumber(String phoneNumber) {
    state = state.copyWith(
        phoneNumber: phoneNumber, clearPhoneError: true, clearError: true);
  }

  Future<CheckRegisteredResult> checkPhoneRegistered() async {
    if (!Validator.validPhoneNumber(state.phoneNumber).status) {
      state = state.copyWith(
        phoneError: getString(
            appStr.errorPleaseEnterPhoneNumber,
            'error_please_enter_phone_number'),
      );
      return CheckRegisteredResult.validationError;
    }
    if (!Validator.validPhoneNumberFormatForLogin(state.phoneNumber).status) {
      state = state.copyWith(
        phoneError: getString(
            appStr.errorPleaseEnterValidPhoneNumber,
            'error_please_enter_valid_phone_number'),
      );
      return CheckRegisteredResult.validationError;
    }

    state = state.copyWith(
        isLoading: true,
        loadingAction: 'phone',
        clearError: true,
        clearPhoneError: true);

    final request = CheckRegisteredRequest(
      loginBy: constants.LoginBy.phone,
      countryPhoneCode: state.selectedCountry?.displayPhoneCode,
      phone: state.phoneNumber,
    );

    final response = await _appRepository.checkRegistered(request);

    switch (response) {
      case Success():
        state = state.copyWith(isLoading: false);
        return CheckRegisteredResult.registered;
      case Error():
        state = state.copyWith(isLoading: false);
        return CheckRegisteredResult.notRegistered;
      case Loading():
        return CheckRegisteredResult.validationError;
    }
  }

  Future<CheckRegisteredResult> checkEmailRegistered() async {
    if (!Validator.validEmail(state.email).status) {
      state = state.copyWith(
        emailError: getString(appStr.errorPleaseEnterEmail, 'error_please_enter_email'),
      );
      return CheckRegisteredResult.validationError;
    }
    if (!Validator.validEmailFormat(state.email).status) {
      state = state.copyWith(
        emailError: getString(appStr.errorPleaseEnterValidEmail, 'error_please_enter_valid_email'),
      );
      return CheckRegisteredResult.validationError;
    }

    state = state.copyWith(
        isLoading: true,
        loadingAction: 'email',
        clearError: true,
        clearEmailError: true);

    final request = CheckRegisteredRequest(
      loginBy: constants.LoginBy.email,
      email: state.email,
    );

    final response = await _appRepository.checkRegistered(request);

    switch (response) {
      case Success():
        state = state.copyWith(isLoading: false);
        return CheckRegisteredResult.registered;
      case Error():
        state = state.copyWith(isLoading: false);
        return CheckRegisteredResult.notRegistered;
      case Loading():
        return CheckRegisteredResult.validationError;
    }
  }

  // --- Social Login ---

  Future<bool> loginWithSocial(String provider) async {
    state = state.copyWith(
      isLoading: true,
      loadingAction: provider,
      clearError: true,
      isSocialLoginSuccess: false,
      clearSocialData: true,
    );

    try {
      String? socialId;
      int loginBy;
      String? firstName;
      String? lastName;
      String? email;

      if (provider == 'google') {
        final result = await _signInWithGoogle();
        if (result == null) {
          state = state.copyWith(isLoading: false);
          return false;
        }
        socialId = result.socialId;
        loginBy = constants.LoginBy.google;
        firstName = result.firstName;
        lastName = result.lastName;
        email = result.email;
      } else if (provider == 'apple') {
        if (!Platform.isIOS) {
          state = state.copyWith(isLoading: false);
          return false;
        }
        final result = await _signInWithApple();
        if (result == null) {
          state = state.copyWith(isLoading: false);
          return false;
        }
        socialId = result.socialId;
        loginBy = constants.LoginBy.apple;
        firstName = result.firstName;
        lastName = result.lastName;
        email = result.email;
      } else {
        state = state.copyWith(isLoading: false);
        return false;
      }

      return await _checkAndSignInSocial(
        loginBy: loginBy,
        socialId: socialId,
        firstName: firstName,
        lastName: lastName,
        email: email,
      );
    } catch (e) {
      debugPrint('Social login error: $e');
      state = state.copyWith(
        isLoading: false,
        error: getString(appStr.errorSocialLoginFailed, 'error_social_login_failed'),
      );
      return false;
    }
  }

  /// Default Web OAuth client ID (same as Kotlin AppConstant.serverClientId)
  static const _defaultServerClientId =
      '58433708004-p7uu8f9jfu5acoc632hoj8cjkh4o2puh.apps.googleusercontent.com';

  Future<_SocialLoginResult?> _signInWithGoogle() async {
    final apiClientId = _sharedPref.getSetting()?.googleServerClientId;
    final serverClientId = (apiClientId?.isNotEmpty == true)
        ? apiClientId!
        : _defaultServerClientId;

    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(serverClientId: serverClientId);

    GoogleSignInAccount? account =
        await googleSignIn.attemptLightweightAuthentication();

    account ??= await googleSignIn.authenticate();

    final nameParts = (account.displayName ?? '').split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : null;
    final lastName =
        nameParts.length > 1 ? nameParts.sublist(1).join(' ') : null;

    final idToken = account.authentication.idToken;
    if (idToken == null) return null;

    return _SocialLoginResult(
      socialId: idToken,
      firstName: firstName,
      lastName: lastName,
      email: account.email,
    );
  }

  Future<_SocialLoginResult?> _signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final identityToken = credential.identityToken;
    if (identityToken == null) return null;

    return _SocialLoginResult(
      socialId: identityToken,
      firstName: credential.givenName,
      lastName: credential.familyName,
      email: credential.email,
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
        length, (_) => charset[random.nextInt(charset.length)]).join();
  }

  Future<bool> _checkAndSignInSocial({
    required int loginBy,
    required String socialId,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final checkRequest = CheckRegisteredRequest(
      loginBy: loginBy,
      socialId: socialId,
    );

    final checkResponse = await _appRepository.checkRegistered(checkRequest);

    switch (checkResponse) {
      case Success():
        return await _signInSocial(loginBy: loginBy, socialId: socialId);
      case Error():
        return await _signUpSocial(loginBy: loginBy, socialId: socialId);
      case Loading():
        return false;
    }
  }

  Future<bool> _signInSocial({
    required int loginBy,
    required String socialId,
  }) async {
    final signInRequest = SignInRequest(
      loginBy: loginBy,
      socialId: socialId,
    );

    final signInResponse = await _appRepository.signIn(signInRequest);

    switch (signInResponse) {
      case Success():
        await _fetchEntityDetail(
          _sharedPref.getEntity()?.countryCode ??
              DeviceInfoHelper.getDeviceCountry(),
        );
        await _sharedPref.setLoggedIn(true);
        _updateDeviceToken();
        _subscribeMassNotificationTopics();
        state = state.copyWith(
          isLoading: false,
          isSocialLoginSuccess: true,
        );
        return true;
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: signInResponse.error?.message ?? 'Sign in failed',
        );
        return false;
      case Loading():
        return false;
    }
  }

  Future<bool> _signUpSocial({
    required int loginBy,
    required String socialId,
  }) async {
    final signUpRequest = SignUpRequest(
      authMethod: loginBy,
      socialId: socialId,
    );

    final signUpResponse = await _appRepository.signUp(signUpRequest);

    switch (signUpResponse) {
      case Success():
        await _fetchEntityDetail(
          _sharedPref.getEntity()?.countryCode ??
              DeviceInfoHelper.getDeviceCountry(),
        );
        await _sharedPref.setLoggedIn(true);
        _updateDeviceToken();
        _subscribeMassNotificationTopics();
        state = state.copyWith(
          isLoading: false,
          isSocialLoginSuccess: true,
        );
        return true;
      case Error():
        state = state.copyWith(
          isLoading: false,
          error: signUpResponse.error?.message ?? 'Sign up failed',
        );
        return false;
      case Loading():
        return false;
    }
  }

  Future<void> _updateDeviceToken() async {
    String? fcmToken = NotificationManager.instance.fcmToken;
    if (fcmToken == null) {
      await Future.delayed(const Duration(seconds: 3));
      fcmToken = NotificationManager.instance.fcmToken;
    }
    if (fcmToken == null) return;

    debugPrint('🔔 Updating device token after login: $fcmToken');
    final request = FirebaseDeviceTokenRequest(deviceToken: fcmToken);
    await _appRepository.updateDeviceToken(request);
  }

  void _subscribeMassNotificationTopics() {
    final entity = _sharedPref.getEntity();
    FirebaseTopicManager.instance.subscribeToLoginTopics(
      cityId: entity?.cityId,
      countryId: entity?.countryId,
    );
  }
}

class _SocialLoginResult {
  final String socialId;
  final String? firstName;
  final String? lastName;
  final String? email;

  _SocialLoginResult({
    required this.socialId,
    this.firstName,
    this.lastName,
    this.email,
  });
}

final loginViewModelProvider =
    StateNotifierProvider.autoDispose<LoginViewModel, LoginState>((ref) {
  final appRepository = ref.watch(appRepositoryProvider);
  final sharedPref = ref.watch(sharedPreferenceManagerProvider).maybeWhen(
        data: (data) => data,
        orElse: () => throw Exception('SharedPreferences not initialized'),
      );
  return LoginViewModel(appRepository, sharedPref);
});
