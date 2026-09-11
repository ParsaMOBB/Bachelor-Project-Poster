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

The two columns are kept within a few millimetres of each other in height by
moving the references into the footer band; `main.tex` prints every measured
panel height to the log (`POSTER PANEL HEIGHT`), which is how the fit is
checked after an edit.

Panels are placed with `\PosterAutoBlock[size]{title}{x}{y}{width}{body}` from
`poster-extras.tex`. Each panel measures its own body first and sizes the white
box to match, publishing the result in `\PosterBlockHeight`; `main.tex` chains
those heights so editing the text never requires re-tuning coordinates.

`\PosterAutoBlockBottom` is the same thing anchored to the bottom margin, used
for the references band.

### Right-to-left notes

Two traps cost real time here, both recorded in `poster-extras.tex`:

**TikZ node bodies are built in LTR mode.** `text width` + `align` hands a
Persian paragraph to the LTR line breaker and the words come out in reverse
order. Every node containing Persian prose therefore goes through
`\RTLnodebox`, which wraps the body in a `minipage` and gives the paragraph
back to the bidi engine.

**Decimal numbers written with Persian digits come out mirrored.** The
separator is a bidi-neutral that splits the digits into two runs, which the RTL
paragraph then orders right-to-left — `۱۲۳٫۴۵` renders as `۴۵٫۱۲۳`. Integers
are safe (one unbroken run); anything with a separator goes through `\num{}` /
`\pct{}`, which typeset an explicit LTR Latin run. This is the convention the
thesis uses too.

Charts, the reference list and the state-space figures sit inside the `latin`
environment. The time-semantics figure is built from minipages rather than a
`tabular`, because `bidi` patches `\@tabular` in terms of
`\UseMathForPositioningText`, which older `array.sty` releases — including the
one in the CI image — do not define.

## Figures

`assets/figures/` is generated from the implementation repository:

```bash
./tools/make_figures.sh
```

The script produces, all as vector PDF:

| figure | source |
| --- | --- |
| `smarthome-original.pdf` | `awtr visualize` on `evaluation/models/smarthome.statespace` |
| `smarthome-reduced.pdf` | the recorded `evaluation/raw/smart-home/reduced.dot` |
| `observable-then-split-delay.pdf`, `observable-then-delay.pdf`, `delay-observable-delay.pdf` | `awtr visualize` on the three `src/test/resources/readme/` fixtures — the same models the implementation README uses to explain observable time |

Override the source repo or jar with `AWTR_ROOT` / `AWTR_JAR`. Graphviz's
default 14pt labels do not survive being scaled down to poster size, so the
script enlarges the type and drops the `@0` execution-time noise before laying
each graph out.

The pipeline diagram and the results chart are drawn inline with TikZ/PGFPlots
in `sections/`, so they stay vector and editable.

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
