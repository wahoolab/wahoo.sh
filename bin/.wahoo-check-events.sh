#!/tmp/wahoo 
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0)"

function usage {
cat <<EOF
usage: .wahoo-check-eventss.sh [options]

Options:

exit 0
EOF
}

[[ "${1}" == "--help" ]] && usage

EVENT_DIR=${WAHOO}/event

while (( $# > 0)); do
   case $1 in
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

function runscripts {
   for x in $(ls * .run 2> /dev/null); do
      [[ -f ${x} ]] || continue
      debug.sh -3 "$$ f=${x}"
      runscript.sh "${d}/${x}" &
   done
}

function check_events {
[[ ! -d ${1} ]] && mkdir ${1}
debug.sh -3 "$$ FLAG_FILE=${FLAG_FILE}"
find ${1} -type f -name "${FLAG_FILE}" | while read f; do
   d=$(dirname ${f})
   cd ${d} || exit 1
   debug.sh -3 "$$ cd ${d}"
   [[ -f .schedule ]] || continue
   OIFS=${IFS}; IFS=":" 
   cat .schedule | egrep -v "^#" | head -1 | read SCHEDULE CREATE_TIME QUIT_EVENT_AFTER_MINUTES
   IFS=${OIFS}
   [[ -n "${SCHEDULE}" ]] || continue
   $(crontab.sh --schedule "${SCHEDULE}") || continue
   runscripts
done
}

# .domain flag file prevents events tied to a particular host from running.
FLAG_FILE=".domain"
check_events ${EVENT_DIR}
FLAG_FILE=".localhost"
check_events ${EVENT_DIR}/$(hostname)

exit 0
