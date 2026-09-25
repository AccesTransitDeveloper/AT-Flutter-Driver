import '../preferences/shared_preference_manager.dart';
import '../../models/responses/auth/entity_detail_response.dart';
import 'validator/validator.dart';

/// Parse and store entity detail response data
void parseEntityDetailResponse(
  EntityDetailResponse? entityDetailResponse,
  SharedPreferenceManager sharedPref,
) {
  if (entityDetailResponse == null) return;

  final setting = entityDetailResponse.setting;
  if (setting != null) {
    sharedPref.setSetting(setting);
    // Update validator config from setting
    ValidatorConfig.updateFromSetting(setting);
  }

  final entity = entityDetailResponse.entity;
  if (entity != null) {
    sharedPref.setEntity(entity);
    setAppLanguage(
      sharedPref: sharedPref,
      languageCode: entity.preferredLanguage ?? 'en',
    );
  }
}

/// Set app language in shared preferences
void setAppLanguage({
  required SharedPreferenceManager sharedPref,
  required String languageCode,
}) {
  sharedPref.setLanguage(languageCode);
}
