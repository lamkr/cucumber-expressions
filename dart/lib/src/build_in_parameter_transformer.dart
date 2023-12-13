import 'package:dart/src/cucumber_expression_exception.dart';
import 'package:intl/locale.dart';

import 'number_parser.dart';
import 'parameter_by_type_transformer.dart';

class BuiltInParameterTransformer implements ParameterByTypeTransformer {
  final NumberParser numberParser;

  BuiltInParameterTransformer(Locale locale)
      : numberParser = NumberParser(locale);

  @override
  Object transform(String fromValue, Type toValueType, {List<Enum> enumValues = const <Enum>[]}) {
    if (enumValues.isNotEmpty) {
      final enumType = enumValues[0].toString().split('.')[0];
      final returnType = toValueType.toString();
      if (returnType != enumType && returnType != 'Enum') {
        throw ArgumentError(
            "The return type must be 'Enum' or the same type as the enum's values: $enumType.");
      }
      return _doTransform(fromValue, Enum, enumValues);
    }
    return _doTransform(fromValue, toValueType, enumValues);
  }

  Object _doTransform(String fromValue, Type toValueType, List<Enum> enumValues) {
    return switch (toValueType) {
      Object || String => fromValue,
      bool => bool.parse(fromValue),
      int => int.parse(fromValue),
      double => double.parse(fromValue),
      num => num.parse(fromValue),
      Enum => _convertToEnum(
        fromValue,
        enumValues,
      ),
      _ => throw createIllegalArgumentException(fromValue, toValueType),
    };
  }

  @override
  T transformTo<T>(String fromValue, {List<Enum> enumValues = const <Enum>[]}) {
    if (enumValues.isNotEmpty) {
      final enumType = enumValues[0].toString().split('.')[0];
      final returnType = T.toString();
      if (returnType != enumType && returnType != 'Enum') {
        throw ArgumentError(
            "The return type must be 'Enum' or the same type as the enum's values: $enumType.");
      }
      return _doTransformTo<Enum>(fromValue, enumValues) as T;
    }
    return _doTransformTo<T>(fromValue, enumValues);
  }

  T _doTransformTo<T>(String fromValue, List<Enum> enumValues) {
    return _doTransform(fromValue, T, enumValues) as T;
    return switch (T) {
      Object || String => fromValue,
      bool => bool.parse(fromValue),
      int => int.parse(fromValue),
      double => double.parse(fromValue),
      num => num.parse(fromValue),
      Enum => _convertToEnum(
          fromValue,
          enumValues,
        ),
      _ => throw createIllegalArgumentException(fromValue, T),
    } as T;
  }

  Enum _convertToEnum(String fromValue, List<Enum> enumValues) {
    for (final e in enumValues) {
      if (e.name == fromValue) {
        return e;
      }
    }
    final enumType = enumValues[0].runtimeType.toString();
    throw CucumberExpressionException(
        "Can't transform '$fromValue' to $enumType. "
        "Not an enum constant");
  }

  ArgumentError createIllegalArgumentException(
          String fromValue, Type toValueType) =>
      ArgumentError("Can't transform '$fromValue' to $toValueType\n"
          "BuiltInParameterTransformer only supports a limited number of class types\n"
          "Consider using a different object mapper or register a parameter type for $toValueType");
}
