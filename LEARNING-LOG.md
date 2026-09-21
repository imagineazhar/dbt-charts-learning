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

## 2026-09-21 · dct 0.8.0 · Setup and module 1 board

Did: scaffolded the project. `setup.sh` runs clean from a fresh copy: venv, jaffle shop at commit `36bde6c`, `dbt build` (28 passed), `dct init`, source `jaffle` registered from the dbt profile, `boards/` linked into the lab. First board (`m01_first_board.yml`) validates, renders to PNG, and serves at `/lessons/m01_first_board/`.

Broke / confused me: `dct validate` raises `WARN-DBT-MODEL-COLUMNS-UNRESOLVED` on both queries. The jaffle `orders` model ends in `select *`, so dct can't derive its columns statically. `--warehouse` doesn't clear it either.

Changed my understanding: validation reads the dbt model SQL to check column references before anything runs. Model style (explicit projections) now affects dashboard safety.

Post material: the partial final week (9 April) drags the weekly line to 1. Correct chart, misleading picture. Good opener for P1 on where fixes belong.
