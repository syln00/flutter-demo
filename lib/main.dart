import 'package:demo/core/services/background_service_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:demo/features/home/home_page.dart';

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
      onStart: onStart, // 服务启动时执行的函数
      isForegroundMode: true, // 启用前台模式
      autoStart: true, // 应用启动时自动启动服务
      // 前台服务通知的初始配置
      foregroundServiceNotificationId: 888,
      initialNotificationTitle: '后台服务',
      initialNotificationContent: '正在初始化...',
    ),
  );
}

void main() async { // main函数改为异步
  // 确保Flutter引擎绑定已初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化后台服务
  await initializeBackgroundService();

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}