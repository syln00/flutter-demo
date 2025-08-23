import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// API服务层
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio();
    _dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    await Future.delayed(Duration(milliseconds: 500 + Random().nextInt(1000)));
    final List<Map<String, dynamic>> mockData = List.generate(20, (index) {
      return {
        'id': 'id_${index + 1}',
        'name': '项目 ${index + 1}',
        'description': '这是项目 ${index + 1} 的详细描述，这是一个优秀的教学案例。',
        'imageUrl': 'https://picsum.photos/seed/${index + 1}/200/200',
      };
    });
    return mockData;
  }

  Future<String> uploadImage(File image, Function(double) onSendProgress) async {
    final fileName = image.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: fileName),
    });

    try {
      final response = await _dio.post(
        'https://httpbin.org/post',
        data: formData,
        onSendProgress: (int sent, int total) {
          final progress = sent / total;
          onSendProgress(progress);
        },
      );

      if (response.statusCode == 200) {
        final uploadedUrl = response.data['files']['file'];
        print('文件上传成功，模拟URL: $uploadedUrl');
        return 'https://i.pravatar.cc/300';
      } else {
        throw Exception('文件上传失败');
      }
    } catch (e) {
      print('上传出错: $e');
      rethrow;
    }
  }
}

/// 提供ApiService实例的Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
