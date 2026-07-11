#!/usr/bin/env bash

set -euo pipefail

panes_file=${1:?panes snapshot required}
session_id=${2:-}

[[ -n $session_id && -f $panes_file ]] || exit 0

awk -F '\t' -v id="$session_id" '
  $1 == id {
    if (!seen || $2 != window) {
      seen = 1
      window = $2
      printf "\n[%s] %s\n", $2, $3
    }
    marker = $5 == "1" ? "*" : " "
    printf "  %s pane %-3s  %-18s %s\n", marker, $4, $6, $7
  }
' "$panes_file"
