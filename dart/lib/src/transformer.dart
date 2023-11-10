/// Transformer for a [ParameterType] with zero or one capture groups.
/// [T] is the type to transform to.
abstract class Transformer<T> {
  static const invalid = _InvalidTransformer();
  
  /// Transforms a string into to an object. The string is either taken
  /// from the sole capture group or matches the whole expression. 
  /// Nested capture groups are ignored. It throws an exception 
  /// if transformation failed.
  /// [arg] is the the value of the single capture group
  T transform(String arg);
}

final class _InvalidTransformer implements Transformer<void> {
  const _InvalidTransformer();
  
  @override
  void transform(String arg) {}
}

final class TransformerInt implements Transformer<int> {
  @override
  int transform(String arg) => int.parse(arg);
}

final class TransformerString implements Transformer<String> {
  @override
  String transform(String arg) => arg;
}