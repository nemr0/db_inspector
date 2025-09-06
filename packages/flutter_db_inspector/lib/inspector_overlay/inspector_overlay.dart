import 'package:db_inspector_core/db_inspector_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_db_inspector/helpers/floating_overlay.dart';
import 'package:flutter_db_inspector/inspector_page/inspector_page.dart';
import 'package:flutter_db_inspector/shared_widgets/custom_button.dart';

import '../helpers/modal_sheet_route.dart';


class InspectorOverlay extends StatelessWidget {
  const InspectorOverlay({
    super.key,
    required this.dbTypes,
    required this.navigatorKey,
  });

  final List<DB> dbTypes;
  final GlobalKey<NavigatorState> navigatorKey;
  static const String _routeName = 'DB Inspector';



  void onTapped() {


       showModalSheet(
        context: navigatorKey.currentContext!,
        builder: (BuildContext context) =>
            InspectorPage(dbTypes: dbTypes),
        settings: RouteSettings(name: InspectorOverlay._routeName),
      ).whenComplete((){
        FloatingOverlay.show(navigatorKey, child: InspectorOverlay(dbTypes: dbTypes, navigatorKey: navigatorKey));
       });
      FloatingOverlay.hide();

  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      onTap:onTapped,
      child: SizedBox(
        height: 50,
        width: 50,
        child: Image.asset(
          'packages/flutter_db_inspector/assets/logo.webp',
        ),
      ),
    );
  }
}
