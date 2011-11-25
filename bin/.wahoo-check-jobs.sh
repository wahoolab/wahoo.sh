#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$0"

if ! $(crlock.sh --try 60 --expire 3600 --fail 5 --max-processes 5 wahoo-check-jobs); then
   exit 1
fi

trap 'rmlock.sh wahoo-check-jobs' 0

JOB_FILE=${WAHOO}/bin/.wahoo-jobs
TMPID=${RANDOM}
EVENT_NAME=${1}
TMPFILE=${TMP}/$$.tmp

[[ -n "${1}" ]] && EVENT_NAME="${1}"

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
   echo "${1}" | sed 's/^@//'
}

function get_event {
   echo "${1}" | sed 's/^!//' | str.sh nospace
}

function get_hosts {
   echo "${1}" | sed 's/^\+//'
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
grep -v "^#" ${JOB_FILE} | while read -r l; do
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
            debug.sh -1 "$0 - ${l}"
            runscript.sh ${TMPFILE}${TMPID} &
         fi
      fi
   fi
done

# Might need to check if we complete this in the same minute we started in.

exit 0
