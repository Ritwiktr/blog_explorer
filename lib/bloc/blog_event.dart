import 'package:equatable/equatable.dart';
import '../models/blog.dart';

abstract class BlogEvent extends Equatable {
  const BlogEvent();

  @override
  List<Object> get props => [];
}

class FetchBlogs extends BlogEvent {}

class ToggleFavorite extends BlogEvent {
  final Blog blog;

  const ToggleFavorite({required this.blog});

  @override
  List<Object> get props => [blog];
}

class FetchFavoriteBlogs extends BlogEvent {}