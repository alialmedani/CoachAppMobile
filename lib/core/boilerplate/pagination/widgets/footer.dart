import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Pagination footer for [SmartRefresher]. Shows a spinner while loading the
/// next page and, on a load-more failure, a localized "couldn't load more"
/// message (SmartRefresher makes the failed footer tappable to retry; pulling
/// up again also retries).
var customFooter = CustomFooter(
  builder: (BuildContext? context, LoadStatus? mode) {
    Widget body;
    if (mode == LoadStatus.loading) {
      body = const CupertinoActivityIndicator();
    } else if (mode == LoadStatus.failed) {
      body = Text(
        'load_more_failed'.tr(),
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 13),
      );
    } else {
      body = const Text("");
    }
    return SizedBox(height: 55.0, child: Center(child: body));
  },
);
