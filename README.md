# Parametric 3D-Printable Ruler

This is a parametric ruler designed in OpenSCAD. Supports metric and imperial markings on both long edges, optional hanging hole, tapered cross-section, and three-color printing where the body, tick-groove floor, and numbers can each be a different filament.

![Variants preview](previews/variants_preview.png)

## Files

| File | Purpose |
|------|---------|
| `ruler_parametric_lib.scad` | All geometry modules (body, ticks, numbers, hole, top-level `ruler()`). |
| `ruler_parametric.scad` | Single-ruler entry point. Edit parameters at the top, then render or export. |
| `ruler_parametric_variants.scad` | Multi-variant entry point. Declares a `variants` array and renders one via `-D variant=N` (or a grid preview when `variant=-1`, the default). |
| `export_variants.sh` | Batch-exports every variant × `{base, body, numbers}` to STL. |

## Requirements

- [OpenSCAD](https://openscad.org/) (tested with the macOS app at `/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD`). On other platforms, make sure `openscad` is on your `PATH`, or set `OPENSCAD=/path/to/openscad`.

## Rendering a single ruler

Edit `ruler_parametric.scad` (uncomment the preset for the size you want, tweak anything else you like), then:

```bash
# PNG preview
openscad ruler_parametric.scad -o ruler.png --imgsize=1400,900 --viewall --autocenter

# Single-color STL (engraved numbers)
openscad ruler_parametric.scad -o ruler_complete.stl

# Three-color STL set (see "Multi-color printing" below)
openscad ruler_parametric.scad -o ruler_base.stl    -D 'render_mode="base"'
openscad ruler_parametric.scad -o ruler_body.stl    -D 'render_mode="body"'
openscad ruler_parametric.scad -o ruler_numbers.stl -D 'render_mode="numbers"'
```

## Batch-exporting every variant

`ruler_parametric_variants.scad` defines eight variants out of the box:

| Variant | Length | Thickness |
|---------|--------|-----------|
| `10cm`  | 100 mm | 1.60 mm |
| `15cm`  | 150 mm | 2.00 mm |
| `20cm`  | 200 mm | 2.16 mm |
| `30cm`  | 300 mm | 2.40 mm |
| `4in`   | 101.6 mm | 1.60 mm |
| `6in`   | 152.4 mm | 2.00 mm |
| `8in`   | 203.2 mm | 2.16 mm |
| `12in`  | 304.8 mm | 2.40 mm |

To export all 24 STLs (8 variants × 3 parts) in one go:

```bash
./export_variants.sh
```

Output lands in `out/ruler_<label>_<part>.stl` — for example `out/ruler_15cm_body.stl`. If OpenSCAD lives somewhere other than the default macOS path, point the script at it:

```bash
OPENSCAD=/usr/local/bin/openscad ./export_variants.sh
```

Editing variants: change the `variants` array in `ruler_parametric_variants.scad`. If you add, remove, or reorder entries, update the `LABELS` array in `export_variants.sh` to match — the two lists need to stay in sync.

To preview all variants in the OpenSCAD GUI before exporting, just open `ruler_parametric_variants.scad`; with `variant = -1` (the default) it lays out every variant in a grid.

## Importing into the slicer

The ruler is designed for three-color printing with four render modes:

- `complete` — single-color ruler (engraved or raised numbers).
- `base` — bottom slab from z=0 to `tick_floor`. Shows through the tick grooves cut into the body above, so this color is what you see *inside* the tick marks.
- `body` — body above `tick_floor`, with tick grooves, number cutouts (when engraved), and the hanging hole. This is the main ruler color.
- `numbers` — the number geometry only (with small corner anchor cubes so the slicer can align it with the body).

Import workflow:

1. Run `./export_variants.sh` (or the three single-file commands above). For each ruler size, there will be three .stl files:
   - `ruler_<size>_numbers.stl`
   - `ruler_<size>_base.stl`
   - `ruler_<size>_body.stl`

2. In your slicer, import the three files for a given ruler size. (You can use the import dialog or just select the three files in the file manager and drag them to the slicer window.)
   - You can select the three files in the file manager and drag them to the slicer window. Or if you use the import dialog, select the three parts and import them together.
   - It may say that the numbers part is too small and ask to scale to millimeters. Click on **No**.
   - It will ask, "Load these files as a single object with multiple parts?". Click on **Yes**.

3. At this point, the ruler will be in the slicer. Now you need to set the colors for the base and the numbers.
   - In the sidebar, there is a Process panel. Click on Objects.
   - Find the ruler object and click on the arrow to the left of it to expand it to show components.
   - Select the `ruler_<size>_base.stl` component. Then click on the numbered rectangle. It will show your filament options.
   - Select which filament you want to use for the base.
   - Do the same for the `ruler_<size>_numbers.stl` and `ruler_<size>_body.stl`.

### Slicer settings

After you've imported the ruler, you need to configure your slicer settings.

- Use a 0.08mm layer preset
- In the **Wall generator** section, switch from Classic to **Arachne**.

I found that under **Speed**, setting the **Top surface** speed to a lower value helps with surface quality. I set it to 30 mm/s (down from the default of 150 mm/s).


## Tuning

Key parameters in both entry-point files:

- `layer_height` — your slicer layer height. Several thicknesses are expressed as multiples of this (e.g. `edge_thickness = 7 * layer_height`).
- `shrink_factor` — measured post-cooling length ÷ intended length. Scales the model by `1/shrink_factor` in X and Y to compensate for thermal shrinkage. Measure on a test print and update this per filament / printer combination.
- `engrave_depth` — positive = engraved numbers (cut into surface); negative = raised numbers (sit above surface). Sign is respected across all render modes.
- `near_edge_unit` / `far_edge_unit` — `"cm"`, `"inch"`, or `"none"` per edge.
- `near_edge_flip` / `far_edge_flip` — flip the numbers upside-down and count from the far end. Useful for dual-unit rulers so the secondary scale reads correctly when you turn the ruler 180°.

See [`CLAUDE.md`](CLAUDE.md) (or [`AGENTS.md`](AGENTS.md)) for a full tour of the module hierarchy and the gap-based multi-color text trick.
