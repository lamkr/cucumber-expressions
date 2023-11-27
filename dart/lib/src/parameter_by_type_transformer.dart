/// The [ParameterTypeRegistry] uses the default transformer
/// to execute all transforms for built-in parameter types and all
/// anonymous types.
abstract class ParameterByTypeTransformer {
  /// Throws exception if transformation failures.
  Object transform(String fromValue, Type toValueType);
}
