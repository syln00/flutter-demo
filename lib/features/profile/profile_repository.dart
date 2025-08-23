import 'dart:io';
import 'package:demo/core/api/api_service.dart'; // 导入api_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ProfileRepository 负责处理个人中心相关的数据交互
class ProfileRepository {
  final ApiService _apiService;

  ProfileRepository(this._apiService);

  /// 上传用户头像
  Future<String> uploadProfilePicture(
      File image, Function(double) onProgress) async {
    return _apiService.uploadImage(image, onProgress);
  }
}

// --- Provider ---

/// 提供 ProfileRepository 实例的 Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ProfileRepository(apiService);
});
