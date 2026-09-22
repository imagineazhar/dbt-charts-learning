# Module 1: Board anatomy

dct version: 0.8.0
Date started: 2026-09-21
Board: `boards/m01_first_board.yml`, plus `boards/first.yml` (the minimal one)

Backfilled on 2026-09-22 from `LEARNING-LOG.md` and the published P1, not
written while working. Exercises the sources do not evidence are marked as not
done rather than assumed.

## Goal

Know what the four parts of a board are, what belongs to the query and what
belongs to the chart, and be able to write one from a blank file.

## Docs read

Quick Guide → Syntax, Queries, Sources, and Boards → Overview, per the
curriculum. Not separately recorded at the time.

## What I built

Two boards.

`boards/first.yml` — the smallest thing that works: one query, one chart, one
row. This is the board P1 walks a reader through, and it is kept byte-identical
to the YAML the post prints.

`boards/m01_first_board.yml` — two queries against `ref('orders')`, a line and
a bar side by side, under a `text:` block. Rendered to
`assets/renders/m01_first_board.png`.

A board is one YAML file that renders as one page, holding four kinds of thing:
`queries:` (named SQL, one result set each), `charts:` (named charts, each
reading one query), exactly one layout (`rows:`, `cols:`, `grid:` or `tabs:`),
and optional extras (`title:`, `variables:`, `theme:`, `style:`).

Curriculum exercises **not** done, and still worth doing:

- Rebuilding the board from a blank file without looking. `first.yml` was
  written from scratch but it is the minimal board, not this one.
- Swapping the layout from `cols:` to `rows:`.
- Removing `source:` from the queries to confirm they inherit it from
  `charts/meta.yml`, where `setup.sh` writes `source: jaffle`. The post asserts
  this works; it has not been tested here.
- Replacing one SQL query with `type: values`.

## Errors and warnings (verbatim)

`dct validate charts/lessons/first.yml`, captured 2026-09-22:

```
WARN-DBT-MODEL-COLUMNS-UNRESOLVED  Query 'orders_by_week' reads dbt model
'orders', whose output columns could not be derived from its SQL (a `*`
projection hides the model's column list); column references against it were
not checked. (query: orders_by_week)
Fix: The reason names what blocks static derivation (a `SELECT *` wants
explicit projections; an unaliased cast or expression wants an alias; seeds and
snapshots are never derivable); the columns can always be verified with `dct
validate --warehouse` after `dbt run`.
At: charts/lessons/first.yml
Docs: dct docs queries
```

Cause: jaffle's `orders` model ends in `select *`, so dct cannot derive its
columns and skips the check. Nothing is wrong; the check was simply not run.
Exit code is 0.

Renaming a model to something that does not exist, as quoted in the post:

```
ERR-DBT-REF-UNKNOWN-NODE  SQL references {{ ref('ordersss') }}, but no model,
seed, or snapshot named 'ordersss' exists in the dbt manifest. Available:
customers, orders, raw_customers, raw_orders, raw_payments, stg_customers,
stg_orders, stg_payments.
Hint: Did you mean 'orders'?
```

Raised before anything runs, because the board points at a model rather than a
table and validation reads dbt's manifest.

`WARN-SINGLE-CHART-REDUNDANT-TITLE` was also hit, on a one-chart board whose
chart title duplicated the board title. That is why `first.yml` gives its chart
no title. The message text was not captured.

## Tableau comparison

The separation rule is the whole difference. The query owns rows and columns;
the chart owns encoding. Every channel takes a bare column name, never an
expression, so if a value needs changing you change the SQL.

In Tableau, dropping a measure on a shelf aggregates it for you and a mark's
grain shifts with whatever else is on the shelves. Here the grain is fixed in
SQL and the chart cannot change it behind you. There is no equivalent of a
calculated field or a table calculation in the chart layer.

Three chart features do compute, and each has to be written down by name:
`histogram` binning, `style.stack: normalize`, and `aggregate:` inside a
`support_table:`.

Colour is the other departure: channels take palette tokens the theme resolves,
not hex codes, so a board restyles itself when the theme changes. In Tableau
the hex usually lives on the mark.

## What surprised me

- Validation reads the SQL of the dbt models a board depends on, before running
  anything. That makes model style a dashboard concern: a model ending in
  `select *` is a model whose dashboards cannot be checked ahead of time.
- The weekly line's last point drops from around eight to one, and nothing is
  broken — the data ends mid-week on 9 April, so the final bucket holds one day
  and is drawn as wide as every full week before it. Correct and misleading at
  once. The fix belongs in the query, where a reviewer can see and disagree
  with it, not in a chart setting where it would be invisible.
- A `text:` block is published output, not a code comment. Whatever is written
  there lands on the page, in the PNG and in the PDF. A line pointing at a file
  in this repo had to be removed for that reason.
- Titles are re-cased for display. `title: "Orders per week"` renders as
  "Orders per Week" and `"Orders by status"` as "Orders by Status", in headline
  style — `per`, `by` and `on` stay lowercase. Data is untouched; the authored
  string survives on the SVG root as `data-dbt-page-title`. So the board file is
  the deliverable, but it is not literally what a reader sees.
- Unknown keys are errors rather than warnings, and there is no escape hatch to
  raw Vega-Lite: `encoding`, `mark`, `spec` and `transform` are rejected at
  compile time. Every board stays fully typed, which is the property the series
  is about.

## Questions still open

- Does giving `orders` an explicit projection clear
  `WARN-DBT-MODEL-COLUMNS-UNRESOLVED`? The warning suggests
  `dct validate --warehouse`; in 0.8.0 that still printed it.
- Is the title casing the default theme's doing or does it apply under all
  five, and can it be switched off? A module 6 question, two renders' work.
- Does `type: values` change what validation can check, given there is no model
  to read?

## Post material

Used in P1: the partial-week chart as the opening image and the argument it
sets up, the four parts of a board, the pipeline seam at `{{ ref() }}`, the
`ERR-DBT-REF-UNKNOWN-NODE` message, the chart field table, and the `text:`
block as published output.

Not used yet: the title-casing finding, which is live in the published post as
an unexplained mismatch between the YAML and the render directly beneath it.
`WARN-DBT-MODEL-COLUMNS-UNRESOLVED` is quoted nowhere yet and carries the
wider point that a board is validated against models rather than tables.
