#!/usr/bin/env bash

set -euo pipefail

panes_file=${1:?panes snapshot required}
session_id=${2:-}

[[ -n $session_id && -f $panes_file ]] || exit 0

awk -F '\t' -v id="$session_id" -v home="$HOME" '
  $1 == id {
    if (!seen || $2 != window) {
      if (seen) printf "\n"
      seen = 1
      window = $2
      printf "\033[1m%s\033[0m \033[90m· window %s\033[0m\n", $3, $2
    }
    path = $7
    if (index(path, home) == 1) path = "~" substr(path, length(home) + 1)
    mark = $5 == "1" ? "\033[34m›\033[0m" : " "
    printf "  %s %-14s \033[90m%s\033[0m\n", mark, $6, path
  }
' "$panes_file"
