#!/usr/bin/env bash

set -euo pipefail

snapshot_dir=${1:?snapshot directory required}
panes_tmp="$snapshot_dir/panes.tmp"
list_tmp="$snapshot_dir/list.tmp"

# One tmux round-trip: pane rows already carry the session fields we summarise.
tmux list-panes -a -F $'#{session_id}\t#{window_index}\t#{window_name}\t#{pane_index}\t#{pane_active}\t#{pane_current_command}\t#{pane_current_path}\t#{session_name}\t#{session_windows}\t#{session_attached}' |
  awk -F '\t' -v panes_tmp="$panes_tmp" -v list_tmp="$list_tmp" '
    {
      printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, $4, $5, $6, $7 >panes_tmp

      if (!($1 in panes)) {
        order[++count] = $1
        name[$1] = $8
        windows[$1] = $9
        attached[$1] = $10
      }
      panes[$1]++
    }
    END {
      for (i = 1; i <= count; i++) {
        id = order[i]
        dot = attached[id] == "0" ? "\033[90m·\033[0m" : "\033[32m●\033[0m"
        printf "%s\t%s %-24s\033[90m%2d win · %2d pane\033[0m\n", id, dot, name[id], windows[id], panes[id] >list_tmp
      }
    }
  '

mv "$panes_tmp" "$snapshot_dir/panes"
mv "$list_tmp" "$snapshot_dir/list"

cat "$snapshot_dir/list"
