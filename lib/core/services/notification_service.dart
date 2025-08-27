import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 全局的 ScaffoldMessenger Key，用于在无 BuildContext 的场景显示横幅
final GlobalKey<ScaffoldMessengerState> appScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// 通知服务
/// 封装了本地通知的初始化、权限请求和显示逻辑
class NotificationService {
  //持有 flutter_local_notifications 插件的实例
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // 用于跟踪初始化是否已完成
  bool _isInitialized = false;

  /// 初始化通知服务
  Future<void> init() async {
    // 如果已经初始化，则直接返回，避免重复执行
    if (_isInitialized) return;

    // 1. 定义 Android 的初始化设置
    // 'app_icon' 是一个占位符，它会自动使用应用在 'android/app/src/main/res/mipmap' 目录下的默认图标
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('mipmap/ic_launcher');

    // 2. 定义 iOS 的初始化设置
    const DarwinInitializationSettings darwinSettings = DarwinInitializationSettings(
      // 当用户点击通知时触发的回调
      onDidReceiveLocalNotification: _onDidReceiveLocalNotification,
    );

    // 3. 组合成总的初始化设置
    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    // 4. 初始化插件
    await _plugin.initialize(
      settings,
      // 当用户点击通知（且应用在前台或后台）时触发的回调
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    // 5. 为iOS请求通知权限
    // 对于Android 13+, 权限请求通常在原生代码中处理或使用permission_handler库
    final iosPermissionGranted = await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    print("iOS permission granted: $iosPermissionGranted");

    _isInitialized = true;
    print("NotificationService Initialized");
  }

  /// 显示一个简单的通知
  Future<void> showSimpleNotification({required String title, required String body}) async {
    // 确保服务已初始化
    if (!_isInitialized) await init();

    // 1. 定义 Android 的通知详情
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'simple_channel_id', // 频道ID
      'Simple Notifications', // 频道名称
      channelDescription: 'Channel for simple notifications', // 频道描述
      importance: Importance.max,
      priority: Priority.high,
    );

    // 2. 定义 iOS 的通知详情
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails();

    // 3. 组合成总的通知详情
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    // 4. 显示通知
    await _plugin.show(
      0, // 通知ID
      title,
      body,
      notificationDetails,
      payload: 'simple_payload', // 附带的数据
    );
    print("Notification Shown");
  }

  /// 显示应用内横幅通知（MaterialBanner），3 秒后自动隐藏
  void showInAppBanner({required String title, required String body}) {
    final messenger = appScaffoldMessengerKey.currentState;
    if (messenger == null) return;

    // 先移除已有 Banner，避免叠加
    messenger.hideCurrentMaterialBanner();

    final banner = MaterialBanner(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => messenger.hideCurrentMaterialBanner(),
          child: const Text('知道了'),
        ),
      ],
      backgroundColor: const Color(0xFFEEF6FF),
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    messenger.showMaterialBanner(banner);

    Future.delayed(const Duration(seconds: 3), () {
      // 若仍在显示则收起
      messenger.hideCurrentMaterialBanner();
    });
  }

  // --- Private Callbacks ---

  // 当应用在前台时，收到iOS旧版通知的回调
  static void _onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    print('iOS (old) notification received: $id, $title, $body, $payload');
  }

  // 用户点击通知时的统一回调
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print('Notification tapped with payload: ${response.payload}');
    // 在这里可以根据 payload 执行不同的跳转逻辑
  }
}

// --- Provider ---

/// 提供 NotificationService 单例的 Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});
