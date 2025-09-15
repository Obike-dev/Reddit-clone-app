import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/features/posts/providers/post_providers.dart';
import 'package:routemaster/routemaster.dart';
// import 'package:reddit_clone_app/theme/pallete.dart';

class AddPostPage extends ConsumerWidget {
  const AddPostPage({super.key});

  final double cardWidthAndHeight = 120;
  final double iconSize = 40;

  void goToPostTypePage(BuildContext context, String postType) {
    Routemaster.of(context).push('/add-post/$postType');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final theme = ref.watch(themeNotifierProvider).themeData;
    final isLoading = ref.watch(PostProviders.postControllerProvider);

    GestureDetector addPost(IconData icon, String postType) => GestureDetector(
          onTap: () => goToPostTypePage(context, postType),
          child: Wrap(
            children: [
              SizedBox(
                height: cardWidthAndHeight,
                width: cardWidthAndHeight,
                child: Card(
                  //  color: theme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 16,
                  child: Center(
                    child: Icon(
                      icon,
                      size: iconSize,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

    return isLoading
        ? const Loader()
        : Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                addPost(Icons.image_outlined, 'image'),
                addPost(Icons.font_download_outlined, 'text'),
                addPost(Icons.link_outlined, 'link'),
              ],
            ),
          );
  }
}
