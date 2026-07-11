#!/usr/bin/env bash

set -eu

plugin_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

tmux_option() {
  local option=$1
  local fallback=$2
  local value

  value=$(tmux show-option -gqv "$option")
  printf '%s' "${value:-$fallback}"
}

key=$(tmux_option '@session-finder-key' 'F')
width=$(tmux_option '@session-finder-width' '85%')
height=$(tmux_option '@session-finder-height' '80%')
border=$(tmux_option '@session-finder-border-style' 'fg=colour240')

tmux bind-key "$key" display-popup -E \
  -w "$width" \
  -h "$height" \
  -b rounded \
  -S "$border" \
  "$plugin_dir/scripts/finder.sh"
