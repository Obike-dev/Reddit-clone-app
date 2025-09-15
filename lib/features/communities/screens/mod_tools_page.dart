import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

class ModToolsPage extends ConsumerWidget {
  final String communityName;
  const ModToolsPage({
    super.key,
    required this.communityName,
  });
  ListTile navigateToEditOrAddModPage({
    required icon,
    required String text,
    required String route,
    required BuildContext context,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(text),
      onTap: () {
        Routemaster.of(context).push(route);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mod Tools'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            navigateToEditOrAddModPage(
              context: context,
              icon: Icons.add_moderator,
              text: 'Add Moderator',
              route: '/add-moderator/$communityName',
            ),
            navigateToEditOrAddModPage(
              context: context,
              icon: Icons.edit,
              text: 'Edit Community',
              route: '/edit-community/$communityName',
            ),
          ],
        ),
      ),
    );
  }
}
