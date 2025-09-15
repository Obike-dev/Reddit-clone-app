import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (ResponsiveBreakpoints.of(context).isMobile) {
      return mobile;
    } else if (ResponsiveBreakpoints.of(context).isTablet) {
      return tablet;
    } else {
      return desktop;
    }
  }
}
