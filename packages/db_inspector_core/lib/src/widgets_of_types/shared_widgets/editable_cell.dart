import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/widgets.dart';

class EditableCell extends StatefulWidget {
  const EditableCell({
    super.key,
    required this.onSaved,
    required this.initialValue,
    this.padding = const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
  });

  final String initialValue;
  final EdgeInsets padding;
  final ValueChanged<String> onSaved;

  @override
  State<EditableCell> createState() => _EditableCellState();
}

class _EditableCellState extends State<EditableCell> {
  late final TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: InspectorColors.boxBackground,
      child: Padding(
        padding: widget.padding,
        child: EditableText(
          selectionColor: InspectorColors.selectedTab.withAlpha(100),
          autofocus: true,
          controller: _controller,
          focusNode: FocusNode(),
          keyboardType: TextInputType.text,
          maxLines: 5,
          minLines: 1,
          textAlign: TextAlign.center,
          onTapOutside: (_) {
            if (_controller.text == widget.initialValue) return;
            widget.onSaved(_controller.text);
          },

          style: TextStyle(
            fontSize: InspectorFontSizes.fontSize,
            color: InspectorColors.text,
            decoration: TextDecoration.none,
          ),
          cursorColor: InspectorColors.unSelectedTabBorder,
          backgroundCursorColor: InspectorColors.selectedTab.withAlpha(100),
          onSubmitted: (value) {
            if (value == widget.initialValue) return;
            widget.onSaved(value);
          },
        ),
      ),
    );
  }
}
