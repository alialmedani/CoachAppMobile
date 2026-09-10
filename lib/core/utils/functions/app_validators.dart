import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:coachappmobile/core/utils/functions/reg_exp.dart';

class AppValidators {
  static String? validateFillFields(BuildContext context, String? name) {
    if (name == null || name.trim().isEmpty) {
      return "field_required".tr();
    }
    return null;
  }

  static String? validatePasswordFields(
    BuildContext context,
    String? password,
  ) {
    if (password == null || password.isEmpty) {
      return "Fill field";
    } else if (AppRegexp.passwordRegex.hasMatch(password) == false) {
      return "password_regexp";
    }
    return null;
  }

  static String? validateRepeatPasswordFields(
    BuildContext context,
    String? password,
    String? repeatedPassword,
  ) {
    if (repeatedPassword == null || repeatedPassword.isEmpty) {
      return "Fill field";
    }
    if (password != repeatedPassword) {
      return "Must have the same password";
    }
    return null;
  }

  static String? validateEmailFields(BuildContext context, String? email) {
    if (email == null || email.isEmpty) {
      return "Fill field";
    } else if (AppRegexp.emailRegexp.hasMatch(email) == false) {
      return "email_regexp";
    }
    return null;
  }

  static String? validatePhoneFields(BuildContext context, String? phone) {
    if (phone == null || phone.isEmpty) {
      return "Fill field";
    }
    if (AppRegexp.phoneRegexp.hasMatch(phone) == false) {
      return "phone_regexp";
    }
    return null;
  }
}
