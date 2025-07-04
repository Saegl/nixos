# set fish_greeting # Disable greeting
# set -x LD_LIBRARY_PATH /run/opengl-driver/lib:$NIX_LD_LIBRARY_PATH

# Unbloated login manager
# if status is-login; and test -z "$DISPLAY"; and test (tty) = "/dev/tty1"
#     niri-session
# end

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
