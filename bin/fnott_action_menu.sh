#!/usr/bin/env bash
# fnott_action_menu — fnott's selection-helper (see fnott.ini).
#
# fnott pipes the action labels in on stdin, but nothing that says which
# notification they belong to, so a bare list of "Reply / Mark as read" is
# ambiguous once more than one notification is queued. `fnottctl actions`
# without an id always targets the first entry of `fnottctl list` (which
# prints "<id>: <summary>"), so that summary names the right one; fuzzel
# shows it above the actions via --mesg.

summary=$(fnottctl list </dev/null | head -1)

exec fuzzel --dmenu0 \
    --minimal-lines \
    --prompt="action ❯ " \
    --mesg="${summary#*: }" \
    --message-color=ffc799ff
