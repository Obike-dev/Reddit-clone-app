import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/error.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/core/common/post_card.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/features/communities/providers/community_providers.dart';
import 'package:reddit_clone_app/features/posts/providers/post_providers.dart';
import 'package:reddit_clone_app/theme/pallete.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:routemaster/routemaster.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  String? selectedCommunity; // store selected community name or id

  final chipCommunityProvider = StateProvider<String?>((ref) => null);

  ChoiceChip communityChip({
    required String communityName,
    required bool isSeleected,
    required VoidCallback onSelected,
    String? url,
  }) =>
      ChoiceChip(
        showCheckmark: false,
        avatar: CircleAvatar(
          backgroundImage: NetworkImage(url ?? ''),
          radius: 12,
        ),
        label: Text(
          communityName,
          style: TextStyle(
            color: ref.read(chipCommunityProvider) == communityName
                ? Colors.white
                : Colors.grey[300],
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: isSeleected,
        selectedColor: const Color.fromARGB(50, 58, 124, 165), // subtle red
        backgroundColor: Colors.grey[850],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: ref.read(chipCommunityProvider) == communityName
                ? const Color.fromARGB(50, 120, 200, 255)
                : Colors.grey[700]!,
          ),
        ),
        onSelected: (_) => onSelected(),
      );
  void navigateToCommunityPage(
      BuildContext context, WidgetRef ref, String route) {
    Routemaster.of(context).push('/r/$route');
  }

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  @override
  Widget build(BuildContext context) {
    final userCommunitiesAsync =
        ref.watch(CommunityProviders.getUserCommunities);

    return userCommunitiesAsync.when(
      data: (communities) {
        if (communities.isEmpty) {
          return const Center(child: Text('Join a community to see posts.'));
        }

        final postsAsync = ref.watch(
            PostProviders.postsOfCommuntiesUserContainsProvider(communities));
        return userCommunitiesAsync.when(
          data: (communities) {
            if (communities.isEmpty) {
              return const Center(
                  child: Text('Join a community to see posts.'));
            }
            return Row(
              children: [
                if (MediaQuery.of(context).size.width >= 1020)
                  Container(
                    width: 300,
                    color: Pallete.blackColor,
                    child: Column(
                      children: [
                        const SizedBox(height: 15),
                        ListTile(
                          onTap: () => navigateToCreateCommunity(context),
                          leading: const Icon(Icons.add),
                          title: const Text('Create a community'),
                        ),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.builder(
                            itemCount: communities.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                onTap: () => navigateToCommunityPage(
                                  context,
                                  ref,
                                  communities[index].name,
                                ),
                                leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(communities[index].avatar),
                                  maxRadius: 15,
                                ),
                                title: Text('r/${communities[index].name}'),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                if (MediaQuery.of(context).size.width >= 1020)
                  Container(width: 1, color: Pallete.drawerColor),
                Expanded(
                  child: Column(
                    crossAxisAlignment: responsiveValue<CrossAxisAlignment>(
                      context,
                      CrossAxisAlignment.start,
                      const [
                        Condition.largerThan(
                          name: MOBILE,
                          value: CrossAxisAlignment.center,
                        )
                      ],
                    ).value,
                    children: [
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Align(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: communityChip(
                                    communityName: 'All',
                                    isSeleected:
                                        ref.watch(chipCommunityProvider) == null,
                                    onSelected: () => ref
                                        .watch(chipCommunityProvider.notifier)
                                        .update((state) => null),
                                  ),
                                ),
                              ),
                              ...communities.map(
                                (community) {
                                  return Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: communityChip(
                                        communityName: community.name,
                                        isSeleected:
                                            ref.watch(chipCommunityProvider) ==
                                                community.name,
                                        url: community.avatar,
                                        onSelected: () => ref
                                            .watch(chipCommunityProvider.notifier)
                                            .update((state) => community.name),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: postsAsync.when(
                          data: (posts) {
                            final filteredPosts =
                                ref.watch(chipCommunityProvider) == null
                                    ? posts
                                    : posts
                                        .where((p) =>
                                            p.communityName ==
                                            ref.watch(chipCommunityProvider))
                                        .toList();

                            if (filteredPosts.isEmpty) {
                              return const Center(child: Text('No posts yet.'));
                            }

                            return ScrollConfiguration(
                              behavior: const ScrollBehavior()
                                  .copyWith(scrollbars: false),
                              child: ListView.builder(
                                itemCount: filteredPosts.length,
                                itemBuilder: (context, index) {
                                  final post = filteredPosts[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: PostCard(post: post),
                                  );
                                },
                              ),
                            );
                          },
                          loading: () => const Loader(),
                          error: (e, st) => ErrorMessage(error: e.toString()),
                        ),
                      ),
                    ],
                  ),
                ),
                if (MediaQuery.of(context).size.width >= 1020)
                  Container(width: 1, color: Pallete.drawerColor),
                if (MediaQuery.of(context).size.width >= 1020)
                  const SizedBox(width: 300),
              ],
            );
          },
          loading: () => const Loader(),
          error: (e, st) => ErrorMessage(error: e.toString()),
        );
      },
      loading: () => const Loader(),
      error: (e, st) => ErrorMessage(error: e.toString()),
    );
  }
}
