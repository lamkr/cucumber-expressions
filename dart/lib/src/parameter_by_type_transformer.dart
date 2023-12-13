/// The [ParameterTypeRegistry] uses the default transformer
/// to execute all transforms for built-in parameter types and all
/// anonymous types.
abstract interface class ParameterByTypeTransformer {
  /// Throws exception if transformation failures.
  T transformTo<T>(String fromValue);

  Object transform(String fromValue, Type toValueType, {List<Enum> enumValues = const <Enum>[]});
}
