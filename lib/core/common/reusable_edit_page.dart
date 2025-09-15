import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone_app/core/constants/constant.dart';

class ReusableEditPage extends ConsumerWidget {
  final File? bannerImage;
  final File? avatarImage;
  final String? defaultBanner;
  final String? defaultAvatar;
  final bool showAvatar;
  final VoidCallback? onBannerTap;
  final VoidCallback? onAvatarTap;
  const ReusableEditPage({
    super.key,
    this.bannerImage,
    this.avatarImage,
    this.defaultBanner,
    this.defaultAvatar,
    this.onBannerTap,
    this.onAvatarTap,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      alignment: Alignment.bottomLeft,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onBannerTap,
          child: SizedBox(
            width: double.infinity,
            height: 200,
            child: DottedBorder(
              options: const RoundedRectDottedBorderOptions(
                radius: Radius.circular(15),
                dashPattern: [10, 4],
                strokeCap: StrokeCap.round,
                strokeWidth: 2,
                color: Colors.grey,
              ),
              child: bannerImage != null
                  ? Image.file(
                      bannerImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : (defaultBanner == null ||
                          defaultBanner!.isEmpty ||
                          defaultBanner == Constants.bannerDefault)
                      ? const Center(
                          child: Icon(Icons.camera_alt_outlined, size: 40),
                        )
                      : Image.network(
                          defaultBanner!,
                          fit: BoxFit.cover,
                        ),
            ),
          ),
        ),
        if (showAvatar)
        Positioned(
          left: 20,
          child: GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 30,
              backgroundImage: avatarImage != null
                  ? FileImage(avatarImage!)
                  : (defaultAvatar != null
                      ? NetworkImage(defaultAvatar!)
                      : const AssetImage('assets/default_avatar.png')
                          as ImageProvider),
            ),
          ),
        ),
      ],
    );
  }
}
