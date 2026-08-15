# Two-line prompt: full cwd + git + venv on line 1, prompt char on line 2.
# No language/tool version detection, and exactly one `git` fork per prompt.

function _prompt_git --description 'Branch and worktree state from a single git call'
    # porcelain=v2 gives branch, upstream distance, stash and per-file status
    # in one shot; --no-optional-locks keeps the prompt from writing the index
    set -l info (command git --no-optional-locks status \
        --porcelain=v2 --branch --show-stash 2>/dev/null)
    or return 1

    set -l branch
    set -l oid
    set -l ahead 0
    set -l behind 0
    set -l stashed 0

    # header lines come first and there are only a handful of them
    set -l body 1
    for line in $info
        string match -q -- '#*' $line; or break
        set body (math $body + 1)
        set -l f (string split ' ' -- $line)
        switch $f[2]
            case branch.head
                set branch $f[3]
            case branch.oid
                set oid $f[3]
            case branch.ab
                set ahead (string sub -s 2 -- $f[3])
                set behind (string sub -s 2 -- $f[4])
            case stash
                set stashed $f[3]
        end
    end

    # detached HEAD, or a fresh repo with no commits yet
    if test "$branch" = '(detached)'
        set branch (string sub -l 7 -- $oid)
    else if test -z "$branch"
        set branch '(unknown)'
    end

    set -l normal (set_color normal)
    set -l out (set_color magenta --bold)$branch$normal

    # X = staged, Y = unstaged; '.' means unchanged in that column
    set -l files $info[$body..]
    # note: '' not empty, concatenating onto an empty list yields an empty list
    set -l state ''
    if string match -qr '^[12] [^.]' -- $files
        set state $state(set_color green)'+'$normal
    end
    if string match -qr '^[12] .[^.]' -- $files
        set state $state(set_color yellow)'*'$normal
    end
    if string match -qr '^u ' -- $files
        set state $state(set_color red)'!'$normal
    end
    if string match -qr '^\? ' -- $files
        set state $state(set_color brblack)'?'$normal
    end
    test $stashed -gt 0; and set state $state(set_color cyan)'$'$normal

    test -n "$state"; and set out "$out $state"

    set -l dist ''
    test $ahead -gt 0; and set dist $dist'↑'$ahead
    test $behind -gt 0; and set dist $dist'↓'$behind
    test -n "$dist"; and set out "$out "(set_color cyan)$dist$normal

    echo -n " ($out)"
end

# $CMD_DURATION keeps its value until the next real command, so it would stick
# around on every bare Enter after a slow job. Latch it here instead and let the
# prompt consume it once.
function _prompt_latch_duration --on-event fish_postexec
    set -g _prompt_last_duration $CMD_DURATION
end

function _prompt_duration --description 'Runtime of the last command, if it was slow'
    set -q _prompt_last_duration; or return
    set -l ms $_prompt_last_duration
    set -e _prompt_last_duration
    test $ms -lt 500; and return

    # round to whole seconds first so 59999ms reads as 1m0s, not 60s
    set -l total (math -s0 "round($ms / 1000)")
    # '' not empty: concatenating onto an empty list yields an empty list
    set -l out ''
    if test $total -lt 60
        set out (math -s1 "$ms / 1000")s
    else
        set -l h (math -s0 "floor($total / 3600)")
        set -l m (math -s0 "floor($total % 3600 / 60)")
        set -l s (math -s0 "$total % 60")
        test $h -gt 0; and set out {$h}h
        set out $out{$m}m{$s}s
    end

    echo -n ' '(set_color yellow)$out(set_color normal)
end

function fish_prompt --description 'Two-line prompt: cwd, git, venv'
    # both must be grabbed before anything else runs; `set` leaves $status alone
    set -l last_pipestatus $pipestatus
    set -l last_status $status
    set -l normal (set_color normal)

    # cwd, always the full absolute path: no truncation, no ~ for $HOME
    echo -n (set_color $fish_color_cwd --bold)$PWD$normal

    _prompt_git

    # python virtualenv
    if set -q VIRTUAL_ENV
        set -l venv (path basename $VIRTUAL_ENV)
        # .venv/ and venv/ say nothing, name it after the project instead
        if contains -- $venv .venv venv env .env
            set venv (path basename (path dirname $VIRTUAL_ENV))
        end
        echo -n ' '(set_color yellow)"($venv)"$normal
    end

    _prompt_duration

    echo

    # exit status, only when it failed. fish's helper renders pipelines as
    # [1|0|2] and turns signals into names, so ^C shows [SIGINT] not [130]
    set -lx __fish_last_status $last_status
    __fish_print_pipestatus '[' '] ' '|' (set_color brblack) (set_color red --bold) $last_pipestatus

    # prompt char, red when the last command failed
    if test $last_status -ne 0
        set_color red --bold
    else
        set_color green --bold
    end
    if fish_is_root_user
        echo -n '# '
    else
        echo -n '$ '
    end
    set_color normal
end
