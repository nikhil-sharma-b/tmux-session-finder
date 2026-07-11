#!/usr/bin/env bash

set -euo pipefail

session_id=${1:-}
[[ -n $session_id ]] || exit 0

session_count=$(tmux list-sessions -F '#{session_id}' | awk 'END { print NR }')
if (( session_count <= 1 )); then
  printf '\nCannot kill only remaining session.\n'
  sleep 1
  exit 0
fi

name=$(tmux display-message -p -t "$session_id" '#{session_name}')
printf '\nKill session "%s"? [y/N] ' "$name"
IFS= read -r answer

case $answer in
  y|Y|yes|YES)
    tmux kill-session -t "$session_id"
    ;;
esac
