import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:coachappmobile/core/services/realtime/realtime_service.dart';
import 'package:coachappmobile/firebase_options.dart';
import 'cashe_helper.dart';

// Background isolate entry point. Must be a top-level function and annotated
// so the Flutter VM keeps it in release builds.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    debugPrint(
      'Background FCM message: ${message.messageId} data=${message.data}',
    );
  }
}

class FireBaseNotification {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Waits up to [timeout] for the APNs token to be issued on iOS. Returns the
  /// token (or null if it never arrives) — on non-iOS platforms returns null
  /// immediately without waiting. iOS will not mint an FCM token until APNs has
  /// registered the device, so this MUST succeed before calling [getToken].
  static Future<String?> _waitForApnsToken({
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return null;
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      try {
        final apns = await FirebaseMessaging.instance.getAPNSToken();
        if (apns != null && apns.isNotEmpty) return apns;
      } catch (_) {
        // ignore and retry
      }
      await Future.delayed(const Duration(milliseconds: 400));
    }
    return null;
  }

  /// Public helper for login flows: returns a usable FCM token, waiting for
  /// APNs on iOS and falling back to whatever was cached during app start.
  static Future<String?> ensureFcmToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final apns = await _waitForApnsToken();
      if (apns == null) {
        if (kDebugMode) print('APNs token not available — using cached FCM');
        return CacheHelper.getDeviceToken;
      }
    }
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await CacheHelper.setDeviceToken(token);
        return token;
      }
    } catch (e) {
      if (kDebugMode) print('ensureFcmToken error: $e');
    }
    return CacheHelper.getDeviceToken;
  }

  Future<void> initNotification() async {
    // Initialize local notifications plugin first
    await _initializeLocalNotifications();

    await _requestNotificationPermission();

    // Request iOS permissions first to ensure APNs is set up
    await _requestIOSPermissions();

    // Wait for APNs token before asking for the FCM token on iOS. Without a
    // valid APNs token, getToken() returns null and the device never receives
    // pushes.
    final String? apnsToken = await _waitForApnsToken();
    if (kDebugMode && defaultTargetPlatform == TargetPlatform.iOS) {
      debugPrint('APNs Token: $apnsToken');
    }

    // Get FCM token with error handling for iOS
    String? token;
    try {
      token = await _firebaseMessaging.getToken();
      if (kDebugMode) {
        print("FCM Token: $token");
      }
      if (token != null && token.isNotEmpty) {
        await CacheHelper.setDeviceToken(token);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting FCM token: $e");
        print("Token will be retrieved when APNs is ready");
      }
    }

    // NOTE: We intentionally do NOT subscribe to a global "all" topic.
    // Subscribing every device to one shared topic meant any topic send fanned
    // out to every device regardless of which user/role was logged in — the root
    // cause of cross-user / cross-role notification leakage. Notifications are
    // delivered per-user via the device token registered to the logged-in user.

    // Listen for token refresh — keep the cached token in sync and re-register it
    // server-side so it stays mapped to the current user.
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      if (kDebugMode) {
        print("FCM Token refreshed: $newToken");
      }
      await CacheHelper.setDeviceToken(newToken);
    });

    _initializeForegroundNotifications();
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final data = jsonDecode(payload);
          if (data is Map) {
            _openOrderFromData(data.map((k, v) => MapEntry(k.toString(), v)));
          }
        } catch (_) {
          // payload wasn't JSON — ignore
        }
      },
    );
  }

  Future<void> _requestNotificationPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('Notification permission granted');
      }
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print('Provisional notification permission granted');
      }
    } else {
      if (kDebugMode) {
        print('Notification permission denied');
      }
    }
  }

  Future<void> _requestIOSPermissions() async {
    final bool? result = await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    if (result == true) {
      if (kDebugMode) {
        print('iOS Notification permissions granted');
      }
    } else {
      if (kDebugMode) {
        print('iOS Notification permissions denied');
      }
    }
  }

  void _initializeForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print(
          "Foreground notification received: ${message.notification?.title}",
        );
      }
      _handleForegroundNotification(message);
    });
  }

  void handleBackgroundNotifications() {
    FirebaseMessaging.instance.getInitialMessage().then(_handleNotificationTap);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  void _handleForegroundNotification(RemoteMessage message) async {
    if (message.notification == null) return;

    final String title = message.notification!.title ?? "No Title";
    final String body = message.notification!.body ?? "No Body";
    final String? imageUrl =
        message.notification!.android?.imageUrl ??
        message.notification!.apple?.imageUrl;

    // Surface to the realtime stream so open screens refresh their data even
    // when the backend used the Push (FCM) channel rather than SignalR InApp.
    RealtimeService.instance.emitExternal(
      RealtimeNotification(
        orderId: message.data['orderId']?.toString(),
        raw: Map<String, dynamic>.from(message.data),
      ),
    );

    if (imageUrl != null) {
      final notificationDetails = await _createImageNotificationDetails(
        imageUrl,
        title,
        body,
      );
      await _localNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    } else if (message.data.containsKey('progress')) {
      await _showProgressNotification(message, title, body);
    } else {
      final notificationDetails = _createDefaultNotificationDetails();
      await _localNotificationsPlugin.show(
        message.hashCode,
        title,
        body,
        notificationDetails,
        payload: jsonEncode(message.data),
      );
    }
  }

  Future<NotificationDetails> _createImageNotificationDetails(
    String imageUrl,
    String title,
    String body,
  ) async {
    try {
      final String base64Image = await _downloadAndConvertImage(imageUrl);
      final bigPictureStyleInformation = BigPictureStyleInformation(
        ByteArrayAndroidBitmap.fromBase64String(base64Image),
        contentTitle: title,
        summaryText: body,
      );

      final androidDetails = AndroidNotificationDetails(
        'image_channel_id',
        'Image Notifications',
        channelDescription: 'Notifications with images',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: bigPictureStyleInformation,
        icon: "@mipmap/ic_launcher",
        playSound: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      return NotificationDetails(android: androidDetails, iOS: iosDetails);
    } catch (e) {
      debugPrint("Failed to create image notification: $e");
      return _createDefaultNotificationDetails();
    }
  }

  Future<void> _showProgressNotification(
    RemoteMessage message,
    String title,
    String body,
  ) async {
    final int progress = int.tryParse(message.data['progress'] ?? '0') ?? 0;

    for (int i = progress; i <= 100; i += 10) {
      final androidNotificationDetails = AndroidNotificationDetails(
        icon: "@mipmap/ic_launcher",
        'progress_channel_id',
        'Progress Notifications',
        channelDescription: 'Notifications with progress updates',
        importance: Importance.max,
        priority: Priority.high,
        showProgress: true,
        maxProgress: 100,
        progress: i,
      );

      const iosNotificationDetails = DarwinNotificationDetails(
        presentSound: true,
        presentAlert: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: iosNotificationDetails,
      );

      await _localNotificationsPlugin.show(
        message.hashCode,
        title,
        '$body ($i%)',
        notificationDetails,
      );

      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  NotificationDetails _createDefaultNotificationDetails() {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'default_channel_id',
          'Default Notifications',
          channelDescription: 'Simple notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          icon: "@mipmap/ic_launcher",
        );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    return const NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );
  }

  Future<String> _downloadAndConvertImage(String imageUrl) async {
    try {
      final response = await NetworkAssetBundle(Uri.parse(imageUrl)).load("");
      final bytes = response.buffer.asUint8List();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint("Failed to download image: $e");
      return "";
    }
  }

  void _handleNotificationTap(RemoteMessage? message) {
    if (message == null) return;
    _openOrderFromData(message.data);
  }

  /// Deep-link a notification tap to the right screen for the recipient.
  ///
  /// TODO(CoachApp): re-wire to a CoachApp NotificationRouter once the target
  /// feature screens exist (e.g. trainee → today's plan, coach → trainee detail).
  /// The reference router lives in `reference_pending/` for reference.
  void _openOrderFromData(Map<String, dynamic> data) {
    if (kDebugMode) {
      debugPrint('Notification tap (routing pending): $data');
    }
  }
}
