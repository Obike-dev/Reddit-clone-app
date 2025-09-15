import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reddit_clone_app/core/constants/firebase_constants.dart';
import 'package:reddit_clone_app/core/type_defs.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/models/comment_model.dart';
import 'package:reddit_clone_app/models/community_model.dart';
import 'package:reddit_clone_app/models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference get _posts => _firestore.collection(
        FirebaseConstants.postsCollection,
      );
  CollectionReference get _comments => _firestore.collection(
        FirebaseConstants.commentsCollection,
      );
  CollectionReference get _users => _firestore.collection(
        FirebaseConstants.usersCollection,
      );
  FutureVoid addPost(Post post) async => safeFirestoreCall(
        () => _posts.doc(post.id).set(
              post.toMap(),
            ),
      );

  FutureVoid deletePost(String postId) => safeFirestoreCall(
        () async {
          // Start a batch
          final batch = _firestore.batch();

          // 1. Delete the post
          final postRef = _posts.doc(postId);
          batch.delete(postRef);

          // 2. Get all comments linked to this post
          final commentDocs =
              await _comments.where('postId', isEqualTo: postId).get();

          for (final doc in commentDocs.docs) {
            batch.delete(doc.reference);
          }

          // 3. Commit batch
          await batch.commit();
        },
      );

  FutureVoid editPost(Post post) => safeFirestoreCall(() async {
        _posts.doc(post.id).update(
              post.toMap(),
            );
      });

  Stream<Post> getPostById(String postId) {
    return _posts.doc(postId).snapshots().map(
          (post) => Post.fromMap(
            post.data() as Map<String, dynamic>,
          ),
        );
  }

  Stream<List<Post>> getPostsOfCommuntiesUserContains(
      List<Community> communites) {
    return _posts
        .where(
          'communityName',
          whereIn: communites.map((community) => community.name).toList(),
        )
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((snapshot) =>
                Post.fromMap(snapshot.data() as Map<String, dynamic>))
            .toList());
  }

  void upVotePost(Post post, String userId) {
    toggleVote(post, userId, isUpVote: true);
  }

  void donwVotePost(Post post, String userId) {
    toggleVote(post, userId, isUpVote: false);
  }

  FutureVoid addComment(Comment comment) => safeFirestoreCall(
        () {
          _comments.doc(comment.id).set(
                comment.toMap(),
              );
          return _posts.doc(comment.postId).update({
            'commentCount': FieldValue.increment(1),
          });
        },
      );

  FutureVoid deleteComment(Comment comment) => safeFirestoreCall(
        () {
          _comments.doc(comment.id).delete();

          return _posts.doc(comment.postId).update({
            'commentCount': FieldValue.increment(-1),
          });
        },
      );

  Stream<List<Comment>> getPostComments(String postId) {
    return _comments
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (comments) => comments.docs
              .map((commentData) => Comment.fromMap(
                    commentData.data() as Map<String, dynamic>,
                  ))
              .toList(),
        );
  }

  FutureVoid awardPost(String award, String senderId, Post post) =>
      safeFirestoreCall(() async {
        await _posts.doc(post.id).update({
          'awards': FieldValue.arrayUnion([award]),
        });
        await _users.doc(senderId).update({
          'awards': FieldValue.arrayRemove([award]),
        });
        await _users.doc(post.postAuthorUid).update({
          'awards': FieldValue.arrayUnion([award]),
        });
      });
}
