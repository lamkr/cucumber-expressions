import 'group.dart';
import 'parameter_type.dart';

class Argument<T> {
  final ParameterType parameterType;
  final Group group;

  static List<Argument> build(Group group, List<ParameterType> parameterTypes) {
    List<Group> argGroups = group.children;

    if (argGroups.length != parameterTypes.length) {
      // This requires regex injection through a Cucumber expression.
      // Regex injection should be be possible any more.
      throw ArgumentError(
          'Group has ${argGroups.length} capture groups, '
          'but there were ${parameterTypes.length} parameter types');
    }

    final args = <Argument>[];
    for( var index = 0; index < argGroups.length; index++) {
      final argGroup = argGroups[index];
      final parameterType = parameterTypes[index];
      args.add( Argument._(argGroup, parameterType) );
    }
    return args;
  }

  Argument._(this.group,this.parameterType);

  T get value => parameterType.transform(group.values);

  Type get type => parameterType.type;
}