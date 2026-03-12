import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// Gestion des notifications push : enregistrement du token FCM auprès du backend.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.notification?.title}');
}

class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final ApiService _api = ApiService();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      await _requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _sendTokenToBackend(token);
      FirebaseMessaging.instance.onTokenRefresh.listen(_sendTokenToBackend);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Foreground message: ${message.notification?.title}');
      });
      _initialized = true;
    } catch (e) {
      debugPrint('PushNotificationService.init error: $e');
    }
  }

  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Push permission: ${settings.authorizationStatus}');
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _api.post('/api/push-tokens', data: {
        'token': token,
        'platform': null,
      });
      debugPrint('Push token sent to backend');
    } catch (e) {
      debugPrint('Send push token error: $e');
    }
  }

  /// À appeler après login pour enregistrer le token (au cas où init a été fait avant auth).
  Future<void> registerTokenIfNeeded() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _sendTokenToBackend(token);
    } catch (_) {}
  }
}
