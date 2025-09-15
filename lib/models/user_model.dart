// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/foundation.dart';

class UserModel {
  final String name;
  final String profilePicture;
  final String banner;
  final String uid;
  final bool isGuest;
  final int karma;
  final List<String> awards;

  UserModel({
    required this.name,
    required this.profilePicture,
    required this.banner,
    required this.uid,
    required this.isGuest,
    required this.karma,
    required this.awards,
  });

  UserModel copyWith({
    String? name,
    String? profilePicture,
    String? banner,
    String? uid,
    bool? isGuest,
    int? karma,
    List<String>? awards,
  }) {
    return UserModel(
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      banner: banner ?? this.banner,
      uid: uid ?? this.uid,
      isGuest: isGuest ?? this.isGuest,
      karma: karma ?? this.karma,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'profilePicture': profilePicture,
      'banner': banner,
      'uid': uid,
      'isGuest': isGuest,
      'karma': karma,
      'awards': awards,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] as String,
      profilePicture: map['profilePicture'] as String,
      banner: map['banner'] as String,
      uid: map['uid'] as String,
      isGuest: map['isGuest'] as bool,
      karma: map['karma'] as int,
      awards: List<String>.from(map['awards'] as List),
    );
  }


  @override
  String toString() {
    return 'UserModel(name: $name, profilePicture: $profilePicture, banner: $banner, uid: $uid, isGuest: $isGuest, karma: $karma, awards: $awards,)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.profilePicture == profilePicture &&
        other.banner == banner &&
        other.uid == uid &&
        other.isGuest == isGuest &&
        other.karma == karma &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        profilePicture.hashCode ^
        banner.hashCode ^
        uid.hashCode ^
        isGuest.hashCode ^
        karma.hashCode ^
        awards.hashCode;
  }
}
