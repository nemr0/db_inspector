import 'package:flutter/widgets.dart';

extension ContextExtension on BuildContext {
  /// Get the height and width of the screen
  double get height => MediaQuery.sizeOf(this).height;
  ///  Get the width of the screen
  double get width => MediaQuery.sizeOf(this).width;
  /// Get InsetPadding of the screen
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);

}