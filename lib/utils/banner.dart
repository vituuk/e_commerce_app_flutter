import 'package:flutter/material.dart';

/// A reusable promotional banner widget.
///
/// Displays a card with a title, subtitle, action button on the left,
/// and an image on the right. Fully customisable via constructor parameters.
///
/// Usage:
/// ```dart
/// PromoBanner(
///   title: "Don't miss out —",
///   subtitle: 'Save up to 50% on your favorite products.',
///   buttonLabel: 'Shop Now',
///   imageUrl: 'https://example.com/image.png',
///   onPressed: () {},
/// )
/// ```
class PromoBanner extends StatelessWidget {
  /// Primary heading displayed in bold at the top-left.
  final String title;

  /// Secondary description text below the title.
  final String subtitle;

  /// Label shown inside the action button.
  final String buttonLabel;

  /// Network image URL displayed on the right side of the banner.
  final String imageUrl;

  /// Callback fired when the action button is tapped.
  final VoidCallback? onPressed;

  /// Background colour of the banner card.
  final Color backgroundColor;

  /// Text colour used for the title and subtitle.
  final Color textColor;

  /// Background colour of the action button.
  final Color buttonColor;

  /// Text colour of the action button label.
  final Color buttonTextColor;

  /// Border radius of the banner card.
  final double borderRadius;

  /// Overall height of the banner.
  final double height;

  const PromoBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.buttonLabel = 'Shop Now',
    this.onPressed,
    this.backgroundColor = const Color(0xFFEEF1F6),
    this.textColor = const Color(0xFF1D1D2C),
    this.buttonColor = const Color(0xFF1D1D2C),
    this.buttonTextColor = Colors.white,
    this.borderRadius = 16.0,
    this.height = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: [
          // ── Left side: text content ──
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textColor.withOpacity(0.65),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 14),
                  _ActionButton(
                    label: buttonLabel,
                    color: buttonColor,
                    textColor: buttonTextColor,
                    onPressed: onPressed,
                  ),
                ],
              ),
            ),
          ),

          // ── Right side: image ──
          Expanded(
            flex: 2,
            child: SizedBox.expand(
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: backgroundColor,
                    child: Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: textColor.withOpacity(0.25),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Small outlined / filled button used inside [PromoBanner].
class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}