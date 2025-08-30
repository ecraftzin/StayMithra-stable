import 'package:flutter/material.dart';

class ResponsiveUtils {
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = getScreenWidth(context);
    // Base width is 375 (iPhone 6/7/8 width)
    return (screenWidth / 375) * baseSize;
  }

  static double getResponsiveWidth(BuildContext context, double percentage) {
    return getScreenWidth(context) * percentage;
  }

  static double getResponsiveHeight(BuildContext context, double percentage) {
    return getScreenHeight(context) * percentage;
  }

  static EdgeInsets getResponsivePadding(BuildContext context, {
    double horizontal = 0.04,
    double vertical = 0.02,
  }) {
    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);
    return EdgeInsets.symmetric(
      horizontal: screenWidth * horizontal,
      vertical: screenHeight * vertical,
    );
  }

  static EdgeInsets getResponsiveMargin(BuildContext context, {
    double horizontal = 0.04,
    double vertical = 0.02,
  }) {
    final screenWidth = getScreenWidth(context);
    final screenHeight = getScreenHeight(context);
    return EdgeInsets.symmetric(
      horizontal: screenWidth * horizontal,
      vertical: screenHeight * vertical,
    );
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final screenWidth = getScreenWidth(context);
    return (screenWidth / 375) * baseSize;
  }

  static double getResponsiveButtonHeight(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    return screenHeight * 0.06; // 6% of screen height
  }

  static double getResponsiveAppBarHeight(BuildContext context) {
    final screenHeight = getScreenHeight(context);
    return screenHeight * 0.08; // 8% of screen height
  }

  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 360;
  }

  static bool isMediumScreen(BuildContext context) {
    final width = getScreenWidth(context);
    return width >= 360 && width < 414;
  }

  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= 414;
  }

  static double getBottomSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.bottom;
  }

  static double getTopSafeArea(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  static double getKeyboardHeight(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  static bool isKeyboardVisible(BuildContext context) {
    return getKeyboardHeight(context) > 0;
  }

  // Get responsive spacing based on screen size
  static double getSpacing(BuildContext context, SpacingSize size) {
    final screenWidth = getScreenWidth(context);
    switch (size) {
      case SpacingSize.xs:
        return screenWidth * 0.01;
      case SpacingSize.sm:
        return screenWidth * 0.02;
      case SpacingSize.md:
        return screenWidth * 0.04;
      case SpacingSize.lg:
        return screenWidth * 0.06;
      case SpacingSize.xl:
        return screenWidth * 0.08;
    }
  }

  // Get responsive border radius
  static double getBorderRadius(BuildContext context, BorderRadiusSize size) {
    final screenWidth = getScreenWidth(context);
    switch (size) {
      case BorderRadiusSize.sm:
        return screenWidth * 0.02;
      case BorderRadiusSize.md:
        return screenWidth * 0.03;
      case BorderRadiusSize.lg:
        return screenWidth * 0.04;
      case BorderRadiusSize.xl:
        return screenWidth * 0.06;
    }
  }
}

enum SpacingSize { xs, sm, md, lg, xl }
enum BorderRadiusSize { sm, md, lg, xl }

// Extension for easier usage
extension ResponsiveContext on BuildContext {
  double get screenWidth => ResponsiveUtils.getScreenWidth(this);
  double get screenHeight => ResponsiveUtils.getScreenHeight(this);
  double responsiveFontSize(double baseSize) => ResponsiveUtils.getResponsiveFontSize(this, baseSize);
  double responsiveWidth(double percentage) => ResponsiveUtils.getResponsiveWidth(this, percentage);
  double responsiveHeight(double percentage) => ResponsiveUtils.getResponsiveHeight(this, percentage);
  EdgeInsets responsivePadding({double horizontal = 0.04, double vertical = 0.02}) => 
    ResponsiveUtils.getResponsivePadding(this, horizontal: horizontal, vertical: vertical);
  EdgeInsets responsiveMargin({double horizontal = 0.04, double vertical = 0.02}) => 
    ResponsiveUtils.getResponsiveMargin(this, horizontal: horizontal, vertical: vertical);
  double responsiveIconSize(double baseSize) => ResponsiveUtils.getResponsiveIconSize(this, baseSize);
  double get responsiveButtonHeight => ResponsiveUtils.getResponsiveButtonHeight(this);
  double get responsiveAppBarHeight => ResponsiveUtils.getResponsiveAppBarHeight(this);
  bool get isSmallScreen => ResponsiveUtils.isSmallScreen(this);
  bool get isMediumScreen => ResponsiveUtils.isMediumScreen(this);
  bool get isLargeScreen => ResponsiveUtils.isLargeScreen(this);
  double get bottomSafeArea => ResponsiveUtils.getBottomSafeArea(this);
  double get topSafeArea => ResponsiveUtils.getTopSafeArea(this);
  double get keyboardHeight => ResponsiveUtils.getKeyboardHeight(this);
  bool get isKeyboardVisible => ResponsiveUtils.isKeyboardVisible(this);
  double spacing(SpacingSize size) => ResponsiveUtils.getSpacing(this, size);
  double borderRadius(BorderRadiusSize size) => ResponsiveUtils.getBorderRadius(this, size);
}
