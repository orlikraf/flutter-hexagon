import 'dart:collection';

import 'hex.dart';

/// A map from hexes to values of type [T], for storing per-cell game or UI
/// state such as terrain, units or colors.
///
/// It is a regular [Map], with a few hex-specific helpers.
class HexMap<T> extends MapBase<Hex, T> {
  /// Creates an empty map.
  HexMap();

  /// Creates a map with an entry for each of [cells], valued by [valueOf].
  HexMap.fromCells(Iterable<Hex> cells, T Function(Hex hex) valueOf) {
    for (final hex in cells) {
      _cells[hex] = valueOf(hex);
    }
  }

  /// Creates a map with the same entries as [other].
  HexMap.of(Map<Hex, T> other) {
    _cells.addAll(other);
  }

  final Map<Hex, T> _cells = <Hex, T>{};

  @override
  T? operator [](Object? key) => _cells[key];

  @override
  void operator []=(Hex key, T value) => _cells[key] = value;

  @override
  void clear() => _cells.clear();

  @override
  Iterable<Hex> get keys => _cells.keys;

  @override
  T? remove(Object? key) => _cells.remove(key);

  @override
  bool containsKey(Object? key) => _cells.containsKey(key);

  @override
  int get length => _cells.length;

  /// The hexes in this map, same as [keys].
  Iterable<Hex> get cells => _cells.keys;

  /// The neighbors of [hex] that are in this map.
  Iterable<Hex> neighborsOf(Hex hex) => hex.neighbors.where(containsKey);

  /// The hexes whose value satisfies [test].
  Iterable<Hex> where(bool Function(Hex hex, T value) test) sync* {
    for (final entry in _cells.entries) {
      if (test(entry.key, entry.value)) {
        yield entry.key;
      }
    }
  }
}
