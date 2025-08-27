import 'dart:async';

import 'package:demo/core/services/order_notification_service.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final OrderNotificationService _orderNotificationService =
      OrderNotificationService();
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkOrders();
    });
  }

  Future<void> _checkOrders() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    await _orderNotificationService.checkNewOrders();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订单通知'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isLoading)
              const CircularProgressIndicator()
            else
              const Text('每30秒自动查询新订单'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkOrders,
              child: const Text('立即查询订单'),
            ),
          ],
        ),
      ),
    );
  }
}
