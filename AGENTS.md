
This file provides guidance to coding agents when working with code in this repository.

## Project

Parametric 3D-printable ruler design in OpenSCAD.

### Active files

| File | Purpose |
|------|---------|
| `ruler_parametric_lib.scad` | Ruler library — all modules (body, ticks, numbers, hole, top-level `ruler()`) |
| `ruler_parametric.scad` | Ruler entry point; sets parameters and calls `ruler()` |

## Commands

**Export to PNG for preview:**

You can render the scad file to a png with a command line like:

```
openscad file.scad -o out/file.png --imgsize=1000,800 --viewall --autocenter
```

Note that on a Mac, the path to the `openscad` binary might be `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD`.

Then read the png file to see what it looks like.

**Export STL for printing:**

```
openscad file.scad -o out/file.stl
```

## Architecture

### Convention: lib vs. entry points

All geometry lives in `*_lib.scad` files. Entry-point files just `use` the lib, declare parameters, and make a single top-level call.

### Ruler

`ruler_parametric_lib.scad` contains all modules. `ruler_parametric.scad` declares parameters and calls `ruler()`.

#### Module hierarchy

```
ruler()                                ← top-level; body − ticks − numbers − hole
├── ruler_body()                       ← intersection of tapered extrusion + rounded rect
│   └── ruler_cross_section()          ← 2D polygon: flat center + linear taper to edges
├── ruler_edge_ticks()                 ← tick marks for one edge of the top face
│   ├── mm_ticks()                     ← metric subdivision logic
│   └── inch_ticks()                   ← imperial subdivision logic (binary fractions)
├── ruler_edge_numbers()               ← number labels for one edge
│   └── ruler_numbers()                ← number placement loop
│       └── ruler_number_label()       ← single number (text → linear_extrude)
└── ruler_hanging_hole()               ← through-hole cylinder
```

#### Entry-point parameters

- **`layer_height`:** Slicer layer height (mm). Several parameters are expressed as multiples of this (`edge_thickness`, `tick_floor`, `engrave_depth`, `number_pad_layers`).
- **`shrink_factor`:** Measured post-cooling length ÷ intended length (e.g. 0.9976). The model is scaled by `1/shrink_factor` along X and Y to compensate for thermal shrinkage.

#### Key design concepts

- **Dual-edge markings:** Both measurement scales (e.g. metric + imperial) are on the top face, one per long edge. Ticks extend inward from each edge.
- **Tapered cross-section:** The body is thick at the center and tapers linearly to thin measuring edges. Ticks cut from `tick_floor` (defaults to `edge_thickness`) through the top, leaving a solid floor.
- **Engrave depth sign:** `engrave_depth > 0` engraves numbers into the surface; `< 0` raises them above it. The sign is respected across all render modes.
- **Multi-color export (`render_mode`):** Four modes:
  - `"complete"` — single-color ruler.
  - `"base"` — bottom slab from z=0 to `tick_floor`. Tick grooves cut through the body above reveal this layer as the groove floor color.
  - `"body"` — body above `tick_floor`, with tick grooves, number cutouts (when engraved), and hole.
  - `"numbers"` — number color geometry (with bounding-box anchor cubes for slicer alignment).
  Export "base", "body", and "numbers" as separate STLs, import into slicer, assign different filaments.
- **Gap-based text (engraved, `engrave_depth > 0`):** The body's top layers have thin text-shaped gaps (at the font's native stroke width). Below the gaps sit color pads made from offset-expanded (fat) text. The body covers the fat pads everywhere except through the thin gaps, so the visible text can be finer than the nozzle width — same trick as tick marks. `number_pad_depth` (`number_pad_layers × layer_height`) controls pad thickness; pads are inset with their top surface `engrave_depth` below the ruler surface.
- **Raised text (`engrave_depth < 0`):** Colored text protrudes above the body surface. `number_pad_expand` is still applied to fatten strokes above the nozzle width so the slicer can print them.
- **`number_pad_expand`:** `offset(r=...)` applied to text geometry. Expands each stroke so it exceeds the nozzle width. Used for both engraved pads and raised text.
- **`near_edge_flip` / `far_edge_flip`:** When `true`, the numbers on that edge are rendered upside-down and count from the far end instead of the near end. Designed for rulers with different units per edge — flip the secondary edge so its numbers read correctly when you rotate the ruler 180°.
- Numbers too close to either end of the ruler (within `number_size` of the edge) are automatically omitted to prevent clipping.
