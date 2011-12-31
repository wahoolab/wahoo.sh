#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

# ToDo: Add logging.

debug.sh "$(basename $0) $*"

function usage {
cat <<EOF
usage: crevent.sh [options]

Create an event. 

Options:

   --key "[key]"

   Unique event key (just a string, actually a directory which will get 
   created in \${WAHOO}/event. This means you can create multiple directories
   which all map to the same event. For example "reboot" and "custom/reboot" 
   will both get fired wth reboot event. This option is required.

   --schedule "[schedule]"

   Cron style schedule which is used to fire this event. This option is not
   required.

   --allow "[list of hosts]"

   Comma separated list of hostnames this event is allowed to run on.

   --deny "[list of hosts]"

   Comma separated list of hostnames this event is not allowed to run on.

   --remove "[key]"

   Remove the event specified by key. This can also be called using
   rmevent.sh.

   --silent
    
   Suppress warnings when creating or removing events and the event does
   or does not already exist.

Examples:

   # Create a new event.
   crevent.sh --key "foo"

   # Create an event with a schedule.
   crevent.sh --key "foo" --schedule "* * * * *"

   # Create an event that only applies to the current host.
   crevent.sh --key "foo" --allow \$(hostname)

   # Remove an event.
   crevent.sh --remove "foo"

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

EVENT_DIR=${WAHOO}/event
UNIQUE_EVENT_KEY=
SCHEDULE_FOR_EVENT=
SUPPRESS_WARNINGS=
UNIQUE_EVENT_KEY_TO_REMOVE=
LIST_OF_ALLOWED_HOSTS=
LIST_OF_DENIED_HOSTS=
while (( $# > 0)); do
   case $1 in
      --key)      shift; UNIQUE_EVENT_KEY="${1}"                                 ;;
      --schedule) shift; SCHEDULE_FOR_EVENT="${1}"                               ;;
      --remove)   shift; UNIQUE_EVENT_KEY="${1}"; UNIQUE_EVENT_KEY_TO_REMOVE="Y" ;;
      --allow)    shift; LIST_OF_ALLOWED_HOSTS="${1}"                            ;;
      --deny)     shift; LIST_OF_DENIED_HOSTS="${1}"                             ;;
      --silent)          SUPPRESS_WARNINGS="Y"                                   ;;
      *) break                                                                   ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

[[ -z ${UNIQUE_EVENT_KEY} ]] && error.sh "$0 - Option \"--key [key]\" is required." && exit 1

EVENT_DIR=${EVENT_DIR}/${UNIQUE_EVENT_KEY}

if [[ -n "${UNIQUE_EVENT_KEY_TO_REMOVE}" ]]; then
   if [[ -d ${EVENT_DIR} ]]; then
      rm -rf ${EVENT_DIR}
   elif [[ -z ${SUPPRESS_WARNINGS} ]]; then
      error.sh "$0 - Event \"${UNIQUE_EVENT_KEY}\" not found."
      exit 1
   fi
   exit 0
fi

if [[ ! -d ${EVENT_DIR} ]]; then

   mkdir -p ${EVENT_DIR}
   cd ${EVENT_DIR}

   [[ -n "${SCHEDULE_FOR_EVENT}" ]] && echo "${SCHEDULE_FOR_EVENT}" > .schedule  && chmod 600 .schedule

   cp /dev/null .allow
   if [[ -n "${LIST_OF_ALLOWED_HOSTS}" ]]; then
      echo "${LIST_OF_ALLOWED_HOSTS}" | str.sh split "," > .allow
   elif [[ -n ${LIST_OF_DENIED_HOSTS} ]]; then
      rm .allow
      echo "${LIST_OF_DENIED_HOSTS}" | str.sh split "," > .deny
   fi 

elif [[ -z "${SUPPRESS_WARNINGS}" ]]; then

   error.sh "$0 - Event \"${UNIQUE_EVENT_KEY}\" already exists."
   exit 1

fi

exit 0
