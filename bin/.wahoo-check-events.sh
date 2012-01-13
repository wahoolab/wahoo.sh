#!/tmp/wahoo 

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

# This runs so frequently that we don't want to go with level 1 here.
debug.sh -2 "$$ $(basename $0)"

function usage {
cat <<EOF
usage: .wahoo-check-events.sh [options]

Options:

exit 0
EOF
}

[[ "${1}" == "--help" ]] && usage

EVENT_DIR=${WAHOO}/event
EVENT_NAME=
while (( $# > 0)); do
   case $1 in
      # Fire an event by name.
      --fire) shift; EVENT_NAME="${1}" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

function run_all_scripts_in_background {
   for script in $(ls * .command* 2> /dev/null); do
      # Go to next script if the current file is not executable.
      [[ ! -x ${script} ]] && continue
      debug.sh -1 "$$ Running ${script} for event $(basename $(pwd))"
      runscript.sh "${d}/${script}" &
   done
}

function check_event_directory {
   # Change to a specific event directory.
   cd ${1} || exit 1

   RUN=Y
   if [[ -s .allow ]]; then
      if ! $(grep $(hostname) .allow 1> /dev/null); then
         debug.sh -3 "$$ $(hostname) is not listed in the .allow file."
         RUN=
      fi
   elif [[ -s .deny ]]; then
      if $(grep $(hostname) .deny  1> /dev/null); then
         debug.sh -3 "$$ $(hostname) is listed in the .deny file."
         RUN=
      fi
   fi

   if [[ ${RUN} == "Y" ]]; then
      # We still might need to check the schedule.
      if [[ ${2} == "schedule" ]]; then
         SCHEDULE=$(cat .schedule | egrep -v "^#" 2> /dev/null)
         if [[ -n "${SCHEDULE}" ]]; then
            if ! $(crontab.sh --schedule "${SCHEDULE}"); then
               RUN=
            else
               debug.sh -2 "$$ Schedule \"${SCHEDULE}\" is true for event ${1}."
            fi
         fi
      fi
      [[ ${RUN} == "Y" ]] && run_all_scripts_in_background
   fi
}

if [[ -z ${EVENT_NAME} ]]; then
   # Only looking for events with a schedule defined.
   find ${EVENT_DIR} -type f -size +0 -name ".schedule" | while read f; do
      d=$(dirname ${f})
      check_event_directory ${d} "schedule"
   done
else
   debug.sh -3 "$$ Looking for event \"${EVENT_NAME}\" in ${EVENT_DIR}"
   find ${EVENT_DIR} -type d -name "${EVENT_NAME}" | while read d; do
      check_event_directory ${d} "event"
   done
fi

exit 0
