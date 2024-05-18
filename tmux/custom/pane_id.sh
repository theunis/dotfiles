# This module shows the pane_id in the status bar.

show_pane_id() {
  local index icon color text module

  index=$1 # This variable is used internally by the module loader in order to know the position of this module

  icon="$(  get_tmux_option "@catppuccin_pane_id_icon"  ""           )"
  color="$( get_tmux_option "@catppuccin_pane_id_color" "$thm_cyan"   )"
  text="$(  get_tmux_option "@catppuccin_pane_id_text"  "#{pane_id}"  )"

  module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}

