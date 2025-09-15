import 'package:flutter/widgets.dart';

extension ContextExtension on BuildContext {
  /// Get the height and width of the screen
  double get height => MediaQuery.sizeOf(this).height;
  ///  Get the width of the screen
  double get width => MediaQuery.sizeOf(this).width;
  /// Get InsetPadding of the screen
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  /// Returns true if the device’s shortest side is less than 600 pixels.
  bool get isMobile => MediaQuery.sizeOf(this).shortestSide < 600;

  /// Returns true if the current orientation is portrait.
  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
  /// A grid delegate with a fixed cross-axis count that adapts by orientation
  /// and device size.
  SliverGridDelegateWithFixedCrossAxisCount get gridDelegate =>
      SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile
            ? isPortrait
            ? 2
            : 4
            : isPortrait
            ? 4
            : 8,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      );

  /// The padding imposed by system UI (e.g., status bar, notch).
  EdgeInsets get viewPadding => MediaQuery.paddingOf(this);

  /// Padding to apply around a grid, with optional bottom inset for safe area.
  EdgeInsets gridPadding({bool addBottom = true, bool addTop = true, bool verticalOnly = false}) => EdgeInsets.only(
    top: addTop ? 12 : 0,
    bottom: addBottom ? viewPadding.bottom +30 : 0,
    right: verticalOnly ? 0 :8,
    left: verticalOnly ? 0 : 8,
  );


}