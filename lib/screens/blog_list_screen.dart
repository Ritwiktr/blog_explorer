import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../bloc/blog_bloc.dart';
import '../bloc/blog_event.dart';
import '../bloc/blog_state.dart';
import '../models/blog.dart';
import 'favorites_screen.dart';
import 'blog_detail_screen.dart';

class BlogListScreen extends StatefulWidget {
  @override
  _BlogListScreenState createState() => _BlogListScreenState();
}

class _BlogListScreenState extends State<BlogListScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  String _searchQuery = '';
  List<Blog> _filteredBlogs = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_scrollController.offset > 100 && !_showFloatingButton) {
      setState(() => _showFloatingButton = true);
    } else if (_scrollController.offset <= 100 && _showFloatingButton) {
      setState(() => _showFloatingButton = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<BlogBloc, BlogState>(
        builder: (context, state) {
          if (state is BlogLoaded) {
            _filteredBlogs = _isSearching ? _filterBlogs(state.blogs) : state.blogs;
            return _buildBlogList(_filteredBlogs, screenWidth, screenHeight);
          } else if (state is BlogLoading) {
            return _buildLoadingShimmer(screenWidth, screenHeight);
          } else if (state is BlogError) {
            return _buildErrorWidget(state.message);
          } else {
            return _buildErrorWidget('Something went wrong!');
          }
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          color: Colors.deepPurple[600],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: AppBar(
          title: _isSearching
              ? _buildSearchField()
              : Text(
            'Blog Explorer',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.favorite, color: Colors.pink[200]),
              onPressed: () => _navigateToFavorites(context),
            ),
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchQuery = '';
                  }
                });
              },
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 40,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search blogs...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          prefixIcon: Icon(Icons.search, color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white70),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  List<Blog> _filterBlogs(List<Blog> blogs) {
    if (_searchQuery.isEmpty) {
      return blogs;
    }
    final lowercaseQuery = _searchQuery.toLowerCase();
    return blogs.where((blog) {
      return blog.title.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  Widget _buildBlogList(List<Blog> blogs, double screenWidth, double screenHeight) {
    return RefreshIndicator(
      onRefresh: () async {
        BlocProvider.of<BlogBloc>(context).add(FetchBlogs());
      },
      child: AnimationLimiter(
        child: ListView.builder(
          key: _listKey,
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 16),
          itemCount: blogs.length,
          itemBuilder: (context, index) {
            final blog = blogs[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 375),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildBlogCard(context, blog, screenWidth, screenHeight, index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, Blog blog, double screenWidth, double screenHeight, int index) {
    return GestureDetector(
      onTap: () => _navigateToBlogDetail(context, blog),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: screenWidth - 32,
            height: screenHeight * 0.25,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'blogImage${blog.id}',
                  child: Image.network(
                    blog.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        blog.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black, offset: Offset(0, 1), blurRadius: 3)],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Blog ${index + 1}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeInOut),
    );
  }

  Widget _buildLoadingShimmer(double screenWidth, double screenHeight) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[600]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            width: screenWidth - 32,
            height: screenHeight * 0.25,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 60),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.red[300], fontSize: 18),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => BlocProvider.of<BlogBloc>(context).add(FetchBlogs()),
            child: Text('Retry'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms).scale(duration: 500.ms);
  }

  Widget _buildFloatingActionButton() {
    return AnimatedOpacity(
      opacity: _showFloatingButton ? 1.0 : 0.0,
      duration: Duration(milliseconds: 200),
      child: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        child: Icon(Icons.arrow_upward),
        backgroundColor: Colors.purple,
      ).animate().scale(duration: 200.ms),
    );
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => FavoriteBlogsScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  void _navigateToBlogDetail(BuildContext context, Blog blog) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BlogDetailScreen(blog: blog),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }
}