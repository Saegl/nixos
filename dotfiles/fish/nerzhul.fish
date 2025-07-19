set -gx PATH /data/data/com.termux.nix/files/home/.nix-profile/bin /data/data/com.termux.nix/files/usr/bin $PATH
set -gx EDITOR nvim

status --is-interactive; and begin
    set fish_greeting # Disable greeting

    alias q exit
    alias :Q exit
    alias :q exit
    alias Q exit
    alias e '$EDITOR'
    alias p python
    alias sshserver ''\''/data/data/com.termux.nix/files/home/.nix-profile/bin/sshd'\'' -dD -f ~/nixos/dotfiles/sshd'
    alias garbage nix-collect-garbage
end

function sw
    cd ~/nixos
    and git pull
    and nix-on-droid switch --flake ~/nixos/#nerzhul
end
