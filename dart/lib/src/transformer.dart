import 'parameter_by_type_transformer.dart';

/// Transformer for a [ParameterType] with zero or one capture groups.
/// [T] is the type to transform to.
abstract class Transformer<In, Out> {
  static const invalid = _InvalidTransformer();
  
  /// Transforms a string into to an object. The string is either taken
  /// from the sole capture group or matches the whole expression. 
  /// Nested capture groups are ignored. It throws an exception 
  /// if transformation failed.
  /// [arg] is the the value of the single capture group
  Out transform(In arg);
}

final class _InvalidTransformer implements Transformer<void, void> {
  const _InvalidTransformer();

  @override
  void transform(void arg) {}
}

/// Transformer for a [ParameterType] with (multiple) capture groups.
abstract class CaptureGroupTransformer<In, Out> extends Transformer<List<In>, Out>
{
  /// Transforms multiple strings into to an object. The strings are taken from
  /// the capture groups in the regular expressions in order. Nested capture
  /// groups are ignored. If a capture group is optional the corresponding element
  /// in the array may be null.
  /// Throws exception if transformation failed.
  @override
  Out transform(List<In> args);
}

final class TransformerInt implements Transformer<String, int> {
  @override
  int transform(String arg) => int.parse(arg);
}

final class TransformerDouble implements Transformer<String, double> {
  @override
  double transform(String arg) => double.parse(arg);
}

final class TransformerString implements Transformer<List<String>, String> {
  final ParameterByTypeTransformer internalParameterTransformer;

  TransformerString(this.internalParameterTransformer);

  @override
  String transform(List<String?> args) {
    final arg = args[0] ?? args[1] ?? '';
    return internalParameterTransformer.transformTo<String>(
        arg.replaceAll(r'\\"', '"').replaceAll(r"\\'", "'"),
        ) as String;
  }
}

final class TransformerWord extends TransformerString {
  TransformerWord(super.internalParameterTransformer);
}
