import 'package:dart/src/core/string_extension.dart';

import 'located.dart';
import 'token_type.dart';

class Token implements Located {

  final String text;
  final TokenType type;
  final int _start;
  final int _end;

  Token(this.text, this.type, this._start, this._end);

  @override
  int get start => _start;

  @override
  int get end => _end;

  static bool canEscape(int token) {
    final char = String.fromCharCode(token);
    if (isWhitespace(char.runes.first)) {
      return true;
    }
    switch (char) {
      case escapeCharacter:
      case alternationCharacter:
      case beginParameterCharacter:
      case endParameterCharacter:
      case beginOptionalCharacter:
      case endOptionalCharacter:
        return true;
    }
    return false;
  }

  static TokenType typeOf(int token) {
    final tokenChar = String.fromCharCode(token);
    if (isWhitespace(tokenChar.runes.first)) {
      return TokenType.whiteSpace;
    }
    switch (tokenChar) {
      case alternationCharacter:
        return TokenType.alternation;
      case beginParameterCharacter:
        return TokenType.beginParameter;
      case endParameterCharacter:
        return TokenType.endParameter;
      case beginOptionalCharacter:
        return TokenType.beginOptional;
      case endOptionalCharacter:
        return TokenType.endOptional;
    }
    return TokenType.text;
  }

  static bool isEscapeCharacter(int token) => token == escapeCharacter.codeUnitAt(0);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Token) {
      return false;
    }
    return start == other.start &&
        end == other.end &&
        text == other.text &&
        type == other.type;
  }

  @override
  int get hashCode =>
    start.hashCode ^ end.hashCode ^ text.hashCode ^ type.hashCode;

  @override
  String toString() =>
    '{"type": "$type",'
    '"start": $start,'
    '"end": $end,'
    '"text": "$text"}';
}