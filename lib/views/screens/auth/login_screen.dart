import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodels/auth/login_viewmodel.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../viewmodels/auth/register_viewmodel.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_divider.dart';
import '../../widgets/multi_tap_detector.dart';
import '../../widgets/move_server_bottom_sheet.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onEmailContinuePressed(
    LoginState loginState,
    LoginViewModel loginNotifier,
  ) async {
    FocusScope.of(context).unfocus();

    final result = await loginNotifier.checkEmailRegistered();
    if (!mounted) return;

    switch (result) {
      case CheckRegisteredResult.registered:
        context.navigateToVerificationEmail(
          email: loginState.email,
          supportsOtp: loginState.emailSupportsOtp,
          supportsPassword: loginState.emailSupportsPassword,
        );
      case CheckRegisteredResult.notRegistered:
        context.navigateToAtAiDriver(
          origin: RegisterOrigin.email,
          email: loginState.email,
          countries: loginState.countries,
          selectedCountry: loginState.selectedCountry,
        );
      case CheckRegisteredResult.validationError:
        break;
    }
  }

  Future<void> _onSocialLoginPressed(String provider) async {
    FocusScope.of(context).unfocus();

    final loginNotifier = ref.read(loginViewModelProvider.notifier);
    await loginNotifier.loginWithSocial(provider);
    if (!mounted) return;

    final loginState = ref.read(loginViewModelProvider);
    if (loginState.isSocialLoginSuccess) {
      context.navigateToHome();
    }
  }

  bool _showAppleButton(LoginState loginState) =>
      loginState.showAppleLogin && Platform.isIOS;

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginViewModelProvider);
    final loginNotifier = ref.read(loginViewModelProvider.notifier);
    final colors = context.colors;

    return AppScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppDimens.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimens.paddingXL),

              // Header
              MultiTapDetector(
                onMultiTap: () => showMoveServerBottomSheet(context, ref),
                child: AppText.heading(
                  getString(
                    appStr.headingEnterYourEmail,
                    'heading_enter_your_email',
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.paddingXXL),

              // Email input
              AppTextField(
                controller: _emailController,
                hintText: getString(
                  appStr.hintEmailExample,
                  'hint_email_example',
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: loginNotifier.setEmail,
              ),

              if (loginState.emailError != null) ...[
                const SizedBox(height: AppDimens.paddingS),
                AppText.caption(
                  loginState.emailError!,
                  color: colors.colorWarning,
                ),
              ],

              const SizedBox(height: AppDimens.paddingXL),

              // Continue button
              AppFilledButton(
                text: getString(appStr.buttonContinue, 'button_continue'),
                isLoading: loginState.loadingAction == 'phone',
                onPressed: loginState.email.isNotEmpty
                    ? () => _onEmailContinuePressed(loginState, loginNotifier)
                    : null,
              ),

              // OR divider + social/phone buttons
              if (loginState.showPhoneLogin ||
                  loginState.showGoogleLogin ||
                  _showAppleButton(loginState)) ...[
                const SizedBox(height: AppDimens.paddingXL),
                const AppDivider.or(),
                const SizedBox(height: AppDimens.paddingXL),
              ],

              if (loginState.showGoogleLogin)
                AppFilledIconButton(
                  text: getString(
                    appStr.buttonContinueWithGoogle,
                    'button_continue_with_google',
                  ),
                  icon: Icon(
                    Icons.g_mobiledata,
                    size: AppDimens.iconSizeLarge,
                    color: colors.colorText,
                  ),
                  backgroundColor: colors.colorBackgroundGray,
                  borderColor: Colors.transparent,
                  isLoading: loginState.loadingAction == 'google',
                  onPressed: () => _onSocialLoginPressed('google'),
                ),

              if (loginState.showGoogleLogin && _showAppleButton(loginState))
                const SizedBox(height: AppDimens.paddingM),

              if (_showAppleButton(loginState))
                AppFilledIconButton(
                  text: getString(
                    appStr.buttonContinueWithApple,
                    'button_continue_with_apple',
                  ),
                  icon: Icon(
                    Icons.apple,
                    size: AppDimens.iconSize,
                    color: colors.colorText,
                  ),
                  backgroundColor: colors.colorBackgroundGray,
                  borderColor: Colors.transparent,
                  isLoading: loginState.loadingAction == 'apple',
                  onPressed: () => _onSocialLoginPressed('apple'),
                ),

              if ((loginState.showGoogleLogin ||
                      _showAppleButton(loginState)) &&
                  loginState.showPhoneLogin)
                const SizedBox(height: AppDimens.paddingM),

              if (loginState.showPhoneLogin)
                AppFilledIconButton(
                  text: getString(
                    appStr.buttonContinueWithPhone,
                    'button_continue_with_phone',
                  ),
                  icon: Icon(
                    Icons.phone_outlined,
                    size: AppDimens.iconSize,
                    color: colors.colorText,
                  ),
                  backgroundColor: colors.colorBackgroundGray,
                  borderColor: Colors.transparent,
                  isLoading: loginState.loadingAction == 'email',
                  onPressed: () => context.navigateToVerificationPhone(
                    countries: loginState.countries,
                    selectedCountry: loginState.selectedCountry,
                    supportsOtp: loginState.phoneSupportsOtp,
                    supportsPassword: loginState.phoneSupportsPassword,
                  ),
                ),

              // Error message
              if (loginState.error != null) ...[
                const SizedBox(height: AppDimens.padding),
                AppText.caption(
                  loginState.error!,
                  color: colors.colorWarning,
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AppDimens.paddingXXL),

              // Terms and privacy
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppDimens.paddingL),
                  child: AppText.caption(
                    getString(
                      appStr.descriptionByContinuingYouAgree,
                      'description_by_continuing_you_agree',
                    ),
                    color: colors.colorText,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
