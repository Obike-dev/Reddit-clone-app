import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/features/auth/repository/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/models/user_model.dart';

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;
  AuthController({
    required AuthRepository authRepository,
    required Ref ref,
  })  : _authRepository = authRepository,
        _ref = ref,
        super(false);

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  void signInWithGoogle(BuildContext context, bool isFromLogin) async {
    state = true;
    final user = await _authRepository.signInWithGoogle(isFromLogin);
    state = false;
    user.fold(
      (failure) => showSnackBar(context, failure.message),
      (success) {
        _ref
            .read(AuthProviders.userProvider.notifier)
            .update((state) => success);
      },
    );
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void signInAsGuest(BuildContext context) async {
    state = true;
    final user = await _authRepository.signInAsGuest();
    state = false;
    user.fold(
      (failure) => showSnackBar(context, failure.message),
      (success) {
        _ref
            .read(AuthProviders.userProvider.notifier)
            .update((state) => success);
      },
    );
  }

  void logOut() async {
    _authRepository.logOut();
  }
}
