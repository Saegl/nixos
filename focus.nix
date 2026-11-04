# Distraction-free `focus` user: log in on tty2 (saegl keeps tty1).
# Only the apps below are installed for it, distracting sites are dropped at
# the firewall for its uid, and it sees ~/ff = saegl's ~/projects/ff.
{
  pkgs,
  lib,
  config,
  ...
}: let
  blockedSites = [
    "x.com"
    "twitter.com"
    "twimg.com"
    "lobste.rs"
    "news.ycombinator.com"
    "reddit.com"
    "redd.it"
    "youtube.com"
    "youtu.be"
    "googlevideo.com"
    "instagram.com"
    "facebook.com"
    "tiktok.com"
    "twitch.tv"
  ];

  # helium, neovim, git, niri come from programs.* system-wide
  focusPackages = with pkgs; [
    kitty # terminal
    fuzzel # launcher
    wl-clipboard
    uv # python venvs in ~/ff
    just
    bruno
    mongodb-compass

    # what dotfiles/nvim calls out to
    ripgrep
    fd
    fzf
    tree-sitter
    gcc # nvim-treesitter compiles parsers
    inotify-tools
    lua-language-server
    vscode-langservers-extracted
    pyright
    ruff
    typescript-language-server
    rust-analyzer
    nixd
    clang-tools
    marksman
  ];

  niriConfig = pkgs.writeText "focus-niri.kdl" ''
    hotkey-overlay { skip-at-startup; }
    prefer-no-csd

    input {
        keyboard {
            repeat-delay 350
            repeat-rate 40
            xkb { layout "us,ru"; options "grp:alt_shift_toggle"; }
        }
        touchpad { tap; dwt; natural-scroll; }
        focus-follows-mouse
    }

    output "Xiaomi Corporation A24FAA-RG 4440240000257" {
        scale 0.8
        mode "1920x1080@165.002"
    }

    layout {
        gaps 0
        default-column-width { proportion 0.5; }
        focus-ring { off; }
    }

    binds {
        Mod+Shift+Slash { show-hotkey-overlay; }
        Mod+T { spawn "kitty"; }
        Mod+R { spawn "fuzzel"; }
        Mod+E { spawn "helium"; }
        Mod+C { close-window; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+O { toggle-overview; }
        Mod+Shift+Q { quit; }

        Mod+H { focus-column-left; }
        Mod+L { focus-column-right; }
        Mod+J { focus-window-or-workspace-down; }
        Mod+K { focus-window-or-workspace-up; }
        Mod+Shift+H { move-column-left; }
        Mod+Shift+L { move-column-right; }
        Mod+Shift+J { move-window-down-or-to-workspace-down; }
        Mod+Shift+K { move-window-up-or-to-workspace-up; }
        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+Shift+1 { move-column-to-workspace 1; }
        Mod+Shift+2 { move-column-to-workspace 2; }
        Mod+Shift+3 { move-column-to-workspace 3; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05+"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.05-"; }
        XF86AudioMute        allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86MonBrightnessUp   { spawn "brightnessctl" "set" "+5%"; }
        XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }
    }
  '';

  fishConfig = pkgs.writeText "focus-config.fish" ''
    set fish_greeting
    # Only one niri per user: a second tty login while it runs gets a plain shell
    if status is-interactive; and status is-login; and test -z "$WAYLAND_DISPLAY"
        and not systemctl --user -q is-active niri.service
        exec niri-session # quitting niri logs out, the tty goes back to login prompt
    end
  '';

  mimeapps = pkgs.writeText "focus-mimeapps.list" ''
    [Default Applications]
    x-scheme-handler/http=helium.desktop
    x-scheme-handler/https=helium.desktop
    text/html=helium.desktop
  '';

  lockFile = "/var/lib/lockdown/until"; # unix time; outside generations, so rollback can't skip it
  date = "${pkgs.coreutils}/bin/date";

  # pam_exec account check: nonzero exit refuses the login/sudo/su/ssh
  lockdownCheck = pkgs.writeShellScript "lockdown-check" ''
    [ "$PAM_USER" = saegl ] || [ "$PAM_USER" = root ] || exit 0
    [ -r ${lockFile} ] || exit 0
    until=$(< ${lockFile})
    [ "$(${date} +%s)" -lt "$until" ] 2>/dev/null || exit 0
    echo "Locked down until $(${date} -d "@$until" '+%H:%M (%a %d %b)')"
    exit 1
  '';

  lockdown = pkgs.writeShellScriptBin "lockdown" ''
    set -eu
    if [ $# -eq 0 ]; then
        if [ -r ${lockFile} ] && [ "$(${date} +%s)" -lt "$(< ${lockFile})" ]; then
            echo "Locked until $(${date} -d "@$(< ${lockFile})")"
        else
            echo "Not locked. Usage: lockdown 90m | lockdown 3h"
        fi
        exit 0
    fi
    case $1 in
        *[!0-9hm]* | "" ) echo "usage: lockdown 90m | 3h" >&2; exit 1 ;;
        *h) secs=$(( ''${1%h} * 3600 )) ;;
        *m) secs=$(( ''${1%m} * 60 )) ;;
        *) echo "usage: lockdown 90m | 3h" >&2; exit 1 ;;
    esac
    [ "$(id -u)" -eq 0 ] || exec sudo "$0" "$@"
    mkdir -p ${dirOf lockFile}
    until=$(( $(${date} +%s) + secs ))
    echo "$until" > ${lockFile}
    chmod 644 ${lockFile}
    echo "saegl and root locked until $(${date} -d "@$until"). Logging saegl out."
    sleep 2
    loginctl terminate-user saegl
  '';

  ipset = "${pkgs.ipset}/bin/ipset";
  # Each rule is deleted before being added so firewall reloads don't stack copies
  focusRules = action: ''
    iptables  -w ${action} OUTPUT -m owner --uid-owner focus -m set --match-set focus-block4 dst -j REJECT
    ip6tables -w ${action} OUTPUT -m owner --uid-owner focus -m set --match-set focus-block6 dst -j REJECT
    iptables  -w ${action} OUTPUT -m owner --uid-owner focus -p udp -m multiport --dports 53,853 ! -d 127.0.0.1 -j REJECT
    iptables  -w ${action} OUTPUT -m owner --uid-owner focus -p tcp -m multiport --dports 53,853 ! -d 127.0.0.1 -j REJECT
    ip6tables -w ${action} OUTPUT -m owner --uid-owner focus -p udp -m multiport --dports 53,853 ! -d ::1 -j REJECT
    ip6tables -w ${action} OUTPUT -m owner --uid-owner focus -p tcp -m multiport --dports 53,853 ! -d ::1 -j REJECT
  '';
in {
  users.users.focus = {
    isNormalUser = true; # no wheel: no sudo to undo any of this
    shell = pkgs.fish;
    extraGroups = ["video" "audio" "input"];
    packages = focusPackages;
  };

  # No daemon access, so no `nix shell nixpkgs#telegram-desktop` escape hatch
  nix.settings.allowed-users = ["root" "@wheel"];

  ##############################################################################
  # LOCKDOWN
  # `lockdown 3h` (as saegl) writes an expiry to /var and logs saegl out. Until
  # then PAM refuses saegl and root everywhere: tty, sudo, su, pkexec/run0, ssh
  # (the account stage runs even for key logins). Lifting it early needs root,
  # which needs saegl. Remaining escapes are physical: GRUB `init=` edit, BIOS clock.
  ##############################################################################

  environment.systemPackages = [lockdown];

  security.pam.services = lib.genAttrs ["login" "sudo" "su" "sshd" "polkit-1" "systemd-run0"] (_: {
    rules.account.lockdown = {
      order = 10000; # before pam_unix (11000)
      control = "required";
      modulePath = "${config.security.pam.package}/lib/security/pam_exec.so";
      args = ["quiet" "stdout" "${lockdownCheck}"];
    };
  });

  ##############################################################################
  # SITE BLOCKING
  # All DNS goes through a local dnsmasq, which drops every IP it resolves for
  # blockedSites into an ipset. The firewall rejects focus-uid traffic to that
  # set (any app, any protocol) and stops focus from using any other resolver.
  # saegl resolves through the same dnsmasq but has no rules, so it's unaffected.
  ##############################################################################

  services.dnsmasq = {
    enable = true; # resolveLocalQueries (default) points resolv.conf at it via resolvconf
    settings = {
      listen-address = ["127.0.0.1" "::1"];
      bind-interfaces = true;
      ipset = "/${lib.concatStringsSep "/" blockedSites}/focus-block4,focus-block6";
    };
  };

  # Sets must exist before dnsmasq writes to them; the firewall creates them too
  systemd.services.dnsmasq.after = ["firewall.service"];
  systemd.services.dnsmasq.wants = ["firewall.service"];

  networking.firewall = {
    extraPackages = [pkgs.ipset];
    extraCommands = ''
      ${ipset} -exist create focus-block4 hash:ip family inet
      ${ipset} -exist create focus-block6 hash:ip family inet6
      ${lib.replaceStrings ["\n"] [" 2>/dev/null || true\n"] (focusRules "-D")}
      ${focusRules "-A"}
    '';
    extraStopCommands = lib.replaceStrings ["\n"] [" 2>/dev/null || true\n"] (focusRules "-D");
  };

  # Helium would otherwise be free to switch on DNS-over-HTTPS and skip dnsmasq
  programs.helium.policies.DnsOverHttpsMode = "off";

  ##############################################################################
  # SHARED FOLDER & DOTFILES
  ##############################################################################

  # Files appear owned by focus inside the mount but are written as saegl,
  # so git sees no "dubious ownership" and saegl never has to chown
  system.fsPackages = [pkgs.bindfs];
  fileSystems."/home/focus/ff" = {
    device = "/home/saegl/projects/ff";
    fsType = "fuse.bindfs";
    options = ["map=saegl/focus" "nofail"];
    noCheck = true;
  };
  # Same keys and known_hosts as saegl; bindfs shows them as focus-owned 0600,
  # which ssh requires
  fileSystems."/home/focus/.ssh" = {
    device = "/home/saegl/.ssh";
    fsType = "fuse.bindfs";
    options = ["map=saegl/focus" "nofail"];
    noCheck = true;
  };
  # Live, writable view of saegl's nvim config (vim.pack writes its lockfile here)
  fileSystems."/home/focus/.config/nvim" = {
    device = "/home/saegl/projects/nix/nixos/dotfiles/nvim";
    fsType = "fuse.bindfs";
    options = ["map=saegl/focus" "nofail"];
    noCheck = true;
  };

  # uv-managed pythons live here instead of ~/.local/share/uv (unreadable to
  # focus), so venvs in ~/ff resolve their interpreter for both users
  environment.variables.UV_PYTHON_INSTALL_DIR = "/opt/uv/python";

  systemd.tmpfiles.rules = [
    "d  /opt/uv/python                       0755 saegl users -"
    "d  /home/focus                          0700 focus users -"
    "d  /home/focus/.config                  0755 focus users -"
    "d  /home/focus/.config/niri             0755 focus users -"
    "d  /home/focus/.config/fish             0755 focus users -"
    "d  /home/focus/.config/git              0755 focus users -"
    "L+ /home/focus/.config/niri/config.kdl  - - - - ${niriConfig}"
    "L+ /home/focus/.config/fish/config.fish - - - - ${fishConfig}"
    "L+ /home/focus/.config/git/config       - - - - ${./dotfiles/git/config}"
    "L+ /home/focus/.config/mimeapps.list    - - - - ${mimeapps}"
  ];
}
