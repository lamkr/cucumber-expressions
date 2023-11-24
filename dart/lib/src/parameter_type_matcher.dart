import 'parameter_type.dart';

class ParameterTypeMatcher implements Comparable<ParameterTypeMatcher> {
  final ParameterType parameterType;
  final RegExp _regExp;
  final String _text;
  late RegExpMatch _match;

  ParameterTypeMatcher(this.parameterType, this._regExp, this._text);

  static bool _isWhitespaceOrPunctuationOrSymbol(String char) {
    const expression = r'[\p{Z}\p{P}\p{S}]';
    final result = RegExp(expression, unicode: true).hasMatch(char);
    return result;
  }

  bool advanceToAndFind(int newMatchPos) {
    final matches = _regExp.allMatches(_text, newMatchPos);
    if (matches.isNotEmpty) {
      _match = matches.first;
      if(_groupHasWordBoundaryOnBothSides()) {
        return true;
      }
    }
    return false;
  }

  bool _groupHasWordBoundaryOnBothSides() =>
      _groupHasLeftWordBoundary() && _groupHasRightWordBoundary();

  bool _groupHasLeftWordBoundary() {
    if (_match.start > 0) {
      final before = _text[_match.start - 1];
      return _isWhitespaceOrPunctuationOrSymbol(before);
    }
    return true;
  }

  bool _groupHasRightWordBoundary() {
    if (_match.end < _text.length) {
      final after = _text[_match.end];
      return _isWhitespaceOrPunctuationOrSymbol(after);
    }
    return true;
  }

  int get start => _match.start;

  String get value => _text.substring(_match.start, _match.end);

  @override
  int get hashCode =>
      parameterType.hashCode ^
      _regExp.hashCode ^
      _text.hashCode;

  @override
  bool operator ==(Object other) =>
    (other is ParameterTypeMatcher) &&
        other.parameterType == parameterType &&
        other._regExp == _regExp &&
        other._text == _text;

  @override
  int compareTo(ParameterTypeMatcher other) {
    final posComparison = start.compareTo(other.start);
    if (posComparison != 0) {
      return posComparison;
    }
    final lengthComparison = other.value.length.compareTo(value.length);
    if (lengthComparison != 0) {
      return lengthComparison;
    }
    final weightComparison =
        other.parameterType.weight.compareTo(parameterType.weight);
    if (weightComparison != 0) {
      return weightComparison;
    }
    return 0;
  }
}
