enum Fruit {
  banana,
  apple,
  orange,
}

void main() {
  Fruit fr = transform<Fruit>('banana', enumValues: Fruit.values);
  print(fr.name);

  Enum en = transform<Enum>('banana', enumValues: Fruit.values);
  print(en.name);

  String str = transform<String>('Barbara Liskov');
  print(str);

   str = transform<String>('banana', enumValues: Fruit.values);
  print(str);

}

T transform<T>(String fromValue, {List<Enum> enumValues = const <Enum>[]})
{
  if (enumValues.isNotEmpty) {
    final enumType = enumValues[0].toString().split('.')[0];
    final returnType = T.toString();
    if (returnType != enumType && returnType != 'Enum') {
      throw ArgumentError(
          "The return type must be 'Enum' or the same type as the enum's values: $enumType.");
    }
    return _doTransform<Enum>(fromValue, enumValues) as T;
  }
  return _doTransform<T>(fromValue, enumValues);
}

T _doTransform<T>(String fromValue, List<Enum> enumValues) {
  return switch (T) {
    String => fromValue,
    bool => bool.parse(fromValue),
    int => int.parse(fromValue),
    double => double.parse(fromValue),
    num => num.parse(fromValue),
    Enum => _convertToEnum(
        fromValue,
        enumValues,
      ),
    _ => throw ArgumentError('$fromValue != ${T.toString()}'),
  } as T;
}

Enum _convertToEnum(String fromValue, List<Enum> enumValues) {
  for (final e in enumValues) {
    if (e.name == fromValue) {
      return e;
    }
  }
  final enumType = enumValues[0].runtimeType.toString();
  throw ArgumentError("Can't transform '$fromValue' to $enumType. "
      "Not an enum constant");
}
