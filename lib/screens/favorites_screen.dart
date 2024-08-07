import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/blog_bloc.dart';
import 'blog_detail_screen.dart';

class FavoriteBlogsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Favorite Blogs', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.purple[700]!, Colors.indigo[700]!],
            ),
          ),
        ),
      ),
      body: BlocBuilder<BlogBloc, BlogState>(
        builder: (context, state) {
          if (state is BlogLoadSuccess) {
            final favoriteBlogs = state.blogs.where((blog) => blog.isFavorite).toList();
            if (favoriteBlogs.isEmpty) {
              return Center(
                child: Text(
                  'No favorite blogs yet.',
                  style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                ),
              );
            }
            return ListView.builder(
              itemCount: favoriteBlogs.length,
              itemBuilder: (context, index) {
                final blog = favoriteBlogs[index];
                return AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: 1,
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BlogDetailScreen(blog: blog)),
                        );
                      },
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Hero(
                              tag: 'blogImage${blog.id}',
                              child: Image.network(
                                blog.imageUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                blog.title,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 16),
                            child: Icon(Icons.favorite, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (state is BlogLoadInProgress) {
            return Center(child: CircularProgressIndicator());
          } else if (state is BlogLoadFailure) {
            return Center(child: Text('Failed to load blogs: ${state.error}'));
          } else {
            return Center(child: Text('Something went wrong!'));
          }
        },
      ),
    );
  }
}