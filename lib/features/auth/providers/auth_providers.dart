import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone_app/features/auth/repository/auth_repository.dart';
import 'package:reddit_clone_app/models/user_model.dart';

class AuthProviders {
  static final authControllerProvider =
      StateNotifierProvider<AuthController, bool>(
    (ref) {
      return AuthController(
        authRepository: ref.watch(authRepositoryProvider),
        ref: ref,
      );
    },
  );

  static final userProvider = StateProvider<UserModel?>((ref) => null);
  static final authStateChangeProvider = StreamProvider(
    (ref) => ref.watch(authControllerProvider.notifier).authStateChange,
  );

  static final currentUserModelProvider = FutureProvider<UserModel?>(
    (ref) async {
      final userAuthStatus = await ref.watch(authStateChangeProvider.future);
      if (userAuthStatus != null) {
        final userModel = await ref.read(
          getUserDataProvider(userAuthStatus.uid).future,
        );
        ref.read(userProvider.notifier).update((state) => userModel);
        return userModel;
      } else {
        return null;
      }
    },
  );

  static final getUserDataProvider = StreamProvider.family(
    (ref, String uid) {
      return ref.watch(authControllerProvider.notifier).getUserData(uid);
    },
  );
 static final userKarmaProvider =
      StateProvider((ref) => ref.read(AuthProviders.userProvider)!.karma);
 
}
