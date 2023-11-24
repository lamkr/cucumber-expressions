import 'dart:collection';
import 'package:dart/src/core/locale.dart';
import 'ambiguous_parameter_type_exception.dart';
import 'cucumber_expression_exception.dart';
import 'cucumber_expression_generator.dart';
import 'duplicate_typename_exception.dart';
import 'generated_expression.dart';
import 'parameter_type.dart';
import 'transformer.dart';

class ParameterTypeRegistry {
  // Keeped it to programming reference.
  SplayTreeSet<ParameterType> get _emptySplayTreeSet =>
      SplayTreeSet<ParameterType>();

  static final _integerRegExps = [
    RegExp(r'-?\d+').pattern,
  ];

  static const mustContainNumber = r'(?=.*\d.*)';
  static const sign = r'[-+]?';
  static const integer = r'(?:\d+(?:[{group}]?\d+)*)*';
  static const decimalFraction = r'(?:[{decimal}](?=\d.*))?\d*';
  static const scientificNumber = r'(?:\d+[{expnt}]-?\d+)?';

  static final _doubleRegExps = [
    RegExp('$mustContainNumber'
            '$sign'
            '$integer'
            '$decimalFraction'
            '$scientificNumber')
        .pattern,
  ];

  static const word = r'\S+'; // r'[^\s]+';

  static final _wordRegExps = [
    RegExp(word).pattern,
  ];

  static const stringDoubleQuote = r'"([^"\\]*(\\.[^"\\]*)*)"';
  static const stringApostrophe = r"'([^'\\]*(\\.[^'\\]*)*)'";

  static final _stringRegExps = [
      RegExp(stringDoubleQuote).pattern,
      RegExp(stringApostrophe).pattern,
  ];

  final Locale locale;
  final _parameterTypeByName = <String, ParameterType>{};

  //final _parameterTypesByRegexp = <String, SplayTreeSet<ParameterType>>{};
  final _parameterTypesByRegexp = <String, Set<ParameterType>>{};

  ParameterTypeRegistry([this.locale = Locale.english]) {
    defineParameterType(ParameterType.fromRegExpList(
        'int', _integerRegExps, int, TransformerInt()));

    defineParameterType(ParameterType.fromRegExpList(
        'double', _doubleRegExps, int, TransformerDouble()));

    defineParameterType(ParameterType.fromRegExpList(
        'string', _stringRegExps, int, TransformerString()));
  }

  void defineParameterType(ParameterType parameterType) {
    if (_parameterTypeByName.containsKey(parameterType.name)) {
      if (parameterType.name.isEmpty) {
        throw DuplicateTypeNameException(
            "The anonymous parameter type has already been defined");
      }
      throw DuplicateTypeNameException(
          "There is already a parameter type with name ${parameterType.name}");
    }
    _parameterTypeByName[parameterType.name] = parameterType;

    for (String parameterTypeRegexp in parameterType.regexps) {
      if (!_parameterTypesByRegexp.containsKey(parameterTypeRegexp)) {
        _parameterTypesByRegexp[parameterTypeRegexp] = <ParameterType>{};
      }
      final parameterTypes =
          _parameterTypesByRegexp[parameterTypeRegexp] ?? <ParameterType>{};
      if (parameterTypes.isNotEmpty &&
          parameterTypes.first.preferForRegexpMatch &&
          parameterType.preferForRegexpMatch) {
        throw CucumberExpressionException(
            "There can only be one preferential parameter type per regexp. "
            "The regexp /$parameterTypeRegexp/ is used for two preferential parameter types, "
            "{${parameterTypes.first.name}} and {${parameterType.name}}");
      }
      parameterTypes.add(parameterType);
    }
  }

  ParameterType lookupByTypeName(String typeName) {
    return _parameterTypeByName[typeName] ?? ParameterType.invalid;
  }

  ParameterType lookupByRegexp(
      String parameterTypeRegexp, RegExp expressionRegexp, String text) {
    final parameterTypes =
        _parameterTypesByRegexp[parameterTypeRegexp] ?? <ParameterType>{};
    if (parameterTypes.length > 1 &&
        !parameterTypes.first.preferForRegexpMatch) {
      // We don't do this check on insertion because we only want to restrict
      // ambiguity when we look up by Regexp. Users of CucumberExpression should
      // not be restricted.
      List<GeneratedExpression> generatedExpressions =
          CucumberExpressionGenerator(this).generateExpressions(text);
      throw AmbiguousParameterTypeException(parameterTypeRegexp,
          expressionRegexp, parameterTypes, generatedExpressions);
    }
    return parameterTypes.first;
  }

  Iterable<ParameterType> get parameterTypes => _parameterTypeByName.values;
}
