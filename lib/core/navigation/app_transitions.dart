import 'package:flutter/material.dart';

/// Transición de fade consistente para todas las rutas.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  FadePageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 250),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              child: child,
            );
          },
          transitionDuration: duration,
        );

  final WidgetBuilder builder;
  final Duration duration;
}

/// Transición de slide desde la derecha consistente para todas las rutas.
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  SlidePageRoute({
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: duration,
        );

  final WidgetBuilder builder;
  final Duration duration;
}
