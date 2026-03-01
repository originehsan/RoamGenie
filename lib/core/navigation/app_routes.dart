import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Custom page route: slides in from the right with a gentle fade.
// Use AppRoutes.push(context, screen) everywhere instead of MaterialPageRoute.
// ─────────────────────────────────────────────────────────────────────────────

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset? beginOffset;

  SlidePageRoute({required this.page, this.beginOffset})
      : super(
          transitionDuration: const Duration(milliseconds: 340),
          reverseTransitionDuration: const Duration(milliseconds: 280),
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offset = beginOffset ?? const Offset(1.0, 0.0);
            final slide = Tween<Offset>(
              begin: offset,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ));
            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              ),
            );
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
        );
}

/// Convenience class — use instead of raw Navigator.push everywhere.
class AppRoutes {
  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      SlidePageRoute(page: screen),
    );
  }

  static Future<T?> pushFromBottom<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      SlidePageRoute(
          page: screen, beginOffset: const Offset(0.0, 1.0)),
    );
  }
}
