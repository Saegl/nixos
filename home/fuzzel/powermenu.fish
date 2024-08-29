set options "1 - Lock
2 - Suspend
3 - Log out
4 - Reboot
5 - Reboot to UEFI
6 - Hard reboot
7 - Shutdown"

set SELECTION (echo $options | fuzzel --dmenu -l 7 -p "Power Menu: ")

switch $SELECTION
    case "*Lock"
        systemctl poweroff
    case "*Suspend"
        systemctl suspend
    case "*Log out"
        riverctl exit
    case "*Reboot"
        systemctl reboot
    case "*Reboot to UEFI"
        systemctl reboot --firmware-setup
    case "*Hard reboot"
        pkexec "echo b > /proc/sysrq-trigger"
    case "*Shutdown"
        systemctl poweroff
end
