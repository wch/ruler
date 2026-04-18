// Parametric 3D-Printable Ruler — Library
// All modules and functions. No top-level geometry.

// ─── 2D Cross-Section ────────────────────────────────────────────────

module ruler_cross_section(ruler_width, thickness, taper_width, edge_thickness) {
  // Flat center with linear tapers on both sides.
  // Origin at bottom-left corner of the bounding box.
  polygon(
    [
      [0, 0], // left edge bottom
      [0, edge_thickness], // left edge top
      [taper_width, thickness], // left taper end
      [ruler_width - taper_width, thickness], // right taper start
      [ruler_width, edge_thickness], // right edge top
      [ruler_width, 0], // right edge bottom
    ]
  );
}

// ─── 3D Body ─────────────────────────────────────────────────────────

module ruler_body(
  ruler_length,
  ruler_width,
  thickness,
  taper_width,
  edge_thickness,
  corner_radius
) {
  intersection() {
    // Tapered cross-section extruded along the length (X axis)
    rotate([90, 0, 90])
      linear_extrude(height=ruler_length)
        ruler_cross_section(ruler_width, thickness, taper_width, edge_thickness);

    // Rounded rectangle prism for corner rounding in plan view
    linear_extrude(height=thickness)
      offset(r=corner_radius)
        offset(r=-corner_radius)
          square([ruler_length, ruler_width]);
  }
}

// ─── Metric Ticks ────────────────────────────────────────────────────

// dir: 1 = ticks grow in +Y, -1 = ticks grow in -Y
// Ticks cut from tick_floor up through the top surface.
module mm_ticks(
  ruler_length,
  thickness,
  tick_floor,
  tick_line_width,
  tick_1mm,
  tick_5mm,
  tick_1cm,
  left_padding,
  right_padding,
  edge_y,
  dir
) {
  max_x = ruler_length - right_padding;
  count = floor((max_x - left_padding) / 1);

  for (i = [0:count]) {
    x = left_padding + i * 1;
    if (x <= max_x + 0.001) {
      h =
        (i % 10 == 0) ? tick_1cm
        : (i % 5 == 0) ? tick_5mm : tick_1mm;
      ty = (dir > 0) ? edge_y : edge_y - h;
      translate([x - tick_line_width / 2, ty, tick_floor])
        cube([tick_line_width, h, thickness - tick_floor + 0.1]);
    }
  }
}

// ─── Imperial Ticks ──────────────────────────────────────────────────

// Ticks cut from tick_floor up through the top surface.
module inch_ticks(
  ruler_length,
  thickness,
  tick_floor,
  tick_line_width,
  tick_32nd,
  tick_16th,
  tick_8th,
  tick_4th,
  tick_half,
  tick_1in,
  left_padding,
  right_padding,
  edge_y,
  dir
) {
  // When tick_32nd > 0, iterate at 1/32" steps; otherwise 1/16".
  step = (tick_32nd > 0) ? 25.4 / 32 : 25.4 / 16;
  max_x = ruler_length - right_padding;
  count = floor((max_x - left_padding) / step);

  for (i = [0:count]) {
    x = left_padding + i * step;
    if (x <= max_x + 0.001) {
      h =
        (tick_32nd > 0) ? (
            (i % 32 == 0) ? tick_1in
            : (i % 16 == 0) ? tick_half
            : (i % 8 == 0) ? tick_4th
            : (i % 4 == 0) ? tick_8th
            : (i % 2 == 0) ? tick_16th : tick_32nd
          )
        : (
          (i % 16 == 0) ? tick_1in
          : (i % 8 == 0) ? tick_half
          : (i % 4 == 0) ? tick_4th
          : (i % 2 == 0) ? tick_8th : tick_16th
        );
      ty = (dir > 0) ? edge_y : edge_y - h;
      translate([x - tick_line_width / 2, ty, tick_floor])
        cube([tick_line_width, h, thickness - tick_floor + 0.1]);
    }
  }
}

// ─── Single Number Label ─────────────────────────────────────────────

module ruler_number_label(
  value,
  x,
  y,
  number_size,
  number_font,
  engrave_depth,
  pad_expand = 0,
  flip = false
) {
  translate([x, y + number_size / 2, 0])
    rotate([0, 0, flip ? 180 : 0])
      translate([0, -number_size / 2, 0])
        linear_extrude(height=engrave_depth)
          offset(r=pad_expand)
            text(
              str(value), size=number_size, font=number_font,
              halign="center", valign="bottom"
            );
}

// ─── Number Labels ───────────────────────────────────────────────────

// dir: 1 = numbers above ticks (+Y side), -1 = numbers below ticks (-Y side)
module ruler_numbers(
  ruler_length,
  engrave_depth,
  number_size,
  number_font,
  unit,
  number_every,
  number_offset,
  left_padding,
  right_padding,
  edge_y,
  longest_tick,
  dir,
  pad_expand = 0,
  flip = false
) {
  // For dir=1: numbers sit at edge_y + longest_tick + offset (valign=bottom)
  // For dir=-1: numbers sit at edge_y - longest_tick - offset (valign=top, so we shift by -number_size)
  num_y =
    (dir > 0) ? edge_y + longest_tick + number_offset
    : edge_y - longest_tick - number_offset - number_size;
  max_x = ruler_length - right_padding;
  // Skip numbers too close to either end (they'd get clipped by the body)
  margin = number_size;

  if (unit == "cm") {
    spacing = number_every * 10;
    count = floor((max_x - left_padding) / spacing);
    for (i = [0:count]) {
      x = left_padding + i * spacing;
      if (x <= max_x + 0.001 && x >= margin && x <= ruler_length - margin) {
        ruler_number_label(
          flip ? (count - i) * number_every : i * number_every, x, num_y,
          number_size, number_font, engrave_depth,
          pad_expand, flip
        );
      }
    }
  } else if (unit == "inch") {
    spacing = number_every * 25.4;
    count = floor((max_x - left_padding) / spacing);
    for (i = [0:count]) {
      x = left_padding + i * spacing;
      if (x <= max_x + 0.001 && x >= margin && x <= ruler_length - margin) {
        ruler_number_label(
          flip ? (count - i) * number_every : i * number_every, x, num_y,
          number_size, number_font, engrave_depth,
          pad_expand, flip
        );
      }
    }
  }
}

// ─── Edge Ticks (just tick marks for one edge) ──────────────────────

module ruler_edge_ticks(
  ruler_length,
  ruler_width,
  thickness,
  tick_floor,
  tick_line_width,
  unit,
  edge,
  mm_tick_1mm,
  mm_tick_5mm,
  mm_tick_1cm,
  in_tick_32nd,
  in_tick_16th,
  in_tick_8th,
  in_tick_4th,
  in_tick_half,
  in_tick_1in,
  left_padding,
  right_padding
) {
  edge_y = (edge == "near") ? 0 : ruler_width;
  dir = (edge == "near") ? 1 : -1;

  if (unit == "cm") {
    mm_ticks(
      ruler_length, thickness, tick_floor, tick_line_width,
      mm_tick_1mm, mm_tick_5mm, mm_tick_1cm,
      left_padding, right_padding, edge_y, dir
    );
  } else if (unit == "inch") {
    inch_ticks(
      ruler_length, thickness, tick_floor, tick_line_width,
      in_tick_32nd, in_tick_16th, in_tick_8th, in_tick_4th,
      in_tick_half, in_tick_1in,
      left_padding, right_padding, edge_y, dir
    );
  }
}

// ─── Edge Numbers (just number labels for one edge) ─────────────────

// engrave_depth > 0: engraved (subtracted). < 0: raised (unioned).
// The caller is responsible for using this in difference() or union().
module ruler_edge_numbers(
  ruler_length,
  ruler_width,
  thickness,
  engrave_depth,
  unit,
  edge,
  mm_tick_1cm,
  in_tick_1in,
  number_size,
  number_font,
  number_every,
  number_offset,
  left_padding,
  right_padding,
  pad_expand = 0,
  z_offset = 0,
  flip = false
) {
  edge_y = (edge == "near") ? 0 : ruler_width;
  dir = (edge == "near") ? 1 : -1;
  abs_depth = abs(engrave_depth);
  // Engraved: cut downward from the top surface.
  // Raised: extrude upward from the top surface.
  z = (engrave_depth > 0) ? thickness - abs_depth : thickness;

  translate([0, 0, z + z_offset]) if (unit == "cm") {
    ruler_numbers(
      ruler_length, abs_depth, number_size, number_font,
      "cm", number_every, number_offset,
      left_padding, right_padding, edge_y, mm_tick_1cm, dir,
      pad_expand, flip
    );
  } else if (unit == "inch") {
    ruler_numbers(
      ruler_length, abs_depth, number_size, number_font,
      "inch", number_every, number_offset,
      left_padding, right_padding, edge_y, in_tick_1in, dir,
      pad_expand, flip
    );
  }
}

// ─── Hanging Hole ────────────────────────────────────────────────────

module ruler_hanging_hole(
  ruler_length,
  ruler_width,
  thickness,
  hole_diameter,
  hole_inset,
  hole_end
) {
  hx = (hole_end == "left") ? hole_inset : ruler_length - hole_inset;
  hy = ruler_width / 2;
  translate([hx, hy, -0.1])
    cylinder(h=thickness + 0.2, d=hole_diameter, $fn=36);
}

// ─── Top-Level Assembly ──────────────────────────────────────────────

// render_mode:
//   "complete" — single-color ruler (engraved or raised numbers)
//   "body"     — ruler body with number-shaped cutouts (for multi-color: color A)
//   "numbers"  — just the number fill solids (for multi-color: color B)
// For flush multi-color printing, export "body" and "numbers" as separate STLs,
// import both into the slicer, and assign different filaments.
module ruler(
  ruler_length = 200,
  ruler_width = 30,
  thickness = 3.0,
  taper_width = 6.0,
  edge_thickness = 0.6,
  corner_radius = 3.0,
  near_edge_unit = "cm",
  far_edge_unit = "inch",
  engrave_depth = 0.6,
  tick_floor = -1,
  tick_line_width = 0.4,
  mm_tick_height_1mm = 2.0,
  mm_tick_height_5mm = 4.0,
  mm_tick_height_1cm = 6.0,
  in_tick_height_32nd = 0,
  in_tick_height_16th = 1.5,
  in_tick_height_8th = 2.5,
  in_tick_height_4th = 3.5,
  in_tick_height_half = 5.0,
  in_tick_height_1in = 6.0,
  number_size = 5,
  number_font = "Liberation Sans:style=Bold",
  number_every_cm = 1,
  number_every_inch = 1,
  number_offset = 1.0,
  left_padding = 0,
  right_padding = 0,
  hanging_hole = true,
  hole_diameter = 6.0,
  hole_inset = 8.0,
  hole_end = "right",
  fast_preview = true,
  fillet_radius = 0.3,
  render_mode = "complete",
  near_edge_flip = false,
  far_edge_flip = false,
  number_pad_expand = 0,
  number_pad_depth = 0
) {

  assert(tick_line_width > 0, "tick_line_width must be positive");

  // tick_floor = -1 means use edge_thickness as the floor
  actual_tick_floor = (tick_floor < 0) ? edge_thickness : tick_floor;

  num_depth = engrave_depth;

  // Helper: number geometry for an edge
  module _edge_nums(unit, edge, expand = 0, depth = -1, z_shift = 0, flip = false) {
    d = (depth >= 0) ? depth : num_depth;
    ruler_edge_numbers(
      ruler_length, ruler_width, thickness, d,
      unit, edge,
      mm_tick_height_1cm, in_tick_height_1in,
      number_size, number_font,
      (unit == "cm") ? number_every_cm : number_every_inch,
      number_offset, left_padding, right_padding,
      expand, z_shift, flip
    );
  }

  // Helper: tick geometry for an edge
  module _edge_tks(unit, edge) {
    ruler_edge_ticks(
      ruler_length, ruler_width, thickness,
      actual_tick_floor, tick_line_width, unit, edge,
      mm_tick_height_1mm, mm_tick_height_5mm, mm_tick_height_1cm,
      in_tick_height_32nd, in_tick_height_16th, in_tick_height_8th,
      in_tick_height_4th, in_tick_height_half, in_tick_height_1in,
      left_padding, right_padding
    );
  }

  module _all_nums(expand = 0, depth = -1, z_shift = 0) {
    if (near_edge_unit != "none") _edge_nums(near_edge_unit, "near", expand, depth, z_shift, near_edge_flip);
    if (far_edge_unit != "none") _edge_nums(far_edge_unit, "far", expand, depth, z_shift, far_edge_flip);
  }

  module _body() {
    if (fast_preview) {
      ruler_body(
        ruler_length, ruler_width, thickness,
        taper_width, edge_thickness, corner_radius
      );
    } else {
      minkowski() {
        ruler_body(
          ruler_length - 2 * fillet_radius,
          ruler_width - 2 * fillet_radius,
          thickness - 2 * fillet_radius,
          taper_width, edge_thickness - fillet_radius,
          corner_radius
        );
        sphere(r=fillet_radius, $fn=16);
      }
    }
  }

  if (render_mode == "numbers") {
    e = 0.01;
    if (num_depth > 0) {
      // Engraved (inset) — gap-based multi-color technique:
      // The body's top layers have thin text-shaped gaps cut through them.
      // Below the gaps sit color pads made from offset-expanded (fat) text
      // whose strokes are wide enough for the slicer to print (>= nozzle
      // width). The body covers the fat pads everywhere except through the
      // thin gaps, so the visible text is defined by the gap width (which
      // can be finer than the nozzle) while the underlying pad is printable.
      intersection() {
        _body();
        if (number_pad_depth > 0)
          _all_nums(number_pad_expand, number_pad_depth, -num_depth);
        else
          _all_nums(number_pad_expand);
      }
    } else if (num_depth < 0) {
      // Raised — colored text protrudes above the body surface.
      // Still use pad_expand to fatten strokes above the nozzle width.
      _all_nums(number_pad_expand);
    }
    translate([0, 0, 0]) cube([e, e, e]);
    translate([ruler_length - e, ruler_width - e, 0]) cube([e, e, e]);
  } else if (render_mode == "base") {
    // Bottom slab up to tick_floor — the tick groove floor color.
    // Tick grooves cut through the body above, revealing this layer.
    e = 0.01;
    intersection() {
      _body();
      cube([ruler_length, ruler_width, actual_tick_floor]);
    }
    translate([0, 0, 0]) cube([e, e, e]);
    translate([ruler_length - e, ruler_width - e, 0]) cube([e, e, e]);
  } else if (render_mode == "body") {
    // Body above tick_floor, with tick cuts + hole.
    // Engraved numbers: thin text gaps + fat pad pockets subtracted.
    // Raised numbers: no body cutouts (text sits on top).
    difference() {
      _body();
      // Remove tick base slab
      translate([-1, -1, 0])
        cube([ruler_length + 2, ruler_width + 2, actual_tick_floor]);
      if (near_edge_unit != "none") _edge_tks(near_edge_unit, "near");
      if (far_edge_unit != "none") _edge_tks(far_edge_unit, "far");
      if (num_depth > 0) {
        // Thin text gaps at the top surface
        _all_nums();
        // Fat pad pockets below the gap layer
        if (number_pad_depth > 0)
          _all_nums(number_pad_expand, number_pad_depth, -num_depth);
      }
      if (hanging_hole)
        ruler_hanging_hole(
          ruler_length, ruler_width, thickness,
          hole_diameter, hole_inset, hole_end
        );
    }
  } else {
    // "complete" — single-color mode
    union() {
      difference() {
        _body();
        if (near_edge_unit != "none") _edge_tks(near_edge_unit, "near");
        if (far_edge_unit != "none") _edge_tks(far_edge_unit, "far");
        if (engrave_depth > 0) _all_nums();
        if (hanging_hole)
          ruler_hanging_hole(
            ruler_length, ruler_width, thickness,
            hole_diameter, hole_inset, hole_end
          );
      }
      if (engrave_depth < 0) _all_nums();
    }
  }
}
