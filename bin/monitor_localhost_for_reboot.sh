#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

function usage {
cat <<EOF
usage: monitor_localhost_for_reboot.sh 

Monitors localhost for reboots. 

Note:

   This monitor is automatically run when you schedule run.sh.

   This monitor fires a "reboot" trigger and routes a message 
   using defined keyword.

Environment Variables:

   MONITOR_LOCALHOST_FOR_REBOOT_ENABLED
   
     Must be 'Y' (default) to enable this monitor.

     Current value is "${MONITOR_LOCALHOST_FOR_REBOOT_ENABLED}"

   MONITOR_LOCALHOST_FOR_REBOOT_KEYWORDS

     Keyword(s) used to route messages for this monitor. If not 
     defined, defaults to 'LOG'. Separate multiple keywords with
     a comma.

     Current value is "${MONITOR_LOCALHOST_FOR_REBOOT_KEYWORD}"

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

# Important to clear this sensor between starts and stops, so if it is off we ensure it is cleared.
if [[ ${MONITOR_LOCALHOST_FOR_REBOOT_ENABLED} != "Y" ]]; then
   sensor.sh --clear "monitor_localhost_for_reboot"
   exit 0
fi

MONITOR_LOCALHOST_FOR_REBOOT_KEYWORD=${MONITOR_LOCALHOST_FOR_REBOOT_KEYWORD:-"LOG"}

debug.sh -2 "$$ $(basename $0) KEYWORDS=\"${MONITOR_LOCALHOST_FOR_REBOOT_KEYWORD}\""

# sort -u here since I have seen times when who -b may have returned duplicate lines.
who -b | sort -u | sensor.sh --key "monitor_localhost_for_reboot" | \
   route-message.sh --keywords "${MONITOR_LOCALHOST_FOR_REBOOT_KEYWORDS}" --subject "Reboot!" --fire "reboot"

# ToDo: Need to add a script call here which keeps tracks of hours up/down.

exit 0
