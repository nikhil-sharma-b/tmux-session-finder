#!/usr/bin/env bash

set -euo pipefail

printf '\nNew session name: '
IFS= read -r name

if [[ -z $name ]]; then
  printf 'Session name cannot be empty.\n'
  sleep 1
  exit 0
fi

if tmux has-session -t "=$name" 2>/dev/null; then
  printf 'Session already exists: %s\n' "$name"
  sleep 1
  exit 0
fi

current_path=$(tmux display-message -p '#{pane_current_path}')

if tmux new-session -d -s "$name" -c "$current_path"; then
  tmux switch-client -t "=$name"
  tmux display-popup -C
fi
