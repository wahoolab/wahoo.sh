#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$(basename $0)"

if ! $(crlock.sh --try 60 --expire 3600 --fail 5 --max-processes 5 wahoo-check-jobs); then
   exit 1
fi

trap 'rmlock.sh wahoo-check-jobs' 0

JOB_FILE=${WAHOO}/bin/.wahoo-jobs
TMPID=${RANDOM}
EVENT_NAME=
TMPFILE=${TMP}/$$.tmp

while (( $# > 0)); do
   case $1 in
      --file) shift; JOB_FILE="${1}" ;;
      --event) shift; EVENT_NAME="${1}" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option) )) && error.sh "$0 - $* contains an unrecognized option." && exit 1

# Typically we would clean up after ourselves, but not 
# in this case, we will let runscript.sh take care of it.
# trap 'rm ${TMPFILE}* 2> /dev/null' 0

function test_regex {
   TEST=$(echo "${l}" | egrep "${1}" | wc -l)
   if (( ${TEST} == 0 )); then
      echo 0
   else
      echo 1
   fi
}

function get_schedule {
   # debug.sh -3 "get_schedule \${1}=${1}"
   # debug.sh -3 "get_schedule $(echo "${1}" | sed 's/^@//')"
   echo "${1}" | sed 's/^@//'
}

function get_event {
   echo "${1}" | sed 's/^!//' | str.sh nospace
}

function get_hosts {
   echo "${1}" | sed 's/^\+//' | str.sh split ","
}

function check_host {
   HOST=$(echo "${1}" | str.sh nospace)
   if [[ "${HOST}" == "${HOSTNAME}" || "${HOST}" == "${SIMPLE_HOSTNAME}" ]]; then
      echo 1
   else
      echo 0
   fi
}

MATCH=
SCHEDULE=
EVENT=

# -r option on read prevents the "\" from being removed from lines in the file.
cat ${JOB_FILE} | str.sh noblank nocomment left | while read -r l; do
   # echo "l=${l}"
   # Lines that match ^@ are a new schedule.
   if (( $(test_regex "^@")  )); then
      # Need to initialize HOST_MATCH here everytime we hit a new schedule. Assume a match at this point.
      HOST_MATCH="HOST_MATCH"
      SCHEDULE=$(get_schedule "${l}")
      MATCH=
      if $(crontab.sh --schedule "${SCHEDULE}"); then
         MATCH="MATCH"
      fi
   elif (( $(test_regex "^!")  )); then
      HOST_MATCH="HOST_MATCH"
      EVENT=$(get_event "${l}")
      MATCH=
      if [[ "${EVENT_NAME}" == "${EVENT}" ]]; then
         MATCH="MATCH"
      fi
   fi

   if [[ -n ${MATCH} ]]; then
      if (( $(test_regex "^\+") )); then
         # Assume no match now and test to see if we have one.
         HOST_MATCH=
         for h in $(get_hosts "${l}"); do
            if (( $(check_host "${h}") )); then
               HOST_MATCH="HOST_MATCH"
               break
            fi
         done 
      fi
      if [[ -n ${HOST_MATCH} && -n ${MATCH} ]]; then
         if (( $(test_regex "^!|^\+|^ |^#|^@") == 0)); then
            ((TMPID=TMPID+1))
            echo "${l}" > ${TMPFILE}${TMPID}
            chmod 700 ${TMPFILE}${TMPID}
            # Run in backgroud and keep rolling. 
            debug.sh -1 "$(basename $0) - ${l}"
            runscript.sh ${TMPFILE}${TMPID} &
         fi
      fi
   fi
done

# Might need to check if we complete this in the same minute we started in.

exit 0
