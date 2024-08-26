#!/usr/bin/env bash

#
# initial copy from wfxr/tmux-power
# attempt to keep simplicity, but boost to tmux-powerline style (albeit hardcoded)
#

# $1: option
# $2: default value
tmux_get() {
    local value="$(tmux show -gqv "$1")"
    [ -n "$value" ] && echo "$value" || echo "$2"
}

# $1: option
# $2: value
tmux_set() {
    tmux set-option -gq "$1" "$2"
}

# Options
rarrow=$(tmux_get '@tmux_minipower_right_arrow_icon' '')
larrow=$(tmux_get '@tmux_minipower_left_arrow_icon' '')
rlarrow=$(tmux_get '@tmux_minipower_right_light_arrow_icon' '')
llarrow=$(tmux_get '@tmux_minipower_left_light_arrow_icon' '')

trim="$(tmux_get '@tmux_minipower_trim_icon' '•')"
sep="$(tmux_get '@tmux_minipower_separator_icon' '•')"

day_format=$(tmux_get @tmux_minipower_day_format '%a')
date_format=$(tmux_get @tmux_minipower_date_format '%F')
time_format=$(tmux_get @tmux_minipower_time_format '%H:%M')

# default bg and fg
fg=$(tmux_get @tmux_minipower_fg_color colour241)
bg=$(tmux_get @tmux_minipower_bg_color colour235)

# pane colour
pc=$(tmux_get @tmux_minipower_bg_color colour238)

# theme colour
tc=$(tmux_get @tmux_minipower_bg_color colour23)

# [odd/even][fg/bg] colors for segments
ofgc=$(tmux_get @tmux_minipower_odd_segment_fg_color colour255)
efgc=$(tmux_get @tmux_minipower_even_segment_fg_color colour0)
obgc=$(tmux_get @tmux_minipower_odd_segment_bg_color colour24)
ebgc=$(tmux_get @tmux_minipower_even_segment_bg_color colour2)

user=$(whoami)

# Status options
tmux_set status on
tmux_set status-interval 1
tmux_set status-justify centre

# Basic status bar colors
tmux_set status-fg "${fg}"
tmux_set status-bg "${bg}"
tmux_set status-attr none

# whatever, tput cols does not work yet, default-size=80
width=300

# left status
tmux_set status-left-bg "${bg}"
tmux_set status-left-fg "${fg}"
tmux_set status-left-length $(($width / 3))
BUF="#[fg=${ofgc},bg=${obgc}] #S:#I.#P ${sep} #{pane_tty}#[fg=${obgc},bg=${ebgc}]${rarrow}"
BUF+="#[fg=${efgc},bg=${ebgc}] ${user}, #h #[fg=${ebgc},bg=${obgc}]${rarrow}"
BUF+="#[fg=${ofgc},bg=${obgc}] #{=|-$(($width / 6))|${trim} :pane_current_path} #[fg=${obgc},bg=${bg}]${rarrow}"
tmux_set status-left "$BUF"

# right status
tmux_set status-right-bg "${bg}"
tmux_set status-right-fg "${fg}"
tmux_set status-right-length $(($width / 3))
BUF="#[fg=${obgc}]${larrow}#[fg=${ofgc},bg=${obgc}] #{?client_prefix,prefix,normal} #{?mouse,${sep} mouse,} #{?pane_in_mode,${sep} #{s|-mode||:pane_mode},} "
BUF+="#[fg=${ebgc},bg=${obgc}]${larrow}#[fg=${efgc},bg=${ebgc}] weather "
BUF+="#[fg=${obgc},bg=${ebgc}]${larrow}#[fg=${ofgc},bg=${obgc}] ${day_format} ${date_format} ${time_format} "
tmux_set status-right "$BUF"

# Window status format
BUF="#[fg=${obgc},bg=${bg}] #I#{?window_flags,#{s/[*]//:window_flags},} ${sep} #W "
tmux_set window-status-format "$BUF"
BUF="#[fg=${bg},bg=${obgc}]$rarrow#[fg=${ofgc}] #I#{s/[!]/DING!/:window_flags} ${sep} #W #[fg=${obgc},bg=${bg}]$rarrow"
tmux_set window-status-current-format "$BUF"

# Window status style
tmux_set window-status-style          "fg=${tc},bg=${bg},none"
tmux_set window-status-last-style     "fg=${tc},bg=${bg}"
tmux_set window-status-activity-style "fg=${tc},bg=${bg}"

# Window separator
tmux_set window-status-separator ""

# Pane border
tmux_set pane-border-style "fg=${pc},bg=default"

# Active pane border
tmux_set pane-active-border-style "fg=${tc},bg=default"

# Pane number indicator
tmux_set display-panes-colour "${pc}"
tmux_set display-panes-active-colour "${tc}"

# Clock mode
tmux_set clock-mode-colour "${tc}"
tmux_set clock-mode-style 24

# Message
tmux_set message-style "fg=${tc},bg=${bg}"

# Command message
tmux_set message-command-style "fg=${tc},bg=${bg}"

# Copy mode highlight
tmux_set mode-style "bg=${tc},fg=${fg}"
