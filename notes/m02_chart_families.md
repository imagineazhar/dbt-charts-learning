# Module 2: Chart families

dct version: 0.8.0
Date started: 2026-09-29
Board: `boards/m02_chart_families.yml`

## Goal

Know the 16 authorable chart types, build one board that exercises the main
families on jaffle data, and confirm that some shapes people ask for by name
(stacked bar, horizontal bar) are `style:` options on `type: bar`, not chart
types of their own.

## Docs read

Offline only, no network in this environment: `dct docs charts` (the full
chart-type reference, including the "named shapes that have no `type:`"
table) and `dct docs layout` (for `tabs:` syntax, needed a module early). Did
not read the web docs pages the curriculum names for this module (Bar, Line,
Area, Point, Sector, Tables and Text) — `dct docs charts` covers the same
ground in one place, so those are still open if the web versions say more.

## What I built

One board, `boards/m02_chart_families.yml`: 13 charts off 7 queries against
jaffle (`orders`, `stg_payments`, `customers`). Until 2026-09-30 it was laid out
as `tabs:` with one tab per chart family. It is now one 24-column `grid:` with
every chart on the page (see "Line, area and grid" below). The charts are:

- **Bar** — payment method mix as a plain column bar, weekly orders stacked
  by status (`color: status` + `style.stack: zero`), and top 10 customers by
  lifetime value as a horizontal bar (`style.orientation: horizontal`). All
  three are `type: bar`.
- **Pie and donut** — the same payment mix query, first as `type: pie`, then
  as `type: donut` with a center total.
- **Line and area** — weekly revenue, the same query drawn twice.
- **Scatter** — lifetime value vs number of orders, one dot per customer.
- **Histogram** — order amount distribution, auto-binned from a single `x:`.
- **KPI** — three tiles (total orders, total revenue, total customers) off
  one one-row query, each tile picking a different column with `value:`.
- **Table** — top 10 customers by lifetime value, with column labels,
  alignment and a `currency_whole` format on the value column.

Each chart was rendered on its own with `--chart <id>` to
`assets/renders/m02_chart_families_<name>.png`, and the whole board once to
`m02_chart_families_grid.png`. (While the board used tabs, each tab was
rendered with `--var family=<tab>` instead, since a static render only ever
captures the tab marked `default:`. `m02_chart_families.png` is the old
default-tab render and no longer matches the board.)

The stacked-bar query (`orders_by_week_status`) filters out the last, partial
week (`WHERE order_date < (SELECT date_trunc('week', MAX(order_date)) ...)`)
— the same partial-bucket distortion module 1 found, fixed the same way, in
the query rather than the chart.

## How tabs work

The board used `tabs:` until 2026-09-30, then moved to `grid:` so the post could
show every chart on one page. Everything below was checked while it was tabbed.

`tabs:` is one of four top-level layouts (`rows`, `cols`, `grid`, `tabs`). A
board picks exactly one at the top level, and layouts nest freely. Source:
`dct docs layout`, plus what this board did.

The shape, from `boards/m02_chart_families.yml`:

```yaml
tabs:
  id: family
  default: bar
  items:
    - title: Bar
      rows:
        - payment_bar
        - cols: [weekly_status_stacked, top_customers_bar]
    - title: Donut
      rows:
        - payment_donut
```

- **A tab is a layout container.** Each entry in `items:` has a `title:` and
  then its own `rows:`. The docs' example also shows `text:` as a tab body.
  The Bar tab above is a full-width row followed by a two-column row, so
  nesting inside a tab works.
- **Tabs arrange charts, they do not define them.** Charts and queries are
  declared once under `charts:` and `queries:`, and each tab lists the charts
  it shows by name. Untested: whether a query behind a hidden tab still runs.
- **`id:` names a variable.** The docs say `id` is both the URL parameter and
  the variable name, and is generated if omitted. Verified in this lab:
  `--var family=<tab>` selected the tab when rendering. I did not test how a
  tab value maps to a title, or whether a tab can carry a key separate from
  its title.
- **`default:` picks the tab a static render shows.** Verified: a plain
  `dct render` captured only the `default:` tab, which is why each other tab
  needed its own `--var family=<tab>` render.
- **A tab can carry `text:`.** The Bar tab has one. Like any `text:` block it
  is published output, not a comment. Verified in the render: the text prints
  above the tab's charts, under a heading made from the tab's `title:`.
- **The tab bar is part of the render.** All six titles are drawn across the
  top and the active one is bold. Seen in both the default render and a
  `--var family=donut` render (checked again 2026-09-30 while writing P2).
  This is why the P2 tab renders show the tab bar and the board title, not
  just the chart.

Documented in `dct docs layout` but **untested here**, so kept out of any
draft until run:

- `position: top | left` (tab bar placement)
- `icon:` and `notes:` on a tab item
- a text-only tab (`text:` with `style: { padding: 16 }` and no `rows:`)
- `visible:` on a tab. The docs say `tabs:` layouts keep a hidden item's slot,
  leaving a blank gap. That is the docs' claim, not something I have seen.

For the Tableau reader: this is closest to a tabbed dashboard container, not a
workbook full of sheets. One board, one file, one URL, and the selected tab is
a variable, so it is addressable from outside the board.

## Line, area and grid

Checked 2026-09-30. Query `revenue_by_week` (`week`, `revenue`), with the same
partial-week `WHERE` as the stacked bar. Rendered to PNG and read.

- **Line:** `type: line`, `x: week`, `y: revenue`. A dot on every point. The
  value axis has no `$0` (lowest label `$100`). Nothing in the YAML sets that.
- **Area:** the same chart with `type: area`. The axis starts at `$0`. Same
  query, same fields: only the type changed.
- **Currency warning again:** `revenue` triggers
  `WARN-LIKELY-CURRENCY-OR-PERCENT-MISSING-FORMATTER` without
  `number_format: currency_whole`, like `total_amount` did. Line and area take
  the same slot as bar.
- **`grid:`** takes `columns` (docs: default 24) and `items`. Each item is
  `item: <chart>` plus `col`, `row` (both from 0) and `width` (alias for
  `col_span`; `height` aliases `row_span`). Per the docs `col` and `row` are
  auto-placed if omitted; I set them all and did not test omission.
- **Row height:** I set no `height`. Each row took the height its charts needed
  (the KPI row is short, the chart rows tall).
- **Chart on a third of the width:** the pie and donut showed a legend below
  (percentage, name, value) in the grid, where the same charts rendered alone
  had labels around the slices. Set nowhere in the board. I did not test where
  the switch happens or whether a style key controls it.
- **`--chart` on a scratch board:** rendering one chart from a board that
  defines others not in its layout printed `WARN-UNREFERENCED-CHART` for each of
  them. Not seen on the real board, where every chart is in the grid.

Untested: `height`/`row_span` values, `style.layout.grid.gap`, items that
overlap, `text:` as a grid item, and stacking on `area` (docs say it needs
`color:`).

## Pie to donut

`dct docs charts` says `donut` is an alias for `pie`, that `style.inner_radius`
is the hole ratio (0 to 1, 0 = solid), and that `type: donut` sets it to 0.6.
Checked 2026-09-30 with three charts off `payment_mix`, rendered to SVG and PNG:

- **Plain `type: pie`** (`theta` + `color`, nothing else): slice labels read
  percentage, name and value. No total in the middle, because there is no hole.
- **`type: pie` + `style.inner_radius: 0.6`**: the hole opens, and the centre
  shows `1,672` over `Total Amount`.
- **`type: donut`, nothing else set**: the same centre, and the SVG matches the
  previous chart apart from `data-rendered-at` (2 characters, the seconds).

So the alias claim held, and 0.6 is the donut default as documented.

The centre total appears **without** `total:`. Its label is the column name,
title-cased (`Total Amount`). `total: { label: Total }` only changes the label.
An earlier draft said `total:` "puts the sum in the hole"; that was wrong, and
the P2 draft now says the hole fills itself.

Untested: `inner_radius` values other than 0.6, `total:` on a solid pie,
`style.total.value.format`, and `style.marks.slice.labels.template`.

## Labels on the bars, no value axis

`payment_bar` in `boards/m02_chart_families.yml` carries its values on the bars
and has no y-axis. Two `style:` blocks do it. Fields from `dct docs charts` and
`dct docs reference`; the result checked in a render.

```yaml
style:
  number_format: currency_whole
  axis_y:
    title:  { visible: false }
    labels: { visible: false }
    ticks:  { visible: false }
    line:   { visible: false }
    grid:   { visible: false }
  marks:
    bar:
      labels:
        visible: true
```

- **Labels on the bars:** `style.marks.bar.labels.visible: true`. The docs also
  list `position:` (`above | top | middle | middle_aligned | bottom`) and
  `format:`. Verified here: with none of those set, the label sits inside the
  top of the bar, in white, and reads `$871`. It picked up `currency_whole` from
  `style.number_format`. I did not set `format:` on the mark.
- **Removing the axis:** there is no single switch. The measure axis is
  `axis_y`, and it has five parts, each with its own `visible:`: `title`,
  `labels`, `ticks`, `line` and `grid`. Hiding all five removes the axis.
  Verified: the SVG text nodes for the chart held the four bar values and the
  category names, and no `$0`, `$200`, … tick labels. The render showed no axis
  line and no gridlines.
- **`axis_y` is the measure, not the left edge.** The docs say `axis_x` and
  `axis_y` name the channel, so on a horizontal bar the value axis is still
  `axis_y`, drawn along the bottom. Untested on `top_customers_bar`.
- **Drop the axis only when the bars carry the numbers.** Without the labels,
  hiding the axis leaves bars with no scale.

The first attempt wrote `marks:` as a list (`- labels: ...`). It was rejected
before any render:

```text
ERR-WRONG-SHAPE  Field 'charts.payment_bar.bar.style.marks': Input should be a
valid dictionary or instance of BarChartMarksStylePatch
Hint: 'marks' expects a mapping. Available keys: bar, text. See: dct docs
charts
```

`marks:` is a mapping keyed by mark type (`bar`, `text`), not a list. The
hint names the valid keys, so the fix was in the error message.

Untested: `position:` values, `format:` on the mark, whether labels stay
readable on a very short bar (`$185` fits, but it is the shortest of four),
and `style.marks.text`.

## Errors and warnings (verbatim)

`dct validate`, once per query reading `orders`, `stg_payments` or
`customers` (all end in `select *`) — the same warning module 1 already
logged, repeated six times, one per query:

```
WARN-DBT-MODEL-COLUMNS-UNRESOLVED  Query 'order_amounts' reads dbt model
'orders', whose output columns could not be derived from its SQL (a `*`
projection hides the model's column list); column references against it were
not checked. (query: order_amounts)
Fix: The reason names what blocks static derivation (a `SELECT *` wants
explicit projections; an unaliased cast or expression wants an alias; seeds and
snapshots are never derivable); the columns can always be verified with `dct
validate --warehouse` after `dbt run`.
At: charts/lessons/m02_chart_families.yml
Docs: dct docs queries
```

Confirmed the open question from module 1: `dct validate --warehouse` still
prints this warning in 0.8.0, against the same built jaffle warehouse. It does
not clear it.

New code, on first render, once per chart with an unformatted dollar field:

```
WARN-LIKELY-CURRENCY-OR-PERCENT-MISSING-FORMATTER  payment_bar: Chart
'payment_bar': field 'total_amount' looks like currency but the y-axis format
is '.3~s'.
Fix: Set `style.axis_y.labels.format` to a currency format (e.g. `$,.2f`) or a
percent format (e.g. `.1%`) to match the field's meaning.
Field: total_amount
Docs: dct docs charts
```

Hit on `payment_bar`, `top_customers_bar` and `clv_scatter` — the three
charts with a dollar-shaped column (`total_amount`, `customer_lifetime_value`)
and no `style.number_format`. Fix: added `number_format: currency_whole` to
each chart's `style:` block. Re-rendered clean, zero warnings.

## Tableau comparison

A `donut`/`pie` chart wants one row per segment, already aggregated
(`payment_method`, `total_amount`) — the same discipline Tableau's pie mark
would apply once you actually build one, but Tableau will silently aggregate
a raw fact table for you on drop; dct never will. The query has to arrive
pre-aggregated or the chart is wrong.

`kpi` is the sharpest contrast with Tableau's BANs. A Tableau single-value
card can point at any field and choose an aggregation in the pill. A dct
`kpi` chart requires its query to already return exactly one row, and
`value:` is a bare column reference — no `SUM()`, no aggregation option, in
the chart. Three KPI tiles off one query means the query does all three
aggregations in one `SELECT`.

`table` renders every column from the query, in query order, with no
drag-and-drop field list — hiding a column is `visible: false` in `style:`,
not removing it from the SQL (removing it from the SQL would break anything
that links off it, per the docs' note that hidden columns stay usable in
`link:` templates).

## What surprised me

- **A real, verified table-formatting bug.** `style.columns.<col>.format:
  currency_whole` on the top-customers table only prefixes `$` on the
  **first** data row. Every other row renders the bare number, no symbol.
  Checked this in the rendered SVG rather than trusting the PNG: row one's
  cell is two `<tspan>`s (`$`, then `99`); every other row's cell is one
  `<tspan>` with just the number (`65`, `64`, `57`, …). Not a font or
  rendering artifact — the SVG itself never emits the `$` past row one. Not
  yet tested whether this is specific to `currency_whole`, to a leading
  symbol generally (vs. a trailing one like `%`), or to table columns only.
- `WARN-LIKELY-CURRENCY-OR-PERCENT-MISSING-FORMATTER` is a heuristic lint I
  hadn't seen named anywhere in the docs I'd read — it appears to pattern-match
  the column name (`amount`, `value`, …) against the axis's default D3 format
  and flag a likely mismatch. A nice bit of care in the validator, worth a
  paragraph on its own: dct is willing to guess at *intent*, not just syntax.
- Donut and KPI defaults need almost no styling to look finished: the donut
  centers its own total and computes percentage labels per slice with zero
  extra config; KPI tiles comma-format integers by default. Module 1's board
  needed no styling either, but this is the first time default output looked
  genuinely presentation-ready rather than merely correct.
- The named-shapes table's claim held up exactly as written: stacked bar,
  horizontal bar and plain column bar are the same `type: bar` block with
  different `style:` keys. No separate type, no separate validation error
  class, nothing to guess at.

## Questions still open

- Does the table currency-format bug affect other native aliases
  (`currency_full`, `percent_whole`, `delta`) or only `currency_whole`? Only
  tested one alias, one column, one board.
- Is it specific to a **leading** symbol (`$`) versus a **trailing** one
  (`%`, as in `percent_whole`)? Untested.
- Does the same bug show up on `kpi` or `spark_bar` column-style formatting,
  or only in `type: table`? Untested — the KPI tiles in this board format
  correctly because each is its own chart with a single value, not a column
  of many rows.
- Worth filing upstream once module 2's post work is done; have not searched
  whether it is already a known issue.

## Post material

For P2 ("Sixteen chart types, and the shapes that aren't types"): the
`WARN-LIKELY-CURRENCY-OR-PERCENT-MISSING-FORMATTER` message, quoted and
explained, as an example of dct validating intent rather than only syntax;
the donut and KPI renders as evidence that defaults can look finished; the
Bar-tab render (stacked + horizontal side by side) as the direct illustration
of the "named shapes" table; and — carefully framed as a real, reproducible
limit rather than a complaint — the table currency-formatting bug, with the
SVG `<tspan>` evidence rather than a screenshot claim.
