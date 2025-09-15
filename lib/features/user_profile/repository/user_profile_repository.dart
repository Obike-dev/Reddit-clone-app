import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reddit_clone_app/core/constants/firebase_constants.dart';
import 'package:reddit_clone_app/core/type_defs.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/models/post_model.dart';
import 'package:reddit_clone_app/models/user_model.dart';

class UserProfileRepository {
  final FirebaseFirestore _firestore;
  const UserProfileRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference get _users => _firestore.collection(
        FirebaseConstants.usersCollection,
      );

  CollectionReference get _posts => _firestore.collection(
        FirebaseConstants.postsCollection,
      );

  FutureVoid editUserData(UserModel user) async => safeFirestoreCall(
        () => _users.doc(user.uid).update(
              user.toMap(),
            ),
      );

  Stream<List<Post>> getUserPosts(String uid) {
    return _posts
        .where('postAuthorUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((postObject) =>
                Post.fromMap(postObject.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid updateKarma(String uid, int karma) async => safeFirestoreCall(
        () => _users.doc(uid).update({'karma': karma}),
      );
}
