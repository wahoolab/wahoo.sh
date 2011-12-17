#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$(basename $0) $*"

function usage {
cat <<EOF
usage: crevent.sh [options]

Create an event. 

Options:

   --key "[key]"

     Required unique string used to identify the event. No spaces.

   --schedule "[schedule]"

     Optional cron style schedule which determines when the event
     is triggered.

   --command "[command]"

     Optional command to execute when the event is triggered.

   --domain 

     Indicates that this event applies to all servers in the Wahoo
     domain.

   --hostname [name-of-host]

     Indicates the event only applies to a particular host.

   --silent
    
     Don't report errors if command for event already exists.

   --remove "[key]"

     Remove event specified by [key].

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

EVENT_DIR=${WAHOO}/event
EVENT_KEY=
SCHEDULE=
EVENT_SCOPE="$(hostname)"
FORCE=
EVENT_HOST=
SILENT=
REMOVE=
FLAG_FILE=".domain"
COMMAND=
while (( $# > 0)); do
   case $1 in
      --key) shift; EVENT_KEY="${1}" ;;
      --command) shift; COMMAND="${1}" ;;
      --schedule) shift; SCHEDULE="${1}" ;;
      --remove) shift; EVENT_KEY="${1}"; REMOVE="REMOVE" ;;
      --force) FORCE="FORCE" ;;
      --hostname) shift; EVENT_HOST="${1}" ; FLAG_FILE=".localhost" ;;
      --silent) SILENT="SILENT" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

[[ -z ${EVENT_KEY} ]] && error.sh "$0 - Option \"--key [key]\" is required!" && exit 1

if [[ -n ${EVENT_HOST} ]]; then
   EVENT_DIR=${EVENT_DIR}/${EVENT_HOST}/${EVENT_KEY}
else
   EVENT_DIR=${EVENT_DIR}/${EVENT_KEY}
fi
[[ ! -d ${EVENT_DIR} ]] && mkdir -p ${EVENT_DIR} 

if [[ -n "${REMOVE}" ]]; then
   rm -rf ${EVENT_DIR}; exit 0
fi

cd ${EVENT_DIR} 

[[ ! -f .run ]] && touch .run && chmod 700 .run
[[ -n "${SCHEDULE}" ]] && echo "${SCHEDULE}" >  .schedule && chmod 600 .schedule

# We drop a flag file for scheduled and unscheduled events, but it is only used for scheduled events.
touch ${FLAG_FILE}

if [[ -n "${COMMAND}" ]]; then
   SEARCHABLE_COMMAND=$(echo ${COMMAND} | sed 's/\\/\\\\/g' | sed 's/\$/\\$/g' | sed 's/;/\\;/g' | sed 's/\[/\\\[/g' | sed 's/\]/\\\]/g' | sed 's/\*/\\\*/g')
   if ! $(grep "${SEARCHABLE_COMMAND}$" .run 1> /dev/null); then
      echo "${COMMAND}" >> .run
   else
      [[ -z ${SILENT} ]] && error.sh "$0 - Command \"${COMMAND}\" already exists!" && exit 1
   fi
fi

exit 0
