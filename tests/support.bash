#!/usr/bin/env bash

setup () {
  set -eo pipefail
  export SCRIPT_DIR="$PWD"
  export TMP_DIR="$BATS_TMPDIR/git-fiddle-tests"
  [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
  mkdir -p "$TMP_DIR"
  cd "$TMP_DIR"
  export GIT_CEILING_DIRECTORY="$TMP_DIR"
}

teardown () {
  set -eo pipefail
  [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
}

# create a temporary directory in a cross-platform way
function x_mktemp () {
  prefix=git-fiddle
  mktemp -d 2>/dev/null || mktemp -d -t "$prefix"
}

# create an executable script either from the first argument or from stdin.
function mk_script () {
  local -r script="$1"
  local -r tmp_dir="$(x_mktemp)"
  local -r tmp_editor="$tmp_dir"/editor
  if [ -z "$script" ]; then
    cat > "$tmp_editor"
  else
    echo "$1" > "$tmp_editor"
  fi
  chmod +x "$tmp_editor"
  echo "$tmp_editor"
}

function git_fiddle () { "$SCRIPT_DIR"/git-fiddle "$@"; }

export git_fiddle
