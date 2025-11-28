import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_db_inspector/helpers/floating_overlay.dart';
import 'package:flutter_db_inspector/helpers/list_of_dbs_extension.dart';
import 'package:flutter_db_inspector/inspector_page/inspector_page.dart';

import '../helpers/modal_sheet_route.dart';

class InspectorOverlay extends StatefulWidget {
  const InspectorOverlay({
    super.key,
    required this.dbTypes,
    required this.navigatorKey,
    this.initialChanges = 0,
  });

  final List<DB> dbTypes;
  final GlobalKey<NavigatorState> navigatorKey;
  final int initialChanges;

  @override
  State<InspectorOverlay> createState() => _InspectorOverlayState();
}

class _InspectorOverlayState extends State<InspectorOverlay> {
  late int changes;
  StreamSubscription<int>? _changesSubscription;

  @override
  void initState() {
    changes = widget.initialChanges;
    _changesSubscription = widget.dbTypes.onChangedAll.listen((event) {
      setState(() {
        changes = event;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _changesSubscription?.cancel();
    super.dispose();
  }

  void onTapped() {
    showModalSheet(
      context: widget.navigatorKey.currentContext!,
      builder: (BuildContext context) => InspectorPage(dbTypes: widget.dbTypes),
    ).whenComplete(() {
      FloatingOverlay.instance.show(

        child: InspectorOverlay(
          dbTypes: widget.dbTypes,
          navigatorKey: widget.navigatorKey,
          initialChanges:changes,
        ),
        assumedChildSize: Size(50, 50),
      );
    });
    FloatingOverlay.instance.hide();
  }

  @override
  Widget build(BuildContext context) {
    final didChange = changes > 0;
    return CustomButton(
      onTap: onTapped,
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('packages/flutter_db_inspector/assets/logo.webp'),
            opacity: didChange? 0.3 : 1,
          ),
          color: didChange ? InspectorColors.boxBorder : null,
          shape: BoxShape.circle,
          border: didChange ? Border.all(color: InspectorColors.boxBorder, width: 1.5):null,
        ),
        child: Builder(
          builder: (context) {
            if (!didChange) return const SizedBox.shrink();
            return Center(
              child: Text(changes.toString(),style: TextStyle(
                color: InspectorColors.text,
                fontSize: InspectorFontSizes.fontSize,
                fontWeight: FontWeight.w600,
                decoration:TextDecoration.none,
              ),),
            );
          },
        ),
      ),
    );
  }
}
