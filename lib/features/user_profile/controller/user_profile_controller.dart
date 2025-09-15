import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/providers/storage_repository.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/features/user_profile/repository/user_profile_repository.dart';
import 'package:reddit_clone_app/models/post_model.dart';
import 'package:reddit_clone_app/models/user_model.dart';

class UserProfileController extends StateNotifier<bool> {
  // final Ref _ref;
  final UserProfileRepository _userProfileRepository;
  final StorageRepository _storageRepository;

  UserProfileController({
    required Ref ref,
    required UserProfileRepository userProfileRepository,
    required StorageRepository storageRepository,
  })  : _userProfileRepository = userProfileRepository,
        _storageRepository = storageRepository,
        super(false);
       // _ref = ref,

  void editUserData({
    required File? avatar,
    required File? banner,
    required UserModel user,
    required BuildContext context,
    required String editedName,
  }) {
    uploadAvatarAndBanner<UserModel>(
      avatar: avatar,
      banner: banner,
      id: user.name,
      avatarPath: 'users/profilePicture',
      bannerPath: 'users/banner',
      data: user,
      copyWithFn: ({avatar, banner}) => user.copyWith(
        profilePicture: avatar,
        banner: banner,
        name: editedName,
      ),
      updateFn: _userProfileRepository.editUserData,
      context: context,
      storageRepository: _storageRepository,
      setLoading: (val) => state = val,
      redirectPath: '/u/${user.uid}',
    );
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  void updateKarma(String uid, int karma) {
    _userProfileRepository.updateKarma(uid, karma);
  }
}
