const escapeCharacter = r'\';
const alternationCharacter = '/';
const beginParameterCharacter = '{';
const endParameterCharacter = '}';
const beginOptionalCharacter = '(';
const endOptionalCharacter = ')';

enum TokenType {
  startOfLine,
  endOfLine,
  whiteSpace,
  beginOptional(beginOptionalCharacter, "optional text"),
  endOptional(endOptionalCharacter, "optional text"),
  beginParameter(beginParameterCharacter, "a parameter"),
  endParameter(endParameterCharacter, "a parameter"),
  alternation(alternationCharacter, "alternation"),
  text;

  final String symbol;
  final String purpose;

  const TokenType([this.symbol = '', this.purpose = '']);
}
