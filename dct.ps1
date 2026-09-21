# Run this project's dct without activating the venv:
#
#   .\dct examples
#   .\dct docs cheatsheet
#
# Paths resolve against this script, not the working directory, so it works
# from any tab and any cwd. Activating the venv still works and is unaffected;
# this is only a shortcut for one-off commands.

$exe = Join-Path $PSScriptRoot '.venv\Scripts\dct.exe'

if (-not (Test-Path $exe)) {
    Write-Error "dct not found at $exe - run ./setup.sh in Git Bash first."
    exit 1
}

& $exe @args
exit $LASTEXITCODE
