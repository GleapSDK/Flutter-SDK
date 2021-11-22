import 'dart:collection';

class RingBuffer<E> extends DoubleLinkedQueue<E> {
  int limit;

  RingBuffer(this.limit);

  void setLimit(int limit) {
    this.limit = limit;
  }

  @override
  void add(E value) {
    super.add(value);
    while (super.length > limit) {
      super.removeFirst();
    }
  }
}
