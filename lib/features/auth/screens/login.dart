import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/core/common/sign_in_button.dart';
import 'package:reddit_clone_app/core/constants/constant.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/theme/pallete.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Login extends ConsumerWidget {
  const Login({super.key});

  void signInAsGuest(BuildContext context, WidgetRef ref) {
    ref
        .read(AuthProviders.authControllerProvider.notifier)
        .signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(AuthProviders.authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset(
          Constants.redditLogo,
          height: 30,
        ),
        actions: [
          TextButton(
            onPressed: () => signInAsGuest(context, ref),
            child: Text(
              'Skip',
              style: TextStyle(
                color: Pallete.blueColor,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: isLoading
            ? const Loader()
            : Column(
                children: [
                  const Text(
                    'Dive into anything',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Image.asset(
                      Constants.loginEmote,
                      height: responsiveValue<double>(
                        context,
                        double.infinity,
                        const [
                          Condition.largerThan(name: MOBILE, value: 300),
                          Condition.equals(name: MOBILE, value: 400),
                        ],
                      ).value,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const SignInButton(),
                ],
              ),
      ),
    );
  }
}
