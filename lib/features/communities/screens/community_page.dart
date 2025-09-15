import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/error.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/core/common/post_card.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/features/communities/providers/community_providers.dart';
import 'package:reddit_clone_app/models/community_model.dart';
import 'package:reddit_clone_app/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class CommunityPage extends ConsumerWidget {
  final String route;
  const CommunityPage({
    super.key,
    required this.route,
  });

  OutlinedButton mod0rJoinButton(String text, void Function()? onPressed) =>
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(120, 35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: const BorderSide(
            color: Pallete.greyColor,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(color: Colors.blue),
        ),
      );

  void joinCommunity(
    BuildContext context,
    Community community,
    WidgetRef ref,
    String userUid,
  ) {
    ref
        .read(CommunityProviders.communityControllerProvider.notifier)
        .joinCommunity(context, community, userUid);
  }

  void leaveCommunity(
    BuildContext context,
    Community community,
    WidgetRef ref,
    String userUid,
  ) {
    ref
        .read(CommunityProviders.communityControllerProvider.notifier)
        .leaveCommunity(context, community, userUid);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(AuthProviders.userProvider);

    return Scaffold(
      body: ref
          .watch(CommunityProviders.getCommunityByNameProvider(route))
          .when(
            data: (community) => NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 150,
                      floating: true,
                      snap: true,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              community.banner,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[500],
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Align(
                              alignment: Alignment.topLeft,
                              child: CircleAvatar(
                                maxRadius: 30,
                                backgroundImage: NetworkImage(community.avatar),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'r/${community.name}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                if(!user!.isGuest)
                                community.mods.contains(user.uid)
                                    ? mod0rJoinButton(
                                        'Mod Tools',
                                        () => Routemaster.of(context)
                                            .push('/mod-tools/$route'),
                                      )
                                    : mod0rJoinButton(
                                        community.members.contains(user.uid)
                                            ? 'Joined'
                                            : 'Join',
                                        () => joinCommunity(
                                            context, community, ref, user.uid),
                                      )
                              ],
                            ),
                            Text(
                              '${community.members.length} member/s',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: ref
                    .watch(CommunityProviders.getCommunityPosts(community.name))
                    .when(
                      data: (communities) => ListView.builder(
                        padding:const EdgeInsets.all(0),
                        itemCount: communities.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PostCard(
                            post: communities[index],
                          ),
                        ),
                      ),
                      error: (error, stackTrace) => ErrorMessage(
                        error: error.toString(),
                      ),
                      loading: () => const Loader(),
                    )),
            error: (error, stackTrace) => ErrorMessage(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
