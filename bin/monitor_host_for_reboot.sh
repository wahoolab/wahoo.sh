#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$0"

function usage {
cat <<EOF
usage: 

Options:

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

MONITOR_FOR_REBOOT_ROUTE=${MONITOR_FOR_REBOOT_ROUTE:-"CRITICAL"}

case ${OSNAME} in
   SUNOS|LINUX|AIX) OK= ;;
   * ) sfterr.sh "$0: who -b may not work for reboot check" ;;
esac

# sort -u is unusual here but trying to figure out why I see two lines sometimes which 
# triggers warning when nothing has changed.

who -b | sort -u | sensor.sh -key "server_boot_time" | \
   pamala.sh -keyword "${REBOOT_KEYWORD}" -subject "Server Boot Time Has Changed!"

exit 0
