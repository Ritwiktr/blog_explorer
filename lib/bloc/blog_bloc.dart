import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/blog_repository.dart';
import 'blog_event.dart';
import 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final BlogRepository blogRepository;

  BlogBloc({required this.blogRepository}) : super(BlogInitial()) {
    on<FetchBlogs>((event, emit) async {
      emit(BlogLoading());
      try {
        final blogs = await blogRepository.fetchBlogs();
        emit(BlogLoaded(blogs: blogs));
      } catch (e) {
        emit(BlogError(message: e.toString()));
      }
    });

    on<ToggleFavorite>((event, emit) async {
      if (state is BlogLoaded) {
        final currentState = state as BlogLoaded;
        final updatedBlogs = currentState.blogs.map((blog) {
          return blog.id == event.blog.id
              ? blog.copyWith(isFavorite: !blog.isFavorite)
              : blog;
        }).toList();

        await blogRepository.toggleFavorite(event.blog);
        emit(BlogLoaded(blogs: updatedBlogs));
      }
    });

    on<FetchFavoriteBlogs>((event, emit) async {
      emit(BlogLoading());
      try {
        final favoriteBlogs = await blogRepository.getFavoriteBlogs();
        emit(BlogLoaded(blogs: favoriteBlogs));
      } catch (e) {
        emit(BlogError(message: e.toString()));
      }
    });
  }
}