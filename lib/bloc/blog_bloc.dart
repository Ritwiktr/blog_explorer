import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/blog.dart';
import '../repository/blog_repository.dart';
import 'blog_event.dart';


abstract class BlogState extends Equatable {
  const BlogState();

  @override
  List<Object> get props => [];
}

class BlogInitial extends BlogState {}

class BlogLoadInProgress extends BlogState {}

class BlogLoadSuccess extends BlogState {
  final List<Blog> blogs;

  BlogLoadSuccess({required this.blogs});

  @override
  List<Object> get props => [blogs];
}

class BlogLoadFailure extends BlogState {
  final String error;

  BlogLoadFailure({required this.error});

  @override
  List<Object> get props => [error];
}

// Bloc
class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final BlogRepository blogRepository;

  BlogBloc({required this.blogRepository}) : super(BlogInitial()) {
    on<FetchBlogs>((event, emit) async {
      emit(BlogLoadInProgress());
      try {
        final blogs = await blogRepository.fetchBlogs();
        emit(BlogLoadSuccess(blogs: blogs));
      } catch (e) {
        emit(BlogLoadFailure(error: e.toString()));
      }
    });

    on<ToggleFavorite>((event, emit) {
      if (state is BlogLoadSuccess) {
        final List<Blog> updatedBlogs = (state as BlogLoadSuccess).blogs.map((blog) {
          return blog.id == event.blog.id
              ? blog.copyWith(isFavorite: !blog.isFavorite)
              : blog;
        }).toList();
        emit(BlogLoadSuccess(blogs: updatedBlogs));
      }
    });
  }
}
