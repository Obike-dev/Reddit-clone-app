// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/foundation.dart';

class Post {
  final String id;
  final String title;
  final String? link;
  final String? description;
  final String? imageUrl;
  final String communityName;
  final String communityProfilePhoto;
  final List<String> upVotes;
  final List<String> downVotes;
  final int commentCount;
  final String postAuthor;
  final String postAuthorUid;
  final String postType;
  final DateTime createdAt;
  final List<String> awards;
  Post({
    required this.id,
    required this.title,
    this.link,
    this.description,
    this.imageUrl,
    required this.communityName,
    required this.communityProfilePhoto,
    required this.upVotes,
    required this.downVotes,
    required this.commentCount,
    required this.postAuthor,
    required this.postAuthorUid,
    required this.postType,
    required this.createdAt,
    required this.awards,
  });

  Post copyWith({
    String? id,
    String? title,
    String? link,
    String? description,
    String? imageUrl,
    String? communityName,
    String? communityProfilePhoto,
    List<String>? upVotes,
    List<String>? downVotes,
    int? commentCount,
    String? postAuthor,
    String? postAuthorUid,
    String? postType,
    DateTime? createdAt,
    List<String>? awards,
  }) {
    return Post(
      id: id ?? this.id,
      title: title ?? this.title,
      link: link ?? this.link,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      communityName: communityName ?? this.communityName,
      communityProfilePhoto:
          communityProfilePhoto ?? this.communityProfilePhoto,
      upVotes: upVotes ?? this.upVotes,
      downVotes: downVotes ?? this.downVotes,
      commentCount: commentCount ?? this.commentCount,
      postAuthor: postAuthor ?? this.postAuthor,
      postAuthorUid: postAuthorUid ?? this.postAuthorUid,
      postType: postType ?? this.postType,
      createdAt: createdAt ?? this.createdAt,
      awards: awards ?? this.awards,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'link': link,
      'description': description,
      'imageUrl': imageUrl,
      'communityName': communityName,
      'communityProfilePhoto': communityProfilePhoto,
      'upVotes': upVotes,
      'downVotes': downVotes,
      'commentCount': commentCount,
      'postAuthor': postAuthor,
      'postAuthorUid': postAuthorUid,
      'postType': postType,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'awards': awards,
    };
  }

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'] as String,
      title: map['title'] as String,
      link: map['link'] != null ? map['link'] as String : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      imageUrl: map['imageUrl'] != null ? map['imageUrl'] as String : null,
      communityName: map['communityName'] as String,
      communityProfilePhoto: map['communityProfilePhoto'] as String,
      upVotes: List<String>.from(map['upVotes'] ?? []),
      downVotes: List<String>.from(map['downVotes'] ?? []),
      commentCount: map['commentCount'] as int,
      postAuthor: map['postAuthor'] as String,
      postAuthorUid: map['postAuthorUid'] as String,
      postType: map['postType'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      awards: List<String>.from(map['awards'] ?? []),
    );
  }

  @override
  String toString() {
    return 'Post(id: $id, title: $title, link: $link, description: $description, imageUrl: $imageUrl, communityName: $communityName, communityProfilePhoto: $communityProfilePhoto, upVotes: $upVotes, downVotes: $downVotes, commentCount: $commentCount, postAuthor: $postAuthor, postAuthorUid: $postAuthorUid, postType: $postType, createdAt: $createdAt, awards: $awards)';
  }

  @override
  bool operator ==(covariant Post other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.link == link &&
        other.description == description &&
        other.imageUrl == imageUrl &&
        other.communityName == communityName &&
        other.communityProfilePhoto == communityProfilePhoto &&
        listEquals(other.upVotes, upVotes) &&
        listEquals(other.downVotes, downVotes) &&
        other.commentCount == commentCount &&
        other.postAuthor == postAuthor &&
        other.postAuthorUid == postAuthorUid &&
        other.postType == postType &&
        other.createdAt == createdAt &&
        listEquals(other.awards, awards);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        link.hashCode ^
        description.hashCode ^
        imageUrl.hashCode ^
        communityName.hashCode ^
        communityProfilePhoto.hashCode ^
        upVotes.hashCode ^
        downVotes.hashCode ^
        commentCount.hashCode ^
        postAuthor.hashCode ^
        postAuthorUid.hashCode ^
        postType.hashCode ^
        createdAt.hashCode ^
        awards.hashCode;
  }

  String toJson() => json.encode(toMap());

  factory Post.fromJson(String source) =>
      Post.fromMap(json.decode(source) as Map<String, dynamic>);
}
