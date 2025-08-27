import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:demo/features/login/models/login_request.dart';
import 'package:demo/features/login/models/login_response.dart';
import 'dart:convert'; // Added for base64 decoding

class LoginService {
  final Dio _dio = Dio();
  static const String _publicKeyBase64 =
      'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAm1ZR35L4jZu9C7Gf9J9MS00XYvw5wp1TMTSqqTzU+NDMmfXy2kXJieruxXUeSKOvo/U0Se1iwwq1eeq7skyYMuP5SrMLgw89fqWBbJjQ6rCKMF6eS+oHPODLy1D7Z4mYs6hTsdnkk2wgAesCnGbVkyHN4nG3FzPxy2ML9NNQU630dIhG2ufh9lGwX4WMRNiAG6AXhHiC4P1+sQrJB6t65QNS+se3x3v+hf53xWf98QOtlPFDznElZWODfaGedIi8C+Xbd8qkTq/NNy3Buv/kK8d4vlG413GO3qCkZTSI+mGCHboA+mzumcuHaUHo6RBkdfYI7Zwi5mTEYCLUjbfoQQIDAQAB';

  /// Encrypt password using RSA PKCS1 (same as JSEncrypt)
  String _encryptPassword(String password) {
    try {
      // Build PEM formatted public key
      final pem = '-----BEGIN PUBLIC KEY-----\n'
          '$_publicKeyBase64\n'
          '-----END PUBLIC KEY-----';
      print(pem);
      // Parse PEM public key
      final parser = RSAKeyParser();
      final publicKey = parser.parse(pem) as RSAPublicKey;

      // Use PKCS1 encoding to match JSEncrypt default
      final encrypter = Encrypter(
        RSA(publicKey: publicKey, encoding: RSAEncoding.PKCS1),
      );

      final encrypted = encrypter.encrypt(password);
      return encrypted.base64;
    } catch (error) {
      throw Exception('加密失败: $error');
    }
  }

  Future<LoginResponse> login(LoginRequest request) async {
    print(request.password);
    final encryptedPassword = _encryptPassword(request.password);
    const url = 'https://www.shuguoren.com/tmh-dev/bapp-api/system/auth/login';
    final data = {
      'username': request.username,
      'password': encryptedPassword,
    };

    try {
      final response = await _dio.post(url, data: data);
      print(response.data);
      if (response.data != null && response.data['code'] == 0) {
        return LoginResponse.fromJson(response.data['data']);
      } else {
        throw Exception('Login failed: ${response.data['message']}');
      }
    } on DioException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }
}