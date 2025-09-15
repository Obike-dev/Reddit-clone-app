import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/error.dart';
import 'package:reddit_clone_app/features/communities/providers/community_providers.dart';
import 'package:routemaster/routemaster.dart';

class SearchCommunityDelegate extends SearchDelegate {
  final WidgetRef ref;
  Timer? _debounce;
  SearchCommunityDelegate(this.ref);

  void _onQueryChanged(String newQuery) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(CommunityProviders.debouncedQueryProvider.notifier).state =
          newQuery;
    });
  }

  Widget getSearchResults() {
    _onQueryChanged(query);
    return ref
        .watch(
          CommunityProviders.searchCommunityProvider,
        )
        .when(
            data: (communities) {
              return ListView.builder(
                itemCount: communities.length,
                itemBuilder: (context, index) {
                  final community = communities[index];
                  return ListTile(
                    onTap: () => Routemaster.of(context).push(
                      '/r/${community.name}',
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(community.avatar),
                    ),
                    title: Text(
                      'r/${community.name}',
                    ),
                  );
                },
              );
            },
            error: (error, stackTrace) => ErrorMessage(
                  error: error.toString(),
                ),
            loading: () => const SizedBox());
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          _onQueryChanged('');
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return getSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return getSearchResults();
  }
}
