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

     Applies task to all servers in Wahoo domain.

   --minutes [n]

     Quit running the task after [n] minutes. If [n]=0
     the command will only execute once.
     Default: 0

   --hours [n]

     Quit running the task after [n] hours. If [n]=0 the
     command will only execute once.

   --remove "[key]"

     Remove task using key.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

TASK_DIR=${TMP}/tasks
[[ ! -d ${TASK_DIR} ]] && mkdir ${TASK_DIR}

TASK_KEY=
SCHEDULE="* * * * *"
QUIT_TASK_AFTER_MINUTES=
TASK_SCOPE="$(hostname)"
FORCE=
while (( $# > 0)); do
   case $1 in
      --key) shift; TASK_KEY="${1}" ;;
      --command) shift; COMMAND="${1}" ;;
      --schedule) shift; SCHEDULE="${1}" ;;
      --minutes) shift; QUIT_TASK_AFTER_MINUTES="${1}" ;;
      --hours) shift; ((QUIT_TASK_AFTER_MINUTES=60*${1})) ;;
      --domain) shift; TASK_SCOPE="${WAHOO_DOMAIN}" ;;
      --remove) shift; rm ${TASK_DIR}/${1} 2> /dev/null; exit 0 ;;
      --force) FORCE="FORCE" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

[[ -z ${TASK_KEY} ]] && error.sh "$0 - Option \"--key [key]\" is required!" && exit 1
[[ -z ${COMMAND} ]] && error.sh "$0 - Option \"--commmand [command]\" is required!" && exit 1

TASK_FILE=${TASK_DIR}/${TASK_KEY}

if [[ ! -f ${TASK_FILE} || -n ${FORCE} ]]; then
   echo "${TASK_SCOPE}:${TASK_KEY}:${SCHEDULE}:$(time.sh epoch --minutes):${QUIT_TASK_AFTER_MINUTES}:${COMMAND}" > ${TASK_FILE} 
else
   error.sh "$0 - Task file for task key ${TASK_KEY} already exists!" && exit 1   
fi

exit 0
