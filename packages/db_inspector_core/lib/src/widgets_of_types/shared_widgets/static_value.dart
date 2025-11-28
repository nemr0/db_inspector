import 'package:flutter/widgets.dart';

class StaticCell extends StatelessWidget {
  const StaticCell({super.key, required this.value});
  final String value;
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
