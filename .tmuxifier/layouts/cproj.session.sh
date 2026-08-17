if initialize_session "cproj"; then
  window_root "$PWD"

  new_window "vim"

  split_h 30
  run_cmd "lg"

  split_v 3
  run_cmd "cava"

  new_window "cmake"

  new_window "gdb"

  new_window "zsh"

  select_window 0

  select_pane 0
  run_cmd "vim"
fi

finalize_and_go_to_session
