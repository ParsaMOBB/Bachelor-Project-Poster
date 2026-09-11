#!/usr/bin/env sh
set -eu
cd "$(dirname "$0")"
latexmk -xelatex main.tex
echo "Built: $(pwd)/build/main.pdf"

# Keep the README preview in step with the PDF.  Skipped when poppler is not
# installed; CI builds the PDF through latex-action and does not need this.
if command -v pdftoppm >/dev/null 2>&1; then
  pdftoppm -r 72 -png -singlefile build/main.pdf assets/poster-preview
  echo "Updated: $(pwd)/assets/poster-preview.png"
fi
