import 'dart:convert';
import 'package:hive/hive.dart';

part 'blog.g.dart';

@HiveType(typeId: 0)
class Blog {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final bool isFavorite;

  Blog({
    required this.id,
    required this.title,
    required this.imageUrl,
    this.isFavorite = false,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image_url': imageUrl,
      'is_favorite': isFavorite,
    };
  }

  static List<Blog> fromJsonList(String jsonString) {
    final data = json.decode(jsonString);
    if (data is Map<String, dynamic> && data['blogs'] is List) {
      return List<Blog>.from(data['blogs'].map((item) => Blog.fromJson(item)));
    } else {
      throw Exception('Failed to parse blogs');
    }
  }

  Blog copyWith({String? id, String? title, String? imageUrl, bool? isFavorite}) {
    return Blog(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}