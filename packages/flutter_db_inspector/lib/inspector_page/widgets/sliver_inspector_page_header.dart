import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_db_inspector/helpers/context_extension.dart';
import 'package:flutter_db_inspector/inspector_page/widgets/db_tab.dart';

import '../../helpers/themes.dart';

class SliverInspectorPageHeader extends StatelessWidget {
  const SliverInspectorPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return PinnedHeaderSliver(
      child: ColoredBox(
        color: InspectorColors.headerBackground.withAlpha(150),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Text(
                "DB Inspector",
                style: TextStyle(
                  fontSize: InspectorFontSizes.headerFontSize,
                  color: InspectorColors.text,
                  decoration:TextDecoration.none,

                ),
              ),
            ),
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

class SliverInspectorDBTypes extends StatelessWidget {
  const SliverInspectorDBTypes({
    super.key,
    required this.onDBTypeTapped,
    required this.selectedDBIndex,
    required this.dbTypes,
  });

  final ValueChanged<(int, DB)> onDBTypeTapped;
  final int selectedDBIndex;
  final List<DB> dbTypes;

  @override
  Widget build(BuildContext context) {
    return SliverFloatingHeader(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // A list of tabs for each database type
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
            child: Wrap(
              alignment: WrapAlignment.start,
              spacing: 6,
              runSpacing: 6,
              children: dbTypes.indexed
                  .map<Widget>(
                    ((int, DB) e) => DBTab(
                      dbType: e.$2,
                      isSelected: selectedDBIndex == e.$1,
                      onTap: () => onDBTypeTapped(e),
                    ),
                  )
                  .toList(),
            ),
          ),
          // A divider line
          Container(
            height: 1,
            width: context.width,
            color: InspectorColors.divider,
          ),
        ],
      ),
    );
  }
}
