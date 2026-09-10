import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

var customFooter = CustomFooter(
  builder: (BuildContext? context, LoadStatus? mode) {
    Widget body;
    if (mode == LoadStatus.idle) {
      body = const Text("");
    } else if (mode == LoadStatus.loading) {
      body = const CupertinoActivityIndicator();
    } else if (mode == LoadStatus.failed) {
      body = const Text("");
    } else if (mode == LoadStatus.canLoading) {
      body = const Text("");
    } else {
      body = const Text("");
    }
    return SizedBox(height: 55.0, child: Center(child: body));
  },
);
