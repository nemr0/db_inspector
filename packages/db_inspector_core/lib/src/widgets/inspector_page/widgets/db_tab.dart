import 'package:flutter/widgets.dart';

import '../../../../db_inspector_core.dart';
import '../../helpers/themes.dart';
class DBTab extends StatelessWidget {
  const DBTab({
    super.key,
    required this.dbType,
    required this.isSelected,
    required this.onTap,
  });

  final DBType dbType;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    bool tapped = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            setState(() {
              tapped = true;
            });
            onTap();
          },
          child: AnimatedOpacity(
            opacity: tapped ? 0.6 : 1,
            duration: Duration(milliseconds: 100),
            onEnd: () {
              if (tapped) {
                setState(() {
                  tapped = false;
                });
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? InspectorColors.selectedTab
                    : InspectorColors.unSelectedTab,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? InspectorColors.selectedTabBorder
                      : InspectorColors.unSelectedTabBorder,
                  width: 1.5,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Center(
                child: Text(
                  dbType.name,
                  style: TextStyle(
                    color: InspectorColors.text,
                    fontWeight: FontWeight.w600,
                    fontSize: InspectorFontSizes.tabFontSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}