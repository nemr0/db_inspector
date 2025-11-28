import 'package:flutter/widgets.dart';

import '../../../db_inspector_core.dart';
class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: InspectorColors.unSelectedTabBorder,
      padding: EdgeInsets.symmetric(horizontal: 5),
    );
  }
}
