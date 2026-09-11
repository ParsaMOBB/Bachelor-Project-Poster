#!/usr/bin/env sh
# Regenerate the state-space figures used by sections/results.tex.
#
# The "before" graph is produced by the awtr CLI itself (the headless
# counterpart of Afra's ConvertToGraphviz); the "after" graph is the
# reduced.dot recorded by the evaluation run, so both come from the same
# verified build.  Vector PDF is used so the A1 print stays sharp.
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

java -jar "$AWTR_JAR" visualize \
  "$AWTR_ROOT/evaluation/models/smarthome.statespace" \
  --output "$TMP/original.dot" >/dev/null
cp "$AWTR_ROOT/evaluation/raw/smart-home/reduced.dot" "$TMP/reduced.dot"

# Graphviz defaults put 14pt labels on a graph that has to shrink a long way to
# fit a poster panel.  Enlarge the type and drop the "@0" execution-time noise
# before laying the graph out, so the labels survive the scaling.
restyle() {
  sed -e 's/\\n @0"/"/g' \
      -e "s/^  rankdir=TB;/  rankdir=TB;\n  node [fontname=\"Helvetica\", fontsize=$2];\n  edge [fontname=\"Helvetica\", fontsize=$3];\n  nodesep=0.35; ranksep=0.45;/" \
      "$TMP/$1.dot" > "$TMP/$1-poster.dot"
  dot -Tpdf "$TMP/$1-poster.dot" -o "$OUT/smarthome-$1.pdf"
  echo "wrote $OUT/smarthome-$1.pdf"
}

restyle original 22 18
restyle reduced  26 22

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
