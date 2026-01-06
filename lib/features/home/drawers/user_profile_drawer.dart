import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/alert_dialog.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class UserProfileDrawer extends ConsumerWidget {
  const UserProfileDrawer({super.key});

  void logUserOut(WidgetRef ref) {
    ref.read(AuthProviders.authControllerProvider.notifier).logOut();
  }

  ListTile listTile({required Icon icon, required String title, required void Function()? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: icon,
      ),
      title: Text(title),
    );
  }

  void navigageToUserProfile(BuildContext context, String userId) {
    Routemaster.of(context).push('/u/$userId');
  }

  void toggleTheme(WidgetRef ref) async {
    ref.read(themeNotifierProvider.notifier).toggleTheme();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(AuthProviders.userProvider);
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: SafeArea(
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user!.profilePicture),
              ),
              const SizedBox(height: 20),
              Text(
                'u/${user.name}',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Divider(),
              const SizedBox(height: 20),
              Column(
                children: [
                  listTile(
                    icon: const Icon(
                      Icons.person,
                      size: 30,
                    ),
                    title: 'My Profile',
                    onTap: () => navigageToUserProfile(context, user.uid),
                  ),
                  listTile(
                    icon: Icon(
                      Icons.logout,
                      size: 30,
                      color: Pallete.redColor,
                    ),
                    title: 'Log Out',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ReusableAlertDialog(
                            confirmationText: 'Are you sure you want to log out of this application?',
                            onPressedAction: () => logUserOut(ref),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
              // Switch.adaptive(
              //   value: ref.watch(themeNotifierProvider).mode == ThemeMode.dark,
              //   onChanged: (value) => toggleTheme(ref),
              //   activeColor: Colors.greenAccent,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
