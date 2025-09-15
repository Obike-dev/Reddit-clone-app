import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone_app/core/constants/firebase_constants.dart';
import 'package:reddit_clone_app/core/failure.dart';
import 'package:reddit_clone_app/core/type_defs.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/models/community_model.dart';
import 'package:reddit_clone_app/models/post_model.dart';

class CommunityRepository {
  final FirebaseFirestore _firestore;
  CommunityRepository({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  CollectionReference get _communities => _firestore.collection(
        FirebaseConstants.communitiesCollection,
      );
  CollectionReference get _posts => _firestore.collection(
        FirebaseConstants.postsCollection,
      );
  FutureVoid createCommunity(Community community) async {
    try {
      final communityDocument = await _communities.doc(community.name).get();
      if (communityDocument.exists) {
        throw 'Community with this name already exists';
      }

      return right(
        _communities.doc(community.name).set(
              community.toMap(),
            ),
      );
    } on FirebaseException catch (error) {
      return left(
        Failure(
          error.message ?? 'Error creating community. Please try again later',
        ),
      );
    } catch (error) {
      return left(
        Failure(
          error.toString(),
        ),
      );
    }
  }

  Stream<List<Community>> getUserCommunities(String uid) {
    return _communities.where('members', arrayContains: uid).snapshots().map(
      (snapshot) {
        List<Community> communities = [];
        for (var snapshot in snapshot.docs) {
          communities.add(
            Community.fromMap(
              snapshot.data() as Map<String, dynamic>,
            ),
          );
        }
        return communities;
      },
    );
  }

  Stream<Community> getCommunityByName(String communityName) {
    return _communities.doc(communityName).snapshots().map(
          (snapshot) => Community.fromMap(
            snapshot.data() as Map<String, dynamic>,
          ),
        );
  }

  Stream<List<Post>> getCommunityPosts(String communityName) {
    return _posts
        .where('communityName', isEqualTo: communityName)
        .snapshots()
        .map((community) => community.docs
            .map(
              (communityData) => Post.fromMap(
                communityData.data() as Map<String, dynamic>,
              ),
            )
            .toList());
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communities
        .where(
          'name',
          isGreaterThanOrEqualTo: query.isEmpty ? 0 : query,
          isLessThan: query.isEmpty
              ? null
              : query.substring(0, query.length - 1) +
                  String.fromCharCode(
                    query.codeUnitAt(query.length - 1) + 1,
                  ),
        )
        .snapshots()
        .map((snapshot) {
      List<Community> communites = [];
      for (var community in snapshot.docs) {
        communites.add(
          Community.fromMap(
            community.data() as Map<String, dynamic>,
          ),
        );
      }
      return communites;
    });
  }

  FutureVoid editCommunity(Community community) async => safeFirestoreCall(
        () => _communities.doc(community.id).update(
              community.toMap(),
            ),
      );

  FutureVoid updateCommunityMembership({
    required Community community,
    required String userUid,
    required bool join, // true = join, false = leave
  }) async {
    try {
      final DocumentSnapshot<Object?> doc =
          await _communities.doc(community.id).get();
      final List<String> members = List<String>.from(doc['members'] ?? []);

      final bool isMember = members.contains(userUid);

      if (join) {
        if (isMember) {
          throw 'You are already a member of this community';
        }
        members.add(userUid);
      } else {
        if (!isMember) {
          throw 'You are not a member of this community';
        }
        members.remove(userUid);
      }

      final updatedCommunity = community.copyWith(members: members);

      return right(
        _communities.doc(community.id).update(
              updatedCommunity.toMap(),
            ),
      );
    } catch (e) {
      return left(
        Failure(e.toString()),
      );
    }
  }

  FutureVoid updateCommunityMods({
    required Community community,
    required List<String> uids,
  }) async {
    try {
      final updatedCommunity = community.copyWith(
        mods: uids,
      );
      return right(
        _communities.doc(community.id).update(
              updatedCommunity.toMap(),
            ),
      );
    } catch (e) {
      return left(
        Failure(e.toString()),
      );
    }
  }
}
