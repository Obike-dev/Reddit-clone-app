import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/constants/constant.dart';
import 'package:reddit_clone_app/core/providers/storage_repository.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/features/communities/providers/community_providers.dart';
import 'package:reddit_clone_app/features/communities/repository/community_repository.dart';
import 'package:reddit_clone_app/models/community_model.dart';
import 'package:reddit_clone_app/models/post_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityController extends StateNotifier<bool> {
  final Ref _ref;
  final CommunityRepository _communityRepository;
  final StorageRepository _storageRepository;
  CommunityController({
    required Ref ref,
    required CommunityRepository communityRepository,
    required StorageRepository storageRepository,
  })  : _ref = ref,
        _communityRepository = communityRepository,
        _storageRepository = storageRepository,
        super(false);

  void createCommunity(String userInput, BuildContext context) async {
    state = true;
    final userUid = _ref.read(AuthProviders.userProvider)?.uid ?? '';
    final Community communityModel = Community(
      id: userInput,
      name: userInput,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [userUid],
      mods: [userUid],
    );
    final community =
        await _communityRepository.createCommunity(communityModel);
    state = false;
    community.fold((failure) => showSnackBar(context, failure.message),
        (success) {
      showSnackBar(context, 'Community created succesfuly');
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Community>> getUserCommunities() {
    final userUid = _ref.watch(AuthProviders.userProvider)!.uid;
    return _ref
        .read(CommunityProviders.communityRepositoryProvider)
        .getUserCommunities(userUid);
  }

  Stream<List<Post>> getCommunityPosts(String communityName) {
    return _communityRepository.getCommunityPosts(communityName);
  }

  Stream<Community> getCommunityByName(String communityName) {
    return _communityRepository.getCommunityByName(communityName);
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchCommunity(query);
  }

  void editCommunity({
    required File? avatar,
    required File? banner,
    required Community community,
    required BuildContext context,
  }) {
    uploadAvatarAndBanner<Community>(
      avatar: avatar,
      banner: banner,
      id: community.name,
      avatarPath: 'communities/avatar',
      bannerPath: 'communities/banner',
      data: community,
      copyWithFn: ({avatar, banner}) => community.copyWith(
        avatar: avatar,
        banner: banner,
      ),
      updateFn: _communityRepository.editCommunity,
      context: context,
      storageRepository: _storageRepository,
      setLoading: (val) => state = val,
      redirectPath: '/r/${community.name}',
    );
  }

  void joinCommunity(
    BuildContext context,
    Community community,
    String userUid,
  ) async {
    final result = await _communityRepository.updateCommunityMembership(
      community: community,
      userUid: userUid,
      join: true,
    );

    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (success) => showSnackBar(
        context,
        'You have succesfily joined r/${community.name} community!',
      ),
    );
  }

  void leaveCommunity(
    BuildContext context,
    Community community,
    String userUid,
  ) async {
    final result = await _communityRepository.updateCommunityMembership(
      community: community,
      userUid: userUid,
      join: false,
    );
    result.fold(
      (failure) => showSnackBar(context, failure.message),
      (success) =>
          showSnackBar(context, 'You have left r/${community.name} community'),
    );
  }
}

class UpdateCommunityModNotifier extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  UpdateCommunityModNotifier(this._communityRepository) : super(false);

  void updateCommunityMods({
    required Community community,
    required List<String> uids,
    required BuildContext context,
  }) async {
    state = true;
    final result = await _communityRepository.updateCommunityMods(
      community: community,
      uids: uids,
    );
    state = false;
    result.fold((failure) => showSnackBar(context, failure.message), (success) {
      showSnackBar(context, 'Moderator added successfully');
      Routemaster.of(context).push('/r/${community.name}');
    });
  }
}
