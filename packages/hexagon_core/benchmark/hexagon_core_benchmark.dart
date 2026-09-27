// Rough timings for the operations games call every frame or every turn.
//
// Run with: dart run benchmark/hexagon_core_benchmark.dart
import 'package:hexagon_core/hexagon_core.dart';

void main() {
  final map = HexMap<int>.fromCells(
    HexShape.rectangle(200, 200),
    (hex) => (hex.q * 7 + hex.r * 13) % 10 == 0 ? 1 : 0,
  );
  bool passable(Hex hex) => map[hex] == 0;
  const layout = HexLayout.flat(radius: 16);

  _measure('hexesInRect 1920×1080 viewport', 1000, () {
    var count = 0;
    for (final _ in layout.hexesInRect(
      const PixelRect.fromLTWH(500, 500, 1920, 1080),
    )) {
      count++;
    }
    return count;
  });

  _measure('pixelToHex', 100000, () {
    return layout.pixelToHex(const PixelPoint(1234.5, 678.9)).q;
  });

  _measure('reachable, movement 8', 200, () {
    return Hex.fromOffset(100, 100, HexagonType.flat)
        .reachable(movement: 8, passable: passable)
        .length;
  });

  final start = Hex.fromOffset(5, 5, HexagonType.flat);
  final goal = Hex.fromOffset(190, 190, HexagonType.flat);
  _measure('pathTo across a 200×200 map', 20, () {
    return start.pathTo(goal, passable: passable)?.length ?? -1;
  });

  _measure('fieldOfView, radius 8', 100, () {
    return Hex.fromOffset(100, 100, HexagonType.flat)
        .fieldOfView(8, blocksSight: (hex) => !passable(hex))
        .length;
  });
}

void _measure(String name, int iterations, int Function() body) {
  // Warm up the JIT.
  var sink = 0;
  for (var i = 0; i < iterations ~/ 10 + 1; i++) {
    sink ^= body();
  }
  final watch = Stopwatch()..start();
  for (var i = 0; i < iterations; i++) {
    sink ^= body();
  }
  watch.stop();
  final micros = watch.elapsedMicroseconds / iterations;
  print('${name.padRight(36)} ${micros.toStringAsFixed(2).padLeft(10)} µs'
      '  (checksum $sink)');
}
