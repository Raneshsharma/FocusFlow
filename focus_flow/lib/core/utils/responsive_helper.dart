import 'package:flutter/material.dart';

/// Responsive breakpoints for FocusFlow
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Tablet breakpoint - 600px
  static const double tablet = 600;

  /// Desktop breakpoint - 900px
  static const double desktop = 900;

  /// Large desktop breakpoint - 1200px
  static const double largeDesktop = 1200;
}

/// Extension on BuildContext for responsive checks
extension ResponsiveContext on BuildContext {
  /// Check if the screen width is considered mobile (default)
  bool get isMobile => MediaQuery.of(this).size.width < ResponsiveBreakpoints.tablet;

  /// Check if the screen width is considered tablet
  bool get isTablet =>
      MediaQuery.of(this).size.width >= ResponsiveBreakpoints.tablet &&
      MediaQuery.of(this).size.width < ResponsiveBreakpoints.desktop;

  /// Check if the screen width is considered desktop
  bool get isDesktop => MediaQuery.of(this).size.width >= ResponsiveBreakpoints.desktop;

  /// Get the current screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get the current screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Get the horizontal padding based on screen size
  double get horizontalPadding {
    if (isDesktop) return 48;
    if (isTablet) return 32;
    return 16;
  }

  /// Get the responsive grid cross-axis count for grids
  int get gridCrossAxisCount {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }

  /// Get the responsive grid aspect ratio
  double get gridChildAspectRatio {
    if (isDesktop) return 1.4;
    if (isTablet) return 1.3;
    return 1.2;
  }
}

/// A responsive builder widget that rebuilds based on screen size
class ResponsiveBuilder extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          return desktop ?? tablet ?? mobile;
        }
        if (constraints.maxWidth >= ResponsiveBreakpoints.tablet) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// A widget that applies responsive padding
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        EdgeInsets padding;
        if (constraints.maxWidth >= ResponsiveBreakpoints.desktop) {
          padding = desktopPadding ?? tabletPadding ?? mobilePadding ?? const EdgeInsets.all(16);
        } else if (constraints.maxWidth >= ResponsiveBreakpoints.tablet) {
          padding = tabletPadding ?? mobilePadding ?? const EdgeInsets.all(16);
        } else {
          padding = mobilePadding ?? const EdgeInsets.all(16);
        }
        return Padding(padding: padding, child: child);
      },
    );
  }
}
