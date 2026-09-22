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
