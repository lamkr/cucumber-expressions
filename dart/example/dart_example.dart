void main() {
  //TODO To be implemented
  const illegalParameterNamePattern = r"([{}()\\/])";
  const unescapePattern = r"(\\([\[$.|?*+\]]))";
  const name = r'[JOCA';
  RegExp r= RegExp(unescapePattern);
  final matches= r.allMatches(name);
  matches.map((m) => m..null);
  for( var match in matches.iterator ) {}
  String unescapedTypeName = UNESCAPE_PATTERN.matcher(name).replaceAll(r'$2');
  Matcher matcher = ILLEGAL_PARAMETER_NAME_PATTERN.matcher(unescapedTypeName);
  return !matcher.find();

}
