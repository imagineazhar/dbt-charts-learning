# Learning log

Newest first. One entry per session. Keep entries short; the module notes hold the detail.

Entry format:

```
## YYYY-MM-DD · dct x.y.z · Module N
Did:
Broke / confused me:
Changed my understanding:
Post material:
```

---

## 2026-09-21 · dct 0.8.0 · Repo setup

Did: published the repo. `git init` on `main`, initial commit, public at `github.com/imagineazhar/dbt-charts-learning`. Added `.gitattributes` pinning `eol=lf`. Cleared a stray `jaffle_shop/` and `logs/` from the repo root.

Broke / confused me: that stray `jaffle_shop/` was `dbt init` run from the repo root, which hit the global dbt-fusion 2.0 binary instead of the venv. Fusion scaffolds its own newer jaffle shop — marts, macros, four extra seeds — so the root held a second, different jaffle shop shadowing the pinned `36bde6c` clone. Activate the venv before any dbt command.

Changed my understanding: dct variables interpolate as bare `{{ region }}`, no `variables.` prefix — not dbt's `{{ var('region') }}`. Same Jinja braces, different resolution. (From `dct docs cheatsheet`; not yet exercised on a board.)

Post material: two jaffle shops on one machine and how to tell them apart. Also `core.autocrlf=true` handing Windows readers a CRLF `setup.sh` that Git Bash rejects — the first command the README tells them to run. And the shell the docs forgot to name: `setup.sh` junctions `.venv/bin` to `.venv/Scripts` so Git Bash works on Windows, but the same activate line still fails in PowerShell, which the README never mentioned.

## 2026-09-21 · dct 0.8.0 · Setup and module 1 board

Did: scaffolded the project. `setup.sh` runs clean from a fresh copy: venv, jaffle shop at commit `36bde6c`, `dbt build` (28 passed), `dct init`, source `jaffle` registered from the dbt profile, `boards/` linked into the lab. First board (`m01_first_board.yml`) validates, renders to PNG, and serves at `/lessons/m01_first_board/`.

Broke / confused me: `dct validate` raises `WARN-DBT-MODEL-COLUMNS-UNRESOLVED` on both queries. The jaffle `orders` model ends in `select *`, so dct can't derive its columns statically. `--warehouse` doesn't clear it either.

Changed my understanding: validation reads the dbt model SQL to check column references before anything runs. Model style (explicit projections) now affects dashboard safety.

Post material: the partial final week (9 April) drags the weekly line to 1. Correct chart, misleading picture. Good opener for P1 on where fixes belong.
