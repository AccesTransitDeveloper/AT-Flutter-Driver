import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/string_constants.dart';
import '../../../core/managers/permission_manager.dart';
import '../../../core/router/app_navigation.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/utils/snackbar_utils.dart';
import '../../../data/api/server_config.dart';
import '../../../viewmodels/settings_viewmodel.dart';
import '../../../views/widgets/app_button.dart';
import '../../../views/widgets/app_text_field.dart';
import '../../../views/widgets/app_scaffold.dart';
import '../../../views/widgets/app_text.dart';
import '../../../views/widgets/app_toolbar.dart';
import '../../bottomsheets/country_phone_code_bottom_sheet.dart';
import '../../bottomsheets/logout_bottom_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final state = ref.watch(settingsViewModelProvider);
    final viewModel = ref.read(settingsViewModelProvider.notifier);
    final entity = state.entity;

    final imageUrl = entity?.imageUrl != null && entity!.imageUrl!.isNotEmpty
        ? ServerConfig.getFullImageUrl(entity.imageUrl)
        : null;

    final fullName =
        '${entity?.firstName ?? ''} ${entity?.lastName ?? ''}'.trim();
    final phone = entity?.countryPhoneCode != null && entity?.phone != null
        ? '${entity!.countryPhoneCode} ${entity.phone}'
        : '';
    final email = entity?.email ?? '';

    ref.listen<SettingsState>(settingsViewModelProvider, (previous, next) {
      if (next.navigateToLogin) {
        viewModel.clearNavigationFlag();
        context.navigateToLogin();
      }
      if (next.snackBarMessage != null && next.snackBarMessage!.isNotEmpty) {
        context.showSnackBar(next.snackBarMessage!);
        viewModel.clearSnackBar();
      }
    });

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            AppToolbar(
              title: getString(appStr.headingSettings, 'heading_settings'),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile
                    _ProfileSection(
                      imageUrl: imageUrl,
                      fullName: fullName.isNotEmpty ? fullName : getString(appStr.descriptionDriver, 'description_driver'),
                      phone: phone,
                      email: email,
                      onTap: () async {
                        await context.navigateToProfile();
                        viewModel.refreshUserData();
                      },
                    ),

                    const _Divider(),

                    // Appearance
                    _SettingsMenuItem(
                      icon: Icons.dark_mode_outlined,
                      title: getString(
                          appStr.headingAppearance, 'heading_appearance'),
                      subtitle: state.themeDisplayName,
                      onTap: () =>
                          _showThemeBottomSheet(context, state, viewModel),
                    ),

                    const _Divider(),

                    // App Language
                    _SettingsMenuItem(
                      icon: Icons.language_outlined,
                      title: getString(
                          appStr.descriptionLanguage, 'description_language'),
                      subtitle: state.selectedLanguage.isNotEmpty
                          ? state.selectedLanguage
                          : null,
                      onTap: () =>
                          _showLanguageBottomSheet(context, viewModel),
                    ),

                    const _Divider(),

                    // Speaking Language
                    _SettingsMenuItem(
                      icon: Icons.record_voice_over_outlined,
                      title: getString(appStr.descriptionSpeakingLanguage,
                          'description_speaking_language'),
                      subtitle: state.selectedSpeakingLanguage.isNotEmpty
                          ? state.selectedSpeakingLanguage
                          : null,
                      onTap: () =>
                          _showSpeakingLanguageBottomSheet(context, viewModel),
                    ),

                    const _Divider(),

                    // Heat Map
                    _SettingsSwitchItem(
                      icon: Icons.map_outlined,
                      title: getString(
                          appStr.descriptionHeatMap, 'description_heat_map'),
                      value: state.isHeatMap,
                      onChanged: (_) => viewModel.toggleHeatMap(),
                    ),

                    const _Divider(),

                    // Navigation Map
                    _SettingsMenuItem(
                      icon: Icons.navigation_outlined,
                      title: getString(appStr.descriptionNavigationMap,
                          'description_navigation_map'),
                      subtitle:
                          _navigationMapDisplayName(state.navigationMap),
                      onTap: () => _showNavigationMapBottomSheet(
                          context, state, viewModel),
                    ),

                    const _Divider(),

                    // Emergency Contacts
                    _SettingsMenuItem(
                      icon: Icons.emergency_outlined,
                      title: getString(appStr.headingEmergencyContacts,
                          'heading_emergency_contacts'),
                      subtitle: state.emergencyContacts.isNotEmpty
                          ? '${state.emergencyContacts.length} contact${state.emergencyContacts.length == 1 ? '' : 's'}'
                          : null,
                      onTap: () => _showEmergencyContactsBottomSheet(
                          context, viewModel),
                    ),

                    const _Divider(),

                    // Going Home
                    _GoingHomeSection(
                      addressList: state.addressList,
                      isGoingToAddress: state.isGoingToAddress,
                      isLoading: state.isAddressLoading,
                      onToggle: (value) =>
                          viewModel.toggleGoingToAddress(value),
                      onDeleteAddress: (address) =>
                          viewModel.deleteAddress(address),
                      onAddAddress: () async {
                        final result =
                            await context.navigateToSelectLocation();
                        if (result != null) {
                          viewModel.addAddress(result);
                        }
                      },
                    ),

                    const _Divider(),

                    // Delete Account
                    _SettingsMenuItem(
                      icon: Icons.delete_outline,
                      title: getString(appStr.headingDeleteAccount,
                          'heading_delete_account'),
                      onTap: () => _showDeleteAccountBottomSheet(
                          context, state, viewModel),
                    ),

                    // Logout
                    _SettingsMenuItem(
                      icon: Icons.exit_to_app,
                      title: getString(
                          appStr.headingLogout, 'heading_logout'),
                      onTap: () =>
                          _showLogoutBottomSheet(context, viewModel),
                    ),

                    const SizedBox(height: AppDimens.paddingXL),

                    if (state.appVersion.isNotEmpty)
                      Center(
                        child: AppText.caption(
                          '${getString(appStr.descriptionAppVersion, 'description_app_version')} ${state.appVersion}',
                          color: colors.colorText,
                        ),
                      ),

                    const SizedBox(height: AppDimens.paddingXL),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _navigationMapDisplayName(String value) {
    switch (value) {
      case NavigationMapType.google:
        return getString(
            appStr.descriptionGoogleMap, 'description_google_map');
      case NavigationMapType.waze:
        return getString(
            appStr.descriptionWazeMap, 'description_waze_map');
      default:
        return getString(
            appStr.descriptionInAppGoogle, 'description_in_app_google');
    }
  }

  // ─── Theme ───────────────────────────────────────────────────────────────

  void _showThemeBottomSheet(
    BuildContext context,
    SettingsState state,
    SettingsViewModel viewModel,
  ) {
    final colors = context.colors;
    final themeNotifier = ref.read(themeProvider.notifier);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.title(getString(
                  appStr.descriptionSelectTheme, 'description_select_theme')),
              const SizedBox(height: AppDimens.padding),
              _SelectionOption(
                title: getString(
                    appStr.descriptionLightMode, 'description_light_mode'),
                isSelected: state.selectedTheme == AppThemeMode.light,
                onTap: () {
                  viewModel.setTheme(AppThemeMode.light);
                  themeNotifier.setThemeMode(AppThemeMode.light);
                  context.goBack();
                },
              ),
              _SelectionOption(
                title: getString(
                    appStr.descriptionDarkMode, 'description_dark_mode'),
                isSelected: state.selectedTheme == AppThemeMode.dark,
                onTap: () {
                  viewModel.setTheme(AppThemeMode.dark);
                  themeNotifier.setThemeMode(AppThemeMode.dark);
                  context.goBack();
                },
              ),
              _SelectionOption(
                title: getString(appStr.descriptionSystemDefault,
                    'description_system_default'),
                isSelected: state.selectedTheme == AppThemeMode.system,
                onTap: () {
                  viewModel.setTheme(AppThemeMode.system);
                  themeNotifier.setThemeMode(AppThemeMode.system);
                  context.goBack();
                },
              ),
              const SizedBox(height: AppDimens.paddingS),
            ],
          ),
        ),
      ),
    );
  }

  // ─── App Language ─────────────────────────────────────────────────────────

  void _showLanguageBottomSheet(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, child) {
            final currentState = ref.watch(settingsViewModelProvider);
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.padding),
                    child: AppText.title(getString(appStr.headingSelectLanguage,
                        'heading_select_language')),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding),
                      children: [
                        ...currentState.languageList
                            .asMap()
                            .entries
                            .map((entry) => _SelectionOption(
                                  title: entry.value.name,
                                  isSelected: entry.value.isSelected,
                                  onTap: () {
                                    viewModel.selectLanguage(entry.key);
                                    viewModel.applyLanguage();
                                    context.goBack();
                                  },
                                )),
                        const SizedBox(height: AppDimens.paddingS),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Speaking Language ────────────────────────────────────────────────────

  void _showSpeakingLanguageBottomSheet(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Consumer(
          builder: (context, ref, child) {
            final currentState = ref.watch(settingsViewModelProvider);
            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.padding),
                    child: AppText.title(getString(
                        appStr.descriptionSelectVerbalLanguage,
                        'description_select_verbal_language')),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.padding),
                      children: [
                        ...currentState.speakingLanguageList
                            .asMap()
                            .entries
                            .map((entry) => _SelectionOption(
                                  title: entry.value.name,
                                  isSelected: entry.value.isSelected,
                                  onTap: () => viewModel
                                      .selectSpeakingLanguage(entry.key),
                                )),
                        const SizedBox(height: AppDimens.paddingS),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppDimens.padding),
                    child: AppFilledButton(
                      text: getString(appStr.buttonDone, 'button_done'),
                      isLoading: currentState.isLanguageLoading,
                      onPressed: () async {
                        await viewModel.applySpeakingLanguage();
                        if (context.mounted) context.goBack();
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Navigation Map ───────────────────────────────────────────────────────

  void _showNavigationMapBottomSheet(
    BuildContext context,
    SettingsState state,
    SettingsViewModel viewModel,
  ) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.title(getString(appStr.descriptionNavigationMap,
                  'description_navigation_map')),
              const SizedBox(height: AppDimens.padding),
              _SelectionOption(
                title: getString(
                    appStr.descriptionInAppGoogle, 'description_in_app_google'),
                isSelected: state.navigationMap.isEmpty ||
                    state.navigationMap == NavigationMapType.inAppGoogle,
                onTap: () {
                  viewModel.setNavigationMap(NavigationMapType.inAppGoogle);
                  context.goBack();
                },
              ),
              _SelectionOption(
                title: getString(
                    appStr.descriptionGoogleMap, 'description_google_map'),
                isSelected:
                    state.navigationMap == NavigationMapType.google,
                onTap: () {
                  viewModel.setNavigationMap(NavigationMapType.google);
                  context.goBack();
                },
              ),
              _SelectionOption(
                title: getString(
                    appStr.descriptionWazeMap, 'description_waze_map'),
                isSelected: state.navigationMap == NavigationMapType.waze,
                onTap: () {
                  viewModel.setNavigationMap(NavigationMapType.waze);
                  context.goBack();
                },
              ),
              const SizedBox(height: AppDimens.paddingS),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Emergency Contacts List Sheet ───────────────────────────────────────

  void _showEmergencyContactsBottomSheet(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final colors = context.colors;
    final screenContext = this.context;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Consumer(
        builder: (context, ref, child) {
          final currentState = ref.watch(settingsViewModelProvider);
          final contacts = currentState.emergencyContacts;

          return DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.85,
            expand: false,
            builder: (context, scrollController) => SafeArea(
              top: false,
              child: Padding(
              padding: const EdgeInsets.all(AppDimens.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppText.title(getString(appStr.headingEmergencyContacts,
                          'heading_emergency_contacts')),
                      IconButton(
                        icon:
                            Icon(Icons.add, color: colors.colorPrimary),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          viewModel.showAddContactSheet();
                          _showAddEditContactBottomSheet(screenContext, viewModel);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingS),

                  // Body
                  if (currentState.isContactLoading)
                    const Expanded(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (contacts.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.contact_phone_outlined,
                                size: 48,
                                color: colors.colorTextHint),
                            const SizedBox(height: AppDimens.paddingM),
                            AppText.body(
                              getString(
                                  appStr.descriptionNoEmergencyContacts,
                                  'description_no_emergency_contacts'),
                              color: colors.colorTextHint,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: contacts.length,
                        separatorBuilder: (_, _) => Divider(
                          height: 1,
                          color: colors.colorBackgroundGray,
                        ),
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          return _EmergencyContactTile(
                            contact: contact,
                            onEdit: () {
                              viewModel.showAddContactSheet(contact: contact);
                              _showAddEditContactBottomSheet(screenContext, viewModel);
                            },
                            onDelete: () =>
                                viewModel.deleteEmergencyContact(index),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }

  // ─── Add / Edit Contact Sheet ─────────────────────────────────────────────

  void _showAddEditContactBottomSheet(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _AddContactSheetContent(
        viewModel: viewModel,
        onPickContact: _pickDeviceContact,
      ),
    ).whenComplete(() {
      viewModel.hideAddContactSheet();
    });
  }

  Future<({String name, String phone})?> _pickDeviceContact() async {
    final result = await PermissionManager.instance.requestContacts();
    if (result != PermissionResult.granted) return null;

    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
      sorted: true,
    );

    final contactsWithPhone = contacts.where((c) => c.phones.isNotEmpty).toList();
    if (contactsWithPhone.isEmpty || !mounted) return null;

    final selected = await showModalBottomSheet<Contact>(
      context: context,
      backgroundColor: context.colors.colorBackground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ContactPickerSheet(contacts: contactsWithPhone),
    );

    if (selected != null) {
      final name = selected.displayName;
      final phone = selected.phones.first.number.replaceAll(RegExp(r'[^\d]'), '');
      return (name: name, phone: phone);
    }
    return null;
  }

  // ─── Delete Account ───────────────────────────────────────────────────────

  void _showDeleteAccountBottomSheet(
    BuildContext context,
    SettingsState state,
    SettingsViewModel viewModel,
  ) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.title(getString(
                  appStr.headingDeleteAccount, 'heading_delete_account')),
              const SizedBox(height: AppDimens.paddingS),
              AppText.body(
                getString(appStr.descriptionDeleteAccount,
                    'description_delete_account'),
                color: colors.colorText,
              ),
              const SizedBox(height: AppDimens.paddingXL),
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      text: getString(
                          appStr.buttonCancel, 'button_cancel'),
                      onPressed: () => context.goBack(),
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingM),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final s = ref.watch(settingsViewModelProvider);
                        return AppFilledButton(
                          text: getString(
                              appStr.descriptionDelete, 'description_delete'),
                          onPressed: s.isDeleteLoading
                              ? null
                              : () {
                                  viewModel.confirmDeleteAccount();
                                  final currentState = ref.read(settingsViewModelProvider);
                                  context.goBack();
                                  if (currentState.deleteStep == DeleteStep.authOptions) {
                                    _showAuthenticationOptionsSheet(this.context, viewModel);
                                  }
                                },
                          isLoading: s.isDeleteLoading,
                          backgroundColor: colors.colorWarning,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.paddingS),
            ],
          ),
        ),
      ),
    );
  }

  void _showAuthenticationOptionsSheet(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding),
          child: Consumer(
            builder: (context, ref, child) {
              final s = ref.watch(settingsViewModelProvider);
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.title(getString(
                      appStr.headingVerifyIdentity, 'heading_verify_identity')),
                  const SizedBox(height: AppDimens.paddingS),
                  AppText.body(
                    getString(appStr.descriptionSelectVerificationMethod,
                        'description_select_verification_method'),
                    color: colors.colorText,
                  ),
                  const SizedBox(height: AppDimens.paddingM),
                  ...s.authenticationOptions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppDimens.paddingS),
                      child: InkWell(
                        onTap: () => viewModel.selectAuthenticationOption(index),
                        borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimens.paddingM),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                            border: Border.all(
                              color: option.isSelected
                                  ? colors.colorPrimary
                                  : colors.colorText.withValues(alpha: 0.2),
                              width: option.isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                option.isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: option.isSelected
                                    ? colors.colorPrimary
                                    : colors.colorText,
                                size: 20,
                              ),
                              const SizedBox(width: AppDimens.paddingM),
                              Expanded(
                                child: AppText.body(option.name),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppDimens.paddingM),
                  Row(
                    children: [
                      Expanded(
                        child: AppOutlinedButton(
                          text: getString(appStr.buttonCancel, 'button_cancel'),
                          onPressed: () {
                            viewModel.resetDeleteState();
                            sheetContext.goBack();
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimens.paddingM),
                      Expanded(
                        child: AppFilledButton(
                          text: getString(appStr.buttonConfirm, 'button_confirm'),
                          isLoading: s.isDeleteLoading,
                          onPressed: s.isDeleteLoading
                              ? null
                              : () {
                                  viewModel.confirmAuthenticationOption();
                                  final currentState = ref.read(settingsViewModelProvider);
                                  if (currentState.deleteStep == DeleteStep.password) {
                                    sheetContext.goBack();
                                    _showVerifyPasswordSheet(this.context, viewModel);
                                  } else if (currentState.deleteStep == DeleteStep.otp) {
                                    sheetContext.goBack();
                                    _showVerifyOtpSheet(this.context, viewModel);
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimens.paddingS),
                ],
              );
            },
          ),
        ),
      ),
    ).whenComplete(() {
      // If user dismisses by swiping, reset state
      final currentState = ref.read(settingsViewModelProvider);
      if (currentState.deleteStep == DeleteStep.authOptions) {
        viewModel.resetDeleteState();
      }
    });
  }

  void _showVerifyPasswordSheet(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final colors = context.colors;
    final passwordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppDimens.padding,
            right: AppDimens.padding,
            top: AppDimens.padding,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppDimens.padding,
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final s = ref.watch(settingsViewModelProvider);
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.title(getString(
                        appStr.headingVerifyPassword, 'heading_verify_password')),
                    const SizedBox(height: AppDimens.paddingS),
                    AppText.body(
                      getString(appStr.descriptionEnterPasswordToDelete,
                          'description_enter_password_to_delete'),
                      color: colors.colorText,
                    ),
                    const SizedBox(height: AppDimens.paddingM),
                    AppTextField(
                      controller: passwordController,
                      hintText: getString(
                          appStr.hintEnterPassword, 'hint_enter_password'),
                      obscureText: true,
                      onChanged: viewModel.updateDeletePassword,
                    ),
                    const SizedBox(height: AppDimens.paddingXL),
                    Row(
                      children: [
                        Expanded(
                          child: AppOutlinedButton(
                            text: getString(appStr.buttonCancel, 'button_cancel'),
                            onPressed: () {
                              viewModel.resetDeleteState();
                              sheetContext.goBack();
                            },
                          ),
                        ),
                        const SizedBox(width: AppDimens.paddingM),
                        Expanded(
                          child: AppFilledButton(
                            text: getString(
                                appStr.descriptionDelete, 'description_delete'),
                            isLoading: s.isDeleteLoading,
                            backgroundColor: colors.colorWarning,
                            onPressed: s.isDeleteLoading
                                ? null
                                : () => viewModel.verifyPasswordAndDelete(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.paddingS),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ).whenComplete(() {
      final currentState = ref.read(settingsViewModelProvider);
      if (currentState.deleteStep == DeleteStep.password) {
        viewModel.resetDeleteState();
      }
    });
  }

  void _showVerifyOtpSheet(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final colors = context.colors;
    final otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: AppDimens.padding,
            right: AppDimens.padding,
            top: AppDimens.padding,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppDimens.padding,
          ),
          child: Consumer(
            builder: (context, ref, child) {
              final s = ref.watch(settingsViewModelProvider);
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.title(getString(
                        appStr.headingVerifyOtp, 'heading_verify_otp')),
                    const SizedBox(height: AppDimens.paddingS),
                    AppText.body(
                      getString(appStr.descriptionOtpSentTo, 'description_otp_sent_to')
                          .replacePlaceholders({StringConstant.param: s.otpSendTo}),
                      color: colors.colorText,
                    ),
                    const SizedBox(height: AppDimens.paddingM),
                    AppTextField(
                      controller: otpController,
                      hintText: getString(
                          appStr.hintEnterOtp, 'hint_enter_otp'),
                      keyboardType: TextInputType.number,
                      onChanged: viewModel.updateDeleteOtp,
                    ),
                    const SizedBox(height: AppDimens.paddingS),
                    Align(
                      alignment: Alignment.centerRight,
                      child: s.resendOtpTimer > 0
                          ? AppText.caption(
                              '${getString(appStr.buttonResendOtp, 'button_resend_otp')} (${s.resendOtpTimer}s)',
                              color: colors.colorTextHint,
                            )
                          : GestureDetector(
                              onTap: viewModel.resendDeleteOtp,
                              child: AppText.caption(
                                getString(appStr.buttonResendOtp, 'button_resend_otp'),
                                color: colors.colorPrimary,
                              ),
                            ),
                    ),
                    const SizedBox(height: AppDimens.paddingXL),
                    Row(
                      children: [
                        Expanded(
                          child: AppOutlinedButton(
                            text: getString(appStr.buttonCancel, 'button_cancel'),
                            onPressed: () {
                              viewModel.resetDeleteState();
                              sheetContext.goBack();
                            },
                          ),
                        ),
                        const SizedBox(width: AppDimens.paddingM),
                        Expanded(
                          child: AppFilledButton(
                            text: getString(appStr.buttonVerify, 'button_verify'),
                            isLoading: s.isDeleteLoading,
                            onPressed: s.isDeleteLoading
                                ? null
                                : () => viewModel.verifyOtpAndDelete(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimens.paddingS),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ).whenComplete(() {
      final currentState = ref.read(settingsViewModelProvider);
      if (currentState.deleteStep == DeleteStep.otp) {
        viewModel.resetDeleteState();
      }
    });
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  void _showLogoutBottomSheet(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final colors = context.colors;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final s = ref.watch(settingsViewModelProvider);
          return LogoutBottomSheet(
            isLoading: s.isLogoutLoading,
            onLogout: viewModel.logout,
          );
        },
      ),
    );
  }
}

// ─── Add Contact Sheet Content (ConsumerStatefulWidget) ───────────────────

class _AddContactSheetContent extends ConsumerStatefulWidget {
  final SettingsViewModel viewModel;
  final Future<({String name, String phone})?> Function() onPickContact;

  const _AddContactSheetContent({
    required this.viewModel,
    required this.onPickContact,
  });

  @override
  ConsumerState<_AddContactSheetContent> createState() =>
      _AddContactSheetContentState();
}

class _AddContactSheetContentState
    extends ConsumerState<_AddContactSheetContent> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final s = ref.read(settingsViewModelProvider);
    _nameController = TextEditingController(text: s.contactName);
    _phoneController = TextEditingController(text: s.contactPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentState = ref.watch(settingsViewModelProvider);
    final isEditing = currentState.editingContactId != null;

    // Auto-close when state signals sheet should close
    ref.listen<SettingsState>(settingsViewModelProvider, (previous, next) {
      if (previous?.showAddContactBottomSheet == true &&
          !next.showAddContactBottomSheet) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }

      // Show country phone code picker from this sheet's context (not parent)
      if (next.showContactCountryPhoneCodeBottomSheet &&
          previous?.showContactCountryPhoneCodeBottomSheet != true) {
        CountryPhoneCodeBottomSheet.show(
          context,
          phoneCodeList: next.multiplePhoneCodeCountryList,
          selectedPhoneCode: next.contactCountryCode,
          onPhoneCodeSelected: (country) {
            widget.viewModel.updateContactCountryPhoneCode(country);
          },
        ).then((_) => widget.viewModel.dismissContactCountryPhoneCodeBottomSheet());
      }
    });

    // Sync controllers with state (e.g. after contact picker fills fields)
    if (_nameController.text != currentState.contactName) {
      _nameController.value = TextEditingValue(
        text: currentState.contactName,
        selection: TextSelection.collapsed(offset: currentState.contactName.length),
      );
    }
    if (_phoneController.text != currentState.contactPhone) {
      _phoneController.value = TextEditingValue(
        text: currentState.contactPhone,
        selection: TextSelection.collapsed(offset: currentState.contactPhone.length),
      );
    }

    final title = isEditing
        ? getString(null, 'heading_update_emergency_contact')
        : getString(appStr.headingAddEmergencyContact, 'heading_add_emergency_contact');

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: AppDimens.padding,
          right: AppDimens.padding,
          top: AppDimens.padding,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppDimens.padding,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText.title(title),
              const SizedBox(height: AppDimens.paddingXL),

              // Name
              AppTextField(
                controller: _nameController,
                hintText: getString(
                    appStr.descriptionProfileName, 'description_profile_name'),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.name,
                onChanged: widget.viewModel.updateContactName,
              ),
              const SizedBox(height: AppDimens.paddingM),

              // Phone with country code picker
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      widget.viewModel.toggleContactCountryPhoneCodeBottomSheet();
                    },
                    child: Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: colors.colorBackgroundGray,
                        borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            currentState.contactCountryCode.isNotEmpty
                                ? currentState.contactCountryCode
                                : '+',
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.colorText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 18,
                            color: colors.colorText,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimens.paddingS),
                  Expanded(
                    child: AppTextField(
                      controller: _phoneController,
                      hintText: getString(appStr.descriptionPhone, 'description_phone'),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.phone,
                      onChanged: widget.viewModel.updateContactPhone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimens.paddingM),

              // Pick from contacts
              TextButton.icon(
                onPressed: () async {
                  final picked = await widget.onPickContact();
                  if (picked != null && mounted) {
                    widget.viewModel.updateContactName(picked.name);
                    widget.viewModel.updateContactPhone(picked.phone);
                  }
                },
                icon: Icon(Icons.contacts_outlined, color: colors.colorPrimary),
                label: Text(
                  getString(null, 'button_pick_from_contacts'),
                  style: TextStyle(color: colors.colorPrimary),
                ),
              ),
              const SizedBox(height: AppDimens.paddingXL),

              SizedBox(
                width: double.infinity,
                child: AppFilledButton(
                  text: isEditing
                      ? getString(appStr.buttonUpdate, 'button_update')
                      : getString(appStr.buttonAddContact, 'button_add_contact'),
                  isLoading: currentState.isContactLoading,
                  onPressed: currentState.isContactLoading
                      ? null
                      : () => widget.viewModel.saveEmergencyContact(),
                ),
              ),
              const SizedBox(height: AppDimens.paddingS),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Emergency Contact Tile ────────────────────────────────────────────────

class _EmergencyContactTile extends StatelessWidget {
  final EmergencyContactItem contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EmergencyContactTile({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: AppDimens.paddingS),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.colorBackgroundGray,
            child: Icon(Icons.person_outline,
                color: colors.colorText, size: 20),
          ),
          const SizedBox(width: AppDimens.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.body(contact.name, fontWeight: FontWeight.w500),
                if (contact.phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  AppText.caption(
                    '${contact.countryPhoneCode} ${contact.phone}'.trim(),
                    color: colors.colorTextHint,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined,
                size: 20, color: colors.colorPrimary),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(AppDimens.paddingS),
            onPressed: onEdit,
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: 20, color: colors.colorWarning),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(AppDimens.paddingS),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─── Contact Picker Sheet ──────────────────────────────────────────────────

class _ContactPickerSheet extends StatefulWidget {
  final List<Contact> contacts;

  const _ContactPickerSheet({required this.contacts});

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  late List<Contact> _filteredContacts;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredContacts = widget.contacts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      _filteredContacts = query.isEmpty
          ? widget.contacts
          : widget.contacts
              .where((c) => c.displayName.toLowerCase().contains(query.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding),
          child: Column(
            children: [
              AppTextField(
                controller: _searchController,
                hintText: getString(null, 'hint_search_contacts'),
                prefixIcon: Icon(Icons.search, color: colors.colorTextHint),
                onChanged: _onSearch,
              ),
              const SizedBox(height: AppDimens.paddingM),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _filteredContacts[index];
                    final phone = contact.phones.isNotEmpty
                        ? contact.phones.first.number
                        : '';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colors.colorBackgroundGray,
                        child: Icon(Icons.person, color: colors.colorText, size: 20),
                      ),
                      title: AppText.body(contact.displayName),
                      subtitle: phone.isNotEmpty
                          ? AppText.caption(phone, color: colors.colorTextHint)
                          : null,
                      onTap: () => Navigator.pop(context, contact),
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Going Home Section ────────────────────────────────────────────────────

class _GoingHomeSection extends StatelessWidget {
  final List<SavedAddressItem> addressList;
  final bool isGoingToAddress;
  final bool isLoading;
  final ValueChanged<bool> onToggle;
  final void Function(SavedAddressItem) onDeleteAddress;
  final VoidCallback onAddAddress;

  const _GoingHomeSection({
    required this.addressList,
    required this.isGoingToAddress,
    required this.isLoading,
    required this.onToggle,
    required this.onDeleteAddress,
    required this.onAddAddress,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.all(AppDimens.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home_outlined,
                  color: colors.colorText, size: AppDimens.iconSize),
              const SizedBox(width: AppDimens.padding),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText.body(
                      getString(appStr.descriptionSettingsGoingHome,
                          'description_settings_going_home'),
                      fontWeight: FontWeight.w500,
                    ),
                    AppText.caption(
                      getString(
                          appStr.descriptionSettingsGoingHomeDescription,
                          'description_settings_going_home_description'),
                      color: colors.colorText,
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else if (addressList.isNotEmpty)
                Switch(
                  value: isGoingToAddress,
                  onChanged: onToggle,
                  activeThumbColor: colors.colorPrimary,
                ),
            ],
          ),
          if (addressList.isNotEmpty) ...[
            const SizedBox(height: AppDimens.paddingS),
            ...addressList.map((addr) => _AddressTile(
                  address: addr,
                  onDelete: () => onDeleteAddress(addr),
                )),
          ],
          const SizedBox(height: AppDimens.paddingM),
          GestureDetector(
            onTap: onAddAddress,
            child: Row(
              children: [
                Icon(Icons.add_location_alt_outlined,
                    size: AppDimens.iconSizeSmall, color: colors.colorPrimary),
                const SizedBox(width: AppDimens.paddingS),
                AppText.body(
                  getString(
                      appStr.descriptionAddAddress, 'description_add_address'),
                  color: colors.colorPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  final SavedAddressItem address;
  final VoidCallback onDelete;

  const _AddressTile({required this.address, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(top: AppDimens.paddingS),
      child: Row(
        children: [
          Icon(
            address.isSelected
                ? Icons.location_on
                : Icons.location_on_outlined,
            size: AppDimens.iconSizeSmall,
            color: address.isSelected
                ? colors.colorPrimary
                : colors.colorText,
          ),
          const SizedBox(width: AppDimens.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (address.title.isNotEmpty &&
                    address.title != address.address)
                  AppText.body(address.title,
                      fontWeight: FontWeight.w500),
                AppText.caption(address.address, color: colors.colorText),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline,
                size: AppDimens.iconSizeSmall, color: colors.colorWarning),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(AppDimens.paddingS),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ─── Shared Private Widgets ────────────────────────────────────────────────

class _ProfileSection extends StatelessWidget {
  final String? imageUrl;
  final String fullName;
  final String phone;
  final String email;
  final VoidCallback onTap;

  const _ProfileSection({
    required this.imageUrl,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.padding),
        child: Row(
          children: [
            if (imageUrl != null)
              CachedNetworkImage(
                imageUrl: imageUrl!,
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 32,
                  backgroundImage: imageProvider,
                ),
                placeholder: (context, url) => CircleAvatar(
                  radius: 32,
                  backgroundColor: colors.colorBackgroundGray,
                  child: Icon(Icons.person,
                      size: 32, color: colors.colorText),
                ),
                errorWidget: (context, url, error) => CircleAvatar(
                  radius: 32,
                  backgroundColor: colors.colorBackgroundGray,
                  child: Icon(Icons.person,
                      size: 32, color: colors.colorText),
                ),
              )
            else
              CircleAvatar(
                radius: 32,
                backgroundColor: colors.colorBackgroundGray,
                child: Icon(Icons.person,
                    size: 32, color: colors.colorText),
              ),
            const SizedBox(width: AppDimens.padding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.body(fullName, fontWeight: FontWeight.w600),
                  if (phone.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.paddingXS),
                    AppText.caption(phone, color: colors.colorText),
                  ],
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: AppDimens.paddingXS),
                    AppText.caption(email, color: colors.colorText),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.colorText),
          ],
        ),
      ),
    );
  }
}

class _SettingsMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SettingsMenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.padding,
          vertical: AppDimens.paddingM,
        ),
        child: Row(
          children: [
            Icon(icon, color: colors.colorText, size: AppDimens.iconSize),
            const SizedBox(width: AppDimens.padding),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.body(title, fontWeight: FontWeight.w500),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    AppText.caption(
                      subtitle!,
                      color: colors.colorText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.colorText),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.padding,
        vertical: AppDimens.paddingM,
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.colorText, size: AppDimens.iconSize),
          const SizedBox(width: AppDimens.padding),
          Expanded(
            child: AppText.body(title, fontWeight: FontWeight.w500),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: colors.colorPrimary,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: context.colors.colorBackgroundGray,
    );
  }
}

class _SelectionOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: AppDimens.paddingM),
        child: Row(
          children: [
            Expanded(child: AppText.body(title)),
            if (isSelected) Icon(Icons.check, color: colors.colorPrimary),
          ],
        ),
      ),
    );
  }
}
