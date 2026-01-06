import 'package:flutter/material.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/alert_dialog.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/core/constants/constant.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/features/communities/providers/community_providers.dart';
import 'package:reddit_clone_app/features/posts/providers/post_providers.dart';
import 'package:reddit_clone_app/models/post_model.dart';
import 'package:reddit_clone_app/theme/pallete.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:routemaster/routemaster.dart';
import 'package:url_launcher/url_launcher.dart';

class PostCard extends ConsumerWidget {
  final Post post;
  const PostCard({
    super.key,
    required this.post,
  });

  void goToCommunityPage(BuildContext context) => Routemaster.of(context).push('/r/${post.communityName}');

  void goToUserProfile(BuildContext context) => Routemaster.of(context).push('/u/${post.postAuthorUid}');

  void deletePost(WidgetRef ref, BuildContext context) {
    ref.read(PostProviders.postControllerProvider.notifier).deletePost(context, post.id);
  }

  void upVotePost(WidgetRef ref) {
    ref.read(PostProviders.postControllerProvider.notifier).upVotePost(post);
  }

  void donwVotePost(WidgetRef ref) {
    ref.read(PostProviders.postControllerProvider.notifier).donwVotePost(post);
  }

  void awardPost(WidgetRef ref, String award, BuildContext context) {
    ref.read(PostProviders.postControllerProvider.notifier).awardPost(post: post, award: award, context: context);
  }

  Future<void> launchUrlFunction(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(AuthProviders.userProvider)!;

    final communityAsync = ref.watch(
      CommunityProviders.getCommunityByNameProvider(post.communityName),
    );

    final isModerator = communityAsync.maybeWhen(
      data: (community) => community.mods.contains(user.uid),
      orElse: () => false,
    );
    SizedBox imageOrLinkSizedBox(Widget? widget) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          width: double.infinity,
          child: widget,
        );

    IconButton rowIcons({
      IconData? icon,
      Color? color,
      VoidCallback? onPressed,
    }) =>
        IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: color ?? Colors.white,
          ),
        );

    void goToCommentsPage(postId) {
      Routemaster.of(context).push('/comments/$postId');
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: responsiveValue<double>(
            context,
            550,
            const [
              Condition.between(
                start: 0,
                end: 550,
                value: double.infinity,
              ),
            ],
          ).value,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Pallete.drawerColor,
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: InkWell(
                  onTap: () => goToCommunityPage(context),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(post.communityProfilePhoto),
                  ),
                ),
                title: InkWell(
                  onTap: () => goToCommunityPage(context),
                  child: Text(
                    'r/${post.communityName}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                subtitle: Row(
                  children: [
                    InkWell(
                      onTap: () => goToUserProfile(context),
                      child: Text('u/${post.postAuthor}'),
                    ),
                  ],
                ),
                trailing: post.postAuthorUid == user.uid
                    ? IconButton(
                        onPressed: () {
                          final parentContext = context;
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ReusableAlertDialog(
                                confirmationText: 'Are you sure you want to delete this post?',
                                onPressedAction: () => deletePost(ref, parentContext),
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete),
                      )
                    : const SizedBox(),
              ),
              if (post.awards.isNotEmpty) ...[
                SizedBox(
                  height: 30, // enough to fit the awards row
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: post.awards.length,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Image.asset(
                        Constants.awards[post.awards[index]]!,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Text(
                post.title
                    .split(' ')
                    .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
                    .join(' '),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 5),
              if (post.postType == 'text')
                Text(
                  post.description ?? '',
                  style: const TextStyle(fontSize: 16),
                ),
              if (post.postType == 'image')
                imageOrLinkSizedBox(
                  Image.network(post.imageUrl!, fit: BoxFit.cover),
                ),
              if (post.postType == 'link')
                imageOrLinkSizedBox(
                  AnyLinkPreview(
                    key: ValueKey(post.link),
                    onTap: () => launchUrlFunction(post.link!),
                    link: post.link!,
                    displayDirection: UIDirection.uiDirectionVertical,
                    placeholderWidget: const Center(
                      child: Loader(),
                    ),
                    errorWidget: InkWell(
                      onTap: () => launchUrlFunction(post.link!),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[700]!),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.link_off,
                              color: Colors.redAccent,
                              size: 28,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Preview not available",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Tap to open the link directly.",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  rowIcons(
                    icon: Constants.up,
                    onPressed: user.isGuest ? () {} : () => upVotePost(ref),
                    color: post.upVotes.contains(user.uid) ? Pallete.blueColor : null,
                  ),
                  Text(
                    '${post.upVotes.isEmpty ? '' : post.upVotes.length} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Vote',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  // const SizedBox(width: 10),
                  Text(
                    '${post.downVotes.isEmpty ? '' : post.downVotes.length} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  rowIcons(
                    onPressed: user.isGuest ? () {} : () => donwVotePost(ref),
                    icon: Constants.down,
                    color: post.downVotes.contains(user.uid) ? Pallete.redColor : null,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => goToCommentsPage(post.id),
                    icon: const Icon(Icons.comment, color: Colors.white),
                    label: Text(
                      '${(post.commentCount <= 0) ? 'Comment' : post.commentCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    style: ButtonStyle(
                      // padding: WidgetStateProperty.all(EdgeInsets.zero),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                      shadowColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                  ),
                  const Spacer(),
                  rowIcons(
                    icon: isModerator ? Icons.admin_panel_settings : null,
                  ),
                  const Spacer(),
                  rowIcons(
                    icon: Icons.card_giftcard_outlined,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: user.awards.isEmpty
                                ? const IntrinsicWidth(
                                    child: IntrinsicHeight(
                                      child: Center(
                                        child: Text('No awards'),
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 5,
                                    ),
                                    itemCount: user.awards.length,
                                    itemBuilder: (context, index) {
                                      final award = user.awards[index];
                                      return Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: InkWell(
                                          onTap: () => awardPost(ref, award, context),
                                          child: Image.asset(Constants.awards[award]!),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
