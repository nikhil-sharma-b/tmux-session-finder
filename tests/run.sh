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

strip_ansi() {
  awk '{ gsub(/\033\[[0-9;]*m/, ""); print }'
}

plain_output=$(strip_ansi <"$tmp_dir/output")
awk -F '\t' '$2 ~ /work api/ && $2 ~ /2 win/ && $2 ~ /2 pane/ { found=1 } END { exit !found }' \
  <<<"$plain_output" || fail 'session aggregation incorrect'

work_id=$(awk -F '\t' '$2 ~ /work api/ { print $1 }' <<<"$plain_output")
preview=$("$repo_dir/scripts/preview.sh" "$tmp_dir/panes" "$work_id" | strip_ansi)
[[ $preview == *'editor · window 0'* ]] || fail 'editor window absent from preview'
[[ $preview == *'server · window 1'* ]] || fail 'server window absent from preview'
[[ $preview == *'sleep'* ]] || fail 'foreground command absent from preview'

"$repo_dir/tmux-session-finder.tmux"
binding=$("$real_tmux" -L "$socket_name" list-keys -T prefix F)
[[ $binding == *'display-popup'* && $binding == *'-d /'* ]] || \
  fail 'finder popup does not use a neutral working directory'

for script in "$repo_dir"/*.tmux "$repo_dir"/scripts/*.sh "$repo_dir"/tests/*.sh "$repo_dir"/tests/bin/*; do
  bash -n "$script" || fail "syntax error in $script"
done

printf 'PASS: snapshot, aggregation, preview, query count, popup cwd, syntax\n'
