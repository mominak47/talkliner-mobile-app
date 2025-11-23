import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talkliner/app/controllers/news_controller.dart';
import 'package:talkliner/app/themes/talkliner_theme_colors.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NewsController newsController = Get.find<NewsController>();

    return Obx(() {
      if (newsController.isLoading.value) {
        return Container(
          color: Theme.of(context).brightness == Brightness.dark ? TalklinerThemeColors.gray800 : TalklinerThemeColors.gray020,
          child: ListView.builder(
            itemCount: 5, // Show 5 skeleton items
            itemBuilder: (context, index) => const NewsSkeletonLoader(),
          ),
        );
      }

      if (newsController.error.value != null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                newsController.error.value!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => newsController.fetchNews(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      if (newsController.news.isEmpty) {
        return const Center(
          child: Text(
            'No news available',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return Container(
        color: Theme.of(context).brightness == Brightness.dark ? TalklinerThemeColors.gray800 : TalklinerThemeColors.gray020,
        child: RefreshIndicator(
          onRefresh: () => newsController.fetchNews(),
          child: ListView.builder(
            itemCount: newsController.news.length,
            itemBuilder: (context, index) {
              return NewsItem(news: newsController.news[index]);
            },
          ),
        ),
      );
    });
  }
}

class NewsSkeletonLoader extends StatefulWidget {
  const NewsSkeletonLoader({super.key});

  @override
  State<NewsSkeletonLoader> createState() => _NewsSkeletonLoaderState();
}

class _NewsSkeletonLoaderState extends State<NewsSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey[800]!.withOpacity(_animation.value)
                : Colors.grey[300]!.withOpacity(_animation.value),
            borderRadius: borderRadius ?? BorderRadius.circular(4),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? TalklinerThemeColors.gray900 : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image skeleton
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: _buildSkeletonBox(
              width: double.infinity,
              height: 200,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                _buildSkeletonBox(width: double.infinity, height: 24),
                const SizedBox(height: 8),
                _buildSkeletonBox(width: 200, height: 24),
                const SizedBox(height: 12),
                
                // Description skeleton
                _buildSkeletonBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                _buildSkeletonBox(width: double.infinity, height: 14),
                const SizedBox(height: 6),
                _buildSkeletonBox(width: 150, height: 14),
                const SizedBox(height: 12),
                
                // Date skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildSkeletonBox(width: 100, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageWidget extends StatelessWidget {
  final String imageUrl;

  const _ImageWidget({required this.imageUrl});

  bool _isSvgUrl(String url) {
    return url.toLowerCase().endsWith('.svg') || url.contains('placehold.co');
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.image, size: 64, color: Colors.grey),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSvgUrl(imageUrl)) {
      // For SVG images, use a simpler approach due to parsing issues
      return FutureBuilder(
        future: Future.value(true), // Placeholder for SVG loading
        builder: (context, snapshot) {
          // Show placeholder for SVG images that might have parsing issues
          return _buildPlaceholder();
        },
      );
    }

    // For regular images (PNG, JPEG, etc.)
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              value:
                  loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }
}

class NewsItem extends StatelessWidget {
  final NewsModel news;
  const NewsItem({super.key, required this.news});

  bool _hasValidImage() {
    return news.image.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Open bottom sheet with news details
        Get.bottomSheet(
          DraggableScrollableSheet(
            initialChildSize: 0.8, // 80% of screen height initially
            minChildSize: 0.3, // Minimum 30% when dragged down
            maxChildSize: 0.95, // Maximum 95% when dragged up
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? TalklinerThemeColors.gray900
                          : TalklinerThemeColors.gray020,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(news.title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Image
                      if (_hasValidImage())
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: _ImageWidget(imageUrl: news.image),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(news.description, style: TextStyle(fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(news.createdAt, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                    ],
                  ),
              ));
            },
          ),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? TalklinerThemeColors.gray900 : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with error handling - only show if valid image URL exists
            if (_hasValidImage())
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _ImageWidget(imageUrl: news.image),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    news.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    news.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        news.createdAt,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
