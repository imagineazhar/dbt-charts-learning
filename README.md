# Learning dbt Charts in public

A working lab for learning dbt Charts, and the source material for a public blog and tutorial series. Every board, note and draft in this repo feeds the other two: boards produce the screenshots and code samples, notes capture what I got wrong, and drafts turn both into posts.

dbt Charts is dbt Labs' open-source YAML language for dashboards (package `dbt-charts`, CLI `dct`). SQL decides what data a board shows; the YAML decides how it is shown. Boards compile to Vega-Lite and render as live HTML, static HTML, PDF, PNG or SVG.

## Pinned versions

| Component | Version | Why pinned |
|---|---|---|
| dbt-charts (`dct`) | 0.8.0 | The YAML syntax will change before 1.0. Every post states the version it was written against. |
| dbt-core | 1.11.6 | Matches the jaffle shop lock file |
| dbt-duckdb | 1.10.1 | Same |
| jaffle_shop_duckdb | commit `36bde6c` (2 Mar 2026) | Readers get identical data and identical charts |

When `dct` releases a new version, bump it in `setup.sh`, run `dct migrate` on `boards/`, and log what broke in `LEARNING-LOG.md`. Breaking changes are post material.

## Setup

Requires Python 3.10+ and git.

```bash
./setup.sh
source .venv/bin/activate
cd lab/jaffle_shop && dct serve
```

That block assumes bash, zsh, or Git Bash on Windows — `setup.sh` junctions
`.venv/bin` to `.venv/Scripts` so the same activate line works there. From
PowerShell, use the native equivalents instead:

```powershell
bash ./setup.sh
.\.venv\Scripts\Activate.ps1
cd lab\jaffle_shop; dct serve
```

Without activating, `dct` is not on PATH and PowerShell reports
`dct is not recognized`. For one-off commands there is a shim at the repo
root that needs no activation:

```powershell
.\dct examples
.\dct docs cheatsheet
```

`setup.sh` creates a virtualenv, clones dbt's jaffle shop at the pinned commit, runs `dbt build` into a local DuckDB file, runs `dct init`, registers the dbt profile as a source named `jaffle`, writes `source: jaffle` into `charts/meta.yml` as the directory default, and symlinks `boards/` into the lab as `charts/lessons/`. Boards stay in this repo; the lab is disposable and git-ignored. Delete `lab/jaffle_shop/` and re-run the script to reset.

That `meta.yml` line is a workaround, not a preference: `dct init` scaffolds the file as comments only, which parses to nothing, and dct 0.8.0 then fails every render in the project with an uncaught `ParseError: Empty YAML document`. One real key clears it.

Validate and render from inside `lab/jaffle_shop`:

```bash
dct validate charts/lessons/
dct render charts/lessons/m01_first_board.yml --format png --output ../../assets/renders/m01_first_board.png
```

## Structure

```
CURRICULUM.md      Modules, exercises, and the board each one produces
SERIES-PLAN.md     Blog and tutorial series: posts, angles, status
LEARNING-LOG.md    What I learned about charts and boards, newest first
TROUBLESHOOTING.md Environment and tooling problems, with fixes
setup.sh           Rebuilds the lab from scratch
boards/            Lesson boards (m01_*.yml, m02_*.yml …), tracked in git
notes/             One note per module, written while working
drafts/            Post drafts, one file per post
assets/renders/    PNG/SVG exports used in posts
lab/               Disposable dbt + DuckDB project (git-ignored)
```

## Working loop

1. Pick the next module in `CURRICULUM.md`.
2. Build the module's board in `boards/`. Validate, serve, render.
3. Write the module note in `notes/` as you go, from `notes/_module-template.md`. Record errors verbatim; the `dct` error codes (`ERR-…`, `WARN-…`) are useful in posts.
4. Add a log entry with the date, the `dct` version, and one line on what changed in your understanding. `LEARNING-LOG.md` is for charts and boards only — anything about installation, shells or the operating system goes in `TROUBLESHOOTING.md` instead, so the log stays a record of what you learned rather than what you fought.
5. When a series post's modules are done, start its draft from `drafts/_post-template.md` and update `SERIES-PLAN.md`. The template opens with the writing rules; posts teach dbt Charts and link here for everything else.

## Data

The jaffle shop is a small fictional sandwich shop: 100 customers, 99 orders, 1 January – 9 April 2018. It is small enough to reason about by hand, which suits the early modules. Its only categorical dimensions are order status, payment method and customer. It has no geography and no products, so it runs out for maps and for dense small multiples. `CURRICULUM.md` flags where that ceiling hits and the options for extending it.

## References

- Docs: https://docs.dbtcharts.com/
- Repo: https://github.com/dbt-labs/dbt-charts
- Playground (no install): https://play.dbtcharts.com/
- Offline reference: `dct docs`, `dct docs <topic>`, `dct examples`
