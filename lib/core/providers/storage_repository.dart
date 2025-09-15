import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone_app/core/failure.dart';
import 'package:reddit_clone_app/core/type_defs.dart';

class StorageRepository {
  final FirebaseStorage _firebaseStorage;
  StorageRepository({
    required FirebaseStorage firebaseStorage,
  }) : _firebaseStorage = firebaseStorage;

  FutureEither<String> storeFileToFirebaseStorage({
    required String path,
    required String id,
    required File? file,
  }) async {
    try {
      final ref = _firebaseStorage.ref().child(path).child(id);
      final snapshot = await ref.putFile(file!);

      return right(
        await snapshot.ref.getDownloadURL(),
      );
    } catch (e) {
      return left(
        Failure(e.toString()),
      );
    }
  }
}
