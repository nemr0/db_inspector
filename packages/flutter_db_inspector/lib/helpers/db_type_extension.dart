
import 'package:flutter/widgets.dart';
import 'package:db_inspector_core/db_inspector_core.dart';

import '../inspector_page/tabs/box_db_tab/sliver_box_db_tab.dart';
extension DbTypeExtension on DB {
  Widget get sliver {
   return switch(this){
     BoxDB() => SliverBoxDbTab(boxDB: this as BoxDB),
     DB() => SliverToBoxAdapter(child: SizedBox()),
    };
  } 
}