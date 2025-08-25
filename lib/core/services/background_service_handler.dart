import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:just_audio/just_audio.dart';

@pragma('vm:entry-point')
Future<bool> onStart(ServiceInstance service) async {
  // 确保 Dart VM 的绑定已经初始化
  DartPluginRegistrant.ensureInitialized();

  final audioPlayer = AudioPlayer();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  service.on('playAudio').listen((event) async {
    try {
      await audioPlayer.setUrl('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
      audioPlayer.play();
      service.invoke('update', {'message': '音频播放成功'});
    } catch (e) {
      print("音频播放错误: $e");
      service.invoke('update', {'message': '音频播放失败'});
    }
  });

  int count = 0;
  Timer.periodic(const Duration(seconds: 3), (timer) {
    count++;
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "后台服务运行中",
        content: "计数器已运行 $count 次，时间: ${DateTime.now()}",
      );
    }
    service.invoke(
      'update',
      {
        "count": count,
      },
    );
  });

  return true;
}