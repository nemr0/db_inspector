import 'package:equatable/equatable.dart';
/// Output event that carries both the source identity and the data.
class StreamEvent<BoxID, T> extends Equatable {
  final BoxID streamId;
  final T data;

  const StreamEvent(this.streamId, this.data);

  @override
  List<Object?> get props => [streamId, data];
}