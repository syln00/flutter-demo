import 'package:demo/core/services/notification_service.dart';
import 'package:demo/features/background_task/background_task_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 通知页面
/// 现在是一个 ConsumerWidget，以便我们可以访问 Provider
class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('消息与任务'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('点击下面的按钮来触发相应功能'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final notificationService = ref.read(notificationServiceProvider);
                await notificationService.showSimpleNotification(
                  title: '你好，Flutter！',
                  body: '这是一个来自我们教学应用的本地通知。',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('通知已发送，请检查系统通知栏'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('显示一个本地通知'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const BackgroundTaskPage()),
                );
              },
              child: const Text('进入后台任务页面'),
            ),
          ],
        ),
      ),
    );
  }
}
