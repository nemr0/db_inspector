import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

/// A lightweight tappable widget that shows a short opacity animation on tap
/// and optionally emits haptic feedback.
///
/// Use this when you need a minimal "button" without the full Material widgets.
/// The widget uses a `StatefulBuilder` internally to animate opacity on tap
/// and to prevent multiple rapid invocations of `onTap`.
///
/// Example:
/// ```dart
/// CustomButton(
///   onTap: () => print('pressed'),
///     child: Text('Press me'),
/// );
/// ```
class CustomButton extends StatelessWidget {
  /// Creates a [CustomButton].
  ///
  /// * [child] is required and represents the tappable content.
  /// * [onTap] is invoked when the button is tapped. If null, the button is disabled.
  /// * [animationDuration] controls how long the opacity animation lasts.
  /// * [useFeedback] enables a short haptic feedback (light impact) when tapped.
  /// * [padding] adds space around the child widget.
  /// * [tapOpacity] sets the opacity level when the button is tapped.
  const CustomButton({
    super.key,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 100),
    required this.child,
    this.useFeedback = true,
    this.padding = EdgeInsets.zero,
    this.tapOpacity = 0.6,
  });

  /// Called when the button is tapped. If null the button is disabled.
  final VoidCallback? onTap;

  /// Duration for the opacity animation triggered on tap.
  final Duration animationDuration;

  /// The widget displayed inside the button.
  final Widget child;

  /// When true, emits a light haptic impact on tap (platform permitting).
  final bool useFeedback;
  /// Padding around the child widget.
  final EdgeInsets padding;
  /// Opacity value when the button is tapped.
  final double tapOpacity;
  @override
  Widget build(BuildContext context) {
    // Local mutable state used by the StatefulBuilder to animate and prevent
    // duplicate taps while the animation is in progress.
    bool tapped = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return AnimatedOpacity(
          opacity: tapped ? tapOpacity : 1.0,
          duration: animationDuration,
          onEnd: () {
            if (tapped) {
              setState(() {
                tapped = false;
              });
            }
          },
          child: GestureDetector(
            onTap: onTap == null || tapped
                ? null
                : () {
                    setState(() {
                      tapped = true;
                    });
                    if (useFeedback) HapticFeedback.lightImpact();
                    onTap?.call();
                  },
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
