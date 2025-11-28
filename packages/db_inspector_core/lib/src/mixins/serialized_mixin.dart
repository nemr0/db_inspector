
mixin Serialized<T> {
  T fromSerialized(Map<String,dynamic> data);
  Map<String,dynamic> toSerialized();
}