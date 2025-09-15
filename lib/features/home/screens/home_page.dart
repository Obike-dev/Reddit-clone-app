// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/constants/constant.dart';
import 'package:reddit_clone_app/core/providers/firebase_providers.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/features/home/delegates/search_community_delegate.dart';
import 'package:reddit_clone_app/features/home/drawers/community_list_drawer.dart';
import 'package:reddit_clone_app/features/home/drawers/user_profile_drawer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  void openrightDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void onpageChange(WidgetRef ref, int page) {
    ref.read(pageNumberProvider.notifier).update(
          (state) => page,
        );
  }

  // bool isMobile(BuildContext context) {
  //   if (kIsWeb) return false; // hide for web
  //   final width = MediaQuery.of(context).size.width;
  //   return width < 600; // treat <600px as mobile device
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageNumber = ref.watch(pageNumberProvider);
    final user = ref.watch(AuthProviders.userProvider)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        automaticallyImplyLeading: false,
        leading: MediaQuery.of(context).size.width >= 900
            ? null // 🔹 hide leading on big screens
            : Builder(
                builder: (context) {
                  return IconButton(
                    onPressed: () => openDrawer(context),
                    icon: const Icon(Icons.menu),
                  );
                },
              ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchCommunityDelegate(ref),
              );
            },
            icon: const Icon(Icons.search),
          ),
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.add),
          // ),
          Builder(builder: (context) {
            return IconButton(
              onPressed: () => openrightDrawer(context),
              icon: CircleAvatar(
                backgroundImage: NetworkImage(user.profilePicture),
                radius: 15,
              ),
            );
          })
        ],
      ),
      body: Constants.tabWidgets[pageNumber],
      drawer: const CommunityListDrawer(),
      endDrawer: user.isGuest ? null : const UserProfileDrawer(),
      bottomNavigationBar: user.isGuest
          ? null
          : BottomNavigationBar(
              onTap: (index) => onpageChange(ref, index),
              currentIndex: pageNumber,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: '',
                ),
              ],
            ),
    );
  }
}
