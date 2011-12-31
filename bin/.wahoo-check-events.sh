#!/tmp/wahoo 

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0)"

function usage {
cat <<EOF
usage: .wahoo-check-events.sh [options]

Options:

exit 0
EOF
}

[[ "${1}" == "--help" ]] && usage

# ToDo: Allow users to add and process their own event directories.
EVENT_DIR=${WAHOO}/event

FIRE=
while (( $# > 0)); do
   case $1 in
      --fire) shift; FIRE="${1}" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

function runscripts {
   # Run all executable scripts in the event directory.
   for script in $(ls * .command* 2> /dev/null); do
      [[ -x ${script} ]] || continue
      runscript.sh "${d}/${script}" &
   done
}

function handle_d {
   cd ${1} || exit 1
   debug.sh -3 "$$ cd ${1}"
   RUN=Y
   if [[ -s .allow ]]; then
      $(grep $(hostname) .allow 1> /dev/null) || RUN=
   elif [[ -s .deny ]]; then
      $(grep $(hostname) .deny  1> /dev/null) && RUN=
   fi
   if [[ ${RUN} == "Y" ]]; then
      if [[ ${2} == "schedule" ]]; then
         SCHEDULE=$(cat .schedule | egrep -v "^#")
         if [[ -n "${SCHEDULE}" ]]; then
            $(crontab.sh --schedule "${SCHEDULE}") || RUN=
         fi
      fi
      [[ ${RUN} == "Y" ]] && runscripts
   fi
}

if [[ -z ${FIRE} ]]; then
   # Only looking at events with schedules.
   find ${EVENT_DIR} -type f -size +0 -name ".schedule" | while read f; do
      d=$(dirname ${f})
      handle_d ${d} "schedule"
   done
else
   debug.sh -3 "$$ Looking for event directories in ${l}"
   find ${EVENT_DIR} -type d -name "${FIRE}" | while read d; do
      handle_d ${d} "event"
   done
fi

exit 0
