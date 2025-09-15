import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../shared_widgets/toast_widget.dart';

class FloatingOverlay {
  FloatingOverlay._();

  static final FloatingOverlay instance = FloatingOverlay._();
  late GlobalKey<NavigatorState> _navigatorKey;

  void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;
  }

  OverlayEntry? _entry;

  void show({
    required Widget child,
    EdgeInsets margin = const EdgeInsets.all(16),
    Size assumedChildSize = const Size(
      56,
      56,
    ), // used just before first measure
  }) {
    if (_entry != null) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final pos = ValueNotifier<Offset>(Offset.zero);
      Size childSize = assumedChildSize;
      final childKey = GlobalKey();

      _entry = OverlayEntry(
        builder: (ctx) {
          // Initialize/adjust position after layout
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _initIfNeeded(
              ctx,
              margin: margin,
              childKey: childKey,
              pos: pos,
              childSize: childSize,
            ),
          );

          return ValueListenableBuilder<Offset>(
            valueListenable: pos,
            builder: (_, o, __) => Positioned(
              left: o.dx,
              top: o.dy,
              child: _DragBubble(
                key: childKey,
                onDragDelta: (d) =>
                    pos.value = _clamp(ctx, pos.value + d, childSize, margin),
                onLongPress: hide,
                child: child,
              ),
            ),
          );
        },
      );
      _navigatorKey.currentState!.overlay!.insert(_entry!);
    });
  }

  void hide() {
    if (_entry == null) return;
    _entry?.remove();
    _entry = null;
  }

  Future<void> showToast(String message, {Duration duration = const Duration(seconds: 2)}) async {
   final toastEntry = OverlayEntry(
        builder: (ctx) => ToastOverlayWidget(message: message),
      );
      _navigatorKey.currentState!.overlay!.insert(toastEntry);
      await Future.delayed(duration, (){
        toastEntry.remove();
      });
  }

  Offset _clamp(BuildContext ctx, Offset o, Size childSize, EdgeInsets margin) {
    final media = MediaQuery.of(ctx);
    final size = media.size;
    final pad = media.padding;
    final minX = margin.left;
    final maxX = size.width - pad.right - margin.right - childSize.width;
    final minY = pad.top + margin.top;
    final maxY = size.height - pad.bottom - margin.bottom - childSize.height;
    return Offset(o.dx.clamp(minX, maxX), o.dy.clamp(minY, maxY));
  }

  void _initIfNeeded(
    BuildContext ctx, {
    required EdgeInsets margin,
    required GlobalKey childKey,
    required ValueNotifier<Offset> pos,
    required Size childSize,
  }) {
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
