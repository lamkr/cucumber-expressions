import 'package:dart/src/core/locale.dart';

import 'core/sorted_list.dart';
import 'cucumber_expression_exception.dart';
import 'duplicate_typename_exception.dart';
import 'parameter_type.dart';

class ParameterTypeRegistry {

  static final _integerRegExps = [
    RegExp(r"-?\d+").pattern,
    RegExp(r"\d+").pattern,
  ];

  final Locale locale;
  final _parameterTypeByName = <String, ParameterType>{};
  final _parameterTypesByRegexp = <String, SortedList<ParameterType>>{};


  ParameterTypeRegistry([this.locale = Locale.english]) {
    defineParameterType(ParameterType.fromRegExpList('int', _integerRegExps, int, _transformInt));
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
        _parameterTypesByRegexp[parameterTypeRegexp] = TreeSet<ParameterType<?>>());
      }
      SortedSet<ParameterType<?>> parameterTypes = parameterTypesByRegexp.get(parameterTypeRegexp);
      if (!parameterTypes.isEmpty() && parameterTypes.first().preferForRegexpMatch() && parameterType.preferForRegexpMatch()) {
        throw CucumberExpressionException(String.format(
          "There can only be one preferential parameter type per regexp. " +
          "The regexp /%s/ is used for two preferential parameter types, {%s} and {%s}",
          parameterTypeRegexp, parameterTypes.first().getName(), parameterType.getName()
        ) );
      }
      parameterTypes.add(parameterType);
    }
  }

  ParameterType lookupByTypeName(String typeName) {
    return _parameterTypeByName[typeName] ?? ParameterType.invalid;
  }
}