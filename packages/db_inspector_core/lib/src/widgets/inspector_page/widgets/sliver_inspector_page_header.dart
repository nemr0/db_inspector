
import 'package:db_inspector_core/src/widgets/helpers/context_extension.dart';
import 'package:db_inspector_core/src/widgets/inspector_page/widgets/db_tab.dart';
import 'package:flutter/widgets.dart';

import '../../../../db_inspector_core.dart';
import '../../helpers/themes.dart';

class SliverInspectorPageHeader extends StatelessWidget {
  const SliverInspectorPageHeader({
    super.key,
    required this.onDBTypeTapped,
    required this.selectedDBIndex,
    required this.dbTypes,
  });

  final ValueChanged<(int, DBType)> onDBTypeTapped;
  final int selectedDBIndex;
  final List<DBType> dbTypes;

  @override
  Widget build(BuildContext context) {
    return SliverFloatingHeader(
      child: Padding(
        padding: EdgeInsets.only(top: context.viewInsets.top),
        child: Column(
          children: [
            // A list of tabs for each database type
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: dbTypes.indexed
                  .map<Widget>(
                    ((int, DBType) e) => DBTab(
                  dbType: e.$2,
                  isSelected: selectedDBIndex == e.$1,
                  onTap: () => onDBTypeTapped(e),
                ),
              )
                  .toList(),
            ),

            // A divider line
            Container(
              height: 1,
              width: context.width,
              color: InspectorColors.divider,
            ),
          ],
        ),
      ),
    );
  }
}