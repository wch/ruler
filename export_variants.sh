#!/usr/bin/env bash
# Export STLs for every variant defined in ruler_parametric_variants.scad, in
# three separately-colored parts (base, body, numbers).
#
# Output: stl/ruler_<label>_<part>.stl  (24 files for 8 variants × 3 parts).
#
# Import all three parts for a single variant into your slicer as separate
# objects, aligned at the origin, and assign each a different filament.

set -euo pipefail

SCAD_FILE="ruler_parametric_variants.scad"
OUT_DIR="out"

OPENSCAD="${OPENSCAD:-/Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD}"
if [[ ! -x "$OPENSCAD" ]] && ! command -v "$OPENSCAD" >/dev/null 2>&1; then
  echo "OpenSCAD not found at '$OPENSCAD'. Set OPENSCAD=/path/to/openscad and retry." >&2
  exit 1
fi

# Must match (and be in the same order as) the `variants` array in the .scad.
LABELS=("10cm" "15cm" "20cm" "30cm" "4in" "6in" "8in" "12in")
PARTS=("base" "body" "numbers")

mkdir -p "$OUT_DIR"

total=$(( ${#LABELS[@]} * ${#PARTS[@]} ))
n=0
for i in "${!LABELS[@]}"; do
  label="${LABELS[$i]}"
  for part in "${PARTS[@]}"; do
    n=$((n + 1))
    out="${OUT_DIR}/ruler_${label}_${part}.stl"
    printf '[%2d/%2d] %s\n' "$n" "$total" "$out"
    "$OPENSCAD" "$SCAD_FILE" \
      -o "$out" \
      -D "variant=$i" \
      -D "render_mode=\"$part\""
  done
done

echo "Done. ${total} STLs in ${OUT_DIR}/"
