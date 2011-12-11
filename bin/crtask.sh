#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$0"

function usage {
cat <<EOF
usage: crtask.sh [options]

Create a new scheduled task. Primarily used to create 
tasks associated with a plugin from the plugin's setup.sh.

Options:

   --key "[key]"

     Unique string used to identify the task. No spaces.

   --schedule "[schedule]"

     The cron style schedule to run the task.
     Default: "* * * * * "

   --command "[command]"

     The command you want to execute.

   --domain 

     Task applies to the Wahoo domain.

   --hostname [name-of-host]

     Task only applies to [name-of-host].

   --minutes [n]

     Quit running the task after [n] minutes. If [n]=0
     the command will only execute once.
     Default: 0

   --hours [n]

     Quit running the task after [n] hours. If [n]=0 the
     command will only execute once.

   --silent
  
     Do not report an error if the key already exists.

   --remove "[key]"

     Remove task using key.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

TASK_DIR=${WAHOO}/task
TASK_KEY=
SCHEDULE="* * * * *"
QUIT_TASK_AFTER_MINUTES=
TASK_SCOPE="$(hostname)"
FORCE=
TASK_HOST=
SILENT=
while (( $# > 0)); do
   case $1 in
      --key) shift; TASK_KEY="${1}" ;;
      --command) shift; COMMAND="${1}" ;;
      --schedule) shift; SCHEDULE="${1}" ;;
      --minutes) shift; QUIT_TASK_AFTER_MINUTES="${1}" ;;
      --hours) shift; ((QUIT_TASK_AFTER_MINUTES=60*${1})) ;;
      --remove) shift; rm ${TASK_DIR}/${1} 2> /dev/null; exit 0 ;;
      --force) FORCE="FORCE" ;;
      --hostname) shift; TASK_HOST="${1}" ;;
      --silent) SILENT="SILENT" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

[[ -z ${TASK_KEY} ]] && error.sh "$0 - Option \"--key [key]\" is required!" && exit 1
[[ -z ${COMMAND} ]] && error.sh "$0 - Option \"--commmand [command]\" is required!" && exit 1

if [[ -z ${TASK_HOST} ]]; then
   TASK_FILE=${TASK_DIR}/${TASK_KEY}
else
   [[ ! -d ${TASK_DIR}/${TASK_HOST} ]] && mkdir ${TASK_DIR}/${TASK_HOST}
   TASK_FILE=${TASK_DIR}/${TASK_HOST}/${TASK_KEY}
fi

if [[ ! -f ${TASK_FILE} || -n ${FORCE} ]]; then
   echo "${SCHEDULE}:$(time.sh epoch --minutes):${QUIT_TASK_AFTER_MINUTES}:${COMMAND}" > ${TASK_FILE} 
else
   [[ -z "${SILENT}" ]] && error.sh "$0 - Task file for task key ${TASK_KEY} already exists!" && exit 1   
fi

exit 0
