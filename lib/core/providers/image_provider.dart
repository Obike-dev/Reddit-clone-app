import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/edit_image.dart';

class EditImageProvider {
  static final bannerImageProvider =
      StateNotifierProvider<EditImageNotifier, File?>(
    (ref) => EditImageNotifier(
      bannerOrAvatarImage: null,
    ),
  );
  static final avatarImageProvider =
      StateNotifierProvider<EditImageNotifier, File?>(
    (ref) => EditImageNotifier(
      bannerOrAvatarImage: null,
    ),
  );
}
