import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_db_inspector/helpers/db_type_extension.dart';
import 'package:flutter_db_inspector/helpers/themes.dart';
import 'package:flutter_db_inspector/inspector_page/widgets/sliver_inspector_page_header.dart';

class InspectorPage extends StatefulWidget {
  const InspectorPage({super.key, required this.dbTypes});

  final List<DB> dbTypes;

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
            const SliverInspectorPageHeader(),
            SliverInspectorDBTypes(
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
                    decoration:TextDecoration.none,
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



