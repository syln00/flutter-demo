
import 'package:dio/dio.dart';
import 'package:demo/core/services/secure_storage_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:demo/core/services/notification_service.dart';
import 'package:flutter/services.dart' show rootBundle;

class OrderNotificationService {
  final Dio _dio = Dio();
  final SecureStorageService _secureStorageService = SecureStorageService();
  final NotificationService _notificationService = NotificationService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<bool> _assetExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (_) {
      print('Asset does not exist: $path');
      return false;
    }
  }

  Future<void> checkNewOrders() async {
    try {
      final token = await _secureStorageService.getAccessToken();
      if (token == null) {
        // Not logged in, so can't check for orders.
        return;
      }

      final response = await _dio.get(
        'https://www.shuguoren.com/tmh-dev/bapp-api/trade/order/newOrderCount?shopId=17',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      print(response);
      if (response.statusCode == 200) {
        print(response.data);
        final data = response.data['data'];
        final orderCancelRequestCount = data['orderCancelRequestCount'] as int;
        final orderDispatchCount = data['orderDispatchCount'] as int;
        final orderPickUpCount = data['orderPickUpCount'] as int;
        final saleUndisposedCount = data['saleUndisposedCount'] as int;

        if (orderCancelRequestCount > 0 ||
            orderDispatchCount > 0 ||
            orderPickUpCount > 0 ||
            saleUndisposedCount > 0) {
          const title = '您有新的订单';
          const body = '您有新的订单，请及时处理。';

          // 系统通知
          await _notificationService.showSimpleNotification(title: title, body: body);
          // 应用内横幅
          _notificationService.showInAppBanner(title: title, body: body);

          // 声音
          const networkUrl = 'https://www.soundjay.com/buttons/sounds/button-3.mp3'; // ~1s
          const assetPath = 'assets/newOrder.mp3';

          bool played = false;
          try {
            await _audioPlayer.setUrl(networkUrl);
            await _audioPlayer.play();
            played = true;
          } catch (e) {
            print('Network audio failed: $e');
          }

          if (!played && await _assetExists(assetPath)) {
            try {
              await _audioPlayer.setAsset(assetPath);
              await _audioPlayer.play();
              played = true;
            } catch (e) {
              print('Asset audio failed: $e');
            }
          }
        }
      }
    } catch (e) {
      print('Error checking new orders: $e');
    }
  }
}
