# flutter-hexagon

Hexagons for Flutter apps and games. This repository is a
[pub workspace](https://dart.dev/tools/pub/workspaces) with two packages:

| Package | What it is |
|---|---|
| [`hexagon`](packages/hexagon) | Flutter widgets: `Hexagon`, `HexagonBorder`, `HexGrid`, `HexGridView` and theming. Re-exports `hexagon_core`. |
| [`hexagon_core`](packages/hexagon_core) | Pure Dart grid math: coordinates, pixel layouts, map shapes, pathfinding, movement range and field of view. |

Most apps only depend on `hexagon`. Use `hexagon_core` directly where
Flutter isn't available, such as a game server.

The [example app](packages/hexagon/example) shows both packages: widgets and
borders, grids, and a small strategy map. It is deployed to
[GitHub Pages](https://orlikraf.github.io/flutter-hexagon/) from `main`.

## Development

```sh
flutter pub get                      # resolves the whole workspace

cd packages/hexagon_core && dart test
cd packages/hexagon && flutter test
cd packages/hexagon && dart fix --compare-to-golden test_fixes
cd packages/hexagon/example && flutter run
```

CI runs analysis, tests, the `dart fix` golden test, a benchmark, a web build
of the example and a publish dry run on the oldest supported Flutter
(3.27) and the latest stable.

## Releasing

Publishing is tag-driven (see `.github/workflows/publish.yml`). Publish
`hexagon_core` first, since `hexagon` depends on it:

```sh
git tag hexagon_core-v1.0.0 && git push origin hexagon_core-v1.0.0
git tag hexagon-v1.0.0 && git push origin hexagon-v1.0.0
```
