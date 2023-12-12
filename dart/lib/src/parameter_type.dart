import 'package:collection/collection.dart';

import 'core/null_safety_object.dart';
import 'cucumber_expression_exception.dart';
import 'transformer.dart';
import 'transformer_adaptor.dart';

class ParameterType<T> implements Comparable<ParameterType>, NullSafetyObject {
  static final invalid = _ParameterTypeInvalid();

/*
JS:
  const ILLEGAL_PARAMETER_NAME_PATTERN = /([[\]()$.|?*+])/
  const UNESCAPE_PATTERN = () => /(\\([[$.|?*+\]]))/g

  static final illegalParameterNamePattern = r"([[]()$.|?*+])";
  static final unescapePattern = r"(\\([[$.|?*+]]))/";*/
/*
Java:
  private static final Pattern ILLEGAL_PARAMETER_NAME_PATTERN = Pattern.compile("([{}()\\\\/])");
  private static final Pattern UNESCAPE_PATTERN = Pattern.compile("(\\\\([\\[$.|?*+\\]]))");
*/
  static final illegalParameterNamePattern = r"([{}()\\/])";
  static final unescapePattern = r"(\\([[$.|?*+]]))/g";

/*
Go:
  var HAS_FLAG_REGEXP = regexp.MustCompile(`\(\?[imsU-]+(:.*)?\)`)
  var ILLEGAL_PARAMETER_NAME_REGEXP = regexp.MustCompile(`([{}()\\/])`)
*/
/*
Ruby:
  ILLEGAL_PARAMETER_NAME_PATTERN = /([\[\]()$.|?*+])/.freeze
  UNESCAPE_PATTERN = /(\\([\[$.|?*+\]]))/.freeze
*/
  final String name;
  final List<String> regexps;
  final Type type;
  final Transformer transformer;
  final bool useForSnippets;
  final bool preferForRegexpMatch;
  final bool useRegexpMatchAsStrongTypeHint;
  final bool isAnonymous;

  ParameterType(String name,
      String regexp,
      Type type,
      Transformer transformer, [
        bool useForSnippets = true,
        bool preferForRegexpMatch = false,
        bool useRegexpMatchAsStrongTypeHint = false,
        bool isAnonymous = false,
      ]) : this.fromRegExpList(
    name,
    <String>[regexp],
    type,
    transformer,
    useForSnippets,
    preferForRegexpMatch,
    useRegexpMatchAsStrongTypeHint,
    isAnonymous,
  );

  ParameterType.fromRegExpList(this.name,
      this.regexps,
      this.type,
      this.transformer, [
        this.useForSnippets = true,
        this.preferForRegexpMatch = false,
        this.useRegexpMatchAsStrongTypeHint = false,
        this.isAnonymous = false,
      ]) {
    checkParameterTypeName(name);
  }

  static void checkParameterTypeName(String name) {
    if (!isValidParameterTypeName(name)) {
      throw CucumberExpressionException.createInvalidParameterTypeName(name);
    }
  }

  static bool isValidParameterTypeName(String name) {
    final unescapedTypeName = name.replaceAll(unescapePattern, r'$2');
    final unescapedTypeNameRegExp = RegExp(unescapedTypeName);
    return !unescapedTypeNameRegExp.hasMatch(illegalParameterNamePattern);
  }

  @override
  bool get isValid => true;

  @override
  bool get isInvalid => !isValid;

  int get weight => type is int ? 1000 : 0;

  T transform(List<String> groupValues) {
    if (transformer is TransformerAdaptor) {
      if (groupValues.length > 1) {
        if (isAnonymous) {
          throw CucumberExpressionException(
              'Anonymous ParameterType has multiple capture groups $regexps. '
                  'You can only use a single capture group in an anonymous '
                  'ParameterType.');
        }
        throw CucumberExpressionException(
            'ParameterType $name was registered with '
                'a Transformer but has multiple capture groups $regexps. '
                'Did you mean to use a CaptureGroupTransformer?');
      }
    }

    try {
      final groupValueArray = <String>[...groupValues];
      return transformer.transform(groupValueArray);
    } on CucumberExpressionException catch (_) {
      rethrow;
    } catch (e) {
      throw CucumberExpressionException(
          'ParameterType {$name} failed to transform $groupValues to $type',
          e as Exception);
    }
  }

  @override
  int get hashCode =>
      name.hashCode ^
      Object.hashAll(regexps) ^
      type.hashCode ^
      transform.hashCode ^
      useForSnippets.hashCode ^
      preferForRegexpMatch.hashCode;

  @override
  bool operator ==(Object other) {
    Function deepEqual = const DeepCollectionEquality().equals;
    return (other is ParameterType) &&
        other.name == name &&
        deepEqual(other.regexps, regexps) &&
        other.type == type &&
        other.transform == transform &&
        other.useForSnippets == useForSnippets &&
        other.preferForRegexpMatch == preferForRegexpMatch;
  }

  @override
  int compareTo(ParameterType other) => hashCode - other.hashCode;

  ParameterType deAnonymize(Type type,
      Transformer<Object, Object> transformer) {
    return ParameterType.fromRegExpList(
      'anonymous',
      regexps,
      type,
      TransformerAdaptor<Object, Object>(transformer),
      useForSnippets,
      preferForRegexpMatch,
      useRegexpMatchAsStrongTypeHint,
      isAnonymous,);
  }
}

class _ParameterTypeInvalid extends ParameterType {
  _ParameterTypeInvalid() : super('', '', Null, Transformer.invalid);

  @override
  bool get isInvalid => !isValid;
}
