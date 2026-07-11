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
width=$(tmux_option '@session-finder-width' '80%')
height=$(tmux_option '@session-finder-height' '70%')
border=$(tmux_option '@session-finder-border-style' 'fg=brightblack')
title=$(tmux_option '@session-finder-title' '')

tmux bind-key "$key" display-popup -T "$title" -E \
  -w "$width" \
  -h "$height" \
  -b rounded \
  -S "$border" \
  "$plugin_dir/scripts/finder.sh"
