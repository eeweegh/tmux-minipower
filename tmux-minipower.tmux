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

session_icon="$(tmux_get '@tmux_minipower_session_icon' '')"
user_icon="$(tmux_get '@tmux_minipower_user_icon' '')"
time_icon="$(tmux_get '@tmux_minipower_time_icon' '')"
date_icon="$(tmux_get '@tmux_minipower_date_icon' '')"
trim_icon="$(tmux_get '@tmux_minipower_trim_icon' '•')"

day_format=$(tmux_get @tmux_minipower_day_format '%a')
date_format=$(tmux_get @tmux_minipower_date_format '%F')
time_format=$(tmux_get @tmux_minipower_time_format '%H:%M')

TC='#87ceeb'


G01=colour232
G02=colour233
G03=colour234
G04=colour235
G05=colour236
G06=colour237
G07=colour238
G08=colour239
G09=colour240
G10=colour241
G11=colour242
G12=colour243

FG=colour241
BG=colour235

# Status options
tmux_set status-interval 1
tmux_set status on

# Basic status bar colors
tmux_set status-fg "$FG"
tmux_set status-bg "$BG"
tmux_set status-attr none


#     
# Left side of status bar
tmux_set status-left-bg "$G04"
tmux_set status-left-fg "$G12"
tmux_set status-left-length 150
LS="#[fg=colour255,bg=colour24] #S:#I.#P #[fg=colour24,bg=colour2]${rarrow}"
LS+="#[fg=colour232,bg=colour2] #h #[fg=colour2,bg=colour24]${rarrow}"
LS+="#[fg=colour255,bg=colour24] #{=|-40|${trim_icon} :pane_current_path} #[fg=colour24,bg=$BG]${rarrow}"
tmux_set status-left "$LS"

# Right side of status bar
tmux_set status-right-bg "$BG"
tmux_set status-right-fg "$G12"
tmux_set status-right-length 150
RS="#[fg=colour24]${larrow}#[fg=colour255,bg=colour24] #{?client_prefix,Prefix,Normal} #{?mouse,${trim_icon} Mouse,} #{?pane_in_mode,${trim_icon} #{pane_mode},} "
RS+="#[fg=colour2,bg=colour24]${larrow}#[fg=colour232,bg=colour2] weather "
RS+="#[fg=colour24,bg=colour2]${larrow}#[fg=colour255,bg=colour24] ${day_format} ${date_format} ${time_format} "
tmux_set status-right "$RS"

# Window status format
tmux_set window-status-format         "#[fg=$BG,bg=$G06]$rarrow#[fg=$TC,bg=$G06] #I:#W #[fg=$G06,bg=$BG]$rarrow"
tmux_set window-status-current-format "#[fg=$BG,bg=$TC]$rarrow#[fg=$BG,bg=$TC] #I:#W #[fg=$TC,bg=$BG]$rarrow"

# Window status style
tmux_set window-status-style          "fg=$TC,bg=$BG,none"
tmux_set window-status-last-style     "fg=$TC,bg=$BG"
tmux_set window-status-activity-style "fg=$TC,bg=$BG"

# Window separator
tmux_set window-status-separator ""

# Pane border
tmux_set pane-border-style "fg=$G07,bg=default"

# Active pane border
tmux_set pane-active-border-style "fg=$TC,bg=default"

# Pane number indicator
tmux_set display-panes-colour "$G07"
tmux_set display-panes-active-colour "$TC"

# Clock mode
tmux_set clock-mode-colour "$TC"
tmux_set clock-mode-style 24

# Message
tmux_set message-style "fg=$TC,bg=$BG"

# Command message
tmux_set message-command-style "fg=$TC,bg=$BG"

# Copy mode highlight
tmux_set mode-style "bg=$TC,fg=$FG"
