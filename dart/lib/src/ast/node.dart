import 'package:collection/collection.dart';
import 'located.dart';

final class Node implements Located {
  final NodeType type;
  final List<Node> nodes;
  final String token;
  final int _start;
  final int _end;

  Node.withToken(NodeType type, int start, int end, String token)
      : this(type, start, end, <Node>[], token);

  Node.withNodes(NodeType type, int start, int end, List<Node> nodes)
      : this(type, start, end, nodes, '');

  Node(this.type, this._start, this._end, this.nodes, this.token);

  @override
  int get start => _start;

  @override
  int get end => _end;

  String get text {
    if (nodes.isEmpty) {
      return token;
    }
    return nodes.map((node) => node.text).join();
  }

  @override
  String toString() => toStringWithDepth(0).toString();

  StringBuffer toStringWithDepth(int depth) {
    StringBuffer sb = StringBuffer();
    for (int i = 0; i < depth; i++) {
      sb.write('  ');
    }
    sb
      ..write('{')
      ..write('"type": "')
      ..write(type)
      ..write('", "start": ')
      ..write(start)
      ..write(', "end": ')
      ..write(end);

    if (token.isNotEmpty) {
      sb
        ..write(', "token": "')
        ..write(token.replaceAll(r'\\', r'\\\\'))
        ..write('"');
    }

    if (nodes.isNotEmpty) {
      sb.write(', "nodes": ');
      if (nodes.isNotEmpty) {
        StringBuffer padding = StringBuffer();
        for (int i = 0; i < depth; i++) {
          padding.write('  ');
        }
        final nodesInString =
          nodes
            .map((node) => node.toStringWithDepth(depth + 1))
            .join(',\n');
        sb.write('[\n$nodesInString\n$padding]');
      } else {
        sb.write('[]');
      }
    }
    sb.write('}');
    return sb;
  }

  @override
  bool operator ==(Object other) {
    if (this == other) {
      return true;
    }
    Function deepEqual = const DeepCollectionEquality().equals;
    return (other is Node) &&
        other.start == start &&
        other.end == end &&
        other.type == type &&
        deepEqual(other.nodes, nodes) &&
        other.token == token;
  }

  @override
  int get hashCode =>
      type.hashCode ^ token.hashCode ^ _start ^ _end ^ Object.hashAll(nodes);

  int compareTo(Node other) => hashCode - other.hashCode;
}

enum NodeType {
  textNode,
  optionalNode,
  alternationNode,
  alternativeNode,
  parameterNode,
  expressionNode
}
