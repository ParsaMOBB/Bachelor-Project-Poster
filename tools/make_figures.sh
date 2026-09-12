#!/usr/bin/env sh
# Regenerate the state-space figures used by sections/method.tex and
# sections/results.tex.
#
# The "before" graphs are produced by the awtr CLI itself (the headless
# counterpart of Afra's ConvertToGraphviz); the quotient is the reduced.dot
# written by the same verified run, so every figure comes from one build.
# Vector PDF is used so the A1 print stays sharp.
#
# Usage:
#   ./tools/make_figures.sh
#   AWTR_ROOT=/path/to/AfraWeakTimedReduction ./tools/make_figures.sh
set -eu

HERE=$(cd "$(dirname "$0")" && pwd)
POSTER=$(cd "$HERE/.." && pwd)
AWTR_ROOT=${AWTR_ROOT:-"$POSTER/../../AfraWeakTimedReduction"}
AWTR_JAR=${AWTR_JAR:-"$AWTR_ROOT/target/awtr.jar"}
OUT="$POSTER/assets/figures"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

[ -f "$AWTR_JAR" ] || { echo "awtr jar not found: $AWTR_JAR (run 'mvn package')" >&2; exit 1; }
command -v dot >/dev/null 2>&1 || { echo "Graphviz 'dot' not found" >&2; exit 1; }

mkdir -p "$OUT"

# Graphviz defaults put 14pt labels on a graph that has to shrink a long way to
# fit a poster panel.  Enlarge the type before laying the graph out, so the
# labels survive the scaling.  The absolute-time "@N" and "shift(+N)" suffixes
# are Afra bookkeeping: they double the length of every edge label without
# telling a poster reader anything, so they go too.
restyle() {  # restyle <source.dot> <out.pdf> <node pt> <edge pt>
  sed -e 's/\\n @[0-9]*\( -> shift(+[0-9]*)\)\{0,1\}"/"/g' \
      -e "s/^  rankdir=TB;/  rankdir=TB;\n  node [fontname=\"Helvetica\", fontsize=$3];\n  edge [fontname=\"Helvetica\", fontsize=$4];\n  nodesep=0.35; ranksep=0.45;/" \
      "$1" > "$TMP/styled.dot"
  dot -Tpdf "$TMP/styled.dot" -o "$2"
  echo "wrote $2"
}

# The mood pair: two RMC-generated state spaces that are weak timed bisimilar,
# plus the quotient both of them reduce to.  Only mood.LAUGH and mood.CRY are
# observable, so mood1's extra HAPPINESS/SADNESS steps become tau and its split
# delays add up to mood2's direct 5- and 8-unit waits.
MOOD_OBSERVABLE=mood.LAUGH,mood.CRY
for m in mood1 mood2; do
  java -jar "$AWTR_JAR" visualize \
    "$AWTR_ROOT/src/test/resources/rebeca-generated/$m.statespace" \
    --output "$TMP/$m.dot" >/dev/null
  restyle "$TMP/$m.dot" "$OUT/$m.pdf" 36 30
done

# Reducing either model yields the same quotient up to state naming; mood1's run
# is the one that is drawn.
java -jar "$AWTR_JAR" reduce \
  "$AWTR_ROOT/src/test/resources/rebeca-generated/mood1.statespace" \
  --observable "$MOOD_OBSERVABLE" --output-dir "$TMP/mood1-out" >/dev/null
restyle "$TMP/mood1-out/reduced.dot" "$OUT/mood-quotient.pdf" 38 32

# The three README time-semantics models, laid out left-to-right: they are the
# worked example for what "observable" means once time is involved.
for m in observable-then-delay observable-then-split-delay delay-observable-delay; do
  java -jar "$AWTR_JAR" visualize \
    "$AWTR_ROOT/src/test/resources/readme/$m.statespace" \
    --output "$TMP/$m.dot" >/dev/null
  sed -e 's/\\n @0"/"/g' \
      -e 's/^  rankdir=TB;/  rankdir=LR;\n  node [fontname="Helvetica", fontsize=20];\n  edge [fontname="Helvetica", fontsize=20];\n  nodesep=0.30; ranksep=0.80;/' \
      "$TMP/$m.dot" > "$TMP/$m-poster.dot"
  dot -Tpdf "$TMP/$m-poster.dot" -o "$OUT/$m.pdf"
  echo "wrote $OUT/$m.pdf"
done
