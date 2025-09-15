import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/error.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/features/communities/providers/community_providers.dart';
import 'package:reddit_clone_app/models/community_model.dart';

class AddModeratorPage extends ConsumerStatefulWidget {
  final String communityName;
  const AddModeratorPage({
    super.key,
    required this.communityName,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddModeratorPageState();
}

class _AddModeratorPageState extends ConsumerState<AddModeratorPage> {
  Set<String> uids = {};

  bool initialized = false;
  void addUid(String moderator) {
    setState(() {
      uids.add(moderator);
    });
  }

  void removeUid(String moderator) {
    setState(() {
      uids.remove(moderator);
    });
  }

  void saveModerator({
    required WidgetRef ref,
    required BuildContext context,
    required List<String> uids,
    required Community community,
  }) {
    ref
        .read(CommunityProviders.updateCommunityModNotifierProvider.notifier)
        .updateCommunityMods(
          community: community,
          uids: uids.toList(),
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
     final communityAsyncValue = ref.watch(
    CommunityProviders.getCommunityByNameProvider(widget.communityName),
  );

  final isLoading = ref.watch(CommunityProviders.updateCommunityModNotifierProvider);

  final community = communityAsyncValue.asData?.value;
    return Scaffold(
      appBar: AppBar(
        title: Text('r/${widget.communityName}'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => saveModerator(
              ref: ref,
              context: context,
              uids: uids.toList(),
              community: community!,
            ),
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: isLoading ? const Loader() : ref
          .watch(CommunityProviders.getCommunityByNameProvider(
              widget.communityName))
          .when(
            data: (community) => Padding(
              padding: const EdgeInsets.only(top: 20),
              child: ListView.builder(
                itemCount: community.members.length,
                itemBuilder: (context, index) => ref
                    .watch(
                      AuthProviders.getUserDataProvider(
                          community.members[index]),
                    )
                    .when(
                      data: (user) {
                        if (!initialized) {
                          uids.addAll(community.mods);
                          initialized = true;
                        }

                        return CheckboxListTile.adaptive(
                          title: Text(
                            user.name,
                            style: const TextStyle(fontSize: 17),
                          ),
                          value: uids.contains(user.uid),
                          onChanged: (value) {
                            if (value!) {
                              addUid(user.uid);
                            } else {
                              removeUid(user.uid);
                            }
                          },
                        );
                      },
                      error: (error, stackTrace) => ErrorMessage(
                        error: error.toString(),
                      ),
                      loading: () => const Loader(),
                    ),
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
