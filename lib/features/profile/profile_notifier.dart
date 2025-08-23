import 'dart:io';

import 'package:demo/features/profile/profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'profile_notifier.freezed.dart';

// 定义上传状态的枚举
enum UploadStatus { idle, picking, picked, uploading, success, error }

// 使用freezed定义页面状态类
@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(UploadStatus.idle) UploadStatus status,
    File? selectedImage,
    @Default(0.0) double uploadProgress,
    String? uploadedImageUrl,
    String? errorMessage,
  }) = _ProfileState;
}

// 创建 StateNotifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;
  final ImagePicker _picker = ImagePicker();

  ProfileNotifier(this._repository) : super(const ProfileState());

  // 选择图片
  Future<void> pickImage() async {
    state = state.copyWith(status: UploadStatus.picking);
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        state = state.copyWith(
          status: UploadStatus.picked,
          selectedImage: File(pickedFile.path),
          uploadProgress: 0.0, // 重置进度
        );
      } else {
        state = state.copyWith(status: UploadStatus.idle);
      }
    } catch (e) {
      state = state.copyWith(status: UploadStatus.error, errorMessage: e.toString());
    }
  }

  // 上传图片
  Future<void> uploadImage() async {
    if (state.selectedImage == null) return;

    state = state.copyWith(status: UploadStatus.uploading, uploadProgress: 0.0);
    try {
      final imageUrl = await _repository.uploadProfilePicture(
        state.selectedImage!,
        (progress) {
          // 更新上传进度
          state = state.copyWith(uploadProgress: progress);
        },
      );
      state = state.copyWith(status: UploadStatus.success, uploadedImageUrl: imageUrl);
    } catch (e) {
      state = state.copyWith(status: UploadStatus.error, errorMessage: e.toString());
    }
  }
}

// --- Provider ---
final profileNotifierProvider = StateNotifierProvider.autoDispose<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});