import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/utils.dart';

class EditImageNotifier extends StateNotifier<File?> {
  File? bannerOrAvatarImage;

  EditImageNotifier({
    required this.bannerOrAvatarImage,
  }) : super(bannerOrAvatarImage);
  void selectBannerOrAvatarImage() async {
    final image = await pickImage();
    if (image != null) {
      bannerOrAvatarImage = File(image.files.first.path!);
      state = bannerOrAvatarImage;
    }
  }
}