// Parametric 3D-Printable Ruler — Multi-Variant Export
//
// Declares an array of ruler variants (metric + imperial, various lengths) and
// renders one of them based on the `variant` parameter. Use together with
// `export_variants.sh` to batch-export STLs for all variants × all render modes.
//
// Usage:
//   variant = -1 (default) → grid preview of every variant (for GUI inspection)
//   variant =  N           → render variants[N] alone (for STL export)
//
// Example STL export:
//   openscad ruler_parametric_variants.scad -o ruler_15cm_body.stl \
//     -D 'variant=1' -D 'render_mode="body"'

use <ruler_parametric_lib.scad>

$fn = 60;

// ─── Variant Definitions ────────────────────────────────────────────────

// Tuple indices
V_UNIT      = 0; // "cm" or "inch" — applied to both edges
V_LENGTH_MM = 1; // Ruler length in mm
V_THICKNESS = 2; // Max thickness at center (mm)
V_LABEL     = 3; // Used for STL filenames (must match export_variants.sh)

variants = [
  // unit,   length_mm,     thickness, label
  ["cm",     100,           1.60,      "10cm"],
  ["cm",     150,           2.00,      "15cm"],
  ["cm",     200,           2.16,      "20cm"],
  ["cm",     300,           2.40,      "30cm"],
  ["inch",    4 * 25.4,     1.60,      "4in"],
  ["inch",    6 * 25.4,     2.00,      "6in"],
  ["inch",    8 * 25.4,     2.16,      "8in"],
  ["inch",   12 * 25.4,     2.40,      "12in"],
];

// ─── Variant Selector ───────────────────────────────────────────────────

// -1 = grid preview of all variants; 0..len(variants)-1 = single variant
variant = -1;

// "complete" | "body" | "base" | "numbers"
render_mode = "complete";

// ─── Print Settings (shared) ────────────────────────────────────────────

layer_height = 0.08;
shrink_factor = 0.9982;

// ─── Body Geometry (shared) ─────────────────────────────────────────────

ruler_width = 25;
taper_width = 6;
edge_thickness = 7 * layer_height;
corner_radius = 0.5;

// ─── Marking Configuration (shared) ─────────────────────────────────────

near_edge_flip = false;
far_edge_flip = false;
tick_floor = edge_thickness - (2 * layer_height);
tick_line_width = 0.2;

mm_tick_height_1mm = 2.0;
mm_tick_height_5mm = 4.0;
mm_tick_height_1cm = 6.0;

in_tick_height_32nd = 0;
in_tick_height_16th = 1.5;
in_tick_height_8th  = 2.5;
in_tick_height_4th  = 3.5;
in_tick_height_half = 5.0;
in_tick_height_1in  = 6.0;

// ─── Number Labels (shared) ─────────────────────────────────────────────

number_font = "Liberation Sans";
number_size = 3.5;
engrave_depth = -1.5 * layer_height;
number_pad_expand = 0.0;
number_pad_layers = 1;
number_every_cm = 1;
number_every_inch = 1;
number_offset = 4.75;

// ─── Edge Padding (shared) ──────────────────────────────────────────────

left_padding = 0;
right_padding = 0;

// ─── Hanging Hole (shared) ──────────────────────────────────────────────

hanging_hole = false;
hole_diameter = 6.0;
hole_inset = 8.0;
hole_end = "right";

// ─── Rendering (shared) ─────────────────────────────────────────────────

fast_preview = true;
fillet_radius = 0.3;

// ─── Render ─────────────────────────────────────────────────────────────

module render_variant(i) {
  v = variants[i];
  rotate([0, 0, 90])
    scale([1 / shrink_factor, 1 / shrink_factor, 1])
      ruler(
        ruler_length = v[V_LENGTH_MM],
        ruler_width = ruler_width,
        thickness = v[V_THICKNESS],
        taper_width = taper_width,
        edge_thickness = edge_thickness,
        corner_radius = corner_radius,
        near_edge_unit = v[V_UNIT],
        far_edge_unit = v[V_UNIT],
        near_edge_flip = near_edge_flip,
        far_edge_flip = far_edge_flip,
        engrave_depth = engrave_depth,
        tick_floor = tick_floor,
        tick_line_width = tick_line_width,
        mm_tick_height_1mm = mm_tick_height_1mm,
        mm_tick_height_5mm = mm_tick_height_5mm,
        mm_tick_height_1cm = mm_tick_height_1cm,
        in_tick_height_32nd = in_tick_height_32nd,
        in_tick_height_16th = in_tick_height_16th,
        in_tick_height_8th = in_tick_height_8th,
        in_tick_height_4th = in_tick_height_4th,
        in_tick_height_half = in_tick_height_half,
        in_tick_height_1in = in_tick_height_1in,
        number_size = number_size,
        number_font = number_font,
        number_every_cm = number_every_cm,
        number_every_inch = number_every_inch,
        number_offset = number_offset,
        left_padding = left_padding,
        right_padding = right_padding,
        hanging_hole = hanging_hole,
        hole_diameter = hole_diameter,
        hole_inset = hole_inset,
        hole_end = hole_end,
        fast_preview = fast_preview,
        fillet_radius = fillet_radius,
        render_mode = render_mode,
        number_pad_expand = number_pad_expand,
        number_pad_depth = number_pad_layers * layer_height
      );
}

if (variant >= 0) {
  render_variant(variant);
} else {
  // Grid preview: after the 90° rotate each variant extends along Y, so stack
  // them along X with ruler_width + gap spacing.
  grid_gap = 5;
  for (i = [0 : len(variants) - 1]) {
    translate([i * (ruler_width + grid_gap), 0, 0]) render_variant(i);
  }
}
