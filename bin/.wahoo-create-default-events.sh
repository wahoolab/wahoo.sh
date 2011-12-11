

function template_header {
cat <<EOF
Put files in this folder and Wahoo will execute them the next time
the event is triggered. Files named README, ending in .txt or .log
will not be executed. Files are run simultaneously in the background. 
There is no specific execution order. 
EOF
}

# Triggered when monitor_localhost_for_reboot.sh detects a reboot.
mkdir -p ${WAHOO}/event/reboot
mkdir -p ${WAHOO}/event/$(hostname)/reboot

(
cat <<EOF
$(template_header)

The "reboot" event is triggered anytime the monitor_localhost_for_reboot.sh
script detects that a reboot has occurred.

What should I put here?

   * Scripts to restart services.
   * Scripts to validate that services restarted automatically.
   * Scripts to open a ticket which must be acknowledge.
   * Scripts which notify specific non-Admin interested parties that a reboot
     has occurred.

Updated: 12/10/2011

EOF
) > ${WAHOO}/event/reboot/README
