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

## Phase 1: Correctness fixes (0.2.x patch releases)

Order: most user-visible first. Every item gets a failing test first.

| # | Bug | Location | Test that proves it |
|---|-----|----------|---------------------|
| 1 | `Coordinates.hashCode` uses `x ^ y ^ z`: 331 tiles share only 16 hashes | `grid/coordinates.dart:40` | Distinct-hash count over a depth-10 grid, above 95% |
| 2 | Offset grid mixes units when comparing aspect ratios, so tiles overflow (5×10 flat grid in 400×1000 renders 440px wide) | `grid/hexagon_offset_grid.dart:167-176` | Pump across a sweep of box sizes; no overflow exception, content fits |
| 3 | `HexagonGrid` drops `padding` when `width`/`height` is set, and ignores the parent's constraints | `grid/hexagon_grid.dart:218-224` | Explicit width plus padding: content stays within bounds |
| 4 | Exact float `==` on `hh`/`ww` picks the wrong branch (126 of the heights from 100 to 2000) | `grid/hexagon_grid.dart:232,239` | Height 115, depth 1: fits |
| 5 | `HexagonWidgetBuilder.key` is put on every tile, so siblings get duplicate keys | `hexagon_widget.dart:203` | Grid with a keyed template must not assert. Fix: deprecate the field and stop forwarding it |
| 6 | `HexagonGrid.buildTile` can't return `null`, though the docs say it can | `grid/hexagon_grid.dart:105` | Returning `null` falls back to `hexagonBuilder` |
| 7 | Negative `cornerRadius` asserts, though the docs say it's ignored; large radii make a self-intersecting path | `hexagon_path_builder.dart:13`, `hexagon_widget.dart` | Clamp to `[0, maxRadius]`; path bounds stay inside the size |
| 8 | Rounded corners aren't circular (the Bézier constant is 0.7698 but should be 0.6188) | `hexagon_path_builder.dart:104` | Replace with `arcToPoint`; sampled arc points lie at distance `r` from the arc centre |
| 9 | `width` and `height` together: the painted hexagon overflows its box | `hexagon_widget.dart:111,123` | Fit the hexagon inside `min(w, h/ratio)` and centre it (contain) |
| 10 | Only `oddFlat` asserts `columns > 0 && rows > 0` | `grid/hexagon_offset_grid.dart` | All four constructors assert |
| 11 | `HexagonPainter.hitTest` depends on state saved during `paint` | `hexagon_painter.dart:14,31` | Hit-test works deterministically (Phase 3 replaces the painter anyway) |

Supporting tests added in this phase:
- **Geometry unit tests** for the path builder: six vertices, correct
  apothem and circumradius, bounds for both orientations, with and without
  `inBounds`.
- **Layout tests** for both grids: for a matrix of (type × depth or
  rows/cols × constraint shape), no `RenderFlex` overflow and total size ≤
  constraints.
- **Golden tests** on Linux CI only, using the Ahem font: single flat and
  pointy hexagons, rounded corners, and each of the four offset grids.

**Done when:** every row above has a test that passes, and the README
examples render without overflow.

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
- [ ] **Errors:** replace `throw Exception('Error: ...')` with `FlutterError`
      and actionable messages (e.g. "HexagonGrid got unbounded constraints
      in both axes; give it a width/height or wrap it in a SizedBox").
      Split `_pointBetween(distance?, fraction?)` into two functions.
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
