import '../../../models/responses/auth/entity_detail_response.dart' as models;

/// Global validator configuration
class ValidatorConfig {
  static String passwordRegex = '';
  static PasswordRule? passwordRule;
  static int phoneNumberMinLength = 6;
  static int phoneNumberMaxLength = 12;
  static int resendOtpTime = 30;

  /// Update config from typed entity detail setting
  static void updateFromSetting(models.Setting setting) {
    final rule = setting.passwordRule;
    if (rule != null) {
      passwordRule = PasswordRule(
        minLength: rule.minLength,
        requireNumbers: rule.requireNumbers,
        requireUppercase: rule.requireUppercase,
        requireLowercase: rule.requireLowercase,
        requireSpecial: rule.requireSpecial,
        regEx: rule.regEx,
      );
      passwordRegex = rule.regEx ?? '';
    }
    if (setting.minPhoneLength != null) {
      phoneNumberMinLength = setting.minPhoneLength!;
    }
    if (setting.maxPhoneLength != null) {
      phoneNumberMaxLength = setting.maxPhoneLength!;
    }
    final entitySetting = setting.entitySetting;
    if (entitySetting?.secOtpResendInterval != null) {
      resendOtpTime = entitySetting!.secOtpResendInterval!;
    }
  }
}

class PasswordRule {
  final int? minLength;
  final bool? requireNumbers;
  final bool? requireUppercase;
  final bool? requireLowercase;
  final bool? requireSpecial;
  final String? regEx;

  PasswordRule({
    this.minLength,
    this.requireNumbers,
    this.requireUppercase,
    this.requireLowercase,
    this.requireSpecial,
    this.regEx,
  });

  factory PasswordRule.fromJson(Map<String, dynamic> json) {
    return PasswordRule(
      minLength: json['minLength'] as int?,
      requireNumbers: json['requireNumbers'] as bool?,
      requireUppercase: json['requireUppercase'] as bool?,
      requireLowercase: json['requireLowercase'] as bool?,
      requireSpecial: json['requireSpecial'] as bool?,
      regEx: json['regEx'] as String?,
    );
  }
}

/// Validation result
class ValidationResult {
  final bool status;

  const ValidationResult(this.status);
}

/// Validator utility class
class Validator {
  Validator._();

  static ValidationResult validFirstName(String firstName) {
    return ValidationResult(firstName.isNotEmpty && firstName.isValidName());
  }

  static ValidationResult validLastName(String lastName) {
    return ValidationResult(lastName.isNotEmpty && lastName.isValidName());
  }

  static ValidationResult validEmail(String email) {
    return ValidationResult(email.isNotEmpty);
  }

  static ValidationResult validEmailFormat(String email) {
    return ValidationResult(email.isNotEmpty && email.isValidEmail());
  }

  static ValidationResult validCountryCode(String countryCode) {
    return ValidationResult(countryCode.isNotEmpty);
  }

  static ValidationResult validPhoneNumber(String phoneNumber) {
    return ValidationResult(phoneNumber.isNotEmpty);
  }

  static ValidationResult validPhoneNumberFormat(String phoneNumber) {
    return ValidationResult(phoneNumber.isNotEmpty && phoneNumber.isValidPhoneNumber());
  }

  static ValidationResult validPhoneNumberFormatForLogin(String phoneNumber) {
    return ValidationResult(phoneNumber.isNotEmpty && phoneNumber.isValidPhoneNumberForLogin());
  }

  static ValidationResult validPassword(String password) {
    return ValidationResult(password.isNotEmpty);
  }

  static ValidationResult validPasswordFormat(String password) {
    return ValidationResult(password.isNotEmpty && password.isValidPassword());
  }

  static ValidationResult validReferralCode(String referralCode) {
    return ValidationResult(referralCode.isNotEmpty);
  }

  static ValidationResult validOtp(String otp) {
    return ValidationResult(otp.isNotEmpty && otp.length >= 6);
  }

  static ValidationResult validLicense(String license) {
    return ValidationResult(license.trim().isNotEmpty);
  }
}

/// String extension methods for validation
extension StringValidation on String {
  bool isValidName() {
    return isNotEmpty && trim().split('').every((char) => RegExp(r'[a-zA-Z]').hasMatch(char));
  }

  bool isValidEmail() {
    final emailPattern = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,64}');
    return isNotEmpty && emailPattern.hasMatch(this);
  }

  bool isValidPhoneNumber() {
    return isNotEmpty &&
        length >= ValidatorConfig.phoneNumberMinLength &&
        length <= ValidatorConfig.phoneNumberMaxLength &&
        split('').every((char) => RegExp(r'[0-9]').hasMatch(char));
  }

  bool isValidPhoneNumberForLogin() {
    return isNotEmpty &&
        length >= 6 &&
        length <= 12 &&
        split('').every((char) => RegExp(r'[0-9]').hasMatch(char));
  }

  bool isValidPassword() {
    try {
      final regex = ValidatorConfig.passwordRegex.isNotEmpty
          ? RegExp(ValidatorConfig.passwordRegex)
          : RegExp(r'^.{6,}$');
      return isNotEmpty && regex.hasMatch(this);
    } catch (e) {
      return isNotEmpty && RegExp(r'^.{6,}$').hasMatch(this);
    }
  }

  String passwordValidationMessage() {
    final rules = ValidatorConfig.passwordRule;
    final minLength = rules?.minLength ?? 6;

    final errors = <String>[];

    if (length < minLength) {
      errors.add('at least $minLength characters long');
    }

    if ((rules?.requireNumbers ?? false) && !contains(RegExp(r'[0-9]'))) {
      errors.add('at least one number');
    }

    if ((rules?.requireUppercase ?? false) && !contains(RegExp(r'[A-Z]'))) {
      errors.add('at least one uppercase letter');
    }

    if ((rules?.requireLowercase ?? false) && !contains(RegExp(r'[a-z]'))) {
      errors.add('at least one lowercase letter');
    }

    if (rules?.requireSpecial ?? false) {
      final specialCharRegex = RegExp(r'''[!"#\$%&'()*+,\-./:;<=>?@\[\]^_`{|}~]''');
      if (!specialCharRegex.hasMatch(this)) {
        errors.add('at least one special character');
      }
    }

    if (errors.isEmpty) {
      return '';
    } else {
      return 'Password must have ${errors.join(', ')}';
    }
  }

  String generateHiddenPhoneNumber() {
    final visibleLength = length - 4;
    final hiddenLength = length - visibleLength;
    final buffer = StringBuffer();
    for (var i = 0; i < visibleLength; i++) {
      buffer.write('*');
    }
    buffer.write(substring(length - hiddenLength));
    return buffer.toString();
  }

  String generateHiddenEmail() {
    final emailParts = split('@');
    if (emailParts.length >= 2) {
      final hiddenLength = emailParts.first.length - 1;
      final buffer = StringBuffer();
      if (hiddenLength <= 0) {
        buffer.write(emailParts.first);
      } else {
        buffer.write(emailParts.first[0]);
      }
      for (var i = 0; i < hiddenLength; i++) {
        buffer.write('*');
      }
      buffer.write('@${emailParts.last}');
      return buffer.toString();
    }
    return this;
  }
}
