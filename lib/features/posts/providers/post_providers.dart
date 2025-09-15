import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/providers/firebase_providers.dart';
import 'package:reddit_clone_app/features/posts/controller/post_controller.dart';
import 'package:reddit_clone_app/features/posts/repository/post_repository.dart';
import 'package:reddit_clone_app/features/user_profile/providers/user_model_provider.dart';
import 'package:reddit_clone_app/models/community_model.dart';

class PostProviders {
  static final postRepositoryProvider = Provider<PostRepository>((ref) {
    return PostRepository(
      firestore: ref.read(
        FirebaseProviders.firebaseFirestoreProvider,
      ),
    );
  });
  static final postControllerProvider =
      StateNotifierProvider<PostController, bool>((ref) {
    return PostController(
      ref: ref,
      postRepository: ref.read(postRepositoryProvider),
    );
  });

  static final postsOfCommuntiesUserContainsProvider = StreamProvider.family(
    (ref, List<Community> communities) => ref
        .read(postControllerProvider.notifier)
        .getPostsOfCommuntiesUserContains(communities),
  );

  static final getUserPostsProvider = StreamProvider.family(
    (ref, String uid) => ref
        .read(UserModelProvider.userProfileControllerProvider)
        .getUserPosts(uid),
  );

  static final getPostByIdProvider = StreamProvider.family(
    (ref, String postId) => ref
        .read(PostProviders.postControllerProvider.notifier)
        .getPostById(postId),
  );

  static final getPostCommentsProvider = StreamProvider.family(
    (ref, String postId) => ref
        .read(PostProviders.postControllerProvider.notifier)
        .getPostComments(postId),
  );


  //   static final getNestedComments = StreamProvider.family(
  //   (ref, String commentId) => ref
  //       .read(PostProviders.postControllerProvider.notifier)
  //       .replyComments(commentId),
  // );
}
