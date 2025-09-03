import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/widgets.dart';
class SliverBoxDbTab extends StatelessWidget {
  const SliverBoxDbTab({super.key, required this.boxDB});
  final BoxDB boxDB;
  @override
  Widget build(BuildContext context) {
    final boxes = boxDB.getOpenBoxes();
    return const Placeholder();
  }
}
