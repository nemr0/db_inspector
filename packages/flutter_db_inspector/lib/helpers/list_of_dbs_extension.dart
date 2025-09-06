import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';

extension ListOfDbsExtension on List<DB>{
  Stream<int> get onChangedAll {
    return Stream<int>.multi((controller) {
      var count = 0;
      final subs = <StreamSubscription<int>>[];

      for (final db in this) {
        subs.add(db.onChange.listen((_) {
          controller.add(++count);
        }));
      }

      controller.onCancel = () {
        for (final sub in subs) {
          sub.cancel();
        }
      };
      controller.onPause = (){
        for (final sub in subs) {
          sub.pause();
        }
      };
      controller.onResume = (){
        for (final sub in subs) {
          sub.resume();
        }
      };
    });
  }

  Future<void> connectAll()async{
    await Future.wait([...map((e) => e.connect())]);
  }

  Future<void> disconnectAll()async{
    await Future.wait([...map((e) => e.disconnect())]);
  }
}