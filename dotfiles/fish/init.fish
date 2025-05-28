function flac2opus
    for f in *.flac
        set newname (string replace -r '^\d+\s*' '' "$f")
        set newname (string replace -r '\.flac$' '.opus' "$newname")
        opusenc "$f" "$newname"
    end
end

