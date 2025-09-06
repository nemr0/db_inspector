import 'package:flutter/widgets.dart';

/// Push with:
/// await showModalSheet(
///   context: context,
///   builder: (_) => YourSheetContent(),
/// );
Future<T?> showModalSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
  Color barrierColor = const Color(0x99000000), // ~60% black
  Duration duration = const Duration(milliseconds: 300),
  Curve curve = Curves.easeOutCubic,
  Curve reverseCurve = Curves.easeInCubic,
  RouteSettings? settings,
}) {
  return Navigator.of(context,rootNavigator: true).push(
    ModalSheetRoute<T>(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierTint: barrierColor,
      duration: duration,
      curve: curve,
      reverseCurve: reverseCurve,
      settings: settings,
    ),
  );
}

/// A widgets-only bottom modal sheet implemented as a PopupRoute.
/// No Material/Cupertino imports.
class ModalSheetRoute<T> extends PopupRoute<T> {
  ModalSheetRoute({
    super.settings,
    required this.builder,
    this.barrierDismissible = true,
    this.barrierTint = const Color(0x99000000),
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration,
    this.curve = Curves.easeOutCubic,
    this.reverseCurve = Curves.easeInCubic,
    this.semanticBarrierLabel = 'Dismiss',
    this.maxSheetHeightFactor = 0.9,
    this.alignment = Alignment.bottomCenter,
  });

  final WidgetBuilder builder;
  @override
  final bool barrierDismissible;
  final Color barrierTint;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final Curve reverseCurve;
  final String? semanticBarrierLabel;

  /// Caps the sheet height to a fraction of the screen (0–1).
  final double maxSheetHeightFactor;

  /// Usually bottomCenter for a sheet, but you can center for a dialog feel.
  final Alignment alignment;



  @override
  Color? get barrierColor => barrierTint;

  @override
  String? get barrierLabel => semanticBarrierLabel;

  @override
  Duration get transitionDuration => duration;

  @override
  Duration get reverseTransitionDuration =>
      reverseDuration ?? const Duration(milliseconds: 250);

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> anim, Animation<double> secAnim) {
    final media = MediaQuery.maybeOf(context);
    final size = media?.size ?? const Size(800, 600);
    final maxHeight = size.height * maxSheetHeightFactor;

    // The sheet surface (you can style this as you like).
    final Widget sheet = Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
          minWidth: size.width,
        ),
        child: _SheetSurface(child: builder(context)),
      ),
    );

    // Navigator will handle the modal barrier; we animate only the sheet.
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: sheet,
    );
  }

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: curve,
      reverseCurve: reverseCurve,
    );

    // Slide up with a slight fade.
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// A plain, rounded, widgets-only sheet container.
/// Customize colors, padding, radii as needed.
class _SheetSurface extends StatelessWidget {
  const _SheetSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Basic styling without Material: rounded top corners & background.
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: child
    );
  }
}
