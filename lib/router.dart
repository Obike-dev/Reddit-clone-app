import 'package:flutter/material.dart';
import 'package:reddit_clone_app/features/auth/screens/login.dart';
import 'package:reddit_clone_app/features/communities/screens/create_community_page.dart';
import 'package:reddit_clone_app/features/communities/screens/add_moderator_page.dart';
import 'package:reddit_clone_app/features/communities/screens/community_page.dart';
import 'package:reddit_clone_app/features/communities/screens/edit_community_page.dart';
import 'package:reddit_clone_app/features/communities/screens/mod_tools_page.dart';
import 'package:reddit_clone_app/features/home/screens/home_page.dart';
import 'package:reddit_clone_app/features/posts/screens/add_post_type_page.dart';
import 'package:reddit_clone_app/features/posts/screens/comment_page.dart';
import 'package:reddit_clone_app/features/user_profile/screens/edit_user_profile_page.dart';
import 'package:reddit_clone_app/features/user_profile/screens/user_profile_page.dart';
import 'package:routemaster/routemaster.dart';

final unAuthenticatedUsersRoutes = RouteMap(routes: {
  '/': (_) => const MaterialPage(
        child: Login(),
      )
});

final authenticatedUsersRoutes = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(
          child: HomePage(),
        ),
    '/create-community': (_) => const MaterialPage(
          child: CreateCommunity(),
        ),
    '/r/:route': (route) => MaterialPage(
          child: CommunityPage(
            route: route.pathParameters['route']!,
          ),
        ),
    '/mod-tools/:route': (route) => MaterialPage(
          child: ModToolsPage(
            communityName: route.pathParameters['route']!,
          ),
        ),
    '/edit-community/:route': (route) => MaterialPage(
          child: EditCommunityPage(
            communityName: route.pathParameters['route']!,
          ),
        ),
    '/add-moderator/:route': (route) => MaterialPage(
          child: AddModeratorPage(
            communityName: route.pathParameters['route']!,
          ),
        ),
    '/u/:route': (route) => MaterialPage(
          child: UserProfilePage(
            userUid: route.pathParameters['route']!,
          ),
        ),
    '/edit-profile/:route': (route) => MaterialPage(
          child: EditUserProfilePage(
            userUid: route.pathParameters['route']!,
          ),
        ),
    '/add-post/:postType': (route) => MaterialPage(
          child: AddPostTypePage(
            postType: route.pathParameters['postType']!,
          ),
        ),
    '/comments/:postId': (route) => MaterialPage(
          child: CommentPage(
            postId: route.pathParameters['postId']!,
          ),
        ),

  },
);
