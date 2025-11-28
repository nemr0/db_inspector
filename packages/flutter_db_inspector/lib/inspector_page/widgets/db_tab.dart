import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/widgets.dart';

class DBTab extends StatelessWidget {
  const DBTab({
    super.key,
    required this.dbType,
    required this.isSelected,
    required this.onTap,
  });

  final DB dbType;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
      return CustomButton(
        onTap: isSelected ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? InspectorColors.selectedTab
                : InspectorColors.unSelectedTab,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? InspectorColors.selectedTabBorder
                  : InspectorColors.unSelectedTabBorder,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            dbType.name,
            style: TextStyle(
              color: InspectorColors.text,
              fontWeight: FontWeight.w600,
              fontSize: InspectorFontSizes.tabFontSize,
              decoration:TextDecoration.none,
            ),
          ),
        ),
      );
  }
}