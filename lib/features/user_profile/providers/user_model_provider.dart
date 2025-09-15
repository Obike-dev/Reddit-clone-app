import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/providers/firebase_providers.dart';
import 'package:reddit_clone_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_clone_app/features/user_profile/repository/user_profile_repository.dart';

class UserModelProvider {
  static final userProfileRepositoryProvider = Provider<UserProfileRepository>(
    (ref) {
      return UserProfileRepository(
        firestore: ref.read(
          FirebaseProviders.firebaseFirestoreProvider,
        ),
      );
    },
  );

  static final userProfileControllerProvider = Provider<UserProfileController>(
    (ref) {
      return UserProfileController(
          ref: ref,
          userProfileRepository: ref.watch(
            UserModelProvider.userProfileRepositoryProvider,
          ),
          storageRepository: ref.watch(
            storageRepositoryProvider,
          ));
    },
  );

 
}
