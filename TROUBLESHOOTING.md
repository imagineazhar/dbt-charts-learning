# Troubleshooting

Environment and tooling problems hit while building this lab, with the fix for
each. None of this is about dbt Charts itself, which is why it lives here and
not in `LEARNING-LOG.md` or in the posts. Posts link here when a reader is
likely to hit the same wall.

## `dct is not recognized` (Windows, PowerShell)

`dct` is only on PATH once the virtualenv is active. The activate line in the
README (`source .venv/bin/activate`) is for bash, zsh and Git Bash. PowerShell
needs its own:

```powershell
.\.venv\Scripts\Activate.ps1
```

For a single command without activating anything, use the shim at the repo root:

```powershell
.\dct examples
```

## `setup.sh` will not run in Git Bash

If Git is configured with `core.autocrlf=true`, the checkout gives you a
`setup.sh` with Windows line endings, which Git Bash refuses to execute. The
repo pins `eol=lf` in `.gitattributes`, so a fresh clone is fine. An older
clone needs its files re-checked-out against that setting.

## Two jaffle shops on one machine

Running any `dbt` command without activating the virtualenv can pick up a
globally installed dbt instead of the pinned one. A global dbt-fusion 2.0
scaffolds its own, newer jaffle shop into whatever directory you ran it from,
shadowing the pinned clone in `lab/`. Same project name, different models,
different numbers.

Activate the virtualenv before any `dbt` command. If a stray `jaffle_shop/` or
`logs/` directory appears at the repo root, that is what happened.

## `dct render` fails on a board under `charts/lessons/`

```
Board file ...\boards\m01_first_board.yml is outside project_dir ...\lab\jaffle_shop.
Pass an explicit --project-dir that contains the board file.
```

`setup.sh` links `boards/` into the lab as `charts/lessons/` so boards stay in
git and the lab stays disposable. `dct validate` and `dct serve` both follow
that link. `dct render` resolves it to the real location and refuses, because
that location sits outside the project.

Render by piping the board in instead:

```bash
cd lab/jaffle_shop
cat ../../boards/m01_first_board.yml \
  | dct render - --format png --output ../../assets/renders/m01_first_board.png
```

Raise with upstream before deciding whether to stop linking and copy instead.

## Every render fails with `Empty YAML document`

`dct init` writes a `charts/meta.yml` that is entirely comments. A file of only
comments parses to nothing, and dct 0.8.0 has no guard for that case, so every
render in the project fails.

Fixed in `setup.sh`, which now writes one real key (`source: jaffle`) into that
file. Worth reporting upstream: the failure is an unhandled crash with no error
code, on a file the tool generated itself.

## Resetting the lab

`lab/` is disposable and git-ignored. Delete `lab/jaffle_shop/` and re-run
`setup.sh` to rebuild it from scratch.
