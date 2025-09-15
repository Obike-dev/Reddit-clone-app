// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Comment {
  final String id;
  final String text;
  final DateTime createdAt;
  final String postId;
  final String commentAuthorName;
  final String commentAuthorUid;
  final String commentAuthorPicture;
  final List<Comment> replies;
  Comment({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.postId,
    required this.commentAuthorName,
    required this.commentAuthorUid,
    required this.commentAuthorPicture,
    this.replies = const [],
  });

  Comment copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    String? postId,
    String? commentAuthorName,
    String? commentAuthorUid,
    String? commentAuthorPicture,
    List<Comment>? replies,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      postId: postId ?? this.postId,
      commentAuthorName: commentAuthorName ?? this.commentAuthorName,
      commentAuthorUid: commentAuthorUid ?? this.commentAuthorUid,
      commentAuthorPicture: commentAuthorPicture ?? this.commentAuthorPicture,
      replies: replies ?? this.replies,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'text': text,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'postId': postId,
      'commentAuthorName': commentAuthorName,
      'commentAuthorUid': commentAuthorUid,
      'commentAuthorPicture': commentAuthorPicture,
      'replies': replies.map((x) => x.toMap()).toList(),
    };
  }


factory Comment.fromMap(Map<String, dynamic> map) {
  return Comment(
    id: map['id'] as String,
    text: map['text'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    postId: map['postId'] as String,
    commentAuthorName: map['commentAuthorName'] as String,
    commentAuthorUid: map['commentAuthorUid'] as String, // ✅ must read it too
    commentAuthorPicture: map['commentAuthorPicture'] as String,
  );
}

  @override
  String toString() {
    return 'Comment(id: $id, text: $text, createdAt: $createdAt, postId: $postId, commentAuthorName: $commentAuthorName, commentAuthorUid: $commentAuthorUid, commentAuthorPicture: $commentAuthorPicture, replies: $replies)';
  }

  @override
  bool operator ==(covariant Comment other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.text == text &&
      other.createdAt == createdAt &&
      other.postId == postId &&
      other.commentAuthorName == commentAuthorName &&
      other.commentAuthorUid == commentAuthorUid &&
      other.commentAuthorPicture == commentAuthorPicture &&
      listEquals(other.replies, replies);
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  int get hashCode {
    return id.hashCode ^
      text.hashCode ^
      createdAt.hashCode ^
      postId.hashCode ^
      commentAuthorName.hashCode ^
      commentAuthorUid.hashCode ^
      commentAuthorPicture.hashCode ^
      replies.hashCode;
  }
}
