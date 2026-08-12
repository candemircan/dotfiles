---
name: slides
description: "House rules and a verification loop for Can's Quarto reveal.js decks in ~/Projects/cpi/presentations. Load this before you edit a slides.qmd, index.qmd or meta_learning.qmd, before you write or place a figure on a slide, and before you report slide work as done. It carries the fixed rules (no overflow, no em dashes, SVG not PNG, no arrows in quadrants, top-aligned columns, one-line titles) plus the render-and-look checks that replace pasting screenshots."
---

# Slides

Decks live in `~/Projects/cpi/presentations/`: `automated_science_ng_july_26`, `cpi_feb_23`,
`cpi_jan_26`, `eml_cpi_retreat_23`, `first_tac_meeting`, `logbook`, `prompt_or_perish`,
`ringberg_retreat_2026`. Source is `slides.qmd`, `index.qmd` or `meta_learning.qmd`. Figures sit in
`assets/` or `imgs/`. Three decks carry a `basic-theme.scss`; the rest use `clean-revealjs`
defaults. Never report slide work as done before Tier 1 passes.

## House rules

Each rule below is a correction Can has already made. Apply it without being asked.

1. Content must not overflow the slide vertically. This is the most frequent defect. Cut text,
   shrink the figure, or split the slide.
2. Use no em dashes anywhere, in slides or in prose. Use a comma, a colon, or two sentences.
3. Vector figures are SVG, never PNG. PNG looks low resolution when projected.
4. Put no arrows in quadrant or 2x2 diagrams, and no decorative arrows. Arrows are allowed only in
   an explicit step sequence in running text, as in `propose -> fit -> measure -> repeat`.
5. Align text across columns and quadrants at the top.
6. Keep the title on one line, and the sentence under the title on one line.
7. Never leave a red or blue emphasis line sitting alone. Attach it to the text or figure it
   describes.
8. Spell out jargon in visible slide text. Write "higher kernel alignment and class separation",
   not "higher CKA and cleaner class sep". Abbreviations are fine inside `::: {.notes}`.
9. Use no underscores in rendered label text. Write "needs review", not `needs_review`.
10. Keep project tables in chronological order.
11. Put no subtitle under a plot. Put the citation at the end of the sentence above it.
12. Prefer plain words. Write "make more complex", not "complexify".
13. Put his name once on a title slide. Co-author lines go under his name.

## Plot conventions

- Put the legend in the lower right.
- Never connect points with a grey line.
- Put the direction in the axis title: "theory complexity (left)", "predictive accuracy (up)".
- Save vector plots as SVG directly from the plotting code.

## Budgets, measured from his decks

Measured on the rendered `ringberg_retreat_2026/slides.pdf` (818.88 x 546 pts, 900 px wide at
`-r 80`). Count rendered characters: strip `{...}` attributes and `[@cite]` keys first.

| Item | Budget | Evidence |
|---|---|---|
| `##` slide title | 50 characters | 46 chars nearly fills the line; 76 chars wrapped to two lines |
| Sentence under the title | 95 characters | 93 chars fits one line; 108 chars wrapped |
| Body text lines, slide with a figure | 2 | his corrected decks peak at 2 lines next to a figure |
| Body text lines, slide with no figure | 5 | his corrected decks peak at 5 lines |
| Two-column slide with a table | 10, and requires `{.smaller}` | the Overview slide is the only slide this dense |

A slide with 24 or more body lines overflows. That is the defect the rendered check catches.

## Tier 1: static checks, always

Run these on the `.qmd` before you report anything. Set `Q` to the source file.

```bash
Q=slides.qmd
# visible-text copy: blank out fenced code blocks, keep line numbers
V="${TMPDIR:-/tmp}/visible.qmd"
awk '/^```/{c=!c; print ""; next} c{print ""; next} {print}' "$Q" > "$V"

# 1. em dashes: output must be empty (byte escape, so this file stays em-dash free)
grep -n $'\xe2\x80\x94' "$Q"

# 2. arrow glyphs: inspect each hit, allow only a step sequence in running text
grep -nE '→|←|↑|↓|⟶' "$Q"

# 3. PNG used where a vector sibling exists: output must be empty
grep -oE '[^ ()]+\.(png)' "$Q" | while read -r p; do
  for e in svg pdf; do [ -f "${p%.png}.$e" ] && echo "$p has ${p%.png}.$e"; done
done

# 4. titles over 50 rendered characters
grep -nE '^#{1,2} ' "$V" \
| sed -E 's/\{[^}]*\}[[:space:]]*$//; s/\[@[^]]*\]//g; s/[*_`]//g; s/^([0-9]+):#+ /\1 /' \
| awk '{n=$1; $1=""; t=substr($0,2); if (length(t)>50) printf "L%s  %d chars  %s\n", n, length(t), t}'

# 5. first sentence under a title, over 95 characters
awk '/^#{1,2} /{want=1; next}
     want && NF && !/^:::/ && !/^!\[/ && !/^</ {
       gsub(/\[@[^]]*\]/,""); gsub(/[*_`]/,"");
       if (length($0)>95) printf "L%d  %d chars  %.60s\n", NR, length($0), $0; want=0}' "$V"

# 6. body lines and figures per slide, notes excluded
awk '/^#{1,2} /{ if(t!="") printf "%2d lines %2d figs  %s\n", n, f, t; t=$0; n=0; f=0; notes=0; next }
     /^::: *\{\.notes\}/{notes=1; next} notes && /^:::[[:space:]]*$/{notes=0; next} notes{next}
     /^!\[/{f++; next} /^:{3,}/{next} /^<br/{next} /^[[:space:]]*$/{next} /^</{next}
     {n++}
     END{ if(t!="") printf "%2d lines %2d figs  %s\n", n, f, t }' "$Q"

# 7. underscores in rendered label text, and jargon abbreviations
grep -nE '[a-z]+_[a-z]+' "$V" | grep -vE 'assets/|imgs/|\.(svg|png|pdf|qmd)|fig-|width=|http|@'
grep -nE '\b(CKA|SAE|TD|SR|MDS|NLL|AIC|BIC|ROI|ICL|MB|MF|class sep|complexify)\b' "$V"
```

Check 7 reports candidates, not errors. Spell each one out on first use in visible text, or move
it into the notes.

## Tier 2: check the rendered PDF

Do this whenever a rendered PDF exists. It replaces Can pasting screenshots.

```bash
pdfinfo slides.pdf | grep -E 'Pages|Page size'   # confirm a slide export
SCRATCH=${TMPDIR:-/tmp}/slides
mkdir -p "$SCRATCH"
pdftoppm -png -r 80 slides.pdf "$SCRATCH/slide"
```

A slide export is landscape, near 818 x 546 pts. A portrait letter page (612 x 792 pts) is a notes
handout and tells you nothing about slide layout. `first_tac_meeting/slides.pdf` is a handout;
`ringberg_retreat_2026/slides.pdf` is a real slide export.

Read every PNG. Check the things only a picture shows:

- vertical overflow, and content cut off at the bottom edge
- title or lead sentence wrapping to a second line
- text in columns or quadrants not aligned at the top
- font too small to read, or large dead space
- low resolution or blurry images

Fix, re-render the deck, re-run `pdftoppm`, and look again. Report to Can only after this passes.

To convert a vector PDF figure to SVG, `pdf2svg` is absent, so use:

```bash
pdftocairo -svg in.pdf out.svg
```

## Tier 3: no rendered PDF

This machine has no headless browser: no chromium, no Chrome, no decktape. So `quarto render --to
pdf` cannot produce a PDF for a reveal.js deck, and Tier 2 cannot be automated. Run Tier 1, then
pick one:

- Ask Can to export the deck to PDF once from the browser print view, then use Tier 2 from then on.
- Tell him that `quarto install tool chromium` would make Tier 2 fully automatic. He has not
  installed it. Do not install it yourself.

## Reporting

Report in this order: what you changed, the Tier 1 and Tier 2 result, what still needs his eyes.
State plainly when you could only run Tier 1, and why.
