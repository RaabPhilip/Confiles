if status is-interactive
    # Commands to run in interactive sessions can go here
end

export PYTHONPATH="/usr/include/mgba:$PYTHONPATH"

export PATH="$PATH:$HOME/.dotnet/tools"

export BROWSER="/usr/bin/zen-browser"

abbr --add cls clear
abbr --add mkd mkdir
abbr --add rmd rmdir
abbr --add ls 'eza --icons'
abbr --add ll 'eza --icons -l'
abbr --add la 'eza --icons -a -l'
abbr --add reboot 'systemctl reboot'
abbr --add shutdown 'systemctl poweroff'
abbr --add poweroff 'systemctl poweroff'
abbr --add nggc 'ng generate component'
abbr --add nggs 'ng generate service'
abbr --add gita 'git add .'
abbr --add gitc 'git commit -m'
abbr --add zen zen-browser
abbr --add zed zeditor
abbr --add zed. zeditor .
abbr --add touchpad 'hyprctl -r -- keyword device[syna32b3:01-06cb:ce7d-touchpad]:enabled'
abbr --add ff 'clear; fastfetch'

set fish_greeting ""
fastfetch

zoxide init fish --cmd cd | source

set -x GOOGLE_CLOUD_PROJECT "gemini-cli-pipo"
set -x EDITOR 'zeditor'
set -x VISUAL 'zeditor'
set -x TERMINAL 'alacritty'

function bind_bang
    switch (commandline -t)[-1]
        case "!"
            commandline -t -- $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function bind_dollar
    switch (commandline -t)[-1]
        case "!"
            commandline -f backward-delete-char history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

function fish_user_key_bindings
    bind ! bind_bang
    bind '$' bind_dollar
end


function webstorm
    nohup webstorm $argv >/dev/null 2>&1 & disown
end
function idea
    nohup idea $argv >/dev/null 2>&1 & disown
end
function rider
    nohup rider $argv >/dev/null 2>&1 & disown
end
function pycharm
    nohup pycharm $argv >/dev/null 2>&1 & disown
end
function datagrip
    nohup datagrip $argv >/dev/null 2>&1 & disown
end
function discord
    nohup discord $argv >/dev/null 2>&1 & disown
end
function studio
    nohup studio $argv >/dev/null 2>&1 & disown
end

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
# if test -f /home/pipo/miniconda3/bin/conda
#     eval /home/pipo/miniconda3/bin/conda "shell.fish" "hook" $argv | source
# else
#     if test -f "/home/pipo/miniconda3/etc/fish/conf.d/conda.fish"
#         . "/home/pipo/miniconda3/etc/fish/conf.d/conda.fish"
#     else
#         set -x PATH "/home/pipo/miniconda3/bin" $PATH
#     end
# end
# <<< conda initialize <<<


function spf
    set os $(uname -s)

    if test "$os" = "Linux"
        set spf_last_dir "$HOME/.local/state/superfile/lastdir"
    end

    if test "$os" = "Darwin"
        set spf_last_dir "$HOME/Library/Application Support/superfile/lastdir"
    end

    command spf $argv

    if test -f "$spf_last_dir"
        source "$spf_last_dir"
        rm -f -- "$spf_last_dir" >> /dev/null
    end
end

function kubebld
    # Set the minikube target-docker-env to your local docker-env
    eval $(minikube -p minikube docker-env)
    # Build and 'deploy' the container locally
    mvn clean install -Dquarkus.container-image.build=true
end

function charging
    switch $argv[1]
        case "on"
            adb shell dumpsys battery reset
        case "off"
            adb shell dumpsys battery unplug
    end
end
