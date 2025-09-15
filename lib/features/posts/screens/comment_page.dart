import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/error.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/core/common/post_card.dart';
import 'package:reddit_clone_app/features/auth/providers/auth_providers.dart';
import 'package:reddit_clone_app/features/posts/providers/post_providers.dart';
import 'package:reddit_clone_app/features/posts/screens/comment_card.dart';
import 'package:reddit_clone_app/models/post_model.dart';
import 'package:reddit_clone_app/theme/pallete.dart';

class CommentPage extends ConsumerStatefulWidget {
  final String postId;
  const CommentPage({
    super.key,
    required this.postId,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentPageState();
}

class _CommentPageState extends ConsumerState<CommentPage> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    commentController.dispose();
  }

  void addComment(Post post) {
    ref
        .read(PostProviders.postControllerProvider.notifier)
        .addComment(context, post, commentController.text.trim());
    setState(() {
      commentController.text = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(AuthProviders.userProvider)!;
    return ref.watch(PostProviders.getPostByIdProvider(widget.postId)).when(
          data: (post) => Scaffold(
              appBar: AppBar(
                title: Text(post.title),
              ),
              body: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: 10),
                                PostCard(post: post),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                          // Comments
                          ref
                              .watch(
                                PostProviders.getPostCommentsProvider(post.id),
                              )
                              .when(
                                data: (comments) {
                                  return SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        final comment = comments[index];
                                        return Column(
                                          children: [
                                            CommentCard(comment: comment),
                                            const Divider(thickness: 0),
                                          ],
                                        );
                                      },
                                      childCount: comments.length,
                                    ),
                                  );
                                },
                                error: (error, _) => SliverToBoxAdapter(
                                  child: ErrorMessage(error: error.toString()),
                                ),
                                loading: () => const SliverToBoxAdapter(
                                  child: Loader(),
                                ),
                              ),
                        ],
                      ),
                    ),
                    // TextField pinned at bottom
                    if(!user.isGuest)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: commentController,
                        onSubmitted: (value) => addComment(post),
                        decoration: InputDecoration(
                          filled: true,
                          hintText: 'comment',
                          fillColor: Pallete.drawerColor,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey[700] ?? Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          error: (error, stackTrace) => ErrorMessage(
            error: error.toString(),
          ),
          loading: () => const Loader(),
        );
  }
}
