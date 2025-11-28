import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_db_inspector/controllers/key_value_controller/key_value_controller.dart';

class SliverKeyValueDbTab extends StatefulWidget {
  const SliverKeyValueDbTab({super.key, required this.db});

  final KeyValueDB db;

  @override
  State<SliverKeyValueDbTab> createState() => _SliverKeyValueDbTabState();
}

class _SliverKeyValueDbTabState extends State<SliverKeyValueDbTab> {
  late final KeyValueController controller;
  String? selectedKey;
  dynamic selectedValue;

  @override
  void initState() {
    controller = KeyValueController(widget.db);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _onSaveKey(String? key, MapEntry<String, StreamEvent>? oldValue) async {

    if (key == null) {
      setState(() {
        selectedKey = null;
      });
      return;
    }
    if(oldValue == null){
      // New key
      if(controller.value.containsKey(key)){
        // Key already exists
        setState(() {
          selectedKey = null;
        });
        return;
      }
      await widget.db.setValue(key, null);
      await controller.refresh();
      setState(() {
        selectedKey = null;
      });
      return;
    }
    await widget.db.deleteKey(oldValue.key);
    await widget.db.setValue(key, oldValue.value.data);
    await controller.refresh();
    setState(() {
      selectedKey = null;
    });
  }

  Future<void> _onSaveValue(MapEntry<String, dynamic> value) async {
    await widget.db.setValue(value.key, value.value);
    await controller.refresh();
    setState(() {
      selectedValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'click on a key or value to edit it',
              style: TextStyle(
                fontSize: InspectorFontSizes.fontSize,
                color: InspectorColors.text.withAlpha(100),
                decoration: TextDecoration.none,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (context, _, _) {
              return Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                defaultColumnWidth: FlexColumnWidth(1),
                // columnWidths: {1: const FlexColumnWidth(5)},

                /// Creates a table with two columns: one for keys and one for values.
                /// The table is built using the data from the provided [KeyValueDB].
                border: TableBorder.all(color: InspectorColors.boxBackground),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: InspectorColors.headerBackground.withAlpha(150),
                    ),
                    children: [
                      CellWidget('Type'),
                      CellWidget('Key'),
                      CellWidget('Value'),
                    ],
                  ),
                  ...controller.value.entries.map((entry) {
                    return TableRow(
                      children: [
                        CellWidget(entry.value.data.runtimeType.toString()),
                        if (selectedKey == entry.key && entry.value.isDeleted == false)
                          EditorCell(
                            value: entry.key,
                            onSave: (value) => _onSaveKey(value, entry),
                          )
                        else
                          CellWidget(entry.key, onTap: () {
                            setState(() {
                              selectedValue = null;
                              selectedKey = entry.key;
                            });
                          },),
                          if(selectedValue == entry.value.data && entry.value.isDeleted == false) EditorCell(
                            value: entry.value.data,
                            onSave: (value) => _onSaveValue(MapEntry(entry.key, value)),
                          ) else CellWidget(entry.value.data.toString(),onTap:entry.value.isDeleted ? null : () {
                            setState(() {
                              selectedKey = null;
                              selectedValue = entry.value.data;
                            });
                          },)

                      ],
                    );
                  }),

                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class CellWidget extends StatelessWidget {
  const CellWidget(
      this.text,
      {
    super.key,
        this.onTap,
        this.padding = const EdgeInsets.all(8.0)
  });
  final VoidCallback? onTap;
  final String text;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.intrinsicHeight,
      child: Builder(
        builder: (context) {
          if(text.isEmpty){
            return CustomButton(
              onTap: onTap,
              child: SizedBox(
                height: 50,
                width: 100,
              ),
            );
          }
          return CustomButton(
            onTap: onTap,
            child: Center(
              child: Padding(
                padding: padding,
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: InspectorFontSizes.headerFontSize,
                    color: InspectorColors.text,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}

class EditorCell extends StatefulWidget {
  const EditorCell({super.key, this.value, this.onSave});

  final dynamic value;
  final ValueChanged<String?>? onSave;

  @override
  State<EditorCell> createState() => _EditorCellState();
}

class _EditorCellState extends State<EditorCell> {
  late TextEditingController controller;
  late final String initialValue;

  @override
  void initState() {
    initialValue = widget.value?.toString() ?? '';
    controller = TextEditingController(text: initialValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: InspectorColors.boxBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14.0,
          horizontal: 8.0,
        ),
        child: EditableText(
          selectionColor: InspectorColors.selectedTab.withAlpha(100),
          autofocus: true,
          controller: controller,
          focusNode: FocusNode(),
          keyboardType: TextInputType.text,
          maxLines: 5,
          minLines: 1,
          textAlign: TextAlign.center,
          onTapOutside: (_) => widget.onSave?.call(initialValue == controller.text ? null : controller.text),

          style: TextStyle(
            fontSize: InspectorFontSizes.fontSize,
            color: InspectorColors.text,
            decoration: TextDecoration.none,
          ),
          cursorColor: InspectorColors.unSelectedTabBorder,
          backgroundCursorColor: InspectorColors.selectedTab.withAlpha(100),
          onSubmitted: (value) =>  widget.onSave?.call(initialValue == value ? null : value),

    ),
      ),
    );
  }
}


class CellBody extends StatelessWidget {
  const CellBody({super.key, required this.isSelected, this.entry});
  final bool isSelected;
  final MapEntry<String, StreamEvent>? entry;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(5),
          height: 5,
          width: 5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? InspectorColors.selectedTab : InspectorColors.unSelectedTabBorder,
          ),
        ),
        CustomDivider(),
        Text(
          entry?.key ?? 'New_Key',
          style: TextStyle(
            fontSize: InspectorFontSizes.fontSize,
            color: InspectorColors.text,
            decoration: TextDecoration.none,
          ),
        ),

      ],
    );
  }
}



