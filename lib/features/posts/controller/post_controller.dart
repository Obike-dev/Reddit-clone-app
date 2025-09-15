import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/validators.dart';
import 'package:reddit_clone_app/core/providers/firebase_providers.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/features/posts/repository/post_repository.dart';
import 'package:reddit_clone_app/models/comment_model.dart';
import 'package:reddit_clone_app/models/community_model.dart';
import 'package:reddit_clone_app/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

class PostController extends StateNotifier<bool> {
  final Ref _ref;
  final PostRepository _postRepository;
  PostController({
    required Ref ref,
    required PostRepository postRepository,
  })  : _ref = ref,
        _postRepository = postRepository,
        super(false);

  void addPost({
    required String title,
    required BuildContext context,
    required Community selectedCommunity,
    String? description,
    String? link,
    File? imageFile,
    required String postType, // 'text', 'link', 'image'
  }) async {
    state = true;
    final user = _ref.read(AuthProviders.userProvider)!;
    final String postId = const Uuid().v1();
    String? contentValue;

    if (title.trim().isEmpty) {
      showSnackBar(context, 'Please enter a title');
      state = false;
      return;
    }
    // --- VALIDATION BEFORE AWAIT ---
    if (postType == 'text') {
      if (description == null || description.trim().isEmpty) {
        showSnackBar(context, 'Please enter a description');
        state = false;
        return;
      }
      contentValue = description;
      // 1. Get current user
      final user = _ref.read(AuthProviders.userProvider)!;

      // 3. Update local provider immediately
      updateKarmaBy(user.uid, 2, _ref);
    } else if (postType == 'link') {
      if (link == null || link.trim().isEmpty) {
        showSnackBar(context, 'Please enter a link');
        state = false;
        return;
      }
      if (!isValidUrlFormat(link.trim())) {
        showSnackBar(context,
            'Please enter a valid URL (must contain http/https and www.)');
        state = false;
        return;
      }
      contentValue = link;
      // 1. Get current user
      final user = _ref.read(AuthProviders.userProvider)!;

      // 3. Update local provider immediately
      updateKarmaBy(user.uid, 3, _ref);
    }

    // --- HANDLE IMAGE UPLOAD ---
    if (postType == 'image') {
      final storageRepo = _ref.read(storageRepositoryProvider);
      final uploadResult = await storageRepo.storeFileToFirebaseStorage(
        path: 'posts/${selectedCommunity.name}',
        id: postId,
        file: imageFile,
      );

      final uploadFailureOrUrl = uploadResult.fold(
        (failure) {
          // This is still safe because it's directly after await, but if we want to be extra safe:
          if (!context.mounted) return null;
          showSnackBar(context, failure.message);
          return null;
        },
        (url) => url,
      );

      if (uploadFailureOrUrl == null) return;
      contentValue = uploadFailureOrUrl;
      // 1. Get current user
      final user = _ref.read(AuthProviders.userProvider)!;

      // 3. Update local provider immediately
      updateKarmaBy(user.uid, 3, _ref);
    }

    // --- CREATE POST ---
    final post = Post(
      id: postId,
      title: title,
      communityName: selectedCommunity.name,
      communityProfilePhoto: selectedCommunity.avatar,
      upVotes: [],
      downVotes: [],
      commentCount: 0,
      postAuthor: user.name,
      postAuthorUid: user.uid,
      postType: postType,
      createdAt: DateTime.now(),
      awards: [],
      description: postType == 'text' ? contentValue : null,
      link: postType == 'link' ? contentValue : null,
      imageUrl: postType == 'image' ? contentValue : null,
    );

    // --- SAVE POST ---
    final result = await _postRepository.addPost(post);
    state = false;
    result.fold(
      (failure) {
        if (!context.mounted) return;
        showSnackBar(context, failure.message);
      },
      (success) {
        if (!context.mounted) return;
        showSnackBar(context, 'Your post has been sent');
        _ref.read(pageNumberProvider.notifier).state = 0;
        Routemaster.of(context).replace('/');
      },
    );
  }

  void deletePost(BuildContext context, String postId) async {
    final deletedPost = await _postRepository.deletePost(postId);
    deletedPost.fold(
      (failure) => showSnackBar(context, failure.message),
      (success) {
        showSnackBar(context, 'Post has been deleted successfully');

        final user =
            _ref.read(AuthProviders.userProvider)!; // current logged-in user
        updateKarmaBy(user.uid, -1, _ref);

        Routemaster.of(context).push('/');
      },
    );
  }

  void editPost(
    BuildContext context,
    Post post,
    String postType,
  ) async {
    final result = await _postRepository.editPost(post);
    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (success) => showSnackBar(context, 'Post updated successfully'),
    );
  }

  Stream<Post> getPostById(String postId) =>
      _postRepository.getPostById(postId);

  Stream<List<Post>> getPostsOfCommuntiesUserContains(
      List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.getPostsOfCommuntiesUserContains(communities);
    }
    return Stream.value([]);
  }

  void upVotePost(Post post) {
    final uid = _ref.read(AuthProviders.userProvider)!.uid;
    _postRepository.upVotePost(post, uid);
  }

  void donwVotePost(Post post) {
    final uid = _ref.read(AuthProviders.userProvider)!.uid;
    _postRepository.donwVotePost(post, uid);
  }

  void addComment(
    BuildContext context,
    Post post,
    String text,
  ) async {
    final String commentId = const Uuid().v1();
    final user = _ref.read(AuthProviders.userProvider)!;
    final Comment comment = Comment(
      id: commentId,
      text: text,
      createdAt: DateTime.now(),
      postId: post.id,
      commentAuthorName: user.name,
      commentAuthorUid: user.uid,
      commentAuthorPicture: user.profilePicture,
      replies: [],
    );
    final result = await _postRepository.addComment(comment);

    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (success) {
        updateKarmaBy(user.uid, 1, _ref);
      },
    );
  }

  // Stream<List<Comment>> replyComments(String commentId) {
  //  return _postRepository.nestedComments(commentId);
  // }

  void deleteComment(Comment comment) => _postRepository.deleteComment(comment);

  Stream<List<Comment>> getPostComments(String postId) =>
      _postRepository.getPostComments(postId);

  void awardPost({
    required Post post,
    required String award,
    required BuildContext context,
  }) async {
    final user = _ref.read(AuthProviders.userProvider)!;
    final res = await _postRepository.awardPost(award, user.uid, post);

    res.fold((failure) => showSnackBar(context, failure.message), (success) {
      updateKarmaBy(user.uid, 5, _ref);
      _ref.read(AuthProviders.userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }
}
