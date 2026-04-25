import 'package:flutter/material.dart';

class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final bool reverse;

  SharedAxisPageRoute({
    required this.child,
    this.reverse = false,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Incoming page (forward)
            final slideIn = Tween<Offset>(
              begin: Offset(reverse ? -0.15 : 0.15, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));

            final scaleIn = Tween<double>(
              begin: 0.94,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));


            // Outgoing page (being pushed or popped)
            final slideOut = Tween<Offset>(
              begin: Offset.zero,
              end: Offset(reverse ? 0.15 : -0.15, 0.0),
            ).animate(CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutCubic,
            ));

            final scaleOut = Tween<double>(
              begin: 1.0,
              end: 0.94,
            ).animate(CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeOutCubic,
            ));

            final fadeOut = CurvedAnimation(
              parent: secondaryAnimation,
              curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slideIn,
                child: ScaleTransition(
                  scale: scaleIn,
                  child: FadeTransition(
                    opacity: ReverseAnimation(fadeOut),
                    child: SlideTransition(
                      position: slideOut,
                      child: ScaleTransition(
                        scale: scaleOut,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
}
