import 'package:flutter/widgets.dart';

abstract class WidgetOfType<T extends Object> {
  const WidgetOfType();

  Widget builder({required bool selected, required T initialValue,required ValueChanged<T> onChanged});
}

