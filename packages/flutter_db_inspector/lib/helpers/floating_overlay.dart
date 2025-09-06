import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FloatingOverlay {
  static OverlayEntry? _entry;

  static void show(
      GlobalKey<NavigatorState> navigatorKey, {
        required Widget child,
        EdgeInsets margin = const EdgeInsets.all(16),
        Size assumedChildSize = const Size(56, 56), // used just before first measure
      }) {
    if (_entry != null) return;
    SchedulerBinding.instance.addPostFrameCallback((_){

      final pos = ValueNotifier<Offset>(Offset.zero);
      Size childSize = assumedChildSize;
      final childKey = GlobalKey();



      _entry = OverlayEntry(
        builder: (ctx) {
          // Initialize/adjust position after layout
          WidgetsBinding.instance.addPostFrameCallback((_) => _initIfNeeded(ctx, margin: margin, childKey: childKey, pos: pos, childSize: childSize));

          return ValueListenableBuilder<Offset>(
            valueListenable: pos,
            builder: (_, o, __) => Positioned(
              left: o.dx,
              top: o.dy,
              child: _DragBubble(
                key: childKey,
                onDragDelta: (d) => pos.value = _clamp(ctx, pos.value + d, childSize, margin),
                onLongPress: hide,
                child: child,
              ),
            ),
          );
        },
      );
      navigatorKey.currentState!.overlay!.insert(_entry!);
    });


  }

  static void hide() {
    if(_entry == null) return;
    _entry?.remove();
    _entry = null;
  }
  static Offset _clamp(BuildContext ctx, Offset o, Size childSize, EdgeInsets margin) {
    final media = MediaQuery.of(ctx);
    final size = media.size;
    final pad = media.padding;
    final minX = margin.left;
    final maxX = size.width - pad.right - margin.right - childSize.width;
    final minY = pad.top + margin.top;
    final maxY = size.height - pad.bottom - margin.bottom - childSize.height;
    return Offset(
      o.dx.clamp(minX, maxX),
      o.dy.clamp(minY, maxY),
    );
  }

  static void _initIfNeeded(BuildContext ctx, {required EdgeInsets margin, required GlobalKey childKey, required ValueNotifier<Offset> pos, required Size childSize}) {
    // Measure real child size, then place at bottom-left.
    final rb = childKey.currentContext?.findRenderObject() as RenderBox?;
    final measured = rb?.size;
    if (measured != null) {
      childSize = measured;
    }
    if (pos.value == Offset.zero) {
      final media = MediaQuery.of(ctx);
      final size = media.size;
      final pad = media.padding;
      final start = Offset(
        margin.left,
        size.height - pad.bottom - margin.bottom - childSize.height,
      );
      pos.value = _clamp(ctx, start, childSize, margin);
    } else {
      // Re-clamp if size changed.
      pos.value = _clamp(ctx, pos.value, childSize, margin);
    }
  }
}

class _DragBubble extends StatelessWidget {
  const _DragBubble({
    super.key,
    required this.onDragDelta,
    required this.onLongPress,
    required this.child,
  });

  final void Function(Offset delta) onDragDelta;
  final VoidCallback onLongPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Only the bubble intercepts touches; outside taps pass through automatically.
    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanUpdate: (d) => onDragDelta(d.delta),
        onLongPress: onLongPress,
        child: child,
      ),
    );
  }
}
