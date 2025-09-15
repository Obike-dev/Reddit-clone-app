import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reddit_clone_app/core/providers/storage_repository.dart';

final storageRepositoryProvider = StateProvider(
  (ref) => StorageRepository(
    firebaseStorage: ref.watch(
      FirebaseProviders.firebaseStorageProvider,
    ),
  ),
);

final pageNumberProvider = StateProvider<int>((ref) {
  return 0;
});

class FirebaseProviders {
  static final firebaseFirestoreProvider =
      Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

  static final firebaseAuthProvider =
      Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

  static final firebaseStorageProvider =
      Provider<FirebaseStorage>((ref) => FirebaseStorage.instance);

  static final googleSignInProvider =
      Provider<GoogleSignIn>((ref) => GoogleSignIn());
}
