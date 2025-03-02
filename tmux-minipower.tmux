#!/usr/bin/env bash

#
# inspiration from wfxr/tmux-power
# attempt to keep simplicity/speed, but boost to tmux-powerline style (albeit hardcoded)
#

# $1: option
# $2: default value
tmux_get() {
    local value
    value="$(tmux show -gqv "$1")"
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

# rlarrow=$(tmux_get '@tmux_minipower_right_light_arrow_icon' '')
# llarrow=$(tmux_get '@tmux_minipower_left_light_arrow_icon' '')

sep="$(tmux_get '@tmux_minipower_separator_icon' '#[dim]•#[nodim]')"
trim="$(tmux_get '@tmux_minipower_trim_icon' "${sep}")"
bell="$(tmux_get '@tmux_minipower_bell_icon' '🔔')"
prev="$(tmux_get '@tmux_minipower_prev_icon' '⤿')"
active="$(tmux_get '@tmux_minipower_active_icon' '🗲')"
zoom="$(tmux_get '@tmux_minipower_zoom_icon' '🔍')"
mark="$(tmux_get '@tmux_minipower_mark_icon' '✓')"
silent="$(tmux_get '@tmux_minipower_silent_icon' '💤')"


day_format=$(tmux_get @tmux_minipower_day_format '%a')
date_format=$(tmux_get @tmux_minipower_date_format '#[dim]%Y-%m-#[nodim]%d')
time_format=$(tmux_get @tmux_minipower_time_format '%H:%M')

# default bg and fg
foreground=$(tmux_get @tmux_minipower_fg_color colour241)
background=$(tmux_get @tmux_minipower_bg_color colour235)

# pane colour
pc=$(tmux_get @tmux_minipower_bg_color colour238)

# theme colour
tc=$(tmux_get @tmux_minipower_theme_color colour23)

# [odd/even][fg/bg] colors for segments
osfg=$(tmux_get @tmux_minipower_odd_segment_fg_color colour255)
osbg=$(tmux_get @tmux_minipower_odd_segment_bg_color colour24)
esfg=$(tmux_get @tmux_minipower_even_segment_fg_color colour0)
esbg=$(tmux_get @tmux_minipower_even_segment_bg_color colour2)

# window status colors (default and current)
wsfg=$(tmux_get @tmux_minipower_window_status_fg_color colour255)
wsbg=$(tmux_get @tmux_minipower_window_status_bg_color colour24)
wcfg=$(tmux_get @tmux_minipower_window_current_fg_color colour0)
wcbg=$(tmux_get @tmux_minipower_window_current_bg_color colour2)

# special color for prefix mode (on current window)
wspfg=$(tmux_get @tmux_minipower_window_current_prefix_fg_color colour0)
wspbg=$(tmux_get @tmux_minipower_window_current_prefix_bg_color colour3)

# me, myself and I
user=$(whoami)

# static weather
if ! command -v bat >/dev/null 2>&1; then
   weather="no weather"
else
   # shellcheck disable=SC2046
   weather="$(openmeteo $(geolocation))"
fi


# Status options
tmux_set status on
tmux_set status-interval 1
tmux_set status-justify centre

# Basic status bar colors
tmux_set status-fg "${foreground}"
tmux_set status-bg "${background}"
tmux_set status-attr none

# whatever, tput cols does not work yet, default-size=80
width=300

# left status
tmux_set status-left-fg "${foreground}"
tmux_set status-left-bg "${background}"
tmux_set status-left-length $((width / 3))

# first segment (#1, hence odd) is session:window.pane and tty for selected pane
BUF="#[fg=${osfg},bg=${osbg}] #S:#I.#P ${sep} #{pane_tty} "
BUF+="#[fg=${osbg},bg=${esbg}]${rarrow}"
# second segment is user name and host
BUF+="#[fg=${esfg},bg=${esbg}] ${user} ${sep} #h "
BUF+="#[fg=${esbg},bg=${osbg}]${rarrow}"
# third segment is working directory
BUF+="#[fg=${osfg},bg=${osbg}] #{=|-$((width / 6))|${trim} :pane_current_path} "
BUF+="#[fg=${osbg},bg=${background}]${rarrow}"
#
tmux_set status-left "${BUF}"

# right status
tmux_set status-right-fg "${foreground}"
tmux_set status-right-bg "${background}"
tmux_set status-right-length $((width / 3))

# first segment is mode information, in readable words
BUF="#[fg=${osbg}]${larrow}"
BUF+="#[fg=${osfg},bg=${osbg}] #{?client_prefix,prefix,normal} #{?mouse,${sep} mouse,} #{?pane_in_mode,${sep} #{s|-mode||:pane_mode},} "
# second segment is weather
BUF+="#[fg=${esbg},bg=${osbg}]${larrow}"
BUF+="#[fg=${esfg},bg=${esbg}] ${weather} "
# third segment is datetime, with highlight on day of week, day of month and time
BUF+="#[fg=${osbg},bg=${esbg}]${larrow}"
BUF+="#[fg=${osfg},bg=${osbg}] ${day_format} ${date_format} ${time_format} "
#
tmux_set status-right "${BUF}"

#
# replace - (previous), # (active), Z (zoomed), M (marked), ~ (inactive) and ! (bell) with symbols
#
icons() {
   # S1 is fg colour to return to if switched (like for bell)
   # take out active indicator, colour is used for that
   echo "#{?#{==:#{window_flags},"*"},,#{?window_flags, #{s/[*]//:#{s/["'!'"]/#[fg=red]${bell}#[fg=$1]/:#{s/-/${prev}/:#{s/#/${active}/:#{s/Z/${zoom}/:#{s/M/${mark}/:#{s/~/${silent}/:window_flags}}}}}}},}}"
}

#
# insert $1 or $2 based on window begin active, and client prefix active
#
acp() {
   echo "#{?#{&&:#{window_active},#{client_prefix}},$1,$2}"
}

#
# different color for generic status, and current
# current becomes highlighted in prefix mode
#
windowsegment() {
   local current=$1 fg bg
   if [[ $current == "true" ]] ; then
      fg=${wcfg}
      bg=${wcbg}
   else
      fg=${wsfg}
      bg=${wsbg}
   fi
   # left curving side for first window in list
   BUF="#{?window_start_flag,$(acp "#[fg=${wspbg}]" "#[fg=${bg}]")${larrow},}"
   # extra space when not first in list: number, icons and name
   BUF+="$(acp "#[fg=${wspfg}]#[bg=${wspbg}]" "#[fg=${fg}]#[bg=${bg}]")#{?window_start_flag,, }#I$(icons "${fg}") ${sep} #W "
   # right curving side for last window in list
   BUF+="#{?window_end_flag,$(acp "#[fg=${wspbg}],#[fg=${bg}]" "#[fg=${bg}]")#[bg=${background}]${rarrow},}"

   echo "${BUF}"
}

#
# regular (non current window format)
#
tmux_set window-status-format         "$(windowsegment false)"
tmux_set window-status-current-format "$(windowsegment true)"

# Window status style, just set to null, because handled inline
tmux_set window-status-style          ""
tmux_set window-status-current-style  ""
tmux_set window-status-last-style     ""
tmux_set window-status-bell-style     ""
tmux_set window-status-activity-style ""

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
tmux_set message-style "fg=${osfg},bg=${background}"

# Command message
tmux_set message-command-style "fg=${osfg},bg=${background}"

# Copy mode highlight
tmux_set mode-style "bg=${tc},fg=${osfg}"
