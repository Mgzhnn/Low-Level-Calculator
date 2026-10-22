#!/usr/bin/env bash
# Run the self-checking testbenches with GHDL (VHDL-2008).
# Usage, from anywhere:  tests/run_tests.sh
# Set GHDL to use a binary that is not on PATH.
set -u

cd "$(dirname "$0")/.."
GHDL="${GHDL:-ghdl}"
SRC=core_calculator.srcs/sources_1/imports/FFFinal_Calculator
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT
FLAGS=(--std=08 -fsynopsys --workdir="$WORK")

# Analysis order: each file after the entities it instantiates directly
for f in addition signed_addsubtractor state_machine controller_and_adder_connector \
         absolute_value Multiplier_4bit Divider_4bit euclidian final_calculator \
         Display_Encoder myseven_segments Final_Top; do
    "$GHDL" -a "${FLAGS[@]}" "$SRC/$f.vhd" || { echo "FAIL: cannot analyse $f.vhd"; exit 1; }
done

failed=0
for tb in tb_calc_check tb_display_check; do
    "$GHDL" -a "${FLAGS[@]}" "tests/$tb.vhd" && "$GHDL" -e "${FLAGS[@]}" "$tb" || { echo "FAIL $tb: build error"; failed=$((failed + 1)); continue; }
    out="$("$GHDL" -r "${FLAGS[@]}" "$tb" 2>&1 | grep -v "assertion warning")"
    echo "$out" | sed -n 's/.*(report note): //p'
    echo "$out" | grep -q "PASS $tb" || failed=$((failed + 1))
done

if [ "$failed" -eq 0 ]; then
    echo "All tests passed"
else
    echo "$failed test(s) failed"
    exit 1
fi
