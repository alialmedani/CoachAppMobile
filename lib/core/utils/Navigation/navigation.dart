import 'package:flutter/cupertino.dart';
import 'package:page_animation_transition/animations/left_to_right_faded_transition.dart';
import 'package:page_animation_transition/page_animation_transition.dart';
import 'package:coachappmobile/core/classes/keys.dart';

class Navigation {
  static bool isOpen = false;
  static Future? popThenPush(Widget page) async {
    Navigation.pop();
    return await Navigation.push(page);
  }

  static Future? push(Widget page) async {
    if (Keys.navigatorKey.currentContext != null) {
      return await Navigator.push(
        Keys.navigatorKey.currentContext!,
        PageAnimationTransition(
          page: page,
          pageAnimationType: LeftToRightFadedTransition(),
        ),
      );
    }
  }

  static Future<void> pop({dynamic value}) async {
    Navigator.pop(Keys.navigatorKey.currentContext!, value);
  }

  static Future? pushReplacement(Widget page) async {
    return await Navigator.pushReplacement(
      Keys.navigatorKey.currentContext!,
      PageAnimationTransition(
        page: page,
        pageAnimationType: LeftToRightFadedTransition(),
      ),
    );
  }

  static void popToRoot() {
    Navigator.popUntil(
      Keys.navigatorKey.currentContext!,
      (route) => route.isFirst,
    );
  }

  static Future? pushAndRemoveUntil(Widget page) async {
    return await Navigator.pushAndRemoveUntil(
      Keys.navigatorKey.currentContext!,
      CupertinoPageRoute(builder: (BuildContext context) => page),
      (Route<dynamic> route) => false,
    );
  }
}
