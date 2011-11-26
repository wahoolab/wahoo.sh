#!/tmp/wahoo

# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$0"

function usage {
cat <<EOF
usage: crlock.sh [options] [lock_key]

Locking script.

Options:

   --try [integer]              

      Defines the # of times you will try to obtain the lock 
      if it is not available. Roughly one try per second.

   --grab

      Lock is grabbed even if it is not available after the 
      # if tries defined.

   --expire [integer]

      Maximum # of seconds this lock is valid for.

   --fail [integer]

      # of failures before triggering an error message to 
      standard error. This feature is disabled by default.

   --max-processes [integer]

      Max # of simultaneous processes which are allowed to
      make attempts to aquire a lock before sending an
      error to standard error and failing.

   --remove 

      Remove a lock.  

   
EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

MAX_LOCK_SECONDS=${MAX_LOCK_SECONDS:-0}
LOCK_DIR=${TMP}/locks/
MAX_TRIES=1
GRAB_LOCK=
LOCK_KEY=
FAILURE_LIMIT=0
REMOVE_LOCK=
MAX_PROCESSES=
while (( $# > 0)); do
   case $1 in
      --expire) shift; MAX_LOCK_SECONDS="${1}" ;;
      --try) shift; MAX_TRIES="${1}" ;;
      --grab) GRAB_LOCK="GRAB_LOCK" ;;
      --fail) shift; FAILURE_LIMIT="${1}" ;;
      --remove) REMOVE_LOCK="REMOVE_LOCK" ;;
      --max-processes) shift; MAX_PROCESSES="${1}" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option) )) && error.sh "$0 - $* contains an unrecognized option." && exit 1

LOCK_KEY="${1}"
[[ -z ${LOCK_KEY} ]] && error.sh "$0 - LOCK_KEY is not defined." && exit 1

if (( ${MAX_LOCK_SECONDS} > 0 )); then
   ((EXPIRE_TIME=$(time.sh epoch)+MAX_LOCK_SECONDS))
else
   EXPIRE_TIME=0
fi

LOCK_DIR=${TMP}/locks/${LOCK_KEY}
[[ ! -d ${LOCK_DIR} ]] && mkdir -p ${LOCK_DIR}
cd ${LOCK_DIR}
trap 'rm ${LOCK_DIR}/$$.trying 2> /dev/null' 0

if [[ -n ${REMOVE_LOCK} ]]; then
   rm ${LOCK_DIR}/* 2> /dev/null 
   exit 0
fi

TRIES=0
AQUISITION="FAILED"

p=0
if (( ${MAX_PROCESSES:-0} > 0 )); then
   cat *.trying 2> /dev/null | while read t; do
      echo t=${t}
      (( ${t} > (($(time.sh epoch)-60)) )) && ((p=p+1))
   done
   if (( ${p} >= ${MAX_PROCESSES} )); then
      error.sh "$0 - Too many processes are trying to aquire lock ${LOCK_KEY}." && exit 1
   fi
fi

while ((1)); do
   ((TRIES=TRIES+1))
   # Lock is available if there are no .lock files.
   if (( $(ls *.lock 2> /dev/null | wc -l) == 0 )); then
      echo ${EXPIRE_TIME} > $$.lock && AQUISITION="SUCCESSFUL" && break
   else
      # Lock not available unless it has expired. 
      EXPIRES=$(cat *.lock | tail -1)
      if (( ${EXPIRES} > 0 && ${EXPIRES} < $(time.sh epoch) )); then
         # Lock is expired, so we will remove it and log a message since the process that created it did not remove it.
         rm *.lock 2> /dev/null && echo ${EXPIRE_TIME} >> $$.lock && AQUISITION="EXPIRED" && break
         wahoo.sh log "Aquisition of lock ${LOCK_KEY} succeeded because existing lock has expired."
      fi
   fi
   if (( ${TRIES} >= ${MAX_TRIES} )); then
      if [[ -n "${GRAB_LOCK}" ]]; then
         rm *.lock 2> /dev/null && echo ${EXPIRE_TIME} >> $$.lock && AQUISITION="GRABBED"
         wahoo.sh log "Aquisition of lock ${LOCK_KEY} was grabbed."
      fi
      break
   fi
   # echo here because I need the end of line.
   echo "$(time.sh epoch)" > $$.trying
   sleep 1
done

if [[ ${AQUISITION} == "FAILED" ]]; then
   # Add a line to the fail.log so we can keep track of the # of consecutive failures.
   echo $(date) $* >> fail.log 
   EXIT_STATUS=1
   wahoo.sh log "Aquisition of lock ${LOCK_KEY} failed."
   if (( ${FAILURE_LIMIT} > 0 )); then
      if (( $(wc -l fail.log | cut -d" " -f1) > ${FAILURE_LIMIT} )); then
         error.sh "$0 - Failure limit has been reached trying to aquire lock ${LOCK_KEY}."
         wahoo.sh log "Failure limit has been reached trying to aquire lock ${LOCK_KEY}."
      fi
   fi
else
   cp /dev/null fail.log
   EXIT_STATUS=0
fi

exit ${EXIT_STATUS}
