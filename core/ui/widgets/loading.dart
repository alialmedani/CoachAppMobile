import 'package:flutter/material.dart';

import '../../constant/app_colors/app_colors.dart';
import '../../constant/app_images/app_images.dart';

/// Compact branded loader shown while a screen's data is fetched (used by the
/// get_model and pagination_list boilerplate). Replaces the old full-height
/// shimmer skeleton with a small, gently pulsing app logo + a slim spinner so
/// navigating between screens feels lighter.
class LoadingWidget extends StatefulWidget {
  final double? width;
  final double? height;

  const LoadingWidget({super.key, this.width, this.height});

  @override
  State<LoadingWidget> createState() => _LoadingWidgetState();
}

class _LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gently pulsing app logo.
          FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(_pulse),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(_pulse),
              child: Image.asset(
                logoPngImage,
                height: 64,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
