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

TASK_DIR=${WAHOO}/task

while (( $# > 0)); do
   case $1 in
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

for d in ${TASK_DIR} ${TASK_DIR}/$(hostname); do
   [[ ! -d ${d} ]] && continue
   cd ${d}
   for f in $(ls); do
      [[ ! -f ${f} ]] && continue
      OIFS=${IFS}; IFS=":"
      head -1 ${f} | read SCHEDULE CREATE_TIME QUIT_TASK_AFTER_MINUTES COMMAND
      IFS=${OIFS} 
      if $(crontab.sh --schedule "${SCHEDULE}"); then
         if [[ -n ${QUIT_TASK_AFTER_MINUTES} ]]; then
            if (( $(time.sh epoch --minutes) > ((CREATE_TIME+QUIT_TASK_AFTER_MINUTES)) )); then
               rm ${f}
            else
               runscript.sh "${COMMAND}" &
            fi
         fi
         if [[ -f ${TASK_DIR}/${TASK_KEY} ]]; then
            runscript.sh "${COMMAND}" &            
         fi
      fi
   done
done

exit 0
