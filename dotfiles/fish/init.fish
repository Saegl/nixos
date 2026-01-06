set -gx PATH $HOME/.cargo/bin $PATH

status is-interactive; and begin
    set fish_greeting # Disable greeting

    alias q exit
    alias :Q exit
    alias :q exit
    alias Q exit
    alias e '$EDITOR'
    alias ga 'git add'
    alias gc 'git commit'
    alias gd 'git diff'
    alias ghb 'gh browse'
    alias gs 'git status'
    alias gui 'nohup neovide & disown ; exit'
    alias p python
    alias pkg 'nix-shell --run fish -p'
    alias nix-fish 'nix-shell --run fish'
    alias pt pytest
    alias setld 'set -x LD_LIBRARY_PATH /run/opengl-driver/lib:$NIX_LD_LIBRARY_PATH'
    alias setldcuda 'set -x LD_LIBRARY_PATH $LD_LIBRARY_PATH $CUDA_PATH/lib $CUDNN_PATH/lib'
    alias sf 'nvim -c '\''Telescope find_files'\'''
    alias unsetld 'set -u LD_LIBRARY_PATH'
    alias vimdiff 'nvim -d'

    zoxide init fish | source

    if test "$TERM" != dumb
        starship init fish | source
    end

    direnv hook fish | source

    set TRASH "$HOME/.local/share/Trash"
end

# Unbloated login manager
if status is-interactive; and status is-login; and test -z "$DISPLAY"; and test (tty) = "/dev/tty1"
  niri-session
end

if status is-interactive;
    set DOTFILES "$HOME/projects/nix/nixos/dotfiles"

    if not functions -q dotlink
        function dotlink
            set target $argv[1]
            set source $argv[2]
            if not test -L $target; or test (readlink $target) != $source
                mkdir -p (dirname $target)
                ln -sf $source $target
            end
        end
    end

    ## Bootstrap 
    # ln -sf ~/projects/nix/nixos/dotfiles/fish/init.fish ~/.config/fish/conf.d/init.fish

    dotlink ~/.config/fnott/fnott.ini "$DOTFILES/fnott/fnott.ini"
    # dotlink ~/.config/foot/foot.ini "$DOTFILES/foot/foot.ini"
    dotlink ~/.config/foot "$DOTFILES/foot"
    dotlink ~/.config/kitty/kitty.conf "$DOTFILES/kitty/kitty.conf"
    dotlink ~/.unison/shared.prf "$DOTFILES/unison/shared.prf"
    dotlink ~/.config/starship.toml "$DOTFILES/starship/starship.toml"
    dotlink ~/.config/yazi/yazi.toml "$DOTFILES/yazi/yazi.toml"
    dotlink ~/.config/river/init "$DOTFILES/river/init"
    dotlink ~/.config/fish/conf.d/init.fish "$DOTFILES/fish/init.fish"
    dotlink ~/.config/git/config "$DOTFILES/git/config"

    dotlink ~/.local/share/applications/cutechess-xwayland.desktop "$DOTFILES/desktop/cutechess-xwayland.desktop"
    dotlink ~/.local/share/applications/ghidra-patched.desktop "$DOTFILES/desktop/ghidra-patched.desktop"
    dotlink ~/.local/share/applications/org.radare.iaito.desktop "$DOTFILES/desktop/org.radare.iaito.desktop"
    dotlink ~/.local/share/applications/kitty.finflow.desktop "$DOTFILES/desktop/kitty.finflow.desktop"
    dotlink ~/.local/share/applications/mongodb-compass.desktop "$DOTFILES/desktop/mongodb-compass.desktop"
    dotlink ~/.local/share/applications/zen-browser.desktop "$DOTFILES/desktop/zen-browser.desktop"

    dotlink ~/.config/gtk-3.0/settings.ini "$DOTFILES/gtk-3.0/settings.ini"
    dotlink ~/.config/gtk-4.0/settings.ini "$DOTFILES/gtk-4.0/settings.ini"

    dotlink ~/.config/waybar/config.jsonc "$DOTFILES/waybar/config.jsonc"
    dotlink ~/.config/waybar/style.css "$DOTFILES/waybar/style.css"
    dotlink ~/.config/waybar/style_minimal.css "$DOTFILES/waybar/style_minimal.css"

    dotlink ~/.config/nvim "$DOTFILES/nvim"
    dotlink ~/.config/niri "$DOTFILES/niri"
end

function flac2opus
    for f in *.flac
        set newname (string replace -r '^\d+\s*' '' "$f")
        set newname (string replace -r '\.flac$' '.opus' "$newname")
        opusenc "$f" "$newname"
    end
end

function view_ld
    for p in $LD_LIBRARY_PATH
        echo $p
    end
end

function echoeach
    for p in $argv
        echo $p
    end
end

function clear_trash
    echo "Clearing trash..."
    rm -rf ~/.local/share/Trash/files/*
    rm -rf ~/.local/share/Trash/info/*
    echo "Complete"
end
