import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/error.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/core/common/reusable_edit_page.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:reddit_clone_app/core/providers/image_provider.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/features/communities/providers/community_providers.dart';
import 'package:reddit_clone_app/features/posts/providers/post_providers.dart';
import 'package:reddit_clone_app/models/community_model.dart';

class AddPostTypePage extends ConsumerStatefulWidget {
  final String postType;

  const AddPostTypePage({
    super.key,
    required this.postType,
  });

  @override
  ConsumerState<AddPostTypePage> createState() => _AddPostTypePageState();
}

class _AddPostTypePageState extends ConsumerState<AddPostTypePage> {
  late final TextEditingController titleController;
  late final TextEditingController textController;
  late final TextEditingController linkController;

  TextField textField({
    required String hintMessage,
    required TextEditingController controller,
    required int charLength,
    int? maxLines,
  }) =>
      TextField(
        controller: controller,
        maxLength: charLength,
        maxLines: maxLines,
        decoration: InputDecoration(
          fillColor: Colors.grey[0],
          filled: true,
          hintText: hintMessage,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(15),
          ),
          border: InputBorder.none,
        ),
      );
  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    textController = TextEditingController();
    linkController = TextEditingController();
  }

  @override
  void dispose() {
    titleController.dispose();
    textController.dispose();
    linkController.dispose();
    super.dispose();
  }

  void sharePost({
    required WidgetRef ref,
    required BuildContext context,
    required Community selectedCommunity,
    required String postType,
  }) {
    ref.read(PostProviders.postControllerProvider.notifier).addPost(
          title: titleController.text.trim(),
          context: context,
          selectedCommunity: selectedCommunity,
          postType: postType,
          description: textController.text.trim(),
          link: linkController.text.trim(),
          imageFile: ref.read(
            EditImageProvider.bannerImageProvider,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(PostProviders.postControllerProvider);
    final isPostTypeImage = widget.postType == 'image';
    final isPostTypeText = widget.postType == 'text';
    final isPostTypeLink = widget.postType == 'link';
    final selectedBannerImageState = ref.watch(
      EditImageProvider.bannerImageProvider,
    );
    final selectedBannerImage = ref.watch(
      EditImageProvider.bannerImageProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Post ${widget.postType[0].toUpperCase()}${widget.postType.substring(1)}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: isLoading
                ? null
                : () {
                    if (titleController.text.trim().isEmpty) {
                      showSnackBar(context, 'Please enter a title');
                      return;
                    }
                    if (isPostTypeText && textController.text.trim().isEmpty) {
                      showSnackBar(context, 'Please enter text');
                      return;
                    }
                    if (isPostTypeLink && linkController.text.trim().isEmpty) {
                      showSnackBar(context, 'Please enter a link');
                      return;
                    }

                    final selectedCommunityName =
                        ref.read(CommunityProviders.selectedCommunityProvider);
                    if (selectedCommunityName == null) {
                      showSnackBar(context, 'Please select a community');
                      return;
                    }
                    final communitiesAsync =
                        ref.read(CommunityProviders.getUserCommunities);

                    communitiesAsync.whenData((communities) {
                      final Community selectedCommunity =
                          communities.firstWhere(
                        (community) => community.name == selectedCommunityName,
                        orElse: () => throw Exception('Community not found'),
                      );

                      sharePost(
                        ref: ref,
                        context: context,
                        selectedCommunity: selectedCommunity,
                        postType: widget.postType,
                      );
                    });
                  },
            child: isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue,
                    ),
                  )
                : const Text(
                    'Share',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 17,
                    ),
                  ),
          )
        ],
      ),
      body: AbsorbPointer(
        absorbing: isLoading,
        child: Padding(
          padding: const EdgeInsets.only(
            top: 30,
            left: 5,
            right: 5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              textField(
                  hintMessage: 'Enter title here',
                  controller: titleController,
                  charLength: 30),
              const SizedBox(height: 15),
              if (isPostTypeImage)
                ReusableEditPage(
                  bannerImage: selectedBannerImageState,
                  onBannerTap: () =>
                      selectedBannerImage.selectBannerOrAvatarImage(),
                  showAvatar: false,
                ),
              if (isPostTypeText)
                textField(
                  hintMessage: 'Enter text here',
                  controller: textController,
                  maxLines: 5,
                  charLength: 300,
                ),
              if (isPostTypeLink)
                textField(
                    hintMessage: 'Enter link here',
                    controller: linkController,
                    charLength: 200),
              const SizedBox(height: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 15),
                  ref.watch(CommunityProviders.getUserCommunities).when(
                        data: (communities) {
                          if (communities.isEmpty) {
                            return const Text(
                              'You are not part of any community.',
                            );
                          }
                          return DropdownButton2<String>(
                            value: ref.watch(
                              CommunityProviders.selectedCommunityProvider,
                            ),
                            hint: const Text('Choose a community'),
                            isExpanded: true,
                            items: communities.map((community) {
                              return DropdownMenuItem<String>(
                                value: community.name,
                                child: Text(community.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              ref
                                  .read(CommunityProviders
                                      .selectedCommunityProvider.notifier)
                                  .state = value;
                            },
                          );
                        },
                        error: (error, stackTrace) => ErrorMessage(
                          error: error.toString(),
                        ),
                        loading: () => const Loader(),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
