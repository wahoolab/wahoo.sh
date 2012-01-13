#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

# WAHOO_DEBUG_LEVEL=3

debug.sh "$$ $(basename $0) $*"

# ToDo: Auto-restart after N hours or N size? Will we have memory leaks using arrays?
# ToDo: Does this program get slower over time?
# ToDo: Start statengined.sh if not running and files found to process in queue.
# ToDo: Should we manage size of output files here? Archiving? 
# ToDo: Should we have a command to dump current output? To be used in "trace" state.
# ToDo: Need a .log file.
# ToDo: Track historical averages? Dump and read every hour? Scoring? Violating KISS?
# ToDo: Aggregation of log files will be done as a separate job.
# ToDo: Respond to SIGHUP to resource variables.
# ToDo: Can I run 100's of instances of this program?

# WAHOO_DEBUG_LEVEL=3

# These must be upper-case.
typeset -u ALLOW_NEGATIVE_VALUES CONVERSION_TYPE

# Counters frequently reset and when that happens the delta between the last and current
# value could be negative. When set to 'N' negative values are replaced with a zero and
# a message is written to the application log.
ALLOW_NEGATIVE_VALUES=N

# Default statengine log file.
STATENGINE_LOG_FILE=${WAHOO}/log/statengine.log

# Default sleep interval.
SLEEP_INTERVAL=60

# Default inbox.
INBOX=${TMP}/statengined/in

DEFAULT_OUTPUT_FILE="${WAHOO}/log/statengine.out"

while (( $# > 0)); do
   case $1 in
      # Seconds to sleep between checking inbox for new items.
      --sleep-interval) shift; SLEEP_INTERVAL="${1}"      ;;
      # Full path to alternate log file.
      --log)            shift; STATENGINE_LOG_FILE="${1}" ;;
      # Full path to alternate inbox.
      --inbox)          shift; INBOX="${1}"               ;;
      # Full path to alternate default output file.
      --output-file)    shift; DEFAULT_OUTPUT_FILE="${1}" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

# Sleep interval must be at least 1 second.
(( ${SLEEP_INTERVAL} <= 0 )) && SLEEP_INTERVAL=1

[[ ! -d ${INBOX} ]] && mkdir -p ${INBOX}
cd ${INBOX} || exit 1

function get_current_time {
   # Very expensive call, limit these!
   echo $(time.sh epoch)
}

function get_value_delta {
   ((VALUE-${last_unconverted_value[$KEY]}))
   # ToDo: How much faster if we don't echo here and just allow VALUE to be set above?
   echo ${VALUE}
}

function get_seconds_delta {
   # ToDo: Potential for error here is last_time is not set. Impact of checking?
   echo $( ((EPOCH_TIME-${last_time[$KEY]})) )
}

# FYI: For arrays foo[${bar}]="x" does not seem to work, use foo[$bar]="x" instead.
unset last_unconverted_value
unset last_time
typeset -A last_converted_value 
typeset -A last_time

# Keep track of total amount of time statengined.sh has been running.
DAEMON_START_TIME=$(get_current_time)
# Keep track of total # of stats processed since start time.
TOTAL_STAT_COUNT=0

applog.sh "$(basename $0) - statengined is alive"

# Main outer loop, keep looping until the program is killed.
while ((1)); do

   debug.sh -3 "$$ pwd=$(pwd)"

   ls | while read f; do

      # Do not process a file unless a "." dot file also exists. This file is written last and you can be sure that
      #  there are no more writes to ${f} when it exists.
      [[ -f .${f} ]] || continue

      # The .${f} is a very small write, but lets wait 1 seconds just to make sure nothing is still writing to it.
      sleep 1 

      PROCESSING_TIME=$(get_current_time)

      debug.sh -3 "Working on file ${f}"

      # Record Format:
      # Statistics Group, Conversion Type (NONE, DELTA, MINUTE, HOUR, DAY), Output File, Statistics Host
      OIFS=${IFS}; IFS=","
      cat .${f} | read STATISTICS_GROUP CONVERSION_TYPE OUTPUT_FILE STATISTICS_HOST DECIMALS

      [[ -z "${DECIMALS}"    ]] && DECIMALS=2
      [[ -z "${OUTPUT_FILE}" ]] && OUTPUT_FILE="${DEFAULT_OUTPUT_FILE}"

      # Record Format:
      # Epoch, Time, Key, Value
      # ToDo: Need to sort oldest to newest in case that has not already been done in the file.
      cat ${f} | while read EPOCH_TIME LONG_TIME KEY VALUE; do
         debug.sh -3 "KEY=${KEY}"
         KEY=$(echo "${KEY}" | str.sh "remove" "." | str.sh "nospace")
         debug.sh -3 "EPOCH_TIME=${EPOCH_TIME}, KEY=${KEY}, VALUE=${VALUE}"
         CONVERTED_VALUE=
         debug.sh -3 "last_unconverted_value[$KEY]=${last_unconverted_value[$KEY]}"
         if [[ -z "${last_unconverted_value[$KEY]}" ]]; then
            debug.sh -3 "key not found"
            if [[ ${CONVERSION_TYPE} == "NONE" ]]; then
               CONVERTED_VALUE="${VALUE}"
            fi
         else
            case ${CONVERSION_TYPE} in
               NONE)
                  CONVERTED_VALUE="${VALUE}"
                  ;;
               DELTA)
                  CONVERTED_VALUE=$(get_value_delta)
                  ;;
               SECOND|MINUTE|HOUR|DAY)
                  DELTA=$(get_value_delta)
                  SECONDS=$(get_seconds_delta)
                  if (( ${SECONDS} > 0 )); then
                     ((CONVERTED_VALUE=DELTA/SECONDS))
                  else
                     CONVERTED_VALUE=0
                  fi
                  ;;
               *)
                  error.sh "$0 - CONVERSION_TYPE \"${CONVERSION_TYPE}\" not found!"
                  # Break out of loop, we can not process this file any furthur.
                  break; 
                  ;;
            esac
         fi 

         case ${CONVERSION_TYPE} in
            MINUTE) ((CONVERTED_VALUE=CONVERTED_VALUE*60))       ;;
            HOUR)   ((CONVERTED_VALUE=CONVERTED_VALUE*60*60))    ;;
            DAY)    ((CONVERTED_VALUE=CONVERTED_VALUE*60*60*24)) ;;
         esac

         debug.sh -3 "Setting last_unconverted_value[$KEY]=${VALUE}"
         last_unconverted_value[$KEY]=${VALUE}
         debug.sh -3 "xyz is ${last_unconverted_value[${KEY}]}"
         last_time[${KEY}]=${EPOCH_TIME}

         if (( ${CONVERTED_VALUE} < 0 )) && [[ ${ALLOW_NEGATIVE_VALUES} != "Y" ]]; then
            CONVERTED_VALUE=0
            applog.sh "$(basename $0) - KEY=\"${KEY}\" returned negative value."
         fi

         if [[ -n ${CONVERTED_VALUE} ]]; then
            OUTPUT="${EPOCH_TIME},${LONG_TIME},${STATISTICS_GROUP},${KEY},$(printf "%.${DECIMALS}f" ${CONVERTED_VALUE}),${CONVERSION_TYPE}" 
            debug.sh -3 "$$ ${OUTPUT}"
            echo "${OUTPUT}" >> "${OUTPUT_FILE}"
         fi
         ((TOTAL_STAT_COUNT=TOTAL_STAT_COUNT+1))
      done
      IFS=${OIFS}
      rm ${f} .${f}
      ((TOTAL_PROCESSING_TIME=TOTAL_PROCESSING_TIME+($(get_current_time)-PROCESSING_TIME)))
      ((TOTAL_DAEMON_RUN_TIME=$(get_current_time)-DAEMON_START_TIME))
      # Todo: This needs to go to the log file.
      if [[ -n ${STATENGINE_LOG_FILE} ]]; then
         echo "TOTALS: STATS=${TOTAL_STAT_COUNT} PROCESSING_TIME=${TOTAL_PROCESSING_TIME} RUN_TIME=${TOTAL_DAEMON_RUN_TIME}" >> ${STATENGINE_LOG_FILE}
      fi
   done
   # Pause and wait a bit before check for new files.
   sleep ${SLEEP_INTERVAL}
   debug.sh -3 "$$ Checking for stats to process"
done

exit 0

