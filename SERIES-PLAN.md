# Series plan

Working title: **Dashboards as code, learned in public**

Eleven posts written as I learn, each backed by a board in `boards/` and reproducible from `setup.sh`. Tutorials show the code; essays argue from what the code showed. Every post opens with the `dct` version it was written against.

## Thread

dbt Charts moves the dashboard definition into a text file that goes through the same review as the model feeding it. That makes the design decisions behind a dashboard (which question, which metric, which filter, which grain) visible in a diff. The series tests that claim against real use and reports where it holds and where it breaks. It ties back to "decision architecture before data architecture": if the board is a reviewable spec, the decisions it encodes can be reviewed too.

The thread runs underneath the tutorials. P1, P8 and P11 argue it directly; the rest supply the evidence.

## Audience

Primary: analytics engineers who already use dbt and build dashboards in Tableau, Power BI or Looker. Secondary: BI developers curious about code-first dashboards. Assume SQL and dbt fluency. Explain YAML only where dbt Charts departs from ordinary dbt YAML.

## Posts

| # | Working title | Type | Modules | Board / artefact | Status |
|---|---|---|---|---|---|
| P1 | What dbt Charts is, and your first board | Tutorial + framing | 0, 1 | `m01_first_board.yml` | [Published 2026-09-22](https://medium.com/@imagineazhar/dashboards-as-code-part-1-getting-started-with-dbt-charts-7e80502b8acd) |
| P2 | Sixteen chart types, and the shapes that aren't types | Tutorial | 2, 3 | `m02`, `m03` | Not started |
| P3 | Laying out a board: rows, cols, tabs, grid | Tutorial | 4 | `m04_layouts.yml` | Not started |
| P4 | Filters you can read: variables wired into SQL | Tutorial | 5 | `m05_filters.yml` | Not started |
| P5 | Encoding a house style in `meta.yml` | Tutorial + opinion | 6 | `m06_house_style.yml`, 5 theme renders | Not started |
| P6 | Layers, small multiples, and the first chart I couldn't build | Tutorial + limits | 7 | `m07_composition.yml` | Not started |
| P7 | Drill-down without a BI tool | Tutorial | 8 | `m08_*` | Not started |
| P8 | Reviewing a dashboard in a pull request | Essay + walkthrough | 9 | CI workflow, PR screenshot, `impact` output | Not started |
| P9 | I asked an agent to build the same board | Experiment | 10 | Transcript, board diff | Not started |
| P10 | Shipping boards: PNG, SVG, PDF, MkDocs | Tutorial | 11 | Renders, MkDocs page | Not started |
| P11 | From decision brief to board | Capstone essay | C | Capstone board, brief, review diff | Not started |

Status values: Not started → Modules done → Drafting → Edited → Published (with date and link).

## Per-post requirements

- Version line at the top: `Written against dct 0.8.0`.
- Link to the board file at a tagged commit so readers get the exact code.
- At least one rendered visual from `assets/renders/`.
- One real dct message, quoted, and what it means — chosen for what it teaches about boards.
- Tableau comparison where it clarifies; skip it where it doesn't.
- No claims about planned features beyond linking the upstream issue.

## What goes in a post, and what does not

The posts teach dbt Charts. Nothing else earns space in them.

In the post: boards, queries, charts, layout, dct's own messages, the tool's
limits, and the decisions behind a dashboard.

In the repo, linked rather than explained: installation, operating system
differences, shell problems, version pinning, and anything else about getting
a machine ready. `README.md` and `TROUBLESHOOTING.md` carry that load, which
keeps a reader who is already set up moving.

Writing rules are in `drafts/_post-template.md`. The short version: one idea
per paragraph, concrete thing before the explanation, define a term or drop it,
skimmable headings, and 1,200 to 1,600 words. A post running long usually means
something belongs in the repo or in a later post.

## Distribution

Long form on Medium. The plan had been The Insight Floor and imagineazhar.com; P1 went to Medium instead. Code in this repo, public on GitHub, tagged per post (`p1`, `p2` …). Short cuts per post for LinkedIn, drawn from the log entries and renders. Carousel candidates: P2 (chart recipe table), P5 (five themes side by side), P8 (PR diff).

## Open decisions

- Visual embed format for posts: settled in module 11. Until then, PNG.
- Data extension at module 7: see `CURRICULUM.md`, "Data ceiling and options".
- Publishing cadence: not set.
- Whether P8 publishes before P2–P7 as an early hook. It carries the argument, but readers need P1 to follow it.
