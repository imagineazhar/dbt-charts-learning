---
title: What dbt Charts is, and your first board
series: Dashboards as code, learned in public
part: P1
dct_version: 0.8.0
board: https://github.com/imagineazhar/dbt-charts-learning/blob/p1/boards/m01_first_board.yml
status: drafting
---

_Written against dct 0.8.0. The syntax changes before 1.0, so check the version before copying code._

![A board with two charts: weekly orders as a line, orders by status as a bar](../assets/renders/m01_first_board.png)

Look at the line on the left. Orders per week sit between five and nine from January to March, then fall off a cliff to one.

Nothing is broken. Every number on that axis is the number in the warehouse. The last point covers the week of 9 April, and the data stops on 9 April — one day drawn the same width as every full week before it.

So the chart is correct and the picture is wrong. That happens in every BI tool. What is different here is that the query producing it sits eleven lines above the chart, in the same file, in the same pull request. The fix is one `WHERE` clause, and anyone reviewing it can see both the problem and the correction.

That is the idea this series tests.

## What this series is

I am learning dbt Charts in public and writing it up as I go. Eleven posts, each one backed by a working board you can clone and run.

The claim I want to test: when a dashboard is a text file, the decisions inside it — which question, which metric, which grain — become reviewable. That might hold up. It might not. I will report both.

**Who this is for:** you use dbt, you build dashboards somewhere else, and you are curious whether this is worth your time. I assume SQL and dbt. I explain YAML only where dbt Charts does something unusual with it.

**The posts:** first board (this one), chart types, layout, filters, styling, composition, drill-down, reviewing a dashboard in a pull request, building one with an AI agent, publishing, and a capstone.

## What dbt Charts is

It is dbt Labs' open-source language for dashboards. You write a board as a YAML file. The tool turns it into charts and renders them as a web page, a PNG, an SVG or a PDF. The package is `dbt-charts` and the command is `dct`.

One rule explains most of the design:

> The query decides what data appears. The chart decides how it looks. The chart never aggregates.

Want orders counted by week? You write `COUNT(*)` and `GROUP BY` yourself. There are no calculated fields in the chart layer, no table calculations, no quietly applied `SUM`. Every number on the canvas comes from a line of SQL you can point at.

**If you come from Tableau,** this is the adjustment to make. In Tableau, dropping a measure onto a shelf aggregates it for you, and the grain of a mark depends on what else is on the shelves. That is fast, and it is why two people can open the same workbook and disagree about what a number means. Here the grain is fixed in SQL and the chart can only draw what the query returned. You give up exploratory speed. You get a dashboard where "what is this number?" has a written answer.

Whether that trade is worth it is the whole series. I am not settling it in post one.

## Getting the lab running

Everything in this series runs on dbt's jaffle shop — a fictional sandwich shop with 100 customers and 99 orders. Small enough to check by hand, which is the point early on.

```bash
git clone https://github.com/imagineazhar/dbt-charts-learning.git
cd dbt-charts-learning
git checkout p1
./setup.sh
```

The script installs pinned versions of everything, builds the sample data locally, and wires up the boards. Pinning matters: it means your charts show the same numbers as mine.

Then start the preview server:

```bash
source .venv/bin/activate
cd lab/jaffle_shop && dct serve
```

Open the URL it prints and go to `/lessons/m01_first_board/`.

Windows setup and fixes for the usual problems live in the repo, in the README and `TROUBLESHOOTING.md`. I have kept them out of the post so this stays about charts.

If you would rather look before installing anything, [play.dbtcharts.com](https://play.dbtcharts.com/) runs boards in the browser.

## Your first board

Here is the whole thing — two queries, two charts, one layout:

```yaml
title: "Module 1: first board on jaffle shop"

queries:
  orders_by_week:
    sql: |
      SELECT date_trunc('week', order_date) AS week,
             COUNT(*) AS orders
      FROM {{ ref('orders') }}
      GROUP BY 1
      ORDER BY 1
    source: jaffle

  orders_by_status:
    sql: |
      SELECT status, COUNT(*) AS orders
      FROM {{ ref('orders') }}
      GROUP BY 1
      ORDER BY 2 DESC
    source: jaffle

charts:
  weekly_orders:
    query: orders_by_week
    type: line
    title: "Orders per week"
    x: week
    y: orders

  status_mix:
    query: orders_by_status
    type: bar
    title: "Orders by status"
    x: status
    y: orders

rows:
  - cols:
      - weekly_orders
      - status_mix
```

Three blocks, and each one does exactly one job.

**`queries:`** holds the data. Each query has a name, some SQL, and a source to run it against. `{{ ref('orders') }}` is the dbt reference you already know. That matters more than it looks: a board points at a model, not a table, so renaming the model breaks the board loudly instead of silently.

**`charts:`** holds the encoding. Each chart names a query, picks a type, and maps columns to channels. `x: week` is a column name from the query above — not an expression. If a value needs changing, change it in the SQL.

**`rows:`** holds the layout. Items stack vertically; a `cols:` block puts them side by side. Charts appear by name only, so layout stays pure arrangement and never hides chart settings.

To build it yourself, delete the file and write it again from blank. Then change one thing at a time and reload: swap `cols` for `rows`, move `source: jaffle` up into `charts/meta.yml` so both queries inherit it, replace a query with a small hand-written table. Twenty minutes of that teaches more than reading the syntax reference twice.

## The warning you will see

Validate the board and dct has something to say:

```text
WARN-DBT-MODEL-COLUMNS-UNRESOLVED  Query 'orders_by_week' reads dbt model
'orders', whose output columns could not be derived from its SQL (a `*`
projection hides the model's column list); column references against it were
not checked.
```

It fires on both queries, and nothing is actually wrong. dbt's `orders` model ends in `select *`, so dct cannot work out which columns it produces, and so it cannot confirm that `week`, `orders` and `status` exist. It is telling you the check was skipped.

The interesting part is that the check exists at all. **dct reads the SQL of your dbt models to verify your charts before anything runs.** Your model style is now a dashboard concern: a model ending in `select *` is a model whose dashboards cannot be checked ahead of time.

Note also what the warning does not do. It does not fail. It does not guess. It names precisely what it could not verify, rather than implying it verified it. That is rarer than it should be.

## What this post did not settle

One board is not much evidence. I do not yet know what the layout system cannot express, which chart I will want and fail to build, or whether a dashboard diff is genuinely readable in a pull request.

Those are posts three, six and eight. I would rather find out in public than guess here.

## Next

**P2: Sixteen chart types, and the shapes that aren't types** — why asking for a bullet chart returns an error instead of a chart, and why that error is better designed than it first looks.

The board from this post is in [the repo](https://github.com/imagineazhar/dbt-charts-learning), tagged `p1`.
