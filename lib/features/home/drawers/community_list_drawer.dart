import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/error.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/core/common/sign_in_button.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';

import 'package:reddit_clone_app/features/communities/providers/community_providers.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunityPage(
      BuildContext context, WidgetRef ref, String route) {
    Routemaster.of(context).push('/r/$route');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communities = ref.watch(CommunityProviders.communityProvider);
    final user = ref.watch(AuthProviders.userProvider)!;

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              user.isGuest
                  ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SignInButton(),
                    )
                  : ListTile(
                      onTap: () => navigateToCreateCommunity(context),
                      leading: const Icon(Icons.add),
                      title: const Text('Create a community'),
                    ),
              if (!user.isGuest)
                communities.when(
                  data: (community) {
                    return Expanded(
                      child: ListView.builder(
                        itemCount: community.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => navigateToCommunityPage(
                              context,
                              ref,
                              community[index].name,
                            ),
                            leading: CircleAvatar(
                              backgroundImage:
                                  NetworkImage(community[index].avatar),
                              maxRadius: 15,
                            ),
                            title: Text('r/${community[index].name}'),
                          );
                        },
                      ),
                    );
                  },
                  loading: () {
                    return const Loader();
                  },
                  error: (error, stackTrace) {
                    return ErrorMessage(error: error.toString());
                  },
                )
            ],
          ),
        ),
      ),
    );
  }
}
