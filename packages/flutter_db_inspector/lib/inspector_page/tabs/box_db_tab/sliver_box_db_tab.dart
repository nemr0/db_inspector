import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_db_inspector/helpers/context_extension.dart';
import 'package:flutter_db_inspector/helpers/themes.dart';
import 'package:flutter_db_inspector/inspector_page/tabs/box_db_tab/box_screen/box_screen.dart';
import 'package:flutter_db_inspector/shared_widgets/custom_button.dart';

import '../../../helpers/modal_sheet_route.dart';

class SliverBoxDbTab extends StatefulWidget {
  const SliverBoxDbTab({super.key, required this.boxDB});

  final BoxDB boxDB;

  @override
  State<SliverBoxDbTab> createState() => _SliverBoxDbTabState();
}

class _SliverBoxDbTabState extends State<SliverBoxDbTab> {
  late final StreamSubscription<Map<String, int>> _boxEventSubscription;
  final Map<String, int> _boxData = {};
  String? selectedBox;

  @override
  void initState() {
    _init();
    super.initState();
  }

  _init() {
    _boxEventSubscription = widget.boxDB.watchBoxLength().listen((data) {
      setState(() {
        _boxData.addAll(data);
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
    final boxSelected = selectedBox != null && boxes.contains(selectedBox);
    return SliverPadding(
      padding: context.gridPadding(
        verticalOnly: boxSelected,
        addTop: !boxSelected,
      ),
      sliver: Builder(
        builder: (context) {
          return SliverGrid(
            delegate: SliverChildBuilderDelegate((_, index) {
              return CustomButton(
                onTap: () {
                  final current = boxes.elementAt(index);
                  showModalSheet(
                    context: context,
                    builder: (context) => BoxScreen(
                      name: current,
                      dataStream: widget.boxDB.watchBox(boxName: current),
                      onDelete: (key) => widget.boxDB.deleteFromBox(current, key),
                    ),
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: InspectorColors.boxBackground,
                    border: Border.all(
                      color: InspectorColors.boxBorder,
                      width: 1.5,
                    ),
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
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Properties: ${_boxData[boxes.elementAt(index)] ?? 0}',
                        style: TextStyle(
                          color: InspectorColors.text,
                          fontSize: InspectorFontSizes.fontSize,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: boxes.length),
            gridDelegate: context.gridDelegate,
          );
        },
      ),
    );
  }
}
