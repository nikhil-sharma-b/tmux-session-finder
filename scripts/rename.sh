#!/usr/bin/env bash

set -euo pipefail

session_id=${1:-}
[[ -n $session_id ]] || exit 0

current_name=$(tmux display-message -p -t "$session_id" '#{session_name}')
printf '\nRename session "%s" to: ' "$current_name"
IFS= read -r name

if [[ -z $name ]]; then
  printf 'Session name cannot be empty.\n'
  sleep 1
  exit 0
fi

if [[ $name != "$current_name" ]] && tmux has-session -t "=$name" 2>/dev/null; then
  printf 'Session already exists: %s\n' "$name"
  sleep 1
  exit 0
fi

tmux rename-session -t "$session_id" "$name"
