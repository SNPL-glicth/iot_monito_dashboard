import 'package:flutter/material.dart';

abstract final class DesignSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 48.0;
}

abstract final class DesignRadius {
  static const sm = 4.0;
  static const md = 8.0;
  static const lg = 12.0;
  static const xl = 16.0;
}

abstract final class DesignLayout {
  static const mobileBreakpoint = 600.0;
  static const desktopBreakpoint = 1024.0;
  static const sidebarWidth = 200.0;
  static const contentMaxWidth = 1440.0;

  static bool isMobile(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width < mobileBreakpoint;
  static bool isDesktop(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width >= desktopBreakpoint;
}
