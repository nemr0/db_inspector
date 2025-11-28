mixin Serialized<T> {
  T serialize(Map<String, dynamic> data);
  Map<String, dynamic> deserialize();
}
