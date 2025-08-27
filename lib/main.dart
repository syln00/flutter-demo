import 'package:demo/core/services/background_service_handler.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:demo/features/login/screens/login_screen.dart';
import 'package:demo/core/services/notification_service.dart';


/// 初始化后台服务
Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    // iOS的配置
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart, // 应用在前台时执行的函数
      onBackground: onStart, // 应用在后台时执行的函数 (实际效果有限)
    ),
    // Android的配置
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      notificationChannelId: notificationChannelId,
      foregroundServiceNotificationId: 888,
      initialNotificationTitle: '后台服务',
      initialNotificationContent: '服务正在运行中...',
      foregroundServiceTypes: [
        AndroidForegroundType.mediaPlayback,
      ],
    ),
  );
}

/// 请求通知权限
Future<void> requestNotificationPermissions() async {
  final messaging = FirebaseMessaging.instance;
  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('用户授予的通知权限: ${settings.authorizationStatus}');
}

void main() async { // main函数改为异步
  // 确保Flutter引擎绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Firebase
  await Firebase.initializeApp();

  // 预先创建通知渠道，避免服务启动时渠道未就绪
  await ensureNotificationChannelInitialized();

  // 初始化后台服务
  await initializeBackgroundService();

  // 请求通知权限
  await requestNotificationPermissions();

  // 运行应用
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter 教学演示',
      debugShowCheckedModeBanner: false, // 隐藏右上角的Debug标签
      scaffoldMessengerKey: appScaffoldMessengerKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}