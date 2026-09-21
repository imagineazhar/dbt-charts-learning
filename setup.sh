#!/usr/bin/env bash
# Rebuilds the learning lab from scratch. Safe to re-run.
# Pinned versions: change them deliberately and log the change in LEARNING-LOG.md.
set -euo pipefail

DCT_VERSION="0.8.0"
DBT_CORE_VERSION="1.11.6"
DBT_DUCKDB_VERSION="1.10.1"
JAFFLE_COMMIT="36bde6cba69d962b83be1d52fc65a0dce1cb4ebb"   # dbt-labs/jaffle_shop_duckdb, 2 Mar 2026

ROOT="$(cd "$(dirname "$0")" && pwd)"
LAB="$ROOT/lab/jaffle_shop"

# --- platform shims --------------------------------------------------------
# Git Bash on Windows differs from POSIX in three ways that matter here:
#   1. `python3` on PATH is usually the Microsoft Store App Execution Alias,
#      which prints an ad and exits 49 instead of running Python.
#   2. venvs put their binaries in Scripts/, not bin/.
#   3. `ln -s` silently COPIES a directory instead of linking it, which would
#      freeze boards/ into the lab so later edits never show up.
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) IS_WINDOWS=1 ;;
  *)                    IS_WINDOWS=0 ;;
esac

if [ "$IS_WINDOWS" = 1 ]; then
  PY_CANDIDATES=("py -3" "python3" "python")
  VENV_BIN="Scripts"
else
  PY_CANDIDATES=("python3")
  VENV_BIN="bin"
fi

# First candidate that actually runs wins; the Store stub fails this test.
PYTHON=()
for _cand in "${PY_CANDIDATES[@]}"; do
  # shellcheck disable=SC2086
  if $_cand --version >/dev/null 2>&1; then
    read -r -a PYTHON <<< "$_cand"
    break
  fi
done
if [ ${#PYTHON[@]} -eq 0 ]; then
  echo "No working Python found (tried: ${PY_CANDIDATES[*]})." >&2
  if [ "$IS_WINDOWS" = 1 ]; then
    echo "Install Python from python.org, or disable the Store alias under" >&2
    echo "Settings > Apps > Advanced app settings > App execution aliases." >&2
  fi
  exit 1
fi

# Point a directory link at src, replacing whatever is at dst.
# Never follows an existing link into its target.
link_dir() {
  local src="$1" dst="$2" bak
  if [ "$IS_WINDOWS" = 1 ]; then
    if [ -L "$dst" ]; then
      cmd //c rmdir "$(cygpath -w "$dst")" >/dev/null   # unlinks only, target untouched
    elif [ -e "$dst" ]; then
      # A real directory here is usually a copy left by `ln -s` on Git Bash.
      # It may hold edits, so move it aside rather than deleting it.
      bak="$dst.bak.$(date +%Y%m%d%H%M%S)"
      echo "  note: $dst is a real directory, not a link -> moved to $(basename "$bak")"
      mv "$dst" "$bak"
    fi
    cmd //c mklink //J "$(cygpath -w "$dst")" "$(cygpath -w "$src")" >/dev/null
  else
    ln -sfn "$src" "$dst"
  fi
}

echo "1/5 Python environment"
"${PYTHON[@]}" -m venv "$ROOT/.venv"
# Make the documented `source .venv/bin/activate` work on Windows too.
if [ "$IS_WINDOWS" = 1 ] && [ ! -e "$ROOT/.venv/bin" ]; then
  cmd //c mklink //J "$(cygpath -w "$ROOT/.venv/bin")" "$(cygpath -w "$ROOT/.venv/Scripts")" >/dev/null
fi
# shellcheck disable=SC1091
source "$ROOT/.venv/$VENV_BIN/activate"
# `python -m pip`, not `pip`: on Windows pip cannot replace its own running .exe.
python -m pip install -q --upgrade pip
pip install -q "dbt-charts==$DCT_VERSION" "dbt-core==$DBT_CORE_VERSION" "dbt-duckdb==$DBT_DUCKDB_VERSION"

echo "2/5 Jaffle shop (DuckDB) at pinned commit"
if [ ! -d "$LAB/.git" ]; then
  git clone -q https://github.com/dbt-labs/jaffle_shop_duckdb.git "$LAB"
fi
git -C "$LAB" checkout -q "$JAFFLE_COMMIT"

echo "3/5 dbt build"
(cd "$LAB" && dbt build --profiles-dir . --quiet)

echo "4/5 dct init + source registration"
cd "$LAB"
dct init -y --no-skills --no-mcp --no-vscode --no-cursor >/dev/null
if ! grep -q "^sources:" dbt_charts.yml; then
  cat >> dbt_charts.yml <<'YAML'

sources:
  jaffle:
    type: dbt_profile
    profile: jaffle_shop
    target: dev
YAML
fi

echo "5/5 Link lesson boards into the lab"
link_dir "$ROOT/boards" "$LAB/charts/lessons"
dct validate charts/lessons/ || true

cat <<MSG

Lab ready.
  source .venv/bin/activate
  cd lab/jaffle_shop && dct serve
Lesson boards: open the URL dct serve prints, then /lessons/<board-name>/
MSG
