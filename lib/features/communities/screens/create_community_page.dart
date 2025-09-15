import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/common/loader.dart';
import 'package:reddit_clone_app/features/communities/providers/community_providers.dart';
import 'package:reddit_clone_app/theme/pallete.dart';

class CreateCommunity extends ConsumerStatefulWidget {
  const CreateCommunity({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateCommunityState();
}

class _CreateCommunityState extends ConsumerState<CreateCommunity> {
  final TextEditingController communityNameController = TextEditingController();

  void createCommunity() {
    ref
        .read(CommunityProviders.communityControllerProvider.notifier)
        .createCommunity(
          communityNameController.text.trim(),
          context,
        );
  }

  @override
  void dispose() {
    super.dispose();
    communityNameController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(CommunityProviders.communityControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create a Community',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 10,
          right: 10,
        ),
        child: isLoading
            ? const Loader()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Community name'),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    controller: communityNameController,
                    cursorColor: Pallete.blueColor,
                    maxLength: 21,
                    decoration: const InputDecoration(
                      fillColor: Pallete.drawerColor,
                      filled: true,
                      hintText: 'r/Comunity_name',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.all(
                          Radius.circular(7),
                        ),
                      ),
                      contentPadding: EdgeInsets.all(17),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: createCommunity,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Create community',
                      style: TextStyle(
                        color: Pallete.whiteColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
