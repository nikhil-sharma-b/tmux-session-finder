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
popup_style=$(tmux_option '@session-finder-popup-style' 'bg=default,fg=default')

# Passing the command as more than one argument makes tmux exec it directly
# instead of running it through default-shell, which skips shell startup cost.
tmux bind-key "$key" display-popup -T "$title" -E \
  -d / \
  -w "$width" \
  -h "$height" \
  -b rounded \
  -S "$border" \
  -s "$popup_style" \
  "$plugin_dir/scripts/finder.sh" "$plugin_dir/scripts"
