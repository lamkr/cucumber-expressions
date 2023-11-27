import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:intl/locale.dart';
import 'ambiguous_parameter_type_exception.dart';
import 'build_in_parameter_transformer.dart';
import 'core/locale.dart';
import 'cucumber_expression_exception.dart';
import 'cucumber_expression_generator.dart';
import 'duplicate_typename_exception.dart';
import 'generated_expression.dart';
import 'parameter_by_type_transformer.dart';
import 'parameter_type.dart';
import 'transformer.dart';

class ParameterTypeRegistry {
  // Keeped it to programming reference.
  SplayTreeSet<ParameterType> get _emptySplayTreeSet =>
      SplayTreeSet<ParameterType>();

  static final _integerRegExps = [
    RegExp(r'-?\d+').pattern,
    RegExp(r'\d+').pattern,
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

  late final Locale locale;
  final _parameterTypeByName = <String, ParameterType>{};

  final ParameterByTypeTransformer defaultParameterTransformer;

  //final _parameterTypesByRegexp = <String, SplayTreeSet<ParameterType>>{};
  final _parameterTypesByRegexp = <String, Set<ParameterType>>{};

  ParameterTypeRegistry([Locale? locale])
      : this.withDefaultParameterTansformer(
          BuiltInParameterTransformer(locale ?? englishLocale),
          locale ?? englishLocale,
        );

  ParameterTypeRegistry.withDefaultParameterTansformer(
      this.defaultParameterTransformer, this.locale) {
    defineParameterType(
      ParameterType.fromRegExpList(
          'int', _integerRegExps, int, TransformerInt()),
    );

    final localizedDecimalPattern = NumberFormat.decimalPattern(locale.languageCode);

    List<String> localizedDoubleRegExps = _doubleRegExps
        .map((regexp) =>
          regexp
              .replaceAll("{decimal}", localizedDecimalPattern.symbols.DECIMAL_SEP)
              .replaceAll("{group}", localizedDecimalPattern.symbols.GROUP_SEP)
              .replaceAll("{expnt}", localizedDecimalPattern.symbols.EXP_SYMBOL))
        .toList(growable: false);

    defineParameterType(
      ParameterType.fromRegExpList(
          'double', localizedDoubleRegExps, double, TransformerDouble()),
    );

    defineParameterType(
      ParameterType.fromRegExpList(
        'string',
        _stringRegExps,
        String,
        TransformerString(defaultParameterTransformer),
      ),
    );

    defineParameterType(
      ParameterType.fromRegExpList(
        'word',
        _wordRegExps,
        String,
        TransformerWord(defaultParameterTransformer),
        false,
      ),
    );
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
      Set<ParameterType> parameterTypes =
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
