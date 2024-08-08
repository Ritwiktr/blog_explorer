import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../bloc/blog_bloc.dart';
import '../bloc/blog_event.dart';
import '../bloc/blog_state.dart';
import '../models/blog.dart';
import 'blog_detail_screen.dart';

class FavoriteBlogsScreen extends StatefulWidget {
  @override
  _FavoriteBlogsScreenState createState() => _FavoriteBlogsScreenState();
}

class _FavoriteBlogsScreenState extends State<FavoriteBlogsScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;
  String _searchQuery = '';
  List<Blog> _filteredBlogs = [];
  bool _isSearching = false;
  late AnimationController _favoriteAnimationController;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _favoriteAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _favoriteAnimationController.dispose();
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
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocBuilder<BlogBloc, BlogState>(
        builder: (context, state) {
          if (state is BlogLoaded) {
            final favoriteBlogs = state.blogs.where((blog) => blog.isFavorite).toList();
            _filteredBlogs = _isSearching ? _filterBlogs(favoriteBlogs) : favoriteBlogs;
            if (_filteredBlogs.isEmpty) {
              return _buildEmptyState();
            }
            return _buildFavoriteBlogList(_filteredBlogs);
          } else if (state is BlogLoading) {
            return _buildLoadingShimmer();
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
            'Favorite Blogs',
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
          hintText: 'Search favorite blogs...',
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No favorite blogs yet.',
            style: TextStyle(fontSize: 18, color: Colors.grey[400]),
          ),
        ],
      ),
    ).animate().fade(duration: 500.ms).scale(duration: 500.ms);
  }

  Widget _buildFavoriteBlogList(List<Blog> blogs) {
    return RefreshIndicator(
      onRefresh: () async {
        BlocProvider.of<BlogBloc>(context).add(FetchBlogs());
      },
      child: AnimationLimiter(
        child: ListView.builder(
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
                  child: _buildBlogCard(context, blog, index),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlogCard(BuildContext context, Blog blog, int index) {
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
          child: Stack(
            children: [
              Hero(
                tag: 'blogImage${blog.id}',
                child: Image.network(
                  blog.imageUrl,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                    ),
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
                child: _buildFavoriteButton(blog),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.easeInOut),
    );
  }

  Widget _buildFavoriteButton(Blog blog) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<BlogBloc>(context).add(ToggleFavorite(blog: blog));
        _favoriteAnimationController.reset();
        _favoriteAnimationController.forward();
      },
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.8),
        ),
        child: AnimatedBuilder(
          animation: _favoriteAnimationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + _favoriteAnimationController.value * 0.2,
              child: Icon(
                blog.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: blog.isFavorite ? Colors.red : Colors.grey,
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 200,
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