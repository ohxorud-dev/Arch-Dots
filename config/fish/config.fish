if status is-interactive
    # Commands to run in interactive sessions can go here
end

starship init fish | source

alias waybar-reload="killall waybar; nohup waybar &"
alias l="ls -al"