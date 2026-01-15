import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('ic_notification'); 

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
  }

  Future<void> showLowStockNotification({
    required int id,
    required String itemName,
    required int stock,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'low_stock_channel',
      'Stok Menipis',
      channelDescription: 'Notifikasi saat stok barang menipis',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_notification', // drawable
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await _notifications.show(
      id,
      '⚠️ Stok Menipis',
      '$itemName tersisa $stock',
      details,
    );
  }
}