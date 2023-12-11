import 'package:dart/src/ast/token_type.dart';
import 'package:dart/src/cucumber_expression_exception.dart';

import 'ast/token.dart';

class CucumberExpressionTokenizer {

  List<Token> tokenize(String expression) {
    final tokens = <Token>[];
    final iterator = _TokenIterator(expression);
    while(iterator.moveNext()) {
      tokens.add(iterator.current);
    }
    return tokens;
  }
}

final class _TokenIterator implements Iterator<Token> {
  final String _expression;
  final Iterator<int> _codePoints;
  bool _treatAsText = false;
  int _escaped = 0;
  Token _currentToken = Token.invalid;
  TokenType _currentTokenType = TokenType.startOfLine;
  TokenType _previousTokenType = TokenType.endOfLine;
  final _buffer = StringBuffer();
  int _bufferStartIndex = 0;

  _TokenIterator(this._expression)
      : _codePoints = _expression.codeUnits.iterator;

  @override
  Token get current => _currentToken;

  @override
  bool moveNext() {
    if( _previousTokenType == TokenType.endOfLine ) {
      return false;
    }

    while (_codePoints.moveNext()) {
      final codePoint = _codePoints.current;
      if (!_treatAsText && Token.isEscapeCharacter(codePoint)) {
        _escaped++;
        _treatAsText = true;
        continue;
      }
      _currentTokenType = _tokenTypeOf(codePoint, _treatAsText);
      _treatAsText = false;

      if (_previousTokenType == TokenType.startOfLine ||
          _shouldContinueTokenType(_previousTokenType, _currentTokenType)) {
        _advanceTokenTypes();
        _buffer.writeCharCode(codePoint);
      }
      else {
        _currentToken = _convertBufferToToken(_previousTokenType);
        _advanceTokenTypes();
        _buffer.writeCharCode(codePoint);
        return true;
      }
    }

    if (_buffer.isNotEmpty) {
      _currentToken = _convertBufferToToken(_previousTokenType);
      _advanceTokenTypes();
      return true;
    }

    _currentTokenType = TokenType.endOfLine;
    if (_treatAsText) {
      throw CucumberExpressionException.createTheEndOfLineCanNotBeEscaped(_expression);
    }

    _currentToken = _convertBufferToToken(_currentTokenType);
    _advanceTokenTypes();
    return true;
  }

  TokenType _tokenTypeOf(int token, bool treatAsText) {
    if (!treatAsText) {
      return Token.typeOf(token);
    }
    if (Token.canEscape(token)) {
      return TokenType.text;
    }
    throw CucumberExpressionException.createCantEscape(_expression,
      _bufferStartIndex + _buffer
          .toString()
          .codeUnits
          .length + _escaped,);
  }

  bool _shouldContinueTokenType(TokenType previousTokenType,
      TokenType currentTokenType) =>
      currentTokenType == previousTokenType
          && (currentTokenType == TokenType.whiteSpace ||
          currentTokenType == TokenType.text);

  void _advanceTokenTypes() {
    _previousTokenType = _currentTokenType;
    _currentTokenType = TokenType.invalid;
  }

  Token _convertBufferToToken(TokenType tokenType) {
    int escapeTokens = 0;
    if (tokenType == TokenType.text) {
      escapeTokens = _escaped;
      _escaped = 0;
    }
    int consumedIndex = _bufferStartIndex + _buffer.toString().codeUnits.length + escapeTokens;
    Token token = Token(_buffer.toString(), tokenType, _bufferStartIndex, consumedIndex);
    _buffer.clear();
    _bufferStartIndex = consumedIndex;
    return token;
  }

}