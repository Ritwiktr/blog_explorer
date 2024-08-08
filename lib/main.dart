import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'bloc/blog_bloc.dart';
import 'bloc/blog_event.dart';
import 'repository/blog_repository.dart';
import 'screens/blog_list_screen.dart';
import 'models/blog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Only register the adapter if it hasn't been registered yet
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(BlogAdapter());
  }

  final BlogRepository blogRepository = BlogRepository();
  await blogRepository.initHive();
  runApp(MyApp(blogRepository: blogRepository));
}

class MyApp extends StatelessWidget {
  final BlogRepository blogRepository;

  const MyApp({Key? key, required this.blogRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BlogBloc(blogRepository: blogRepository)..add(FetchBlogs()),
      child: MaterialApp(
        title: 'Blog Explorer',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.indigo[700],
          scaffoldBackgroundColor: Colors.grey[900],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.indigo[700],
            elevation: 0,
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: BlogListScreen(),
      ),
    );
  }
}