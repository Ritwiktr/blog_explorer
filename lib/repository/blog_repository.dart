import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/blog.dart';

class BlogRepository {
  final String url = 'https://intent-kit-16.hasura.app/api/rest/blogs';
  final String adminSecret = '32qR4KmXOIpsGPQKMqEJHGJS27G5s7HdSKO3gdtQd2kv5e852SiYwWNfxkZOBuQ6';
  static const String _boxName = 'blogs';
  late Box<Blog> _box;

  Future<void> initHive() async {
    _box = await Hive.openBox<Blog>(_boxName);
  }

  Future<List<Blog>> fetchBlogs() async {
    try {
      final response = await http.get(Uri.parse(url), headers: {
        'x-hasura-admin-secret': adminSecret,
      });

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body)['blogs'];
        final blogs = jsonList.map((json) => Blog.fromJson(json)).toList();
        await _saveToLocal(blogs);
        return blogs;
      } else {
        throw Exception('Failed to load blogs');
      }
    } catch (e) {
      // If there's an error (e.g., no internet), return local data
      return _getFromLocal();
    }
  }

  Future<void> _saveToLocal(List<Blog> blogs) async {
    await _box.clear();
    for (var blog in blogs) {
      await _box.put(blog.id, blog);
    }
  }

  List<Blog> _getFromLocal() {
    return _box.values.toList();
  }

  Future<void> toggleFavorite(Blog blog) async {
    final updatedBlog = blog.copyWith(isFavorite: !blog.isFavorite);
    await _box.put(blog.id, updatedBlog);
  }

  Future<List<Blog>> getFavoriteBlogs() async {
    return _box.values.where((blog) => blog.isFavorite).toList();
  }
}