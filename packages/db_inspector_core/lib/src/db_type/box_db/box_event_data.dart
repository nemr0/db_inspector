
import '../../../db_inspector_core.dart';
class BoxEventData implements StreamEvent<String,dynamic> {
  const BoxEventData( {
    required this.key,
    required this.deleted,
    required this.data,
    required this.streamId,
  });

  final String key;
  final bool deleted;


  @override
  final dynamic data;

  @override
  final String streamId;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [key, deleted, data, streamId];

}