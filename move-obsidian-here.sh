#!/bin/bash
obsidian_window_id=$(aerospace list-windows --monitor all --app-id md.obsidian | awk '{print $1}')
current_workspace_id=$(aerospace list-workspaces --focused)

aerospace focus --window-id $obsidian_window_id
obsidian_workspace_id=$(aerospace list-workspaces --focused)

aerospace move-node-to-workspace $current_workspace_id
aerospace workspace $current_workspace_id
aerospace focus --window-id $obsidian_window_id
aerospace resize width 800
