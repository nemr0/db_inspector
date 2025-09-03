import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:db_inspector_core/src/widgets/inspector_page/tabs/box_db_tab/sliver_box_db_tab.dart';
import 'package:flutter/widgets.dart';

extension DbTypeExtension on DBType {
  Widget get sliver {
   return switch(this){
     BoxDB() => SliverBoxDbTab(boxDB: this as BoxDB),
     DBType() => SliverToBoxAdapter(child: SizedBox()),
    };
  } 
}