import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:db_inspector_core/src/widgets/helpers/context_extension.dart';
import 'package:db_inspector_core/src/widgets/helpers/db_type_extension.dart';
import 'package:db_inspector_core/src/widgets/helpers/themes.dart';
import 'package:db_inspector_core/src/widgets/inspector_page/widgets/sliver_inspector_page_header.dart';
import 'package:flutter/widgets.dart';

class InspectorPage extends StatefulWidget {
  const InspectorPage({super.key, required this.dbTypes});

  final List<DBType> dbTypes;

  @override
  State<InspectorPage> createState() => _InspectorPageState();
}

class _InspectorPageState extends State<InspectorPage> {
  int selectedDBIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ColoredBox(
        color: InspectorColors.background,
        child: CustomScrollView(
          slivers: [
            SliverInspectorPageHeader(
              onDBTypeTapped: (value) {
                setState(() {
                  selectedDBIndex = value.$1;
                });
              },
              selectedDBIndex: selectedDBIndex,
              dbTypes: widget.dbTypes,
            ),
            if (widget.dbTypes.isNotEmpty)
            widget.dbTypes[selectedDBIndex].sliver
            else SliverFillRemaining(
              child: Center(
                child: Text(
                  'Please Add a Database for Inspection.',
                  style: TextStyle(
                    color: InspectorColors.text,
                    fontSize: InspectorFontSizes.fontSize,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



