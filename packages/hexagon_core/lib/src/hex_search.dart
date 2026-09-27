import 'hex.dart';

/// Cost of moving from [from] to its neighbor [to].
///
/// Return `null` to make the move impossible.
typedef HexStepCost = double? Function(Hex from, Hex to);

/// Whether a hex can be entered, or whether it blocks sight.
typedef HexPredicate = bool Function(Hex hex);

double _unitCost(Hex from, Hex to) => 1;

/// Movement, pathfinding and visibility queries starting from a hex.
extension HexSearch on Hex {
  /// Every hex reachable from this one with at most [movement] points,
  /// mapped to the cheapest cost of getting there.
  ///
  /// Hexes for which [passable] returns false can't be entered. [cost] gives
  /// the price of each step (1 by default) and can return `null` to forbid a
  /// step. The start hex is always included with cost 0.
  ///
  /// Use [passable] to keep the search inside your map: on an unbounded plane
  /// the search covers every hex within [movement] steps.
  Map<Hex, double> reachable({
    required double movement,
    HexPredicate? passable,
    HexStepCost? cost,
  }) {
    final stepCost = cost ?? _unitCost;
    final costs = <Hex, double>{this: 0};
    final queue = _MinHeap<Hex>()..add(this, 0);
    while (queue.isNotEmpty) {
      final (current, currentCost) = queue.removeFirst();
      if (currentCost > costs[current]!) {
        continue;
      }
      for (final next in current.neighbors) {
        if (passable != null && !passable(next)) {
          continue;
        }
        final step = stepCost(current, next);
        if (step == null) {
          continue;
        }
        final nextCost = currentCost + step;
        if (nextCost > movement) {
          continue;
        }
        final known = costs[next];
        if (known == null || nextCost < known) {
          costs[next] = nextCost;
          queue.add(next, nextCost);
        }
      }
    }
    return costs;
  }

  /// The cheapest path from this hex to [goal], both included, or `null` if
  /// there is none.
  ///
  /// Uses A*. Hexes for which [passable] returns false can't be entered, and
  /// [cost] gives the price of each step (1 by default; `null` forbids it).
  /// The search assumes no step is cheaper than [minStepCost]; if yours can
  /// be, lower it or the result may not be the cheapest path.
  ///
  /// The search gives up and returns `null` after visiting [maxVisited]
  /// hexes, which keeps an unreachable goal on an unbounded plane from
  /// searching forever.
  List<Hex>? pathTo(
    Hex goal, {
    HexPredicate? passable,
    HexStepCost? cost,
    double minStepCost = 1,
    int maxVisited = 100000,
  }) {
    if (this == goal) {
      return [this];
    }
    if (passable != null && !passable(goal)) {
      return null;
    }
    final stepCost = cost ?? _unitCost;
    final costs = <Hex, double>{this: 0};
    final cameFrom = <Hex, Hex>{};
    final closed = <Hex>{};
    final queue = _MinHeap<Hex>()..add(this, distanceTo(goal) * minStepCost);
    while (queue.isNotEmpty) {
      final (current, _) = queue.removeFirst();
      if (current == goal) {
        final path = [goal];
        var hex = goal;
        while (hex != this) {
          hex = cameFrom[hex]!;
          path.add(hex);
        }
        return path.reversed.toList();
      }
      if (!closed.add(current)) {
        continue;
      }
      if (closed.length > maxVisited) {
        return null;
      }
      final currentCost = costs[current]!;
      for (final next in current.neighbors) {
        if (closed.contains(next)) {
          continue;
        }
        if (passable != null && !passable(next)) {
          continue;
        }
        final step = stepCost(current, next);
        if (step == null) {
          continue;
        }
        final nextCost = currentCost + step;
        final known = costs[next];
        if (known == null || nextCost < known) {
          costs[next] = nextCost;
          cameFrom[next] = current;
          queue.add(next, nextCost + next.distanceTo(goal) * minStepCost);
        }
      }
    }
    return null;
  }

  /// Whether [target] is visible from this hex.
  ///
  /// Draws a line between the two hexes and checks that none of the hexes
  /// strictly between them [blocksSight]. The endpoints themselves never
  /// block, so a wall is visible but what's behind it isn't.
  bool canSee(Hex target, {required HexPredicate blocksSight}) {
    final line = lineTo(target);
    for (var i = 1; i < line.length - 1; i++) {
      if (blocksSight(line[i])) {
        return false;
      }
    }
    return true;
  }

  /// Every hex within [radius] steps that is visible from this hex, see
  /// [canSee].
  Set<Hex> fieldOfView(int radius, {required HexPredicate blocksSight}) => {
        for (final hex in range(radius))
          if (canSee(hex, blocksSight: blocksSight)) hex,
      };
}

/// A binary min-heap of items ordered by a priority.
class _MinHeap<E> {
  final List<E> _items = [];
  final List<double> _priorities = [];

  bool get isNotEmpty => _items.isNotEmpty;

  void add(E item, double priority) {
    _items.add(item);
    _priorities.add(priority);
    var index = _items.length - 1;
    while (index > 0) {
      final parent = (index - 1) >> 1;
      if (_priorities[parent] <= _priorities[index]) {
        break;
      }
      _swap(index, parent);
      index = parent;
    }
  }

  (E, double) removeFirst() {
    final result = (_items.first, _priorities.first);
    final lastItem = _items.removeLast();
    final lastPriority = _priorities.removeLast();
    if (_items.isNotEmpty) {
      _items[0] = lastItem;
      _priorities[0] = lastPriority;
      var index = 0;
      final length = _items.length;
      while (true) {
        final left = 2 * index + 1;
        final right = left + 1;
        var smallest = index;
        if (left < length && _priorities[left] < _priorities[smallest]) {
          smallest = left;
        }
        if (right < length && _priorities[right] < _priorities[smallest]) {
          smallest = right;
        }
        if (smallest == index) {
          break;
        }
        _swap(index, smallest);
        index = smallest;
      }
    }
    return result;
  }

  void _swap(int a, int b) {
    final item = _items[a];
    _items[a] = _items[b];
    _items[b] = item;
    final priority = _priorities[a];
    _priorities[a] = _priorities[b];
    _priorities[b] = priority;
  }
}
