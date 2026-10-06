# Learning log

What I learned about charts and boards, newest first. One entry per session,
kept short; the module notes hold the detail.

This log is about dbt Charts only. Environment and tooling problems go in
`TROUBLESHOOTING.md` instead, so that this file stays readable as a record of
what I actually learned about building boards.

Entry format:

```
## YYYY-MM-DD · dct x.y.z · Topic
Did:
Surprised me:
Changed my understanding:
Post material:
```

---

## 2026-10-06 · dct 0.8.0 · The data-dependent errors only appear at render

Did: built `boards/m03_encodings.yml` (weekly orders split by status, and
customer lifetime value ranked on a log axis), then triggered three errors on
throwaway boards: `yearmonth` on a weekly query, a number format on a date
axis, and a zero under a log scale.

Surprised me: `dct validate` passed all three boards. Each error came only from
`dct render`, because each depends on the data or on the axis's data type, which
validate does not read. The docs name the log-scale code
`ERR-LOG-SCALE-POSITIVE-DATA`. The real code is
`ERR-LOG-SCALE-REQUIRES-POSITIVE-DATA`. A hex code in `style.color.static` and
in `style.palette` raised no error, and neither colour reached the SVG.

Changed my understanding: a board that validates clean is not a board that
renders. Validate checks the YAML and the names; render checks the YAML against
the rows. The chart still never aggregates: `yearmonth` on weekly rows is
refused, not merged, and the fix is a monthly query.

Post material: the three render-time messages quoted in full, and "validate
passed" as the setup for each.

---

## 2026-09-30 · dct 0.8.0 · The same data as a line and as an area says two things

Did: added `revenue_line` and `revenue_area` to `boards/m02_chart_families.yml`,
both off one weekly-revenue query, and replaced the `tabs:` layout with a
24-column `grid:` holding all 13 charts.

Surprised me: the line's value axis has no `$0` (lowest label `$100`), and the
area's starts at `$0`. Nothing in the YAML differs but `type:`. In the grid, the
pie and donut, a third of the width, showed a legend below instead of labels
around the slices, which I never set.

Changed my understanding: a chart's axis range is a default the tool picks for
that mark, not a property of the data. Switching `line` to `area` changes what
the reader sees without touching the SQL, so the choice belongs in the review.
A grid is placement by number (`col`, `row`, `width`), and it sizes rows to
their contents when no `height` is given.

Post material: line-to-area as a one-word change with two different readings,
and the grid render as the payoff for the whole post.

---

## 2026-09-30 · dct 0.8.0 · A donut is a pie with `inner_radius`, and it totals itself

Did: added `payment_pie` to `boards/m02_chart_families.yml` and rendered a solid
`type: pie`, a `type: pie` with `style.inner_radius: 0.6`, and a bare
`type: donut`, then compared the last two as SVG.

Surprised me: the number in the hole appears without `total:`. dct sums the
`theta` column and labels it after the column (`Total Amount`). `total:` only
renames it. I had written the opposite in the draft.

Changed my understanding: `donut` really is an alias, not a separate chart. The
two SVGs matched apart from the render timestamp. "Convert a pie to a donut" is
one style key, or one word in `type:`.

Post material: the pie-then-hole progression in P2, and the correction itself: a
claim I had read as documented turned out wrong once I looked at the render.

---

## 2026-09-29 · dct 0.8.0 · A table column's currency format only reaches row one

Did: built `boards/m02_chart_families.yml` (module 2), rendered every tab, and
read the SVG text nodes for the top-customers table after setting
`style.columns.customer_lifetime_value.format: currency_whole`.

Surprised me: the `$` only shows up on the first data row. Every row after it
renders as a bare number. Confirmed in the SVG, not just the PNG: row one's
cell holds two `<tspan>`s (`$`, then `99`); every other row's cell holds one
(`65`, `64`, `57`, …) with no `$` anywhere in the markup. Also hit
`WARN-LIKELY-CURRENCY-OR-PERCENT-MISSING-FORMATTER` for the first time — dct
reads a column's name, guesses it's money or a percent, and flags a chart
whose axis format doesn't match. Adding `style.number_format: currency_whole`
cleared it on bar and scatter charts, where the same format applied to every
point, not just the first.

Changed my understanding: a chart type's minimal cheatsheet example passing
doesn't mean every field of that shape formats correctly at every row —
`table` needs checking per row, not per chart. Also confirmed the "named
shapes" table in `dct docs charts` at face value: stacked bar, horizontal bar
and a plain column chart are the same `type: bar` with different `style:`
keys, nothing more, no separate type.

Post material: the table row-one formatting bug (SVG evidence), and the
currency/percent formatter warning, both for P2.

## 2026-09-22 · dct 0.8.0 · Titles are title-cased, so the file is not what ships

Did: rendered `boards/first.yml` to PNG and `boards/m01_first_board.yml` to
SVG, then read the SVG's text nodes against the YAML that produced them.

Surprised me: every title comes out re-cased. `title: "Orders per week"`
renders as "Orders per Week", `"Orders by status"` as "Orders by Status", and
the board title `"Module 1: first board on jaffle shop"` as "Module 1: First
Board on Jaffle Shop". It is headline casing rather than naive capitalisation —
`per`, `by` and `on` all stay lowercase. Data is untouched: the status values
(`completed`, `placed`, `shipped`, `returned`, `return_pending`) render exactly
as the column holds them. The string I wrote survives on the SVG root as
`data-dbt-page-title`, so the original is kept and then overridden for display.

Changed my understanding: the board file is the deliverable, but it is not
literally what a reader sees. dct owns the presentation of the strings in it,
which means wording chosen in the YAML cannot be assumed to reach the canvas
intact — and a post that prints the YAML above the render is printing two
things that disagree. Not tested: whether the casing belongs to the default
theme or applies under all five, and whether it can be turned off. That is a
module 6 question.

Post material: P1 prints the minimal board and shows its render directly below,
where "week" becomes "Week" in plain sight. Either explain it there or choose a
title that is already in headline case. The wider point — the tool rewrites the
text you give it — belongs in P5 alongside themes.

## 2026-09-21 · dct 0.8.0 · A board's text block is part of the board

Did: removed a line from the first board's text block that pointed at a file in
this repo, and re-rendered.

Surprised me: nothing technical, but it is a useful reminder. A board's `text:`
block is published output, not a code comment. Anything written there shows up
in the PNG, the PDF and the served page. Notes to myself do not belong in it.

Changed my understanding: the board file is the deliverable. There is no
separate "presentation layer" where the audience-facing wording lives, so every
line of the file is either something a reader sees or something that shapes what
they see.

Post material: worth one sentence in P1 when the layout section introduces
`text:` blocks.

## 2026-09-21 · dct 0.8.0 · KPI cards: the number is honest, the colour is not

Did: read the `kpi-overview` example from `dct examples`, then built a throwaway
board to see how a KPI card behaves when its number is positive, negative and
zero.

Surprised me: on a KPI card, the number updates with the data and the colour
does not. The up-arrow and the green are fixed values you type into the board.
Point that card at live data and it stays green with an arrow pointing up after
the number goes negative. The published example looks correct only because its
number never changes.

Changed my understanding: the number and the colour have different guarantees.
The percentage formatting is aware of the sign and always renders it correctly.
The colour is whatever you wrote, and dct 0.8.0 will not derive it from the
number. So a card can be arithmetically right and visually wrong at the same
time.

Post material: the clearest example so far of a chart that is correct and
misleading. Belongs wherever KPI cards are introduced.

## 2026-09-21 · dct 0.8.0 · Validation reads your dbt models

Did: built the first board — two queries against `orders`, a line chart and a
bar chart side by side — and validated it.

Surprised me: `WARN-DBT-MODEL-COLUMNS-UNRESOLVED` on both queries. dbt's
`orders` model ends in `select *`, so dct cannot work out which columns it
produces, and therefore cannot confirm that the columns my charts reference
actually exist. The warning says the check was skipped; it does not say anything
is wrong.

Changed my understanding: validation reads the SQL of the dbt models a board
depends on, before running anything. That makes model style a dashboard concern.
A model that ends in `select *` is a model whose dashboards cannot be checked
ahead of time.

Post material: the warning itself, and the wider point that a board is validated
against models rather than against tables.

## 2026-09-21 · dct 0.8.0 · A correct chart that misleads

Did: looked properly at the weekly orders line on the first board.

Surprised me: the last point drops from around eight to one. Nothing is broken.
The data ends on 9 April, mid-week, so the final bucket holds one day and is
drawn the same width as every full week before it.

Changed my understanding: the fix belongs in the query, not the chart. Filtering
the partial week out in SQL means the reason is written down in the board file,
where a reviewer can see it and disagree. Hiding it in a chart setting would
make the same correction invisible.

Post material: the opening of P1. It sets up the whole series in one picture.

## 2026-09-21 · dct 0.8.0 · Variables use plain braces

Did: read `dct docs cheatsheet` while setting up.

Surprised me: dct variables are written `{{ region }}`, not dbt's
`{{ var('region') }}`. Same braces, different rules.

Changed my understanding: a board file looks like dbt YAML and is not dbt YAML.
Worth checking the dct reference rather than assuming dbt behaviour carries
over. Not yet tried on a real board.

Post material: a short warning in P4, where variables are introduced.
