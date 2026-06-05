import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lesson_flutter/models/category.dart';
import 'package:lesson_flutter/services/api_service.dart';
import 'package:lesson_flutter/widgets/skeleton_loader.dart';

class MySlider extends StatefulWidget {
  const MySlider({super.key});

  @override
  State<MySlider> createState() => _MySliderState();
}

class _MySliderState extends State<MySlider> {
  final PageController _pageController = PageController(
    viewportFraction: 1.0,
    initialPage: 0,
  );
  int _currentPage = 0;
  Timer? _autoPlayTimer;
  bool _isReversing = false; // Track direction: false = forward, true = backward

  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await ApiService.fetchCategories();
      if (mounted) {
        setState(() {
          _categories = categories
              .where((c) => _isValidImageUrl(c.image))
              .toList();
          _isLoading = false;
        });
        _startAutoPlay();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Checks if a URL points to a real image (not a placeholder or broken link)
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    final lower = url.toLowerCase();
    if (lower.contains('placehold.co') ||
        lower.contains('placeimg.com') ||
        lower.contains('pravatar.cc') ||
        lower.contains('lorempixel.com') ||
        lower.contains('loremflickr.com') ||
        lower.contains('picsum.photos') ||
        lower == 'https://google.com' ||
        lower == 'https://www.google.com' ||
        lower == 'https://www.google.com/' ||
        lower == 'http://google.com') {
      return false;
    }
    return true;
  }

  void _startAutoPlay() {
    if (_categories.isEmpty) return;
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        int nextPage;
        
        if (_isReversing) {
          // Moving backward (right to left)
          nextPage = _currentPage - 1;
          if (nextPage < 0) {
            // Reached the start, switch to forward direction
            _isReversing = false;
            nextPage = 1;
          }
        } else {
          // Moving forward (left to right)
          nextPage = _currentPage + 1;
          if (nextPage >= _categories.length) {
            // Reached the end, switch to reverse direction
            _isReversing = true;
            nextPage = _categories.length - 2;
          }
        }
        
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 230,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6.0),
          child: CarouselSkeleton(),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox(height: 230);
    }

    return SizedBox(
      height: 230,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              // padEnds: true centres the first and last card so neighbours
              // always peek equally from both sides
              padEnds: true,
              itemCount: _categories.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                final category = _categories[index];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Category image
                        Image.network(
                          category.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported,
                                  size: 48, color: Colors.grey),
                            );
                          },
                        ),
                        // Gradient overlay for text readability
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.75),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Page indicator dots
          const SizedBox(height: 6),
          Builder(builder: (context) {
            final theme = Theme.of(context);
            final inactiveDotColor = theme.brightness == Brightness.dark
                ? Colors.white.withOpacity(0.3)
                : Colors.grey.shade300;
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _categories.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? theme.colorScheme.primary
                        : inactiveDotColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}


  