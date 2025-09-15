import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/error.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/core/common/reusable_edit_page.dart';
import 'package:reddit_clone_app/core/providers/image_provider.dart';
import 'package:reddit_clone_app/features/communities/providers/community_providers.dart';
import 'package:reddit_clone_app/models/community_model.dart';
import 'package:reddit_clone_app/theme/pallete.dart';

class EditCommunityPage extends ConsumerStatefulWidget {
  final String communityName;
  const EditCommunityPage({
    super.key,
    required this.communityName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditCommunityPageState();
}

class _EditCommunityPageState extends ConsumerState<EditCommunityPage> {
  void saveCommunity(Community community) {
    ref
        .read(
          CommunityProviders.communityControllerProvider.notifier,
        )
        .editCommunity(
          community: community,
          context: context,
          avatar: ref
              .read(
                EditImageProvider.bannerImageProvider.notifier,
              )
              .bannerOrAvatarImage,
          banner: ref
              .read(
                EditImageProvider.bannerImageProvider.notifier,
              )
              .bannerOrAvatarImage,
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      CommunityProviders.communityControllerProvider,
    );
    final selectedBannerImageState = ref.watch(
      EditImageProvider.bannerImageProvider,
    );

    final selectedBannerImage = ref.watch(
      EditImageProvider.bannerImageProvider.notifier,
    );

    final selectedAvatarImageState = ref.watch(
      EditImageProvider.avatarImageProvider,
    );

    final selectedAvatarImage = ref.watch(
      EditImageProvider.avatarImageProvider.notifier,
    );

    return ref
        .watch(
          CommunityProviders.getCommunityByNameProvider(
            widget.communityName,
          ),
        )
        .when(
          data: (community) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Edit Community'),
                centerTitle: true,
                actions: [
                  TextButton(
                    onPressed: () => saveCommunity(community),
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
                            avatarImage: selectedAvatarImageState,
                            defaultBanner: community.banner,
                            defaultAvatar: community.avatar,
                            onBannerTap: () =>
                                selectedBannerImage.selectBannerOrAvatarImage(),
                            onAvatarTap: () =>
                                selectedAvatarImage.selectBannerOrAvatarImage(),
                          )
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
