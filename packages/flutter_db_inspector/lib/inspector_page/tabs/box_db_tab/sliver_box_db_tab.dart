import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_db_inspector/helpers/context_extension.dart';
import 'package:flutter_db_inspector/helpers/themes.dart';
import 'package:flutter_db_inspector/shared_widgets/custom_button.dart';

class SliverBoxDbTab extends StatefulWidget {
  const SliverBoxDbTab({super.key, required this.boxDB});

  final BoxDB boxDB;

  @override
  State<SliverBoxDbTab> createState() => _SliverBoxDbTabState();
}

class _SliverBoxDbTabState extends State<SliverBoxDbTab> {
  late final StreamSubscription<StreamEvent<dynamic, dynamic>> _boxEventSubscription;
  final Map<String, List<dynamic>> _boxData = {};

  @override
  void initState() {
    print('Initializing BoxDB Tab');
    print('BoxDB: ${widget.boxDB}');
    _init();
    super.initState();
  }
  _init(){
    final boxes = widget.boxDB.getOpenBoxes();
    for(final box in boxes) {
      _boxData[box] = [];
    }
    _boxEventSubscription = (widget.boxDB.watchBoxes())
        .listen((event) {
      // Handle box events here
      setState(() {
        final current = _boxData.putIfAbsent(event.streamId, () => []);
        _boxData[event.streamId] = [...current, event];
      });
    });
  }
  @override
  void dispose() {
    _boxEventSubscription.cancel();
    super.dispose();
  }
  String _capitalizeFirstLetter(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
  @override
  Widget build(BuildContext context) {
    final boxes = _boxData.keys;
    print('boxes: $boxes');
    print('boxData: $_boxData');
    return SliverPadding(
      padding: context.gridPadding(),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate((_, index) {
          return CustomButton(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: InspectorColors.boxBackground,
                border: Border.all(color: InspectorColors.boxBorder, width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _capitalizeFirstLetter(boxes.elementAt(index)),
                    style: TextStyle(
                      color: InspectorColors.text,
                      fontSize: InspectorFontSizes.headerFontSize,
                      fontWeight: FontWeight.w600,
                      decoration:TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Properties: ${_boxData[boxes.elementAt(index)]?.length ?? 0}',
                    style: TextStyle(
                      color: InspectorColors.text,
                      fontSize: InspectorFontSizes.fontSize,
                      fontWeight: FontWeight.w600,
                      decoration:TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          );
        }, childCount: boxes.length),
        gridDelegate: context.gridDelegate,
      ),
    );
  }
}
