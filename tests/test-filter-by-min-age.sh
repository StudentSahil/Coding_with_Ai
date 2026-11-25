#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT HUP INT TERM

"${CC:-clang}" -std=gnu23 "$repo_root/src/Filter-By-Min-Age.c" -lm \
  -o "$tmp_dir/filter-by-min-age"

printf 'Alice\n' >"$tmp_dir/missing-age.csv"
printf 'A' >"$tmp_dir/short-line.csv"

for input in "$tmp_dir/missing-age.csv" "$tmp_dir/short-line.csv"; do
  if "$tmp_dir/filter-by-min-age" 18 "$input" \
    >"$tmp_dir/stdout" 2>"$tmp_dir/stderr"; then
    :
  else
    status=$?
    echo "Expected malformed input to exit successfully, got $status." >&2
    cat "$tmp_dir/stderr" >&2
    exit 1
  fi

  if [ -s "$tmp_dir/stdout" ]; then
    echo "Expected malformed input to produce no output." >&2
    cat "$tmp_dir/stdout" >&2
    exit 1
  fi

  if ! grep -Fxq 'Line 1: Age missing.' "$tmp_dir/stderr"; then
    echo "Expected a missing-age diagnostic for $input." >&2
    cat "$tmp_dir/stderr" >&2
    exit 1
  fi
done

printf 'Alice,20\nBob,17\n' >"$tmp_dir/valid.csv"
"$tmp_dir/filter-by-min-age" 18 "$tmp_dir/valid.csv" \
  >"$tmp_dir/stdout" 2>"$tmp_dir/stderr"

if [ "$(cat "$tmp_dir/stdout")" != 'Alice, 20' ]; then
  echo "Valid input was not filtered as expected." >&2
  cat "$tmp_dir/stdout" >&2
  exit 1
fi

if [ -s "$tmp_dir/stderr" ]; then
  echo "Unexpected diagnostic for valid input." >&2
  cat "$tmp_dir/stderr" >&2
  exit 1
fi

echo "Filter-By-Min-Age tests passed."
