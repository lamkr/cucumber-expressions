import 'dart:collection';

import 'package:dart/src/core/locale.dart';

import 'cucumber_expression_exception.dart';
import 'duplicate_typename_exception.dart';
import 'parameter_type.dart';
import 'transformer.dart';

class ParameterTypeRegistry {

  SplayTreeSet<ParameterType> get _emptySplayTreeSet => SplayTreeSet<ParameterType>();

  static final _integerRegExps = [
    RegExp(r"-?\d+").pattern,
    RegExp(r"\d+").pattern,
  ];

  final Locale locale;
  final _parameterTypeByName = <String, ParameterType>{};
  final _parameterTypesByRegexp = <String, SplayTreeSet<ParameterType>>{};

  ParameterTypeRegistry([this.locale = Locale.english]) {
    defineParameterType(ParameterType.fromRegExpList('int', _integerRegExps, int, TransformerInt()));
  }
  
  void defineParameterType(ParameterType parameterType) {
    if (_parameterTypeByName.containsKey(parameterType.name)) {
      if (parameterType.name.isEmpty) {
        throw DuplicateTypeNameException("The anonymous parameter type has already been defined");
      }
      throw DuplicateTypeNameException("There is already a parameter type with name ${parameterType.name}");
    }
    _parameterTypeByName[parameterType.name] = parameterType;

    for (String parameterTypeRegexp in parameterType.regexps ) {
      if (!_parameterTypesByRegexp.containsKey(parameterTypeRegexp)) {
        _parameterTypesByRegexp[parameterTypeRegexp] = SplayTreeSet<ParameterType>();
      }
      final parameterTypes = _parameterTypesByRegexp[parameterTypeRegexp] ?? _emptySplayTreeSet;
      if (parameterTypes.isNotEmpty && parameterTypes.first.preferForRegexpMatch && parameterType.preferForRegexpMatch) {
        throw CucumberExpressionException(
          "There can only be one preferential parameter type per regexp. "
          "The regexp /$parameterTypeRegexp/ is used for two preferential parameter types, "
          "${parameterTypes.first.name} and ${parameterType.name}");
      }
      parameterTypes.add(parameterType);
    }
  }

  ParameterType lookupByTypeName(String typeName) {
    return _parameterTypeByName[typeName] ?? ParameterType.invalid;
  }
}

