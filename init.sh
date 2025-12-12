#!/bin/bash
nvim_config_dir="$HOME/.config/nvim"
curr_dir=$(realpath $(dirname "$0"))
mkdir -p $nvim_config_dir

ln -s "$curr_dir/init.lua" "$nvim_config_dir/init.lua"
ln -s "$curr_dir/lua" "$nvim_config_dir/lua"
