#!/tmp/wahoo

function usage {
cat <<EOF
usage: statengine.sh [options] 

Options:

  --start

    Start the statengine daemon (statengined.sh).
   
  --stop

    Stop the statengine daemon. Warning, if \${STATENGINE} is
    non-zero the scheduler will restart the daemon.

  --check-daemon
      
    Checks the value of \${STATENGINE} and starts the daemon 
    if it is non-zero.

  --group "[group-name]"
  
    Define a group to associate with the values. Defaults to 
    "statengine".

  --/min

    Instructs statengine to convert values to the rate per
    minute.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

TMPFILE=${TMP}/$$.tmp
trap 'rm ${TMPFILE} 2> /dev/null' 0

INBOX=${TMP}/statengined/in
[[ ! -d ${INBOX} ]] && mkdir -p ${INBOX}

function get_statengine_processes {
   for p in $(ps -ef | grep "statengined.sh" | grep -v "grep" | awk '{print $2}'); do
      echo ${p}
   done
}

function statengine_is_running {
   if (( $(ps -ef | grep "statengined.sh" | grep -vc "grep") > 0 )); then
      echo 1
   else
      echo 0
   fi
}

function start_statengine {
   SLEEP_INTERVAL=${1:-60}
   if ! (( $(statengine_is_running) )); then
      statengined.sh --sleep-interval ${SLEEP_INTERVAL} &
      sleep 1
      if ! (( $(statengine_is_running) )); then
         error.sh "statengine.sh - Failed to start."
      fi
   fi
}

function daemon_may_restart_message {
   if [[ -n ${STATENGINE} ]]; then
      if (( ${STATENGINE} > 0 )); then
         cat <<EOF

   NOTE: The \${STATENGINE} configuration variable is set and 
   the statengine daemon will be restart automatically if the
   task scheduler is running. 

EOF
      fi
   fi
}

function stop_statengine {
   if (( $(statengine_is_running) )); then
      get_statengine_processes | while read i; do    
         kill -9 ${i}
      done 
      sleep 1
      if (( $(statengine_is_running) )); then
         error.sh "statengine.sh - Failed to stop."
      fi 
   fi
}

function check_daemon {
   # Defined in your config file.
   STATENGINE=${STATENGINE:-0}
   if (( ${STATENGINE} > 0 )); then
      if ! (( $(statengine_is_running) )); then
         start_statengine ${STATENGINE}
      fi
   fi
}

GROUP="statengine"
CONVERSION_TYPE="NONE"
while (( $# > 0)); do
   case $1 in
      --group) 
         shift; GROUP="${1}"      
         ;;
      --/min)         
         CONVERSION_TYPE="MINUTE" 
         ;;
      --start)        
         start_statengine        
         exit 0
         ;;
      --stop)         
         stop_statengine
         daemon_may_restart_message  
         exit 0
         ;;
      --check-daemon) 
         check_daemon 
         exit 0
         ;;
      --output-file)
	 shift
         OUTPUT_FILE="${1}"
	 ;;
      *) break 
	 ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

while read -r INPUT; do
   echo "${INPUT}" >> ${INBOX}/${GROUP}.$$
done

echo "${GROUP},${CONVERSION_TYPE},${OUTPUT_FILE}" >> ${INBOX}/.${GROUP}.$$

exit 0
