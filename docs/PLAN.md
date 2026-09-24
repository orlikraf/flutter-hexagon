# Improvement plan

Goal: take `hexagon` from "works if you hold it right" to a well-tested,
lint-clean, pub.dev 160/160 package, then build new features on that base.

Rules for every phase:

- Each bug fix lands with a regression test that fails before the fix.
- Nothing merges unless CI (format, analyze, test) is green.
- Breaking changes are deprecated first (0.3.0) and removed in 1.0.0.

Findings referenced below come from the audit of 2026-09-24.

---

## Phase 0: Safety net and dependencies (no behaviour change)

Nothing else is trustworthy until tests run automatically.

### 0.1 Lints
- [x] Add a root `analysis_options.yaml` that includes `flutter_lints` and
      turns on `strict-casts`, `strict-inference` and `strict-raw-types`.
- [x] Add `flutter_lints` to `dev_dependencies`.
- [x] Fix mechanical lint hits that don't change the API: braces on `if`,
      unnecessary `this.`, `SizedBox` instead of empty `Container`, and the
      stray `library hexagon;` in `lib/src/hexagon_widget.dart`.
      Enum renames wait for Phase 2.

### 0.2 CI
- [x] Add `.github/workflows/ci.yml`, run on every push and on PRs to `main`:
      `dart format --set-exit-if-changed`, `flutter analyze`, `flutter test`.
- [x] Test on two Flutter versions: the minimum supported version (3.32.0)
      and current stable.
- [x] Also build the example app (`flutter build web`) so it can't rot.

### 0.3 Dependencies and toolchain
- [x] `pubspec.yaml`: `sdk: ^3.8.0`, `flutter: ">=3.32.0"`, the oldest
      versions CI tests. The floor is set by `flutter_lints` 6 (Dart 3.8).
      (Was `<3.0.0` / `>=1.17.0`: no Dart 3, and allowed Flutter versions
      without null safety.)
- [x] `dev_dependencies`: latest `flutter_lints` (^6.0.0).
- [x] Example: bump the SDK constraint and `flutter_lints` (^2.0.0 to
      ^6.0.0). Removed `cupertino_icons`: it was unused, and its latest
      version needs Dart 3.9. Replaced the deprecated `Switch.activeColor`.
- [ ] **Blocked until the sandbox can reach `storage.googleapis.com` and
      `pub.dev`:** regenerate the example's platform folders (android, ios, macos,
      linux, windows, web) with `flutter create .` on current stable. They
      date from Flutter 3.7: old Gradle/AGP, Groovy build scripts, old
      Xcode project format.
- [x] Regenerate both `pubspec.lock` files with tooling, never by hand
      (taken from `flutter pub get` output in CI).
- [x] FVM: pin current stable (3.47.5) and migrate `.fvm/fvm_config.json`
      to FVM 3's `.fvmrc`.
- [ ] Update `.metadata` (it still points at a `beta` channel revision).
      Blocked with the platform folders: `flutter create` rewrites it.
- [x] Add `.github/dependabot.yml` for the `pub` (root and `/example`) and
      `github-actions` ecosystems, so dependencies don't go stale again.

### 0.4 Make the test suite honest
- [x] Fix `test/hexagon_test.dart:41`. `flat != flat2` has been wrong since
      `inBounds` defaulted to `true`; assert equality instead.
- [x] Wrap grid tests in `Directionality`. A multi-child `Row` asserts
      without it.
- [x] Replace the Flutter counter template in `example/test/widget_test.dart`
      with a smoke test that pumps each tab.
- [x] Fix the "HexagonGird" typo.

### 0.5 Harden publishing (`publish.yml`)
- [x] Switch to pub.dev automated publishing with GitHub OIDC
      (`dart-lang/setup-dart/.github/workflows/publish.yml`). Then delete
      the `CREDENTIAL_JSON` secret: it's a long-lived Google refresh token.
- [x] Remove `fjogeleit/yaml-update-action@main`: a third-party action on
      a moving branch, in a job that holds secrets. Instead, fail the job
      if the tag doesn't match `pubspec.yaml`'s version and the top
      CHANGELOG entry. The repo becomes the source of truth.
- [x] Add a minimal `permissions:` block, pin actions to commit SHAs, and
      run tests before publishing (drop `skipTests: true`).

### 0.6 Package metadata
- [x] Add `repository`, `issue_tracker` and `topics` (hexagon, grid, shape,
      game). Fix `homepage` to point at the maintained repo.
- [x] Add `.pubignore` to leave `docs/`, `.github/` and `.fvm/` out of the
      published archive.

**Done when:** CI is green on a PR, the dependencies are current, and a
dry-run publish passes.

---

## Phase 1: Correctness fixes

Every fix has a regression test. The tests were pushed first (`c60ede7`)
and CI showed them failing on the old code: 20 failed, 139 passed. The
passing ones were sweep cases that already fit, and the hit-test guard.

| # | Bug | Fix | Test | Status |
|---|-----|-----|------|--------|
| 1 | `Coordinates.hashCode` was `x ^ y ^ z`: 331 tiles shared 16 hashes | `Object.hash` (also on the path builder and painter) | `coordinates_test.dart`: over 95% distinct hashes on a depth-10 grid | [x] |
| 2 | Offset grid compared aspect ratios in mixed units and overflowed (5×10 flat in 400×1000 rendered 440px wide; 1×1 pointy overflowed 16px) | Fit by width, check the resulting height, else fit by height. Single-row and single-column grids no longer reserve a phantom half tile | `hexagon_offset_grid_test.dart`: 4 constructors × 5 shapes × 4 boxes | [x] |
| 3 | `HexagonGrid` dropped `padding` with explicit `width`/`height`, and ignored the parent's constraints | Subtract padding; clamp to the parent's constraints | `hexagon_grid_test.dart`: explicit width with padding, width larger than the parent | [x] |
| 4 | Exact float `==` picked the wrong dimension (depth 3 in 800×115 rendered 882px tall) | Same fit check as #2, with a tolerance | `hexagon_grid_test.dart`: depth 3 in 800×115, plus a sweep of 2 types × 5 depths × 5 boxes | [x] |
| 5 | A key on the shared `hexagonBuilder` template was copied onto every tile ("Duplicate keys found") | Assert with a message pointing to `buildTile`. Per-tile keys stay supported, so the field isn't deprecated | Both grid test files | [x] |
| 6 | `HexagonGrid.buildTile` couldn't return `null`, though the docs said it could | Nullable return type (non-breaking for callers) | `hexagon_grid_build_tile_test.dart` | [x] |
| 7 | Negative `cornerRadius` threw; oversized radii self-intersected | Clamp to `[0, apothem]` | `hexagon_path_builder_test.dart`, `hexagon_widget_test.dart` | [x] |
| 8 | Rounded corners weren't circular (off by about 3% of the radius) | `arcToPoint` | At maximum radius the outline is a circle within 1px | [x] |
| 9 | With both `width` and `height`, the hexagon was painted outside its box | Largest hexagon that fits, centered | Path bounds for a wide flat box and a tall pointy box | [x] |
| 10 | Only `oddFlat` asserted `columns > 0 && rows > 0` | All four constructors assert | `hexagon_offset_grid_test.dart` | [x] |
| 11 | ~~`HexagonPainter.hitTest` depends on state saved during `paint`~~ | Not a bug: `RenderCustomPaint` keeps the old painter when the new one is `==`, so hit tests use the painted path. The painter is replaced in Phase 3 | Guard test: taps hit the hexagon (not its corners), also after a rebuild | n/a |

Supporting tests:
- [x] **Geometry unit tests** for the path builder: bounds for both
      orientations, with and without `inBounds`.
- [x] **Layout sweeps** for both grids: no overflow, and every tile inside
      the box.
- [ ] **Golden tests.** Deferred: the reference images have to be
      generated and reviewed locally, which needs `storage.googleapis.com`
      and `pub.dev`.

**Done when:** every row above has a passing test, and the example app
renders every tab without overflow (the example smoke test in CI).

---

## Phase 2: API modernisation (0.3.0 deprecates, 1.0.0 removes)

- [ ] **Enums:** `HexagonType.flat` / `.pointy`, `GridType.even` / `.odd`.
      Keep the old names as `@Deprecated static const FLAT = flat;` in
      enhanced enums so 0.3.0 isn't breaking.
- [ ] **Public surface:** export `HexagonPathBuilder` (or its replacement,
      `HexagonBorder`, from Phase 3). Nothing in the public API should
      require `package:hexagon/src/...`. Make the `flatFactor` and
      `pointyFactor` extension methods private.
- [ ] **Coordinates:**
  - make `Coordinates.axial` a `const` constructor
  - assert `x + y + z == 0` in `.cube`
  - drop the redundant `.toInt()`
  - `Object.hash` (Phase 1)
- [ ] **HexDirections:** `static const` fields, private constructor,
      consistent names (`topRight`/`bottomLeft` on both orientations), plus
      `HexDirections.of(HexagonType)` returning the ordered six.
- [ ] **Widgets:**
  - [x] `Key? key` on `HexagonGrid` and `HexagonOffsetGrid` (done in phase 0)
  - [x] `const` constructors (done in phase 0)
  - [x] give `HexagonWidgetBuilder.build(inBounds)` a type (done in phase 0)
- [ ] **Layout side effect:** remove the root `Align` from `HexagonWidget`.
      It's breaking (the widget currently expands inside bounded parents),
      so document it in the migration guide.
- [x] **Errors:** replace `throw Exception('Error: ...')` with `FlutterError`
      and actionable messages. Split `_pointBetween(distance?, fraction?)`.
      (Done in Phase 1, since the code was rewritten there.)
- [ ] **Imports:** `package:flutter/widgets.dart` instead of `material.dart`
      across `lib/`, and consistent relative imports.
- [ ] **Docs:** class-level dartdoc on every public type, field-level docs
      written once (not copied onto every constructor), `{@tool snippet}`
      examples, fix all typos. Add a migration guide in `doc/migration.md`.

**Done when:** `flutter analyze` is clean with the lints on, `dart doc` has
no warnings, and `pana` reports 160/160 (checked in CI).

---

## Phase 3: Internals, rendering and performance

- [ ] **One geometry module** (`lib/src/geometry/hex_metrics.dart`): named
      constants in place of the magic `0.75`, `8` and `1.5`, and one
      sizing function that both grids share. Today the two grids duplicate
      the math and only agree by coincidence (0.75·2/√3 = √3/2).
- [ ] **`HexagonBorder extends OutlinedBorder`**: this replaces the custom
      painter and clipper, and unlocks:
  - `ShapeDecoration`, `Material(shape: HexagonBorder())` (ink splashes,
    elevation), `Card`, `InkWell` with hexagon-shaped hit areas
  - border `side` (stroke colour and width), which users keep asking for
  - `lerp` for animated morphs (flat ↔ pointy, radius changes)
- [ ] **Paths:** build once per size and share between paint and clip.
      Precompute the six unit-corner offsets (no trig per frame).
- [ ] **Clipping:** skip `ClipPath` when there's no child; add a
      `clipBehavior` parameter.
- [ ] **Benchmark:**
  - add `benchmark/` with a depth-20 `HexagonGrid` (1,261 tiles)
  - record build, layout and raster times with `integration_test` and a
    timeline summary
  - record the before and after numbers in this file
- [ ] **Grid rendering:** try a single `RenderObject` (or
      `CustomMultiChildLayout`) for grids instead of nested Rows and
      Columns. Keep it if the benchmark shows a win.

**Done when:** the benchmark numbers are recorded and no regressions show
in the goldens.

---

## Phase 4: Polish and 1.0.0

- [ ] Rewrite the README:
  - correct API (e.g. `buildTile`, not `buildHexagon`)
  - fresh screenshots
  - a feature table
  - a "which grid do I need?" section
- [ ] Rebuild the example app:
  - dispose the `TabController`
  - remove the redundant `DefaultTabController`
  - use `SingleTickerProviderStateMixin`
  - add one tab per feature, including `HexagonBorder` with `Material` and
    `InkWell`
- [ ] Add small value features to `Coordinates`: `neighbors`,
      `ring(radius)`, `spiral(radius)`, rotation, and rounding from
      fractional cube coordinates. (The Future work section needs these.)
- [ ] Switch the CHANGELOG to Keep-a-Changelog format and use ISO dates.
- [ ] Remove the 0.3.0 deprecations and tag `1.0.0` through the hardened
      publish workflow.

---

## Future work: layout inside the hexagon (parked, start after Phase 4)

> Deliberately **not started**. Start it only after Phases 0 to 4 have
> shipped. It builds on `HexagonBorder`, the geometry module and the
> `Coordinates` helpers.

**Problem.** Content inside a hexagon is laid out in a rectangle
(`OverflowBox`) and then clipped, so text and images get cut off at the
corners. The README roadmap lists this as "Solve content spacing".

Planned, in increasing order of difficulty:

1. **Content fit modes:** `contentFit: inscribedRect | inscribedCircle |
   boundingBox`. Compute the largest axis-aligned rectangle (or circle)
   inside the hexagon and lay the child out in it. This is the quick win
   that fixes most clipping complaints.
2. **`HexagonLayoutBuilder`:** like `LayoutBuilder`, but hands the child a
   `HexagonConstraints` (orientation, corners, apothem, circumradius,
   inscribed rect and circle, `widthAt(y)` and `heightAt(x)`) so children
   can lay themselves out around the shape.
3. **Hexagon-aware slots:** a `Stack`-like widget with `HexAlignment`:
   - `center`, `corner(i)`, `edge(i)` positions
   - optional rotation to follow the edge
   - useful for game UIs (stats on edges, badges on corners)
4. **Shape-aware text flow (the hard part):** a custom `RenderObject`
   that lays text out line by line, where each line's maximum width is
   `widthAt(y)` for that band. It needs:
   - greedy line breaking with `TextPainter` or `Paragraph` per line
   - vertical centring by iterating until the block height converges
   - ellipsis on the last line, and RTL, `TextScaler` and semantics
   - intrinsic sizes and baselines
5. **Subdivision layouts:** split a hexagon into 6 triangles or 7 sub-hexes
   ("flower") for nested menus or radial pickers, reusing the grid code.

Open questions to research first:
- how to report intrinsic dimensions for non-rectangular content
- hit-testing children near clipped corners
- how text flow performs for hundreds of tiles in a grid (caching per size
  and string)
