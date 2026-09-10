// import 'package:flutter/material.dart';

// import '../classes/keys.dart';
// import '../ui/screens/driver_order_deeplink_screen.dart';
// import '../ui/screens/splash_screen.dart';
// import '../../features/Express/driver/screen/my_orders_screen.dart';
// import '../../features/Express/user/order/screen/order_details_screen.dart';

// /// Centralized routing for a tapped notification (push or in-app list item).
// ///
// /// The backend encodes the recipient's portal in the deep link
// /// (e.g. "/driver/orders/{id}", "/merchant/orders/{id}"), so we route by that
// /// portal instead of blindly opening the merchant order screen for everyone.
// /// All target screens rely on the app-root MultiBlocProvider, so pushing them
// /// on the root navigator is safe.
// class NotificationRouter {
//   const NotificationRouter._();

//   /// Route a notification. [orderId] / [deepLink] come from the FCM data map or
//   /// the in-app NotificationItemModel. Set [fallbackToHome] to false for in-app
//   /// taps (the user is already inside the app, so don't bounce through splash).
//   static void open({
//     String? orderId,
//     String? deepLink,
//     bool fallbackToHome = true,
//   }) {
//     final nav = Keys.navigatorKey.currentState;
//     if (nav == null) return;

//     final id = orderId?.trim();
//     final portal = _portalOf(deepLink);

//     // Drivers → open the SPECIFIC assigned order via the driver-centric actions
//     // screen. That screen needs the full OrderModel, so the bridge screen fetches
//     // it by id first. With no orderId, fall back to the orders list. (The merchant
//     // OrderDetailsScreen would be the wrong screen for a driver.)
//     if (portal == _Portal.driver) {
//       if (id != null && id.isNotEmpty) {
//         nav.push(
//           MaterialPageRoute(builder: (_) => DriverOrderDeepLinkScreen(orderId: id)),
//         );
//       } else {
//         nav.push(MaterialPageRoute(builder: (_) => const MyOrdersScreen()));
//       }
//       return;
//     }

//     // Merchant (and the default order case) → open the specific order.
//     if (id != null && id.isNotEmpty) {
//       nav.push(
//         MaterialPageRoute(builder: (_) => OrderDetailsScreen(orderId: id)),
//       );
//       return;
//     }

//     // Nothing actionable.
//     if (fallbackToHome) {
//       nav.push(MaterialPageRoute(builder: (_) => const SplashScreen()));
//     }
//   }

//   static _Portal _portalOf(String? deepLink) {
//     if (deepLink == null || deepLink.isEmpty) return _Portal.unknown;

//     // deepLink may be absolute (https://host/driver/orders/{id}) or relative
//     // (/driver/orders/{id}) — inspect the path segment either way.
//     var path = deepLink;
//     final uri = Uri.tryParse(deepLink);
//     if (uri != null && uri.path.isNotEmpty) path = uri.path;

//     final p = path.toLowerCase();
//     if (p.startsWith('/driver')) return _Portal.driver;
//     if (p.startsWith('/merchant')) return _Portal.merchant;
//     if (p.startsWith('/admin')) return _Portal.admin;
//     return _Portal.storefront;
//   }
// }

// enum _Portal { driver, merchant, admin, storefront, unknown }
