import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/error.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/core/common/post_card.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/features/posts/providers/post_providers.dart';
import 'package:reddit_clone_app/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class UserProfilePage extends ConsumerWidget {
  final String userUid;
  const UserProfilePage({
    super.key,
    required this.userUid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPostsAsync =
        ref.watch(PostProviders.getUserPostsProvider(userUid));

    // final updateKarma = ref
    //     .watch(UserModelProvider.userProfileControllerProvider)
    //     .updateKarma(userUid, );

    final userKarma = ref.watch(AuthProviders.userKarmaProvider);

    return Scaffold(
      body: ref.watch(AuthProviders.getUserDataProvider(userUid)).when(
            data: (user) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                // updateKarma;
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Banner image
                            Image.network(
                              user.banner,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 150,
                                width: double.infinity,
                                color: Colors.grey,
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey[300],
                                  size: 40,
                                ),
                              ),
                            ),

                            // Overlapping avatar
                            Positioned(
                              bottom: -40,
                              left: 10,
                              child: CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.black,
                                child: CircleAvatar(
                                  radius: 37,
                                  backgroundImage:
                                      NetworkImage(user.profilePicture),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 60), // for avatar space
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
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
                                    onPressed: () =>
                                        Routemaster.of(context).push(
                                      '/edit-profile/$userUid',
                                    ),
                                    child: const Text(
                                      'Edit Profile',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(userKarma < 0 ? '0' : '$userKarma Karma'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(),
                      ],
                    ),
                  ),
                ];
              },
              body: userPostsAsync.when(
                data: (posts) => ListView.builder(
                  padding: const EdgeInsets.only(top: 20),
                  itemCount: posts.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PostCard(
                      post: posts[index],
                    ),
                  ),
                ),
                error: (error, stackTrace) =>
                    ErrorMessage(error: error.toString()),
                loading: () => const Loader(),
              ),
            ),
            error: (error, stackTrace) => ErrorMessage(
              error: error.toString(),
            ),
            loading: () => const Loader(),
          ),
    );
  }
}
