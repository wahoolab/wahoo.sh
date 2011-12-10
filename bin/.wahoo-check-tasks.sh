#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$0"

function usage {
cat <<EOF
usage: .wahoo-check-tasks.sh [options]

Options:

exit 0
EOF
}

[[ "${1}" == "--help" ]] && usage

TASK_DIR=${TMP}/tasks
[[ ! -d ${TASK_DIR} ]] && mkdir ${TASK_DIR}

while (( $# > 0)); do
   case $1 in
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

cat ${TASK_DIR}/* | egrep "^$(hostname):|^${WAHOO_DOMAIN}:" | while read LINE; do
   OIFS=${IFS}; IFS=":"
   echo "${LINE}" | read TASK_SCOPE TASK_KEY SCHEDULE CREATE_TIME QUIT_TASK_AFTER_MINUTES COMMAND
   IFS=${OIFS} 
   if $(crontab.sh --schedule "${SCHEDULE}"); then
      if [[ -n ${QUIT_TASK_AFTER_MINUTES} ]]; then
         if (( $(time.sh epoch --minutes) > ((CREATE_TIME+QUIT_TASK_AFTER_MINUTES)) )); then
            rm ${TASK_DIR}/${TASK_KEY}
         fi
      fi
      if [[ -f ${TASK_DIR}/${TASK_KEY} ]]; then
         runscript.sh "${COMMAND}" &            
      fi
   fi
done

exit 0
