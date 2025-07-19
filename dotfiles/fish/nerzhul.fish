set -gx PATH /data/data/com.termux.nix/files/home/.nix-profile/bin /data/data/com.termux.nix/files/usr/bin $PATH
status --is-interactive; and begin
    set fish_greeting # Disable greeting

    alias q exit
    alias :Q exit
    alias :q exit
    alias Q exit
    alias e '$EDITOR'
    alias p python
    alias sshserver ''\''/data/data/com.termux.nix/files/home/.nix-profile/bin/sshd'\'' -dD -f ~/nixos/dotfiles/sshd'
    alias sw 'nix-on-droid switch --flake ~/nixos/#nerzhul'

    if test "$TERM" != dumb
        starship init fish | source
    end
end
