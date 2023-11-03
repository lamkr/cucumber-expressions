import "dart:collection" show Queue;

class Stack<T> {
  final Queue<T> _queue;

  Stack() : _queue = Queue<T>();

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  bool get isNotEmpty => _queue.isNotEmpty;

  void clear() => _queue.clear();

  T peek() {
    if (isEmpty) {
      throw StateError("Empty stack.");
    }
    return _queue.last;
  }

  T pop() {
    if (isEmpty) {
      throw StateError("Empty stack.");
    }
    return _queue.removeLast();
  }

  void push(final T element) => _queue.addLast(element);
}