# Curriculum

Twelve modules and a capstone, ordered so each board reuses what the previous one taught. Each module lists the docs to read, the exercise, the board it produces, what to capture for the blog, and the series post it feeds (see `SERIES-PLAN.md`).

Docs paths are relative to https://docs.dbtcharts.com/. The offline equivalent is `dct docs <topic>`.

Written against `dct` 0.8.0. Anything marked "planned" upstream is excluded until it ships.

## Status

| # | Module | Board | Post | Status |
|---|---|---|---|---|
| 0 | Orientation and setup | `guide.yml` (generated) | P1 | Post published |
| 1 | Board anatomy | `m01_first_board.yml` | P1 | Post published |
| 2 | Chart families | `m02_chart_families.yml` | P2 | Not started |
| 3 | Encodings and axes | `m03_encodings.yml` | P2 | Not started |
| 4 | Layout | `m04_layouts.yml` | P3 | Not started |
| 5 | Variables and filters | `m05_filters.yml` | P4 | Not started |
| 6 | Themes and styling | `m06_house_style.yml` | P5 | Not started |
| 7 | Composition | `m07_composition.yml` | P6 | Not started |
| 8 | Multi-board navigation | `m08_overview.yml` + `m08_detail.yml` | P7 | Not started |
| 9 | Governance workflow | CI workflow + `impact` log | P8 | Not started |
| 10 | Building with agents | `m10_agent_built.yml` | P9 | Not started |
| 11 | Output and publishing | Renders + MkDocs page | P10 | Not started |
| C | Capstone | `capstone_*.yml` | P11 | Not started |

## Module 0: Orientation and setup

Read: Overview, Quick Guide, Guides → Installation & Setup, FAQ (skim).

Exercise: run `setup.sh`. Open `charts/guide.yml` in the lab and read it line by line against the Quick Guide. Open the same example in the playground and edit it there. Run `dct docs cheatsheet` and `dct examples`.

Capture: the pipeline in one diagram (board YAML → compile → execute → render). Time from clone to first rendered board. What `dct init` wrote and why each file exists (`dbt_charts.yml` as project anchor and source registry, `charts/meta.yml` as directory-level defaults).

## Module 1: Board anatomy

Read: Quick Guide → Syntax, Queries, Sources, Boards → Overview.

Exercise: `boards/m01_first_board.yml` already exists: two SQL queries against `ref('orders')`, a line and a bar, side by side. Rebuild it from a blank file without looking. Then change one thing at a time: swap the layout from `cols` to `rows`, remove `source:` and move it into `meta.yml`, replace one SQL query with `type: values`.

Capture:

- The separation rule: the query owns rows and columns, the chart owns encoding, and the chart never aggregates. Compare with where that logic lives in Tableau (calculated fields, table calcs, the viz itself).
- `WARN-DBT-MODEL-COLUMNS-UNRESOLVED`, raised on the first validate because the jaffle `orders` model ends in `select *`. The validator reads the model's SQL to check column references, and a star projection blocks it. The warning text suggests `dct validate --warehouse`; in 0.8.0 that still printed the warning. Try an explicit projection in the model and record whether it clears.
- The last point on the weekly line drops to 1 because the week of 9 April is partial. The chart is correct and misleading. Note how you fix it (filter in SQL) and where the fix belongs.

## Module 2: Chart families

Read: Charts → Overview, then Bar, Line, Area, Point, Sector, Tables and Text. `dct docs charts` for the full type list.

The 16 authorable types in 0.8.0: `bar`, `line`, `area`, `scatter`, `pie`, `donut`, `kpi`, `table`, `histogram`, `heatmap`, `geoshape`, `map`, `point_map`, `bubble_map`, `spark_bar`, `callout`.

Exercise: one board with a tab per family, all on jaffle data. Order amount histogram, payment method mix as bar and as donut, customer lifetime value vs number of orders as scatter, a KPI row, a table of top customers. Build a stacked bar and a horizontal bar without a `type:` of their own (they are style options on `bar`).

Capture: the "named shapes that have no `type:`" table in `dct docs charts`. Stacked, grouped, 100%, lollipop, bullet, slope, bump and dot plot are recipes composed from the base types. Guessing `type: bullet` returns an error that names the recipe. That error design is worth a paragraph. Skip the geographic types here (see data ceiling below).

## Module 3: Encodings and axes

Read: Chart Color Channels, Axis Labels, Time Axes, Axis Scales, `dct docs color`.

Exercise: rebuild the weekly orders line with `color:` split by status. Control time grain and axis formatting. Put customer lifetime value on a log scale and explain in the note whether it helps with 100 customers.

Capture: colours are palette tokens resolved by the theme, not hex values. Record what you lose and gain compared with setting hex codes per mark in Tableau.

## Module 4: Layout

Read: Board Layouts, Board Content, Board Sizing, Board Imports & Dynamic Layouts, Layout Types Reference.

Exercise: rebuild one dashboard four ways: `rows`, `cols`, `tabs`, `grid`. Split a large board into partials under `charts/partials/` and import them. Set widths and heights until it renders cleanly as PNG at a fixed size.

Capture: what a layout tree can and cannot express compared with Tableau containers. Where sizing fought you.

## Module 5: Variables and filters

Read: Variables (all four pages), Chart Interactions.

Exercise: a status selector populated from a query, wired into two queries with `{{ filter('status', status) }}`. A date range control. Render the same board with `dct render --var status=completed` and serve it with `?status=completed` in the URL.

Capture: a variable filters nothing until you wire it into a query. Every filter is visible in the SQL. Compare with Tableau filter scope (worksheet, data source, context filters) and write down which failure modes that removes and which it adds.

## Module 6: Themes and styling

Read: Themes, Styling, Guides → Palettes, Palette resolver, Tonal Foundations, YAML Style Guide.

Exercise: render one board in each built-in theme (`clarity`, `paper`, `vivid`, `neon`, `stark`). Then build a house style: set it once in `meta.yml` and check that every lesson board picks it up. Number formats (`currency_whole`, percentages), mark styling, curve interpolation.

Capture: side-by-side renders of the five themes. Which of your usual design rules you could encode, and which you couldn't. This is the module where your own viz standards meet the tool's defaults; take a position.

## Module 7: Composition

Read: Layered Charts, Small Multiples, the combo charts section of `dct docs charts`, Chart types and extensibility.

Exercise: bars with a target line layered on top (targets from a `type: values` query). A bullet chart from the recipe. Small multiples of weekly orders by payment method.

Capture: arbitrary Vega-Lite is rejected on purpose, so every board stays typed and reviewable. There is no user-defined chart type yet (tracked in dbt-labs/dbt-charts#2). Find the first chart you wanted and couldn't build. That limit is a post section.

Data ceiling: four payment methods and five statuses make thin small multiples. See the note at the end.

## Module 8: Multi-board navigation

Read: Linking Between Boards, Examples → Drill-Down Boards, Interactive Board Example.

Exercise: an overview board of all customers that links to a customer detail board, passing `customer_id` as a variable.

Capture: how drill paths are declared, and whether the path is readable from the YAML alone without running the board.

## Module 9: Governance workflow

Read: `dct` CLI → validate, impact, migrate, describe, search. Guides → Validating Boards in CI, Error Handling, Troubleshooting. Error and Warning references.

Exercise: push this repo to GitHub. Run `dct init ci` in the lab and adapt the workflow to this repo layout. Open a PR that renames a column in a jaffle model; run `dct impact` first and confirm it names the boards that break. Validate with `--strict`.

Capture: the PR diff of a dashboard change, as a screenshot. This module carries the series' central argument (see `SERIES-PLAN.md`).

## Module 10: Building with agents

Read: `dct` CLI → skills, AI assistants, mcp. Run `dct skills`.

Exercise: give a coding agent (Claude Code) the jaffle lab and one plain-language request. Keep the full transcript. Compare its board with the one you built by hand for the same question: correctness, readability, what you had to correct.

Capture: the transcript, the diff between the two boards, the corrections. Hold off on conclusions until the diff is in front of you.

## Module 11: Output and publishing

Read: `dct` CLI → render, serve. Integrations → MkDocs. dbt Charts Cloud → Overview (read only; decide later whether to use it).

Exercise: render every lesson board to PNG and SVG into `assets/renders/`. Embed one live board in an MkDocs page. Decide the embed format for the blog: static PNG, SVG, or a hosted board.

Capture: which format survives Substack, and which survives your own site. This settles how every post from here on ships its visuals.

## Capstone

Build a complete executive board on the jaffle data from a written brief: state the decisions the board supports first, then derive the metrics, then the queries, then the charts. Ship it with CI, a rendered PDF, and a README.

Capture: the brief, the board, the review diff. The capstone post is the series finale.

## Data ceiling and options

Jaffle shop covers modules 0–6 and most of 8–11. It hits limits at maps (no geography) and dense small multiples (few categories, 14 weeks).

Options when you reach module 7, logged as a decision in `LEARNING-LOG.md`:

- Stay on jaffle shop and use small `type: values` tables for the gaps, for example a hand-written store table with coordinates. Fully reproducible.
- Add dbt's jaffle shop generator (`pip install jafgen`, then `jafgen 2`). It produces two years of orders, stores in several cities, products and supplies. Its output is random with no seed option (two runs produced different files when tested), so readers get the same shapes and different numbers.
- Commit a generated jafgen snapshot as Parquet. Reproducible, at the cost of repo size.
