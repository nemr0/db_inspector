import 'package:equatable/equatable.dart';
/// Output event that carries both the source identity and the data.
class StreamEvent<ID, T extends Object?> extends Equatable {
  final ID streamId;
  final T data;

  const StreamEvent(this.streamId, this.data);

  @override
  List<Object?> get props => [streamId, data];
}