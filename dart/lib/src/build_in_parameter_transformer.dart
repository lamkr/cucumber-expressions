import 'package:dart/src/cucumber_expression_exception.dart';
import 'package:intl/locale.dart';

import 'number_parser.dart';
import 'parameter_by_type_transformer.dart';

class BuiltInParameterTransformer implements ParameterByTypeTransformer {
  final NumberParser numberParser;

  BuiltInParameterTransformer(Locale locale)
      : numberParser = NumberParser(locale);

  @override
  T? transform<T>(String? fromValue) =>
      doTransform<T>(fromValue, T.runtimeType);

  T? doTransform<T>(String? fromValue, Type originalToValueType) {
    if( fromValue == null ) {
      return null;
    }
    return switch (T) {
      String => fromValue,
      bool => bool.parse(fromValue),
      int => int.parse(fromValue),
      double => double.parse(fromValue),
      num => num.parse(fromValue),
      Enum => _convertToEnum(
          fromValue, T as List<Enum>, originalToValueType as Enum),
      _ => throw createIllegalArgumentException(fromValue, T.runtimeType),
    } as T;
  }

  Enum _convertToEnum(
      String fromValue, List<Enum> values, Enum originalToValueType) {
    try {
      return values.byName(fromValue);
    } catch (e) {
      throw CucumberExpressionException(
          "Can't transform '$fromValue' to $originalToValueType. "
          "Not an enum constant");
    }
  }

  ArgumentError createIllegalArgumentException(
          String fromValue, Type toValueType) =>
      ArgumentError("Can't transform '$fromValue' to $toValueType\n"
          "BuiltInParameterTransformer only supports a limited number of class types\n"
          "Consider using a different object mapper or register a parameter type for $toValueType");
}
