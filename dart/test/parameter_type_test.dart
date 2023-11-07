import 'package:dart/src/core/type_ex.dart';
import 'package:dart/src/parameter_type.dart';
import 'package:dart/src/parameter_type_registry.dart';
import 'package:test/test.dart';

void main() {
  test('Does not allow ignore flag on regexp', () {
    try {
      ParameterType('case-insensitive', r'/[a-z]+/i', String, (s) => s, true, true);
      assert(false, 'It should cause an error');
    }
    catch (e) {
      expect(e, isA<Error>());
      expect(e.toString(), "ParameterType Regexps can't use flag 'i'");
    }
  });

  test('Has a type name for {int}', () {
    final parameterTypeRegistry = ParameterTypeRegistry();
    final elem = parameterTypeRegistry.lookupByTypeName('int');
    expect(elem.type.name, 'Number');
  });
}
/*
it('has a type name for {int}', () => {
  const r = new ParameterTypeRegistry()
  const t = r.lookupByTypeName('int')!
  // @ts-ignore
  assert.strictEqual(t.type.name, 'Number')
})

it('has a type name for {bigint}', () => {
const r = new ParameterTypeRegistry()
const t = r.lookupByTypeName('biginteger')!
// @ts-ignore
assert.strictEqual(t.type.name, 'BigInt')
})

it('has a type name for {word}', () => {
const r = new ParameterTypeRegistry()
const t = r.lookupByTypeName('word')!
// @ts-ignore
assert.strictEqual(t.type.name, 'String')
})
})
*/