// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:signalr_netcore/signalr_client.dart';

// import '../../classes/cashe_helper.dart';
// import '../../constant/end_points/api_url.dart';

// /// A real-time notification pushed from the backend (SignalR `ReceiveNotification`)
// /// or surfaced locally from an incoming FCM message.
// class RealtimeNotification {
//   final String? title;
//   final String? body;
//   final String? deepLink;
//   final String? orderId;
//   final Map<String, dynamic> raw;

//   const RealtimeNotification({
//     this.title,
//     this.body,
//     this.deepLink,
//     this.orderId,
//     this.raw = const {},
//   });

//   /// Build from the SignalR payload (keys may be camel- or Pascal-cased
//   /// depending on the server's JSON policy, so we look both up).
//   factory RealtimeNotification.fromMap(Map<String, dynamic> json) {
//     String? pick(List<String> keys) {
//       for (final k in keys) {
//         final v = json[k];
//         if (v != null && v.toString().isNotEmpty) return v.toString();
//       }
//       return null;
//     }

//     final deepLink = pick(['deepLink', 'DeepLink']);
//     return RealtimeNotification(
//       title: pick(['title', 'Title']),
//       body: pick(['body', 'Body', 'message', 'Message']),
//       deepLink: deepLink,
//       orderId: pick(['orderId', 'OrderId']) ?? _orderIdFromDeepLink(deepLink),
//       raw: json,
//     );
//   }

//   static String? _orderIdFromDeepLink(String? deepLink) {
//     if (deepLink == null) return null;
//     // Match a GUID anywhere in the deep link (e.g. /orders/{guid}).
//     final m = RegExp(
//       r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
//     ).firstMatch(deepLink);
//     return m?.group(0);
//   }
// }

// /// App-wide SignalR client for the merchant/driver real-time notification hub.
// ///
// /// Lifecycle is tied to auth: [connect] once a token exists (idempotent),
// /// [disconnect] on logout. Screens listen to [events] and refresh their data
// /// when something changes. Incoming FCM messages can also be surfaced through
// /// the same stream via [emitExternal] so foreground refresh works regardless of
// /// which channel the backend used.
// class RealtimeService {
//   RealtimeService._();
//   static final RealtimeService instance = RealtimeService._();

//   HubConnection? _connection;
//   bool _starting = false;

//   final StreamController<RealtimeNotification> _controller =
//       StreamController<RealtimeNotification>.broadcast();

//   /// Broadcast stream of real-time notifications (SignalR + surfaced FCM).
//   Stream<RealtimeNotification> get events => _controller.stream;

//   bool get isConnected =>
//       _connection?.state == HubConnectionState.Connected;

//   /// Open the SignalR connection if a token exists and we're not already
//   /// connected/connecting. Safe to call repeatedly (e.g. on every home mount).
//   Future<void> connect() async {
//     if (_starting || isConnected) return;
//     final token = CacheHelper.token;
//     if (token == null || token.isEmpty) return;

//     _starting = true;
//     try {
//       final url = '${baseUrl}signalr-hubs/notifications';
//       final connection = HubConnectionBuilder()
//           .withUrl(
//             url,
//             options: HttpConnectionOptions(
//               accessTokenFactory: () async => CacheHelper.token ?? '',
//             ),
//           )
//           .withAutomaticReconnect()
//           .build();

//       connection.on('ReceiveNotification', _onReceive);
//       connection.onclose(({error}) {
//         if (kDebugMode) debugPrint('[Realtime] closed: $error');
//       });

//       await connection.start();
//       _connection = connection;
//       if (kDebugMode) debugPrint('[Realtime] connected to $url');
//     } catch (e) {
//       if (kDebugMode) debugPrint('[Realtime] connect failed: $e');
//       _connection = null;
//     } finally {
//       _starting = false;
//     }
//   }

//   Future<void> disconnect() async {
//     final c = _connection;
//     _connection = null;
//     if (c == null) return;
//     try {
//       await c.stop();
//     } catch (_) {
//       // ignore — we're tearing down anyway
//     }
//   }

//   /// Surface a notification from another source (e.g. a foreground FCM message)
//   /// so listening screens refresh even when SignalR's InApp channel isn't used.
//   void emitExternal(RealtimeNotification notification) {
//     if (!_controller.isClosed) _controller.add(notification);
//   }

//   void _onReceive(List<Object?>? args) {
//     if (args == null || args.isEmpty) return;
//     final first = args.first;
//     Map<String, dynamic>? map;
//     if (first is Map) {
//       map = first.map((k, v) => MapEntry(k.toString(), v));
//     } else if (first is String) {
//       try {
//         final decoded = jsonDecode(first);
//         if (decoded is Map) {
//           map = decoded.map((k, v) => MapEntry(k.toString(), v));
//         }
//       } catch (_) {
//         // not JSON — ignore
//       }
//     }
//     if (map == null) return;
//     if (kDebugMode) debugPrint('[Realtime] ReceiveNotification: $map');
//     if (!_controller.isClosed) {
//       _controller.add(RealtimeNotification.fromMap(map));
//     }
//   }
// }
