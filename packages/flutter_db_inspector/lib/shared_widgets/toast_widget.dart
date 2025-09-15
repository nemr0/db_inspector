import 'package:flutter/widgets.dart';
import 'package:flutter_db_inspector/helpers/context_extension.dart';
import 'package:flutter_db_inspector/helpers/themes.dart';

class ToastOverlayWidget extends StatelessWidget {
  const ToastOverlayWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:  Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: InspectorColors.headerBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: InspectorColors.selectedTabBorder.withAlpha(100),
            width: 1.5,
          ),
        ),
        margin: EdgeInsets.only(bottom: context.viewPadding.bottom),
        padding: EdgeInsets.all(8),
        child: Text(
          message,
          style: TextStyle(
            color: InspectorColors.text,
            fontSize: InspectorFontSizes.fontSize,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
