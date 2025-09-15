import 'dart:async';

import 'package:db_inspector_core/db_inspector_core.dart';

import 'merged_stream.dart';


Stream<StreamEvent<I,T,S>> startMergedStream<I, T,S>(
    Iterable<Stream<StreamEvent<I,T,S>>> inputs, {
      bool cancelOnError = false,
    }) {
  if (inputs.isEmpty) {
    return Stream<StreamEvent<I, T,S>>.empty();
  }

  late StreamController<StreamEvent<I, T,S>> controller;
  final subs = <StreamSubscription<StreamEvent<I,T,S>>>[];
  var completed = 0;
  var closing = false;

  Future<void> cancelAll() async {
    for (final s in subs) {
      try {
        await s.cancel();
      } catch (_) {}
    }
  }

  void attach() {
    for (final src in inputs) {
      final sub = src.listen(
            (data) {

          if (!closing) controller.add(StreamEvent(streamId: data.streamId, data: data.data, key: data.key, isDeleted: data.isDeleted));
        },
        onError: (err, st) async {
          controller.addError(err, st);
          if (cancelOnError && !closing) {
            closing = true;
            await cancelAll();
            await controller.close();
          }
        },
        onDone: () {
          completed += 1;
          if (completed == inputs.length && !closing) {
            closing = true;
            controller.close();
          }
        },
        cancelOnError: false,
      );
      subs.add(sub);
    }
  }

  controller = StreamController<StreamEvent<I, T,S>>(
    onListen: attach,
    onPause: () {
      for (final s in subs) {
        s.pause();
      }
    },
    onResume: () {
      for (final s in subs) {
        s.resume();
      }
    },
    onCancel: () async {
      if (!closing) {
        closing = true;
        await cancelAll();
      }
    },
  );
  // Return both the stream and an explicit disposer you can call anytime.
  return controller.stream;
}
