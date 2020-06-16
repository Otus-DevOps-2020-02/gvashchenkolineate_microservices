# Tmux cheat sheet

- Start Tmux:

      tmux
      tmux new -s <session name>

- Split pane horizontally:

      Ctrl+b, "

- Switch between horizontally splitted panels:

      Ctrl+b, [ ↑ | ↓ ]

- Start/stop sending command to all panels:

      Ctrl+b, :
      set synchronize-panes on/off

- Detach from a session:

      Ctrl+b, d

- Attach to running session:

      tmux attach -t <session name>

- Get list of tmux sessions:

      tmux ls
      tmux list-sessions

- Rename the session

      Ctrl+b, $
