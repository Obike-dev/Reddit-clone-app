import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/error.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/core/common/reusable_edit_page.dart';
import 'package:reddit_clone_app/core/providers/image_provider.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/features/communities/providers/community_providers.dart';
import 'package:reddit_clone_app/features/user_profile/providers/user_model_provider.dart';
import 'package:reddit_clone_app/models/user_model.dart';
import 'package:reddit_clone_app/theme/pallete.dart';

class EditUserProfilePage extends ConsumerStatefulWidget {
  final String userUid;
  const EditUserProfilePage({
    super.key,
    required this.userUid,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditUserProfilePageState();
}

class _EditUserProfilePageState extends ConsumerState<EditUserProfilePage> {
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: ref.read(AuthProviders.userProvider)!.name,
    );
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void saveUserChanges({
    required UserModel user,
    required BuildContext context,
    required File? profilePicture,
    required File? banner,
  }) {
    ref.read(UserModelProvider.userProfileControllerProvider).editUserData(
          avatar: profilePicture,
          banner: banner,
          user: user,
          context: context,
          editedName: nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(CommunityProviders.communityControllerProvider);
    final selectedBannerImageState = ref.watch(
      EditImageProvider.bannerImageProvider,
    );

    final selectedBannerImage = ref.watch(
      EditImageProvider.bannerImageProvider.notifier,
    );

    final selectedProfilePictureState = ref.watch(
      EditImageProvider.avatarImageProvider,
    );

    final selectedAvatarImage = ref.watch(
      EditImageProvider.avatarImageProvider.notifier,
    );

    return ref
        .watch(
          AuthProviders.getUserDataProvider(widget.userUid),
        )
        .when(
          data: (user) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 23),
                ),
                centerTitle: true,
                actions: [
                  TextButton(
                    onPressed: () => saveUserChanges(
                      user: user,
                      context: context,
                      profilePicture: selectedProfilePictureState,
                      banner: selectedBannerImageState,
                    ),
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: Pallete.blueColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              body: isLoading
                  ? const Loader()
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 30,
                        horizontal: 10,
                      ),
                      child: Column(
                        children: [
                          ReusableEditPage(
                            bannerImage: selectedBannerImageState,
                            avatarImage: selectedProfilePictureState,
                            defaultBanner: user.banner,
                            defaultAvatar: user.profilePicture,
                            onBannerTap: () =>
                                selectedBannerImage.selectBannerOrAvatarImage(),
                            onAvatarTap: () =>
                                selectedAvatarImage.selectBannerOrAvatarImage(),
                          ),
                          const SizedBox(height: 40),
                          TextField(
                            controller: nameController,
                            decoration: InputDecoration(
                              filled: true,
                              hintText: 'name',
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
          loading: () => const Loader(),
          error: (error, stackTrace) => ErrorMessage(
            error: error.toString(),
          ),
        );
  }
}
