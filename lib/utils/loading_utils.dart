import 'package:flutter/material.dart';
import 'package:staymitra/utils/responsive_utils.dart';

class LoadingUtils {
  /// Show a loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(message: message),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Show loading overlay
  static OverlayEntry showLoadingOverlay(BuildContext context, {String? message}) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => LoadingOverlay(message: message),
    );
    overlay.insert(overlayEntry);
    return overlayEntry;
  }

  /// Create a loading widget for lists
  static Widget buildListLoading(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.responsivePadding(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: context.spacing(SpacingSize.md)),
            Text(
              'Loading...',
              style: TextStyle(
                fontSize: context.responsiveFontSize(16),
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Create a loading widget for buttons
  static Widget buildButtonLoading({Color color = Colors.white, double size = 20}) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  /// Create a shimmer loading effect for cards
  static Widget buildShimmerCard(BuildContext context) {
    return Container(
      margin: context.responsiveMargin(vertical: 0.01),
      padding: context.responsivePadding(),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.borderRadius(BorderRadiusSize.md)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header shimmer
          Row(
            children: [
              ShimmerBox(
                width: context.responsiveWidth(0.12),
                height: context.responsiveWidth(0.12),
                borderRadius: context.responsiveWidth(0.06),
              ),
              SizedBox(width: context.spacing(SpacingSize.sm)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(
                      width: context.responsiveWidth(0.3),
                      height: context.responsiveHeight(0.02),
                    ),
                    SizedBox(height: context.spacing(SpacingSize.xs)),
                    ShimmerBox(
                      width: context.responsiveWidth(0.2),
                      height: context.responsiveHeight(0.015),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(SpacingSize.md)),
          // Content shimmer
          ShimmerBox(
            width: double.infinity,
            height: context.responsiveHeight(0.25),
          ),
          SizedBox(height: context.spacing(SpacingSize.sm)),
          ShimmerBox(
            width: context.responsiveWidth(0.8),
            height: context.responsiveHeight(0.02),
          ),
          SizedBox(height: context.spacing(SpacingSize.xs)),
          ShimmerBox(
            width: context.responsiveWidth(0.6),
            height: context.responsiveHeight(0.02),
          ),
        ],
      ),
    );
  }

  /// Create multiple shimmer cards for list loading
  static Widget buildShimmerList(BuildContext context, {int itemCount = 3}) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => buildShimmerCard(context),
    );
  }
}

class LoadingDialog extends StatelessWidget {
  final String? message;

  const LoadingDialog({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: context.responsivePadding(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.borderRadius(BorderRadiusSize.md)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            if (message != null) ...[
              SizedBox(height: context.spacing(SpacingSize.md)),
              Text(
                message!,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(16),
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: context.responsivePadding(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.borderRadius(BorderRadiusSize.md)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
              if (message != null) ...[
                SizedBox(height: context.spacing(SpacingSize.md)),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(16),
                    color: Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  final double? borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius ?? 4),
            gradient: LinearGradient(
              colors: [
                Colors.grey[300]!,
                Colors.grey[100]!,
                Colors.grey[300]!,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((stop) => stop.clamp(0.0, 1.0)).toList(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }
}
