import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_db_inspector/helpers/asset_paths.dart';
import 'package:flutter_db_inspector/helpers/context_extension.dart';
import 'package:flutter_db_inspector/helpers/floating_overlay.dart';
import 'package:flutter_db_inspector/helpers/pretty_formatter.dart';


class BoxScreen extends StatefulWidget {
  const BoxScreen({super.key, required this.name, required this.dataStream, required this.onDelete});

  final Stream<Map<dynamic, StreamEvent<dynamic, Object?, dynamic>>>dataStream;
  final String name;
  final Function(dynamic key) onDelete;
  @override
  State<BoxScreen> createState() => _BoxScreenState();
}

class _BoxScreenState extends State<BoxScreen> {
  Map<dynamic, StreamEvent<dynamic, Object?, dynamic>> data = {};
  StreamSubscription<Map<dynamic,StreamEvent<dynamic, dynamic,dynamic>>>? _dataSubscription;

  @override
  void initState() {
    _dataSubscription = widget.dataStream.listen((value) {
    setState(() {
      data = value;
    });
    });
    super.initState();
  }

  @override
  dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: InspectorColors.background.withAlpha(200),
      child: CustomScrollView(
        slivers: [
          SliverFloatingHeader(
            child:  Container(
              padding: const EdgeInsets.all(8.0),

              decoration: BoxDecoration(color: InspectorColors.headerBackground),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RotatedBox(
                        quarterTurns: 2,
                        child: CustomButton.assetIcon(
                          onTap: () => Navigator.of(context).pop(),
                          assetPath: AssetsPaths.arrowLeft,
                          padding: const EdgeInsets.all(8.0),
                          height: 24,
                          width: 24,
                        ),
                      ),
                      Spacer(),
                      Text(
                        "BOX: ${widget.name}",
                        style: TextStyle(
                          color: InspectorColors.text,
                          fontSize: InspectorFontSizes.headerFontSize,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      Spacer(),
                      CustomButton.assetIcon(
                        onTap: () async {
                         await Clipboard.setData(ClipboardData(text: (data.values.map((s)=>s.data.toString())).toList().toString().toPrettyFormattedString ));
                          FloatingOverlay.instance.showToast('✅ Copied all to clipboard');
                        },
                        assetPath: AssetsPaths.copy,
                        padding: const EdgeInsets.all(8.0),
                        height: 24,
                        width: 24,
                      ),CustomButton.assetIcon(
                        onTap: null,
                        assetPath: AssetsPaths.delete,
                        padding: const EdgeInsets.all(8.0),
                        height: 24,
                        width: 24,
                      ),
                    ],
                  ),

                ],
              ),
            ),
          ),
          SliverPadding(
            padding: context.gridPadding(addTop: false, verticalOnly: true).copyWith(top: 10),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, index) => _getChild(index),
                childCount: data.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getChild(int index) {
    final value = data[data.keys.elementAt(index)];
    final isDeleted =  value?.isDeleted ?? true;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: InspectorColors.boxBackground.withAlpha(isDeleted?100:200),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: InspectorColors.boxBorder, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  (value?.data ?? 'null')
                      .toString()
                      .toPrettyFormattedString,
                  style: TextStyle(
                      color: InspectorColors.text,
                      fontSize: InspectorFontSizes.fontSize,
                      fontWeight: FontWeight.w600,
                      // add through line if deleted
                      decoration: isDeleted ? TextDecoration.lineThrough : TextDecoration.none
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(width: 3),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomButton.assetIcon(
                    assetPath: AssetsPaths.copy,
                    height: 25,
                    width: 25,
                    padding: EdgeInsets.all(4),
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: value?.data.toString()??'null'));
                      FloatingOverlay.instance.showToast('✅ Copied to clipboard');
                    },
                  ),
                  SizedBox(height: 12),
                  CustomButton.assetIcon(
                    assetPath: AssetsPaths.delete,
                    height: 25,
                    width: 25,
                    padding: EdgeInsets.all(4),
                    onTap: () {
                      final key = value?.key;
                      if (key == null || isDeleted) return;
                      widget.onDelete(key);},

                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
