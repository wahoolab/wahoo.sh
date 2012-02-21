#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

# WAHOO_DEBUG_LEVEL=3

function usage {
cat <<EOF
usage: statengine.sh [options] 

Options:

   --start

     Start the statengine daemon (statengined.sh).
   
   --stop

     Stop the statengine daemon. Warning, if \${STATENGINE} is
     non-zero the scheduler will restart the daemon.

   --kill

     Kill the statengine daemon.

   --group "[group-name]"
  
     Define a group to associate with the values. Defaults to 
     "statengine".

   --/min

     Instructs statengine to convert values to the rate per
     minute.

   --output-file "[file-name]"

     Instructs statengine to store stat history in a specific
     file.

   --stathost "[hostname]"

     Hostname the stats originate from (defaults to localhost).

   --decimals "[integer]"

     The number of decimals to store.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

debug.sh -2 "$$ $(basename $0) $*"

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
      applog.sh "Starting statengine"
      statengined.sh --sleep-interval ${SLEEP_INTERVAL} &
      sleep 1
      if ! (( $(statengine_is_running) )); then
         error.sh "statengine.sh - Failed to start."
      fi
   fi
}

function kill_statengine {
   if (( $(statengine_is_running) )); then
      applog.sh "Killed statengined"
      get_statengine_processes | while read i; do
         kill -9 ${i}
      done 
      sleep 1 
      if (( $(statengine_is_running) )); then
         error.sh "statengine.sh - Failed to kill statengined"
      fi 
   fi
}

function stop_statengine {
   PID=$(cat ${INBOX}/.pid 2> /dev/null)
   if [[ -n ${PID} ]]; then
      if (( $(ps -ef | grep "${PID}" | grep "statengined" | grep -v "grep" | wc -l) )); then
         kill ${PID}
         i=0
         while (( ${i} < 120 )); do
            ((i=i+1))
            if (( $(ps -ef | grep "${PID}" | grep "statengined" | grep -v "grep" | wc -l) == 0 )); then
               applog.sh "Stopped statengined"
               break
            fi
            sleep 1
         done
         if (( ${i} == 120 )); then
            kill_statengine
         fi
      fi
   fi
}

GROUP="statengine"
CONVERSION_TYPE="NONE"
STATHOST="$(hostname)"
DECIMALS=2
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
         exit 0
         ;;
      --kill)
         kill_statengine
         exit 0
         ;;
      --output-file)
	 shift
         OUTPUT_FILE="${1}"
	 ;;
       --stathost)
         shift
         STATHOST="${1}" 
         ;;
        --decimals)
         shift
         DECIMALS="${1}"
         ;;
      *) break 
	 ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

l=0
TIME=
while read -r INPUT; do
   debug.sh -3 "INPUT=${INPUT}"
   # If time is not part of input we will add it.
   if (( ${l} == 0 )); then
      ((l=l+1))
      if (( $(echo "${INPUT}" | str.sh "count" ",") < 2 )); then
         TIME="$(time.sh statengine),"
      fi
   fi
   echo "${TIME}${INPUT}" >> ${INBOX}/${GROUP}.$$
   debug.sh -3 "$$ ${TIME}${INPUT}"
done

echo "${GROUP},${CONVERSION_TYPE},${OUTPUT_FILE},${STATHOST},${DECIMALS}" >> ${INBOX}/.${GROUP}.$$

exit 0
