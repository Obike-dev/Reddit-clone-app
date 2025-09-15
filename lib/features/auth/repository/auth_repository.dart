import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone_app/core/constants/constant.dart';
import 'package:reddit_clone_app/core/constants/firebase_constants.dart';
import 'package:reddit_clone_app/core/failure.dart';
import 'package:reddit_clone_app/core/providers/firebase_providers.dart';
import 'package:reddit_clone_app/core/type_defs.dart';
import 'package:reddit_clone_app/models/user_model.dart';

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(
    firestore: ref.read(FirebaseProviders.firebaseFirestoreProvider),
    auth: ref.read(FirebaseProviders.firebaseAuthProvider),
    googleSignIn: ref.read(FirebaseProviders.googleSignInProvider),
  );
});

class AuthRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  AuthRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required GoogleSignIn googleSignIn,
  })  : _firestore = firestore,
        _auth = auth,
        _googleSignIn = googleSignIn;

  CollectionReference get _users => _firestore.collection(
        FirebaseConstants.usersCollection,
      );

  Stream<User?> get authStateChange => _auth.authStateChanges();

  FutureEither<UserModel> signInWithGoogle(bool isFromLogin) async {
    try {
      final UserCredential userCredential;
      if (kIsWeb) {
        GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
        googleAuthProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        userCredential = await _auth.signInWithPopup(googleAuthProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth?.idToken,
          accessToken: googleAuth?.accessToken,
        );

        if (isFromLogin) {
          userCredential = await _auth.signInWithCredential(credential);
        } else {
          userCredential =
              await _auth.currentUser!.linkWithCredential(credential);
        }
      }

      final UserModel userModel;
      if (userCredential.additionalUserInfo!.isNewUser) {
        userModel = UserModel(
          name: userCredential.user?.displayName ?? 'Untitled',
          profilePicture:
              userCredential.user?.photoURL ?? Constants.avatarDefault,
          banner: Constants.bannerDefault,
          uid: userCredential.user!.uid,
          isGuest: userCredential.user!.isAnonymous,
          karma: 0,
          awards: [
            'awesomeAns',
            'gold',
            'platinum',
            'helpful',
            'plusone',
            'rocket',
            'thankyou',
            'til',
          ],
        );
        await _users.doc(userCredential.user!.uid).set(
              userModel.toMap(),
            );
      } else {
        userModel = await getUserData(userCredential.user!.uid).first;
      }

      return right(userModel);
    } on FirebaseException catch (e) {
      return left(
        Failure(e.message ?? 'Something unexpected happened. Try agian later'),
      );
    } catch (e) {
      return left(
        Failure(e.toString()),
      );
    }
  }

  FutureEither<UserModel> signInAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final UserModel userModel = UserModel(
        name: 'Guest',
        profilePicture: Constants.avatarDefault,
        banner: Constants.bannerDefault,
        uid: userCredential.user!.uid,
        isGuest: userCredential.user!.isAnonymous,
        karma: 0,
        awards: [],
      );
      await _users.doc(userCredential.user!.uid).set(
            userModel.toMap(),
          );
      return right(userModel);
    } on FirebaseException catch (e) {
      return left(
        Failure(e.message ?? 'Something unexpected happened. Try agian later'),
      );
    } catch (e) {
      return left(
        Failure(e.toString()),
      );
    }
  }

  Stream<UserModel> getUserData(String uid) {
    return _users.doc(uid).snapshots().map(
          (snapshot) => UserModel.fromMap(
            snapshot.data() as Map<String, dynamic>,
          ),
        );
  }

  void logOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
