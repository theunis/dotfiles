show_jupyter() {
  local index icon color text module connection_string

  index=$1 # This variable is used internally by the module loader in order to know the position of this module

  icon="$(get_tmux_option "@catppuccin_jupyter_icon" "󰠮" )"
  color="$(get_tmux_option "@catppuccin_jupyter_color" "$thm_cyan")"
  text="$(get_tmux_option "@catppuccin_jupyter_text" "#(cat /tmp/jupyter_connection_#{pane_id} 2>/dev/null | xargs basename || echo 'No Jupyter connection')")"

  module=$(build_status_module "$index" "$icon" "$color" "$text")
  echo $module
}
