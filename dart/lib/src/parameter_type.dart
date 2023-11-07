import 'package:collection/collection.dart';

import 'core/null_safety_object.dart';
import 'cucumber_expression_exception.dart';

typedef TransformFunction = void Function(dynamic);

class ParameterType implements NullSafetyObject {
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
  final TransformFunction transform;
  final bool useForSnippets;
  final bool preferForRegexpMatch;

  ParameterType(
    String name,
    String regexp,
    Type type,
    TransformFunction transform, [
    bool useForSnippets = true,
    bool preferForRegexpMatch = false,
  ]) : this.fromRegExpList(
          name,
          <String>[regexp],
          type,
          transform,
          useForSnippets,
          preferForRegexpMatch,
        );

  ParameterType.fromRegExpList(
    this.name,
    this.regexps,
    this.type,
    this.transform, [
    this.useForSnippets = true,
    this.preferForRegexpMatch = false,
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
}

class _ParameterTypeInvalid extends ParameterType {
  _ParameterTypeInvalid():
      super('', '', Null, (dynamic){} );

  @override
  bool get isInvalid => !isValid;
}
