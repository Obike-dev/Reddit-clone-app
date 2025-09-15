import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/features/posts/providers/post_providers.dart';
import 'package:reddit_clone_app/models/comment_model.dart';
import 'package:routemaster/routemaster.dart';

class CommentCard extends ConsumerWidget {
  final Comment comment;
  // final int depth;

  const CommentCard({
    super.key,
    required this.comment,
    // this.depth = 0,
  });

  void goToUserProfile(BuildContext context) =>
      Routemaster.of(context).push('/u/${comment.commentAuthorUid}');

  void deleteComment(WidgetRef ref, Comment comment) => ref
      .read(PostProviders.postControllerProvider.notifier)
      .deleteComment(comment);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: avatar + name/text + menu
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              InkWell(
                onTap: () => goToUserProfile(context),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(comment.commentAuthorPicture),
                ),
              ),
              const SizedBox(width: 8),

              // Name + text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => goToUserProfile(context),
                      child: Text(
                        'u/${comment.commentAuthorName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      comment.text,
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),

              // Popup menu
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    deleteComment(ref, comment);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    height: 20,
                    child: Text('delete'),
                  ),
                ],
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),

          // Reply button flush with avatar
          Padding(
            padding: const EdgeInsets.only(left: 40), // indent under text
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.reply,
                color: Colors.white,
                size: 16,
              ),
              label: const Text(
                'Reply',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
