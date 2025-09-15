import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/error.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/firebase_options.dart';
import 'package:reddit_clone_app/router.dart';
import 'package:reddit_clone_app/theme/pallete.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:routemaster/routemaster.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(
    child: RedditClone(),
  ));
}

class RedditClone extends ConsumerStatefulWidget {
  const RedditClone({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RedditCloneState();
}

class _RedditCloneState extends ConsumerState<RedditClone> {
  @override
  Widget build(BuildContext context) {
    final userModelAsync = ref.watch(AuthProviders.currentUserModelProvider);

    MaterialApp materialAppRouter(RouteMap route) => MaterialApp.router(
          routerDelegate: RoutemasterDelegate(
            routesBuilder: (context) => route,
          ),
          routeInformationParser: const RoutemasterParser(),
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ref.watch(themeNotifierProvider).themeData,
          builder: (context, child) => ResponsiveBreakpoints.builder(
            child: child!,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1000, name: DESKTOP),
              const Breakpoint(start: 1001, end: double.infinity, name: '4K'),
            ],
          ),
        );

    return userModelAsync.when(
      data: (userModel) {
        if (userModel == null) {
          return materialAppRouter(unAuthenticatedUsersRoutes);
        }
        return materialAppRouter(authenticatedUsersRoutes);
      },
      loading: () => MaterialApp(
        home: const Loader(),
        theme: ref.watch(themeNotifierProvider).themeData,
      ),
      error: (e, _) => ErrorMessage(
        error: e.toString(),
      ),
    );
  }
}
