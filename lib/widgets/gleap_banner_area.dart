import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:gleap_sdk/gleap_sdk.dart';

/// Keeps [child] below an inline Gleap banner, like inline banners on the web:
/// while one is shown at the top of the screen, [child] moves down by the
/// banner's height instead of being covered, and moves back up when it closes.
/// Floating banners still float above the app.
///
/// The banner covers the status bar, so the top safe-area padding [child]
/// sees in [MediaQuery] shrinks by the banner's height.
///
/// Wrap the whole app, for example in `MaterialApp.builder`:
///
/// ```dart
/// MaterialApp(
///   builder: (context, child) => GleapBannerArea(child: child!),
///   home: const HomeScreen(),
/// )
/// ```
///
/// Android and iOS; on the web the Gleap JavaScript SDK already pushes the page
/// down, so this does nothing there.
class GleapBannerArea extends StatelessWidget {
  const GleapBannerArea({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 250),
    this.curve = Curves.easeOut,
  });

  final Widget child;

  /// How long [child] takes to move when a banner opens, resizes or closes.
  final Duration duration;

  final Curve curve;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: Gleap.bannerHeight,
      builder: (BuildContext context, double bannerHeight, Widget? child) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: bannerHeight),
          duration: duration,
          curve: curve,
          child: child,
          builder: (BuildContext context, double top, Widget? child) {
            final MediaQueryData? mediaQuery = MediaQuery.maybeOf(context);
            Widget content = child!;
            if (mediaQuery != null) {
              content = MediaQuery(
                data: mediaQuery.copyWith(
                  padding: mediaQuery.padding.copyWith(
                    top: math.max(0.0, mediaQuery.padding.top - top),
                  ),
                  viewPadding: mediaQuery.viewPadding.copyWith(
                    top: math.max(0.0, mediaQuery.viewPadding.top - top),
                  ),
                ),
                child: content,
              );
            }

            return Padding(
              padding: EdgeInsets.only(top: top),
              child: content,
            );
          },
        );
      },
      child: child,
    );
  }
}
