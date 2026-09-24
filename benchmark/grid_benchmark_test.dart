// Benchmark for the grids, run with `flutter test benchmark`.
//
// Timings come from a debug-mode widget test, so compare runs of this
// benchmark with each other, not with a release build. The element and
// render object counts are exact and don't depend on the machine.
//
// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexagon/hexagon.dart';

import '../test/test_utils.dart';

const _runs = 15;
const _box = Size(1000, 1000);

// Not const, so every grid built from them is a new widget.
final _depth = 20;
final _size = 30;

/// Median duration of [action] over [_runs] runs, in milliseconds.
Future<double> _medianMs(Future<void> Function() action) async {
  final samples = <int>[];
  for (var i = 0; i < _runs; i++) {
    final stopwatch = Stopwatch()..start();
    await action();
    stopwatch.stop();
    samples.add(stopwatch.elapsedMicroseconds);
  }
  samples.sort();
  return samples[samples.length ~/ 2] / 1000;
}

int _countRenderObjects(RenderObject root) {
  var count = 0;
  void visit(RenderObject renderObject) {
    count++;
    renderObject.visitChildren(visit);
  }

  visit(root);
  return count;
}

/// Benchmarks the grid returned by [buildGrid], which must create a new
/// (equal) widget on every call, as a parent rebuilding would.
Future<void> _benchmark(
  WidgetTester tester,
  String name,
  int tiles,
  Widget Function() buildGrid,
) async {
  useLargeSurface(tester);
  final grid = buildGrid();

  final firstBuild = await _medianMs(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(boxed(_box, grid));
  });

  late StateSetter rebuild;
  await tester.pumpWidget(
    boxed(
      _box,
      StatefulBuilder(
        builder: (context, setState) {
          rebuild = setState;
          return buildGrid();
        },
      ),
    ),
  );
  final rebuildMs = await _medianMs(() async {
    rebuild(() {});
    await tester.pump();
  });

  var shrink = false;
  final relayout = await _medianMs(() async {
    shrink = !shrink;
    await tester.pumpWidget(
      boxed(shrink ? _box * 0.99 : _box, grid),
    );
  });

  final root = find.byType(grid.runtimeType);
  final elements = collectAllElementsFrom(
    tester.element(root),
    skipOffstage: false,
  ).length;
  final renderObjects = _countRenderObjects(tester.renderObject(root));

  expect(find.byType(HexagonWidget), findsNWidgets(tiles));
  print(
    'BENCHMARK | $name | $tiles '
    '| ${firstBuild.toStringAsFixed(1)} '
    '| ${rebuildMs.toStringAsFixed(1)} '
    '| ${relayout.toStringAsFixed(1)} '
    '| ${(elements / tiles).toStringAsFixed(1)} '
    '| ${(renderObjects / tiles).toStringAsFixed(1)} |',
  );
}

void main() {
  const timeout = Timeout(Duration(minutes: 5));

  testWidgets('HexagonGrid depth 20', timeout: timeout, (tester) async {
    await _benchmark(
      tester,
      'HexagonGrid depth 20',
      1261,
      () => HexagonGrid.flat(depth: _depth),
    );
  });

  testWidgets('HexagonGrid depth 20 with text', timeout: timeout, (
    tester,
  ) async {
    await _benchmark(
      tester,
      'HexagonGrid depth 20 with text',
      1261,
      () => HexagonGrid.flat(
        depth: _depth,
        buildChild: (coordinates) => Text('${coordinates.q},${coordinates.r}'),
      ),
    );
  });

  testWidgets('HexagonOffsetGrid 30x30', timeout: timeout, (tester) async {
    await _benchmark(
      tester,
      'HexagonOffsetGrid 30x30',
      900,
      () => HexagonOffsetGrid.oddPointy(columns: _size, rows: _size),
    );
  });
}
