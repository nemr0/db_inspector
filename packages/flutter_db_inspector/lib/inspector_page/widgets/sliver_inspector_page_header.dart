import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_db_inspector/helpers/context_extension.dart';
import 'package:flutter_db_inspector/inspector_page/widgets/db_tab.dart';


class SliverInspectorPageHeader extends StatelessWidget {
  const SliverInspectorPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverOverlapAbsorber(
      handle: SliverOverlapAbsorberHandle(),
      sliver: PinnedHeaderSliver(
        child: SizedBox(
          height: 60,
          child: ColoredBox(
            color: InspectorColors.headerBackground.withAlpha(150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Center(
                  child: Padding(
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
                ),
                Spacer(),
                Container(
                  height: 1,
                  width: context.width,
                  color: InspectorColors.divider,
                ),
              ],
            ),
          ),
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

        return SliverLayoutBuilder(builder: (BuildContext context, constraints) {
          final scrolled = constraints.scrollOffset > 40;
          return SliverFloatingHeader(
            child: Padding(
              padding:  EdgeInsets.only(top: 60),
              child: ColoredBox(
                color: scrolled ? InspectorColors.headerBackground.withAlpha(150) : Color(0x00000000),
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
              ),
            ),
          );
        },

        );

  }
}
