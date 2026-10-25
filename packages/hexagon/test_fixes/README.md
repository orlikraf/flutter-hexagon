Golden tests for the data-driven fixes in `hexagon_core/lib/fix_data.yaml`.

Run from `packages/hexagon`:

```sh
dart fix --compare-to-golden test_fixes
```

Each `*.dart` file uses the old API; `dart fix` must turn it into the
matching `*.dart.expect` file.
