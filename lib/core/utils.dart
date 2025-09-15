import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone_app/core/constants/firebase_constants.dart';
import 'package:reddit_clone_app/core/failure.dart';
import 'dart:io';
import 'package:reddit_clone_app/core/providers/storage_repository.dart';
import 'package:reddit_clone_app/core/type_defs.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/features/user_profile/providers/user_model_provider.dart';
import 'package:reddit_clone_app/models/post_model.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:routemaster/routemaster.dart';

CollectionReference get _posts => FirebaseFirestore.instance.collection(
      FirebaseConstants.postsCollection,
    );

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
}

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(
    type: FileType.image,
  );
  return image;
}

Future<void> toggleVote(
  Post post,
  String userId, {
  required bool isUpVote,
}) async {
  final docRef = _posts.doc(post.id);

  // Decide which fields to target
  final targetField = isUpVote ? 'upVotes' : 'downVotes';
  final oppositeField = isUpVote ? 'downVotes' : 'upVotes';

  // Build the update map in one go
  final updates = <String, dynamic>{};

  // Always remove from opposite
  updates[oppositeField] = FieldValue.arrayRemove([userId]);

  // Toggle target
  if ((isUpVote ? post.upVotes : post.downVotes).contains(userId)) {
    updates[targetField] = FieldValue.arrayRemove([userId]);
  } else {
    updates[targetField] = FieldValue.arrayUnion([userId]);
  }

  // Perform single update
  await docRef.update(updates);
}

FutureVoid safeFirestoreCall(
  Future<void> Function() action,
) async {
  try {
    await action(); // run the Firestore action
    return right(null);
  } on FirebaseException catch (error) {
    return left(
      Failure(
        error.message ?? error.toString(),
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

typedef CopyWithFn<T> = T Function({String? avatar, String? banner});
typedef UpdateFn<T> = FutureVoid Function(T data);

Future<void> uploadAvatarAndBanner<T>({
  required File? avatar,
  required File? banner,
  required String id,
  required String avatarPath,
  required String bannerPath,
  required T data,
  required CopyWithFn<T> copyWithFn,
  required UpdateFn<T> updateFn,
  required BuildContext context,
  required StorageRepository storageRepository,
  required void Function(bool) setLoading,
  String? redirectPath,
}) async {
  String? avatarUrl;
  String? bannerUrl;

  setLoading(true);

  if (avatar != null) {
    final avatarImage = await storageRepository.storeFileToFirebaseStorage(
      path: avatarPath,
      id: id,
      file: avatar,
    );
    avatarImage.fold(
      (failure) => showSnackBar(context, failure.message),
      (url) => avatarUrl = url,
    );
  }

  if (banner != null) {
    final bannerImage = await storageRepository.storeFileToFirebaseStorage(
      path: bannerPath,
      id: id,
      file: banner,
    );
    bannerImage.fold(
      (failure) => showSnackBar(context, failure.message),
      (url) => bannerUrl = url,
    );
  }

  final updatedData = copyWithFn(avatar: avatarUrl, banner: bannerUrl);
  final result = await updateFn(updatedData);

  setLoading(false);

  result.fold(
    (failure) => showSnackBar(context, failure.message),
    (_) {
      if (redirectPath != null) {
        Routemaster.of(context).push(redirectPath);
      }
      showSnackBar(context, 'Photo updated successfully');
    },
  );
}

void updateKarmaBy(String uid, int delta, Ref ref) {
  final currentKarma = ref.read(AuthProviders.userKarmaProvider);
  final newKarma = currentKarma + delta;

  // 1. Update local provider immediately
  ref.read(AuthProviders.userKarmaProvider.notifier).update((_) => newKarma);

  // 2. Persist to Firestore
  ref
      .read(UserModelProvider.userProfileControllerProvider)
      .updateKarma(uid, newKarma);
  // _userProfileRepository.updateKarma(uid, newKarma);
}

ResponsiveValue<T> responsiveValue<T>(
  BuildContext context,
  T defaultValue,
  List<Condition<T>> conditionalValues,
) {
  return ResponsiveValue<T>(
    context,
    defaultValue: defaultValue,
    conditionalValues: conditionalValues,
  );
}

