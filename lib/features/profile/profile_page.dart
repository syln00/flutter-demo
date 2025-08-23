import 'dart:io';
import 'package:demo/features/profile/profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听 ProfileNotifier 的状态
    final profileState = ref.watch(profileNotifierProvider);
    final profileNotifier = ref.read(profileNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的 (图片上传)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- 头像显示区域 ---
            _buildAvatar(profileState),
            const SizedBox(height: 24),

            // --- 上传进度或状态信息 ---
            _buildStatusInfo(profileState, context),
            const SizedBox(height: 24),

            // --- 操作按钮 ---
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: const Text('从相册选择图片'),
              onPressed: profileState.status == UploadStatus.uploading
                  ? null // 上传中时禁用按钮
                  : () => profileNotifier.pickImage(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload),
              label: const Text('上传图片'),
              // 只有在成功选择图片后才允许上传
              onPressed: profileState.status == UploadStatus.picked
                  ? () => profileNotifier.uploadImage()
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ProfileState state) {
    // 根据状态显示不同的头像内容
    Widget content;
    if (state.status == UploadStatus.success && state.uploadedImageUrl != null) {
      // 成功上传后，显示网络图片
      content = Image.network(state.uploadedImageUrl!, fit: BoxFit.cover);
    } else if (state.selectedImage != null) {
      // 选择图片后，显示本地文件图片
      content = Image.file(state.selectedImage!, fit: BoxFit.cover);
    } else {
      // 默认状态，显示一个占位图标
      content = const Icon(Icons.person, size: 60, color: Colors.grey);
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey.shade200,
      // ClipOval 确保内容（图片）也是圆形的
      child: ClipOval(
        child: SizedBox(
          width: 120,
          height: 120,
          child: content,
        ),
      ),
    );
  }

  Widget _buildStatusInfo(ProfileState state, BuildContext context) {
    // 根据上传状态显示不同的提示信息
    switch (state.status) {
      case UploadStatus.uploading:
        return Column(
          children: [
            // 显示环形进度条和百分比
            LinearProgressIndicator(value: state.uploadProgress),
            const SizedBox(height: 8),
            Text('上传中... ${(state.uploadProgress * 100).toStringAsFixed(0)}%'),
          ],
        );
      case UploadStatus.success:
        return Text('上传成功!', style: TextStyle(color: Colors.green.shade700));
      case UploadStatus.error:
        return Text('上传失败: ${state.errorMessage}', style: TextStyle(color: Theme.of(context).colorScheme.error));
      default:
        // 其他状态下不显示任何信息
        return const SizedBox.shrink();
    }
  }
}