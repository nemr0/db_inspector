
import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/widgets.dart';

import '../helpers/floating_overlay.dart';
import '../inspector_overlay/inspector_overlay.dart';

class DbInspector extends StatelessWidget {
  const DbInspector({super.key, this.dbTypes = const [], required this.child, required this.navigatorKey,  this.enabled = false});

  final List<DB> dbTypes;
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final bool enabled;
  showOverlay() => FloatingOverlay.instance.show( child:  InspectorOverlay(dbTypes: dbTypes, navigatorKey: navigatorKey,));


  hideOverlay() => FloatingOverlay.instance.hide();
  

  @override
  Widget build(BuildContext context) {
    return _WidgetStateHandler(
        initStateCallback: (context) async {
          FloatingOverlay.instance.init(navigatorKey);
         await Future.wait([...dbTypes.map((e)=>e.connect())]);
          if(context.mounted) showOverlay();
        },
        disposeCallback: (context) async {
          await Future.wait([...dbTypes.map((e)=>e.disconnect())]);
          if(context.mounted) hideOverlay();
        },
        child: child,

    );
  }
}

class _WidgetStateHandler extends StatefulWidget {
  const _WidgetStateHandler({
     this.initStateCallback,
     this.disposeCallback,
    required this.child,
  });

  final ValueChanged<BuildContext>? initStateCallback;
  final ValueChanged<BuildContext>? disposeCallback;
  final Widget child;

  @override
  State<_WidgetStateHandler> createState() => _WidgetStateHandlerState();
}

class _WidgetStateHandlerState extends State<_WidgetStateHandler> {
  @override
  void initState() {
    widget.initStateCallback?.call(context);
    super.initState();
  }

  @override
  void dispose() {
    widget.disposeCallback?.call(context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
