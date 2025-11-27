import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';

extension ListOfDbsExtension on List<DB> {
  Stream<int> get onChangedAll {
    final Map<int, int> dbToNoOfProperties = {};
    return Stream<int>.multi((controller) async {
      final List<StreamSubscription<int>> subscriptions = [];

      print('here');
      for (DB db in this) {
        print(db.name);
         subscriptions .add(  db.noOfProperties.map((e) {
           dbToNoOfProperties[indexOf(db)] = e;
           return dbToNoOfProperties.values.fold(0, (previousValue, element) => previousValue + element,);
         }).listen((data){
            controller.add(data);
         }));

          }
      controller.onPause = () {
        for (final sub in subscriptions) {
          sub.pause();
        }
      };
      controller.onResume = () {
        for (final sub in subscriptions) {
          sub.resume();
        }
      };
      controller.onCancel = () {
        for (final sub in subscriptions) {
          sub.cancel();
        }
      };

    });
  }

  Future<void> connectAll() async {
    await Future.wait([...map((e) => e.connect())]);
  }

  Future<void> disconnectAll() async {
    await Future.wait([...map((e) => e.disconnect())]);
  }
}
