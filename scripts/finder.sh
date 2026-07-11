#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! command -v fzf >/dev/null 2>&1; then
  printf 'tmux-session-finder requires fzf.\n'
  sleep 2
  exit 1
fi

snapshot_dir=$(mktemp -d "${TMPDIR:-/tmp}/tmux-session-finder.XXXXXX")
trap 'rm -rf "$snapshot_dir"' EXIT INT TERM

"$script_dir/collect.sh" "$snapshot_dir" >/dev/null

export TMUX_SESSION_FINDER_SCRIPTS=$script_dir
export TMUX_SESSION_FINDER_SNAPSHOT=$snapshot_dir

fzf \
  --ansi \
  --delimiter=$'\t' \
  --with-nth='2..' \
  --no-multi \
  --layout=reverse \
  --border=none \
  --no-scrollbar \
  --separator=' ' \
  --pointer='▌' \
  --marker=' ' \
  --color='fg:-1,bg:-1,hl:4,fg+:-1:regular,bg+:-1,hl+:12,info:8,prompt:8,pointer:4,marker:4,spinner:8,header:8,border:8,gutter:-1' \
  --info=hidden \
  --prompt='  ' \
  --header='↵ switch · ^n new · ^x kill · ^r refresh · esc' \
  --header-first \
  --padding='1,2' \
  --preview='"$TMUX_SESSION_FINDER_SCRIPTS/preview.sh" "$TMUX_SESSION_FINDER_SNAPSHOT/panes" {1}' \
  --preview-window='right,55%,border-left' \
  --bind='enter:execute-silent(tmux switch-client -t {1})+abort' \
  --bind='ctrl-n:execute("$TMUX_SESSION_FINDER_SCRIPTS/create.sh")+reload("$TMUX_SESSION_FINDER_SCRIPTS/collect.sh" "$TMUX_SESSION_FINDER_SNAPSHOT")' \
  --bind='ctrl-x:execute("$TMUX_SESSION_FINDER_SCRIPTS/kill.sh" {1})+reload("$TMUX_SESSION_FINDER_SCRIPTS/collect.sh" "$TMUX_SESSION_FINDER_SNAPSHOT")' \
  --bind='ctrl-r:reload("$TMUX_SESSION_FINDER_SCRIPTS/collect.sh" "$TMUX_SESSION_FINDER_SNAPSHOT")' \
  <"$snapshot_dir/list" >/dev/null
