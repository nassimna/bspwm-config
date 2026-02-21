#!/bin/bash

function run {
  if ! pgrep $1 ;
  then
    $@&
  fi
}

#feh --bg-fill --randomize ./wallpapers* &
feh --bg-fill --randomize ~/.config/bspwm/workmode/wallpapers*

