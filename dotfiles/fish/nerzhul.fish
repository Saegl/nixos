set -gx PATH /data/data/com.termux.nix/files/home/.nix-profile/bin /data/data/com.termux.nix/files/usr/bin $PATH
status --is-interactive; and begin
    set fish_greeting # Disable greeting

    alias :Q exit
    alias :q exit
    alias Q exit
    alias e '$EDITOR'
    alias p python
    alias q exit
    alias sshserver ''\''/data/data/com.termux.nix/files/home/.nix-profile/bin/sshd'\'' -dD -f ~/nixos/hosts/nerzhul/sshd'
    alias sw 'nix-on-droid switch --flake ~/nixos/#nerzhul'
end
