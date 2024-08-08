import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../bloc/blog_bloc.dart';
import '../bloc/blog_event.dart';
import '../bloc/blog_state.dart';
import '../models/blog.dart';

class BlogDetailScreen extends StatefulWidget {
  final Blog blog;

  BlogDetailScreen({required this.blog});

  @override
  _BlogDetailScreenState createState() => _BlogDetailScreenState();
}

class _BlogDetailScreenState extends State<BlogDetailScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlogBloc, BlogState>(
      builder: (context, state) {
        if (state is BlogLoaded) {
          final updatedBlog = state.blogs.firstWhere((b) => b.id == widget.blog.id);
          return _buildScaffold(context, updatedBlog);
        }
        return _buildScaffold(context, widget.blog);
      },
    );
  }

  Widget _buildScaffold(BuildContext context, Blog blog) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                floating: false,
                pinned: true,
                stretch: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: AnimatedOpacity(
                    opacity: _scrollOffset > 200 ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Text(
                      blog.title,
                      style: GoogleFonts.playfairDisplay(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
                        ),
                      ),
                    ),
                  ),
                  background: Hero(
                    tag: 'blogImage${blog.id}',
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          blog.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(color: Colors.white),
                            );
                          },
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedOpacity(
                          duration: Duration(milliseconds: 500),
                          opacity: _scrollOffset < 200 ? 1.0 : 0.0,
                          child: Text(
                            blog.title,
                            style: GoogleFonts.playfairDisplay(
                              textStyle: Theme.of(context).textTheme.headlineMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        MarkdownBody(
                          data: _getBlogContent(),
                          styleSheet: MarkdownStyleSheet(
                            h1: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.bold),
                            h2: GoogleFonts.playfairDisplay(fontSize: 24, fontWeight: FontWeight.bold),
                            p: GoogleFonts.merriweather(fontSize: 16, height: 1.8),
                            listBullet: GoogleFonts.merriweather(fontSize: 16),
                            blockquote: GoogleFonts.merriweather(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                            code: GoogleFonts.firaCode(
                              fontSize: 14,
                              backgroundColor: Colors.grey[200],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _scrollOffset > 200 ? 0.0 : 1.0,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: _buildFavoriteButton(blog),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(Blog blog) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<BlogBloc>(context).add(ToggleFavorite(blog: blog));
        _animationController.reset();
        _animationController.forward();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            blog.isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey<bool>(blog.isFavorite),
            color: blog.isFavorite ? Colors.red : Colors.grey,
            size: 32,
          ),
        ),
      ),
    );
  }

  String _getBlogContent() {
    return '''
The world of technology is ever-evolving, and staying ahead of the curve is crucial for both individuals and businesses. In this blog post, we'll explore some of the most exciting tech trends that are shaping our future.

## Artificial Intelligence and Machine Learning

Artificial Intelligence (AI) and Machine Learning (ML) continue to be at the forefront of technological innovation. These technologies are revolutionizing various industries, from healthcare to finance.

Key applications include:
- Predictive analytics
- Natural language processing
- Autonomous vehicles
- Personalized recommendations

## Internet of Things (IoT)

The Internet of Things is connecting our world like never before. Smart devices are becoming increasingly prevalent in our homes, cities, and workplaces.

Examples of IoT applications:
- Smart home systems
- Wearable technology
- Industrial IoT for manufacturing
- Smart city infrastructure

## Blockchain and Cryptocurrency

Blockchain technology is not just about cryptocurrencies anymore. Its potential applications span various sectors:

1. Supply chain management
2. Voting systems
3. Decentralized finance (DeFi)
4. Digital identity verification

## Augmented and Virtual Reality

AR and VR technologies are transforming how we interact with digital content and each other. From gaming to education, these technologies offer immersive experiences that blur the line between the physical and digital worlds.
''';
  }
}