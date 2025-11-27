/// Output event that carries both the source identity and the data.
class StreamEvent<ID, T extends Object?,S> {
  final ID? streamId;
  final T data;
  final S? key;
  final bool isDeleted;
  const StreamEvent({required this.streamId, required this.data, this.key, required this.isDeleted});

  StreamEvent copyWith({ID? streamId, T? data, S? key, bool? isDeleted}) {
    return StreamEvent(
      streamId: streamId ?? this.streamId,
      data: data ?? this.data,
      key: key ?? this.key,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}

