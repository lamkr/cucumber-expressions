import 'package:dart/src/core/locale.dart';
import 'package:dart/src/cucumber_expression_exception.dart';
import 'package:dart/src/parameter_type.dart';
import 'package:dart/src/parameter_type_registry.dart';
import 'package:dart/src/transformer.dart';
import 'package:test/test.dart';

class Name {
  Name(String s);
}

class Person {
  Person(String s);
}

class Place {
  Place(String s);
}

class TransformerName implements Transformer<Name> {
  @override
  Name transform(String arg) => Name(arg);
}

class TransformerPerson implements Transformer<Person> {
  @override
  Person transform(String arg) => Person(arg);
}

class TransformerPlace implements Transformer<Place> {
  @override
  Place transform(String arg) => Place(arg);
}

void main() {
  const capitalisedWord = r"[A-Z]+\w+";
  final registry = ParameterTypeRegistry(Locale.english);

  test('does_not_allow_more_than_one_preferential_parameter_type_for_each_regexp', () {
    registry.defineParameterType( ParameterType("name", capitalisedWord, Name, TransformerName(), false, true));
    registry.defineParameterType( ParameterType("person", capitalisedWord, Person, TransformerPerson(), false, false));

    try {
      registry.defineParameterType( ParameterType('place', r'/[a-z]+/i', Place, TransformerPlace(), false, true) );
      assert(false, 'It should cause an error');
    }
    catch (e) {
      expect(e, isA<CucumberExpressionException>());
      expect(e.toString(), "There can only be one preferential parameter type per regexp. The regexp /[A-Z]+\\w+/ is used for two preferential parameter types, {name} and {place}");
    }
  });
}

