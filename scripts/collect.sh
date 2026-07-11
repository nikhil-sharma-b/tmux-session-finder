#!/usr/bin/env bash

set -euo pipefail

snapshot_dir=${1:?snapshot directory required}
sessions_tmp="$snapshot_dir/sessions.tmp"
panes_tmp="$snapshot_dir/panes.tmp"
list_tmp="$snapshot_dir/list.tmp"

tmux list-sessions -F $'#{session_id}\t#{session_name}\t#{session_windows}\t#{session_attached}\t#{t:session_created}' >"$sessions_tmp"
tmux list-panes -a -F $'#{session_id}\t#{window_index}\t#{window_name}\t#{pane_index}\t#{pane_active}\t#{pane_current_command}\t#{pane_current_path}' >"$panes_tmp"

awk -F '\t' '
  NR == FNR { panes[$1]++; next }
  {
    dot = $4 == "0" ? "\033[90m·\033[0m" : "\033[32m●\033[0m"
    printf "%s\t%s %-24s\033[90m%2d win · %2d pane\033[0m\n", $1, dot, $2, $3, panes[$1] + 0
  }
' "$panes_tmp" "$sessions_tmp" >"$list_tmp"

mv "$panes_tmp" "$snapshot_dir/panes"
mv "$list_tmp" "$snapshot_dir/list"
rm -f "$sessions_tmp"

cat "$snapshot_dir/list"
