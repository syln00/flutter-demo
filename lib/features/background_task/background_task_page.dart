import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class BackgroundTaskPage extends StatefulWidget {
  const BackgroundTaskPage({super.key});

  @override
  State<BackgroundTaskPage> createState() => _BackgroundTaskPageState();
}

class _BackgroundTaskPageState extends State<BackgroundTaskPage> {
  String _logText = "服务未启动";
  StreamSubscription<Map<String, dynamic>?>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    // 监听来自后台服务的'update'事件
    _streamSubscription = FlutterBackgroundService().on('update').listen((event) {
      if (event != null) {
        setState(() {
          _logText = "收到后台更新: ${event['count']}次";
        });
      }
    });
  }

  @override
  void dispose() {
    // 页面销毁时取消监听，防止内存泄漏
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('后台任务控制'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _logText,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Text("设为前台服务"),
                  onPressed: () {
                    FlutterBackgroundService().invoke("setAsForeground");
                  },
                ),
                ElevatedButton(
                  child: const Text("设为后台服务"),
                  onPressed: () {
                    FlutterBackgroundService().invoke("setAsBackground");
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.audiotrack),
              label: const Text("后台播放提示音"),
              onPressed: () {
                FlutterBackgroundService().invoke("playAudio");
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("停止服务", style: TextStyle(color: Colors.white)),
              onPressed: () {
                FlutterBackgroundService().invoke("stopService");
                setState(() {
                  _logText = "服务已停止";
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
