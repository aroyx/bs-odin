#!/bin/bash

# for my personal use, use it if you need it :)

Split=""
SessionName="HandMadeHero"

if [[ $1 ]]; then
    Split="$1"
fi

if [[ $2 ]]; then
    SessionName="$2"
fi

tmux new-session -d -s "$SessionName" -n "Neovim" nvim

if [[ "$Split" == "" ]]; then
    tmux new-window -d -t "$SessionName" -n "Build"
elif [[ "$Split" == "v" ]]; then
    tmux split-window -h
elif [[ "$Split" == "h" ]]; then
    tmux split-window -v
elif [[ "$Split" == "n" ]]; then
    tmux new-window -n "Build"
fi

tmux select-window -t "$SessionName:Neovim"
tmux attach -t "$SessionName"
