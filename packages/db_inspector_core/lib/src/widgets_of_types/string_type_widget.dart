import 'package:db_inspector_core/src/helpers/themes.dart';
import 'package:db_inspector_core/src/widgets_of_types/abst_widget_of_type.dart';
import 'package:flutter/widgets.dart';

class StringTypeWidget extends WidgetOfType<String> {
  const StringTypeWidget();

  @override
  Widget builder({required bool selected,required String initialValue,required ValueChanged<String> onChanged}) {
    return Row(
      children: [
        DotWidget(selected: selected),
      ],
    );
  }




}

class DotWidget extends StatelessWidget {
  const DotWidget({super.key,required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 8,
      width: 8,
      child: DecoratedBox(
          decoration:  BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? InspectorColors.selectedTab : InspectorColors.boxBackground
          )),
    );
  }
}
