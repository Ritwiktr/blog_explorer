import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/blog_bloc.dart';
import 'bloc/blog_event.dart';
import 'repository/blog_repository.dart';
import 'screens/blog_list_screen.dart';

void main() {
  final BlogRepository blogRepository = BlogRepository();
  runApp(MyApp(blogRepository: blogRepository));
}

class MyApp extends StatelessWidget {
  final BlogRepository blogRepository;

  MyApp({required this.blogRepository});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BlogBloc(blogRepository: blogRepository)..add(FetchBlogs()),
    child: MaterialApp(
    title: 'Enhanced Blog Explorer',
    theme: ThemeData.dark().copyWith(
    primaryColor: Colors.indigo[700],
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
    backgroundColor: Colors.indigo[700],
    elevation: 0,
    ),
    ),
    home: BlogListScreen(),
    ),
    );
  }
}
