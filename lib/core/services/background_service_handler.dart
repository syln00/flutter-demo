import 'dart:async';
import 'dart:ui';

import 'package:demo/core/services/order_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
// Removed android-specific import to avoid using it in background isolate
import 'package:just_audio/just_audio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const String notificationChannelId = 'background_service_channel';
const String notificationChannelName = '后台服务通知';
const String notificationChannelDescription = '用于保持应用在后台运行和播放音频';
const String alertChannelId = 'alert_channel';
const String alertChannelName = '提醒通知';
const String alertChannelDescription = '用于播放默认提示音的提醒通知';

Future<void> _createNotificationChannel() async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidInitializationSettings = AndroidInitializationSettings('@drawable/ic_bg_service_small');
  const initializationSettings = InitializationSettings(android: androidInitializationSettings);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  const androidChannel = AndroidNotificationChannel(
    notificationChannelId,
    notificationChannelName,
    description: notificationChannelDescription,
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);

  // 创建带声音的提醒渠道（使用系统默认提示音）
  const androidAlertChannel = AndroidNotificationChannel(
    alertChannelId,
    alertChannelName,
    description: alertChannelDescription,
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidAlertChannel);
}

Future<void> ensureNotificationChannelInitialized() async {
  await _createNotificationChannel();
}

Future<void> _showAlertNotification({required String title, required String body}) async {
  final plugin = FlutterLocalNotificationsPlugin();
  const androidDetails = AndroidNotificationDetails(
    alertChannelId,
    alertChannelName,
    channelDescription: alertChannelDescription,
    importance: Importance.high,
    priority: Priority.high,
    playSound: true,
    enableVibration: true,
    icon: '@drawable/ic_bg_service_small',
  );
  const details = NotificationDetails(android: androidDetails);
  await plugin.show(1001, title, body, details);
}

@pragma('vm:entry-point')
Future<bool> onStart(ServiceInstance service) async {
  // 确保 Dart VM 的绑定已经初始化
  DartPluginRegistrant.ensureInitialized();

  // 创建通知渠道
  await _createNotificationChannel();

  final audioPlayer = AudioPlayer();
  final orderNotificationService = OrderNotificationService();

  // Removed AndroidServiceInstance-specific listeners to avoid android-only API in background isolate

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('playAudio').listen((event) async {
    // 改为触发带默认提示音的本地通知，避免网络不可达导致播放失败
    await _showAlertNotification(title: '提醒', body: '后台任务触发提示音');
    service.invoke('update', {'message': '已触发系统默认提示音'});
  });

  int count = 0;
  Timer.periodic(const Duration(seconds: 3), (timer) {
    count++;
    service.invoke(
      'update',
      {
        "count": count,
      },
    );
  });

  Timer.periodic(const Duration(seconds: 30), (timer) async {
    await orderNotificationService.checkNewOrders();
  });

  return true;
}
