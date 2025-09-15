import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/constants/constant.dart';
import 'package:reddit_clone_app/core/utils.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/theme/pallete.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SignInButton extends ConsumerWidget {
  final bool isFromLogin;
  const SignInButton({
    super.key,
    this.isFromLogin = true,
  });

  void signInWithGoogle(BuildContext context, WidgetRef ref) {
    ref
        .read(AuthProviders.authControllerProvider.notifier)
        .signInWithGoogle(context, isFromLogin);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => signInWithGoogle(context, ref),
        icon: Image.asset(
          Constants.googleLogo,
          width: 30,
        ),
        label: const Text(
          'Continue with Google',
          style: TextStyle(
            color: Pallete.whiteColor,
            fontWeight: FontWeight.bold,
            fontSize:17,
          ),
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(
            responsiveValue<double>(
              context,
              double.infinity,
              const [
                Condition.largerThan(name: MOBILE, value: 400),
                // Condition.equals(name: MOBILE, value: 400),
              ],
            ).value,
            50,
          ),
          backgroundColor: Pallete.greyColor,
        ),
      ),
    );
  }
}
