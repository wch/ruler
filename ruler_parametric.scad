// Parametric 3D-Printable Ruler
// Entry point — declares parameters and calls ruler().

/**
 * For flush numbers, export "body" and "numbers" separately and print in
 * different colors. For engraved numbers, just export "complete".
 * To export separate "body" and "numbers" STLs:
   openscad ruler_parametric.scad -o ruler_body.stl -D 'render_mode="body"'
   openscad ruler_parametric.scad -o ruler_numbers.stl -D 'render_mode="numbers"'
   openscad ruler_parametric.scad -o ruler_base.stl -D 'render_mode="base"'

 * To export a single STL with engraved numbers:
   openscad ruler_parametric.scad -o ruler_complete.stl
 */
use <ruler_parametric_lib.scad>

$fn = 60;

// ─── Print Settings ─────────────────────────────────────────────────

// Slicer layer height (mm)
layer_height = 0.08;

// Measured post-cooling length / intended length

// The way to calculate this is to:
// - Print a test ruler with 0% shrink_factor at a known intended length (e.g.
//   100mm)
// - Measure the actual length after cooling
// - Divide the actual length by the intended length
//
// A longer ruler will allow you to get a more accurate shrink measurement, but
// they also require larger (and accurate!) measuring tools to measure the
// cooled print.
//
// On my Bambu P2S, I found that with my specific PLA filament, the actual
// length after cooling was about 0.18% shorter than the intended length, so I
// set this to 0.9982.
shrink_factor = 0.9982;

// -- Settings for specific ruler lengths ----------------------------------

// -- Metric ------------------
near_edge_unit = "cm";
far_edge_unit = "cm";

// // For 10cm
// ruler_length = 100;
// thickness = 1.6;

// For 15cm
ruler_length = 150;
thickness = 2;

// // For 20cm
// ruler_length = 200;
// thickness = 2.16;

// // For 30cm
// ruler_length = 300;
// thickness = 2.4;

// -- Inch ------------------
// near_edge_unit = "inch";
// far_edge_unit = "inch";

// // For 4 inch
// ruler_length = 4 * 25.4;
// thickness = 1.6;

// // For 6 inch
// ruler_length = 6 * 25.4;
// thickness = 2;

// // For 8 inch
// ruler_length = 8 * 25.4;
// thickness = 2.16;

// // For 12 inch
// ruler_length = 12 * 25.4;
// thickness = 2.4;

// ─── Body Geometry ───────────────────────────────────────────────────

// // Total length along measuring axis (mm)
// ruler_length = 200;
// // Maximum thickness at center (mm). Should be a multiple of layer_height.
// thickness = 2.16;
// Width perpendicular to measuring axis (mm)
ruler_width = 25;
// How far inward from each edge the taper begins (mm)
taper_width = 6;
// Thickness at thin tapered edges (mm)
edge_thickness = 7 * layer_height;
// Top-view corner rounding radius (mm)
corner_radius = 0.5;

// ─── Marking Configuration ──────────────────────────────────────────

// near_edge_unit = "inch"; // "cm", "inch", or "none" — near edge (y=0)
// far_edge_unit = "inch"; // "cm", "inch", or "none" — far edge (y=width)
near_edge_flip = false; // Flip numbers: upside-down, counting from far end
far_edge_flip = false; // Flip numbers: upside-down, counting from far end
tick_floor = edge_thickness - (2 * layer_height); // Z floor for tick cuts (mm); -1 = use edge_thickness
tick_line_width = 0.2; // Width of tick mark lines (mm)

// ─── Metric Tick Heights (mm) ────────────────────────────────────────

mm_tick_height_1mm = 2.0;
mm_tick_height_5mm = 4.0;
mm_tick_height_1cm = 6.0;

// ─── Imperial Tick Heights (mm) ──────────────────────────────────────

in_tick_height_32nd = 0; // 0 = disabled; set > 0 to enable 1/32" ticks
in_tick_height_16th = 1.5;
in_tick_height_8th = 2.5;
in_tick_height_4th = 3.5;
in_tick_height_half = 5.0;
in_tick_height_1in = 6.0;

// ─── Number Labels ──────────────────────────────────────────────────

// The numbers are engraved (or inset) into the body. So, for example, one layer
// below the surface might be the colored numbers, and then on the top layer, it
// would outline the numbers with the body color. This allows the visible
// numbers to be finer than the line width of the 3D printer; because the
// spacing between lines on the surface can be much smaller than the line width.

number_font = "Liberation Sans";
number_size = 3.5;
// Depth of engraved markings (mm). Negative means raised markings. Because of
// the way that slicers work, you may need to add 0.5 * layer_height from this
// value to get the actual engraved depth to match what you expect. For example,
// if you want the numbers to be engraved 2 layers deep, you may need to set
// this to 1.5 * layer_height. If you want the numbers to sit on the surface, use
// -1.5 * layer_height.
engrave_depth = -1.5 * layer_height;
// Offset expansion for color pads (mm); 0 = no expansion This is how much
// larger the colored part of the number is compared to the "window" cut out of
// the body to see the number (which is exactly the size of the number in the
// selected font).
number_pad_expand = 0.0;
// Thickness of color pads in print layers
number_pad_layers = 1;
// Label every N cm (metric)
number_every_cm = 1;
// Label every N inches (imperial)
number_every_inch = 1;
// Gap between longest tick and number (mm)
number_offset = 4.75;

// ─── Edge Padding ───────────────────────────────────────────────────

left_padding = 0; // Distance from left end to 0 mark (mm)
right_padding = 0; // Unused space at far end (mm)

// ─── Hanging Hole ───────────────────────────────────────────────────

hanging_hole = false;
hole_diameter = 6.0;
hole_inset = 8.0; // Distance from end to hole center (mm)
hole_end = "right";

// ─── Rendering ──────────────────────────────────────────────────────

fast_preview = true;
fillet_radius = 0.3;
// render_mode: "complete" = single color, "body" = upper body with tick/number
//              cutouts, "base" = bottom slab up to tick_floor (tick groove
//              floor color), "numbers" = number color pads. Export all three as
//              separate STLs for multi-color printing in the slicer.
render_mode = "complete";

// ─── Render ─────────────────────────────────────────────────────────

rotate([0, 0, 90]) scale([1 / shrink_factor, 1 / shrink_factor, 1]) ruler(
      ruler_length=ruler_length,
      ruler_width=ruler_width,
      thickness=thickness,
      taper_width=taper_width,
      edge_thickness=edge_thickness,
      corner_radius=corner_radius,
      near_edge_unit=near_edge_unit,
      far_edge_unit=far_edge_unit,
      near_edge_flip=near_edge_flip,
      far_edge_flip=far_edge_flip,
      engrave_depth=engrave_depth,
      tick_floor=tick_floor,
      tick_line_width=tick_line_width,
      mm_tick_height_1mm=mm_tick_height_1mm,
      mm_tick_height_5mm=mm_tick_height_5mm,
      mm_tick_height_1cm=mm_tick_height_1cm,
      in_tick_height_32nd=in_tick_height_32nd,
      in_tick_height_16th=in_tick_height_16th,
      in_tick_height_8th=in_tick_height_8th,
      in_tick_height_4th=in_tick_height_4th,
      in_tick_height_half=in_tick_height_half,
      in_tick_height_1in=in_tick_height_1in,
      number_size=number_size,
      number_font=number_font,
      number_every_cm=number_every_cm,
      number_every_inch=number_every_inch,
      number_offset=number_offset,
      left_padding=left_padding,
      right_padding=right_padding,
      hanging_hole=hanging_hole,
      hole_diameter=hole_diameter,
      hole_inset=hole_inset,
      hole_end=hole_end,
      fast_preview=fast_preview,
      fillet_radius=fillet_radius,
      render_mode=render_mode,
      number_pad_expand=number_pad_expand,
      number_pad_depth=number_pad_layers * layer_height
    );
