/// The [ParameterTypeRegistry] uses the default transformer
/// to execute all transforms for built-in parameter types and all
/// anonymous types.
abstract interface class ParameterByTypeTransformer {
  /// Throws exception if transformation failures.
  //T? transform<T>(String? fromValue, T toValueType);
  T? transform<T>(String? fromValue);
}
