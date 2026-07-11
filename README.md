# tmux-session-finder

Fast fuzzy tmux session switcher in a floating popup. It shows every session and previews each pane's foreground command and working directory.

## Requirements

- tmux 3.2 or newer (`display-popup` support)
- fzf
- Bash

## Install with TPM

Add this plugin to `.tmux.conf`:

```tmux
set -g @plugin 'nikhil-sharma-b/tmux-session-finder'
```

Press `prefix + I` to install it, then press `prefix + F` to open the finder.

For a local checkout:

```tmux
run-shell '~/repos/tmux-session-finder/tmux-session-finder.tmux'
```

Reload tmux config after changing installation settings.

## Controls

- Type to fuzzy-search session names and metadata.
- `Enter`: switch to selected session.
- `Ctrl-n`: create a named session and switch to it.
- `Ctrl-x`: confirm and kill selected session.
- `Ctrl-r`: refresh snapshot.
- `Esc`: close popup.

Killing the only remaining session is blocked.

## Configuration

Set options before loading the plugin:

```tmux
set -g @session-finder-key 'F'
set -g @session-finder-width '80%'
set -g @session-finder-height '70%'
set -g @session-finder-border-style 'fg=brightblack'
set -g @session-finder-title ''
```

The finder uses ANSI terminal colors rather than fixed RGB values, so accents follow the active terminal theme.

## Performance

Each refresh uses exactly two tmux queries: one for all sessions and one for all panes. Results are aggregated once into a snapshot. Searching and moving selection use the snapshot and issue no tmux queries.

Refresh occurs only when opening the finder, pressing `Ctrl-r`, or completing a create/kill action.

## Test

Tests use a separate tmux server and do not touch active sessions:

```sh
./tests/run.sh
```
