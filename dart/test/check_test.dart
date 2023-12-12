import 'dart:async';
import 'dart:math';

import 'package:dart/src/ast/node.dart';
import 'package:test/test.dart';

import 'original_code.dart';
import 'refined_code.dart';

void main() {
  group('Performance', () {
    late Stopwatch stopwatch;

    const max = 15000;
    final rnd = Random(DateTime.now().millisecondsSinceEpoch);
    final count = max;//rnd.nextInt(max);
    final separators = createSeparators(rnd, count);
    final alternatives = createAlternatives(rnd, count);

    print('count = $count');

    test('Speed', () async {
      stopwatch = Stopwatch();
      stopwatch.start();
      refinedCode(count, separators, alternatives);
      stopwatch.stop();
      print('Original code: ${stopwatch.elapsedMilliseconds} ms');

      stopwatch = Stopwatch();
      stopwatch.start();
      originalCode(count, separators, alternatives);
      stopwatch.stop();
      print('Refined code: ${stopwatch.elapsedMilliseconds} ms');

      //expect(stopwatch.elapsedMilliseconds, lessThan(refinedCode.elapsedMilliseconds));
    });

    test('Accuracy', () {
      final originalResults = originalCode(count, separators, alternatives);
      final refinedResults = refinedCode(count, separators, alternatives);

      //expect(originalResults, equals(refinedResults));
    });
  });
}

List<Node> createSeparators(Random rnd, int count) {
  final list = <Node>[];
  while(count>0) {
    final nodeType = NodeType.values[rnd.nextInt(NodeType.values.length)];
    final start = rnd.nextInt(count);
    final end = rnd.nextInt(count);
    list.add(Node.withNodes(nodeType, start, end, []));
    count--;
  }
  return list;
}

List<List<Node>> createAlternatives(Random rnd, int count) {
  final list = <List<Node>>[];
  while(count>0) {
    final countSublist = rnd.nextInt(count);
    list.add( createSeparators(rnd, countSublist) );
    count--;
  }
  return list;
}
