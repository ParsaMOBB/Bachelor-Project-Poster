# my-poster

<div dir="rtl">

پوستر A1 پروژهٔ کارشناسی **«کاهش مدل معنایی ربکا با استفاده از رابطهٔ
شبیه‌سازی دوسویهٔ ضعیف زمان‌دار»**.

- دانشجو: امیرپارسا مؤید
- استاد راهنما: دکتر فاطمه قاسمی
- دانشکدهٔ مهندسی برق و کامپیوتر، پردیس دانشکده‌های فنی، دانشگاه تهران

پوستر بر پایهٔ قالب [tehran-poster](https://github.com/ParsaMOBB/ut-poster)
ساخته شده است. کلاس قالب دست‌نخورده باقی مانده و افزوده‌های این پروژه در
`poster-extras.tex` جمع شده‌اند تا به‌روزرسانی قالب ساده بماند.

</div>

The poster presents **awtr**, a verified weak-timed-bisimilarity reducer for
Afra/RMC Timed Rebeca `.statespace` exports. The implementation and its
evaluation data live in
[AfraWeakTimedReduction](https://github.com/ParsaMOBB/AfraWeakTimedReduction).

## Build

```bash
./build.sh          # -> build/main.pdf
```

Requires XeLaTeX and `latexmk`. All fonts are bundled under `fonts/`, so no
system font installation is needed.

## Layout

A1 portrait (59.4 × 84.1 cm), two content columns plus a full-width references
band along the bottom.

| area | panels |
| --- | --- |
| right column (x = 30.35 cm) — where a Persian reader starts | مقدمه / خلاصه، روش و مدل پیشنهادی |
| left column (x = 1.30 cm) | نتایج، جمع‌بندی |
| footer band (full width) | مراجع اصلی |

Panels are placed with `\PosterAutoBlock[size]{title}{x}{y}{width}{body}` from
`poster-extras.tex`. Each panel measures its own body first and sizes the white
box to match, publishing the result in `\PosterBlockHeight`; `main.tex` chains
those heights so editing the text never requires re-tuning coordinates.

`\PosterAutoBlockBottom` is the same thing anchored to the bottom margin, used
for the references band.

### Right-to-left notes

TikZ builds node bodies in LTR mode, so `text width` + `align` hands Persian
paragraphs to the LTR line breaker and the words come out reversed. Every node
containing Persian prose therefore goes through `\RTLnodebox`, which wraps the
body in a `minipage` and gives the paragraph back to the bidi engine.

Numbers carrying a decimal separator are wrapped in `\num{}` / `\pct{}` for the
same reason. Charts, the reference list and other Latin blocks sit inside the
`latin` environment.

## Figures

`assets/figures/` is generated from the implementation repository:

```bash
./tools/make_figures.sh
```

The script runs `awtr visualize` on `smarthome.statespace` for the "before"
graph and renders the recorded `evaluation/raw/smart-home/reduced.dot` for the
"after" graph, both as vector PDF. Override the source repo or jar with
`AWTR_ROOT` / `AWTR_JAR`.

The pipeline diagram, the time-additivity figure and the results chart are
drawn inline with TikZ/PGFPlots in `sections/`, so they stay vector and
editable.

## Data provenance

Every number on the poster comes from `evaluation/results.csv` of the
implementation repository (tool v1.0.0, commit `3d63904`):

| model | states | transitions | state reduction |
| --- | --- | --- | --- |
| tiny | 6 → 2 | 7 → 2 | 66.7 % |
| smart-home | 16 → 10 | 18 → 12 | 37.5 % |
| smart-home-tc2step | 25 → 10 | 28 → 12 | 60.0 % |
| smart-home-notify | 42 → 10 | 52 → 12 | 76.2 % |

116 unit tests and 62 end-to-end checks pass in that build. The three
SmartHome models reduce to the same 28-class partition and the same 10-state,
12-transition quotient.

Reduction percentages are only meaningful alongside the observable set they
were measured with (`getSense`, `activateh`, `switchoff` for the SmartHome
models; `poll` for `tiny`).

## Credits

Poster class, fonts and university assets come from `tehran-poster`.
