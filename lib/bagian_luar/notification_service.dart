import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
  }

  Future<void> showLowStock({
    required int id,
    required String itemName,
    required int stock,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'low_stock_channel',
      'Stok Menipis',
      channelDescription: 'Notifikasi saat stok barang menipis',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id,
      'Stok Menipis ⚠️',
      '$itemName tersisa $stock',
      details,
    );
  }
}