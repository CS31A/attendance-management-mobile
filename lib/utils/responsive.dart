import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// Get screen width
  static double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height
  static double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return width(context) < mobileBreakpoint;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return width(context) >= mobileBreakpoint &&
        width(context) < tabletBreakpoint;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return width(context) >= desktopBreakpoint;
  }

  /// Get responsive padding based on screen size
  static EdgeInsets padding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Get responsive horizontal padding
  static EdgeInsets paddingHorizontal(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  /// Get responsive vertical padding
  static EdgeInsets paddingVertical(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(vertical: 12);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(vertical: 16);
    } else {
      return const EdgeInsets.symmetric(vertical: 20);
    }
  }

  /// Get responsive font size
  static double fontSize(BuildContext context,
      {double mobile = 14, double tablet = 16, double desktop = 18}) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Get responsive heading font size
  static double headingFontSize(BuildContext context,
      {double mobile = 24, double tablet = 28, double desktop = 32}) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Get responsive icon size
  static double iconSize(BuildContext context,
      {double mobile = 20, double tablet = 24, double desktop = 28}) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Get responsive button height
  static double buttonHeight(BuildContext context) {
    if (isMobile(context)) {
      return 44;
    } else if (isTablet(context)) {
      return 48;
    } else {
      return 52;
    }
  }

  /// Get responsive grid columns
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) {
      return 2;
    } else if (isTablet(context)) {
      return 3;
    } else {
      return 4;
    }
  }

  /// Get responsive spacing
  static double spacing(BuildContext context,
      {double mobile = 8, double tablet = 12, double desktop = 16}) {
    if (isMobile(context)) {
      return mobile;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return desktop;
    }
  }

  /// Get responsive max width for content
  static double maxContentWidth(BuildContext context) {
    if (isMobile(context)) {
      return width(context);
    } else if (isTablet(context)) {
      return 800;
    } else {
      return 1200;
    }
  }

  /// Get responsive border radius
  static double borderRadius(BuildContext context) {
    if (isMobile(context)) {
      return 12;
    } else if (isTablet(context)) {
      return 16;
    } else {
      return 20;
    }
  }
}
