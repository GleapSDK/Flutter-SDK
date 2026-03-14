import 'dart:collection';

class RingBuffer<E> {
  final DoubleLinkedQueue<E> _queue = DoubleLinkedQueue<E>();
  int limit;

  RingBuffer(this.limit);

  void setLimit(int limit) {
    this.limit = limit;
  }

  void add(E value) {
    _queue.add(value);
    while (_queue.length > limit) {
      _queue.removeFirst();
    }
  }

  int get length => _queue.length;

  void clear() => _queue.clear();

  Iterator<E> get iterator => _queue.iterator;

  List<E> toList({bool growable = true}) => _queue.toList(growable: growable);
}
