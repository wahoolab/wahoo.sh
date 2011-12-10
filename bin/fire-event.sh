
function usage {
cat <<EOF
usage: fire-event.sh [event name]

Triggers the commands associated with an event.

Arguments:

   [event name]

      Name of the event. Events are configured in one of the two
      event.cfg files. One is controlled by Wahoo and is not 
      typically modified. The other is under your control and 
      located in your domain directory.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

EVENT_NAME="${1}"

[[ -z ${EVENT_NAME} ]] && exit 1

${WAHOO}/bin/.wahoo-check-events.sh --event ${EVENT_NAME}

if [[ -s ${WAHOO}/domain/${WAHOO_DOMAIN}/events.cfg ]]; then
   ${WAHOO}/bin/.wahoo-check-events.sh --file ${WAHOO}/domain/${WAHOO_DOMAIN}/events.cfg --event ${EVENT_NAME}
fi

