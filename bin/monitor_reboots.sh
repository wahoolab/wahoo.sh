#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

function usage {
cat <<EOF
usage: monitor_reboots.sh 

Monitors localhost for reboots. 

Note:

   This monitor is run automatically, fires a "reboot" event
   and routes a message using the defined keywords.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

# This monitor is disable if no keywords are defined.
[[ -z ${MONITOR_REBOOT_KEYWORDS} ]] && exit 0

debug.sh -2 "$$ $(basename $0) KEYWORDS=\"${MONITOR_REBOOT_KEYWORDS}\""

# sort -u here since I who -b may have returned duplicates in past.
who -b | sort -u | sensor.sh --key "monitor_reboot" | \
   route-message.sh --keywords "${MONITOR_REBOOT_KEYWORDS}" --subject "Reboot!" --fire "reboot"

# ToDo: Need to add a script call here which keeps tracks of hours up/down.

exit 0
