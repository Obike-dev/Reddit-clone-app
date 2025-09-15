import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/providers/firebase_providers.dart';
import 'package:reddit_clone_app/features/communities/controller/community_controller.dart';
import 'package:reddit_clone_app/features/communities/repository/community_repository.dart';
import 'package:reddit_clone_app/models/community_model.dart';

class CommunityProviders {
  static final communityRepositoryProvider = Provider((ref) {
    return CommunityRepository(
      firestore: ref.read(
        FirebaseProviders.firebaseFirestoreProvider,
      ),
    );
  });

  static final communityControllerProvider =
      StateNotifierProvider<CommunityController, bool>((ref) {
    return CommunityController(
      ref: ref,
      communityRepository: ref.watch(communityRepositoryProvider),
      storageRepository: ref.watch(storageRepositoryProvider),
    );
  });

  static final communityProvider = StreamProvider<List<Community>>(
    (ref) {
      return ref
          .watch(communityControllerProvider.notifier)
          .getUserCommunities();
    },
  );

  static final getCommunityByNameProvider = StreamProvider.family(
    (ref, String communityName) {
      return ref
          .watch(communityControllerProvider.notifier)
          .getCommunityByName(communityName);
    },
  );

  static final getUserCommunities = StreamProvider(
    (ref) =>
        ref.watch(communityControllerProvider.notifier).getUserCommunities(),
  );

  static final getCommunityPosts = StreamProvider.family(
    (ref, String communityName) => ref
        .read(communityControllerProvider.notifier)
        .getCommunityPosts(communityName),
  );

  static final debouncedQueryProvider = StateProvider<String>((ref) => '');

  static final searchCommunityProvider = StreamProvider(
    (ref) {
      final query = ref.watch(CommunityProviders.debouncedQueryProvider);
      return ref
          .watch(communityControllerProvider.notifier)
          .searchCommunity(query);
    },
  );

  static final updateCommunityModNotifierProvider =
      StateNotifierProvider<UpdateCommunityModNotifier, bool>(
    (ref) => UpdateCommunityModNotifier(
      ref.watch(CommunityProviders.communityRepositoryProvider),
    ),
  );
  static final selectedCommunityProvider =
      StateProvider<String?>((ref) => null);
}
