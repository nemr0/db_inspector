import 'package:flutter/widgets.dart';
import 'package:flutter_db_inspector/helpers/context_extension.dart';
import 'package:flutter_db_inspector/helpers/themes.dart';

class ToastOverlayWidget extends StatelessWidget {
  const ToastOverlayWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: context.viewPadding.bottom + 20,
      child: Container(
        decoration: BoxDecoration(
          color: InspectorColors.headerBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: InspectorColors.selectedTabBorder,
            width: 1.5,
          ),
        ),
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
