#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
real_tmux=$(command -v tmux)
socket_name="session-finder-test-$$"
tmp_dir=$(mktemp -d "${TMPDIR:-/tmp}/session-finder-test.XXXXXX")

cleanup() {
  "$real_tmux" -L "$socket_name" kill-server 2>/dev/null || true
  rm -rf "$tmp_dir"
}
trap cleanup EXIT INT TERM

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

"$real_tmux" -L "$socket_name" -f /dev/null new-session -d -s 'work api' -n editor 'exec sleep 60'
"$real_tmux" -L "$socket_name" new-window -d -t '=work api:' -n server 'exec sleep 60'
"$real_tmux" -L "$socket_name" new-session -d -s docs -n shell 'exec sleep 60'
socket_path=$("$real_tmux" -L "$socket_name" display-message -p -t docs '#{socket_path}')

export TMUX="$socket_path,0,0"
export REAL_TMUX=$real_tmux
export TMUX_CALL_LOG="$tmp_dir/tmux-calls"
export PATH="$repo_dir/tests/bin:$PATH"
: >"$TMUX_CALL_LOG"

"$repo_dir/scripts/collect.sh" "$tmp_dir" >"$tmp_dir/output"

call_count=$(awk 'END { print NR }' "$TMUX_CALL_LOG")
[[ $call_count == 2 ]] || fail "snapshot used $call_count tmux calls, expected 2"

awk -F '\t' '$2 == "work api" && $3 == "2w" && $4 == "2p" { found=1 } END { exit !found }' \
  "$tmp_dir/output" || fail 'session aggregation incorrect'

work_id=$(awk -F '\t' '$2 == "work api" { print $1 }' "$tmp_dir/output")
preview=$("$repo_dir/scripts/preview.sh" "$tmp_dir/panes" "$work_id")
[[ $preview == *'[0] editor'* ]] || fail 'editor window absent from preview'
[[ $preview == *'[1] server'* ]] || fail 'server window absent from preview'
[[ $preview == *'sleep'* ]] || fail 'foreground command absent from preview'

for script in "$repo_dir"/*.tmux "$repo_dir"/scripts/*.sh "$repo_dir"/tests/*.sh "$repo_dir"/tests/bin/*; do
  bash -n "$script" || fail "syntax error in $script"
done

printf 'PASS: snapshot, aggregation, preview, query count, syntax\n'
