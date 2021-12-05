class SingleCache<K, V> {
  K? key;
  V? value;
  V? operator [](K key) => key == this.key ? value : null;
  operator []=(K key, V value) {
    this.key = key;
    this.value = value;
  }

  bool contains(K key) => this.key == key;
  V putIfAbsent(K key, V Function() ifAbsent) {
    if (key == this.key) {
      return value as V;
    }
    final newValue = ifAbsent();
    value = newValue;
    this.key = key;
    return newValue;
  }
}
