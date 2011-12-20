#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

# debug.sh "$$ $(basename $0) $*"

# ToDo: Auto-restart after N hours or N size? Will we have memory leaks using arrays?
# ToDo: Does this program get slower over time?
# ToDo: Start statengined.sh if not running and files found to process in queue.
# ToDo: Should we manage size of output files here? Archiving? 
# ToDo: Should we have a command to dump current output? To be used in "trace" state.
# ToDo: Need a .log file.
# ToDo: Track historical averages? Dump and read every hour? Scoring? Violating KISS?
# ToDo: Aggregation of log files will be done as a separate job.

WAHOO_DEBUG_LEVEL=0

# ToDo: These options need to be in the .${f} file.
DECIMALS=2
typeset -u ALLOW_NEGATIVE_VALUES CONVERSION_TYPE
ALLOW_NEGATIVE_VALUES=N

# ToDo: Might want to allow a seperate daemons to look in different work queues.
STATENGINE_INBOX=${TMP}/statengine/
[[ ! -d ${STATENGINE_INBOX} ]] && mkdir -p ${STATENGINE_INBOX}
cd ${STATENGINE_INBOX} || exit 1

function get_current_time {
   # Very expensive call, limit these.
   echo $(time.sh epoch)
}

function get_value_delta {
   ((VALUE-${last_unconverted_value[$KEY]}))
   if (( ${VALUE} < 0 )) && [[ ${ALLOW_NEGATIVE_VALUES} != "Y" ]]; then
      VALUE=0
      # ToDo: May want to log some sort of warning here.
   fi
   # ToDo: How much faster if we don't echo here and just allow VALUE to be set above?
   echo ${VALUE}
}

function get_seconds_delta {
   # ToDo: Potential for error here is last_time is not set. Impact of checking?
   echo $( ((STAT_TIME-${last_time[$KEY]})) )
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

# Main outer loop, keep looping until the program is killed.
while ((1)); do

   # Looking for files in inbox.
   ls | while read f; do

      # Do not process a file unless a "." dot file also exists. This file is written last and you can be sure that
      #  there are no more writes to ${f} when it exists.
      [[ -f .${f} ]] || continue

      # The .${f} is a very small write, but lets wait 1 seconds just to make sure nothing is still writing to it.
      sleep 1 

      PROCESSING_TIME=$(get_current_time)

      # debug.sh -3 "Working on file ${f}"

      # Record Format:
      # [METRIC_GROUP_NAME],[CONVERSION_TYPE IN NONE|DELTA|MINUTE|HOUR|DAY]
      # cat .${f} | read CONVERSION_TYPE
      OIFS=${IFS}; IFS=","
      cat .${f} | read METRIC_GROUP CONVERSION_TYPE

      # Record Format:
      # [EPOCH],[KEY],[VALUE]
      # ToDo: Need to sort oldest to newest in case that has not already been done in the file.
      cat ${f} | while read STAT_TIME KEY VALUE; do
         # debug.sh -3 "STAT_TIME=${STAT_TIME}, KEY=${KEY}, VALUE=${VALUE}"
         CONVERTED_VALUE=
         # debug.sh -3 "last_unconverted_value[$KEY]=${last_unconverted_value[$KEY]}"
         if [[ -z ${last_unconverted_value[$KEY]} ]]; then
            # debug.sh -3 "key not found, setting converted value to zero"
            if [[ ${CONVERSION_TYPE} == "NONE" ]]; then
               CONVERTED_VALUE="${VALUE}"
            else
               CONVERTED_VALUE=
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

         # debug.sh -3 "Setting last_unconverted_value[$KEY]=${VALUE}"
         last_unconverted_value[$KEY]=${VALUE}
         # debug.sh -3 "xyz is ${last_unconverted_value[${KEY}]}"
         last_time[${KEY}]=${STAT_TIME}
         if [[ -n ${CONVERTED_VALUE} ]]; then
            # ToDo: Do we need to figure out how to use time tuple here?
            # Todo: How are we going to define the output file here?
            echo "${STAT_TIME},${METRIC_GROUP},${KEY},$(printf "%.${DECIMALS}f" ${CONVERTED_VALUE}),${CONVERSION_TYPE}" >> $TMP/statengine.log
         fi
         ((TOTAL_STAT_COUNT=TOTAL_STAT_COUNT+1))
      done
      IFS=${OIFS}
      rm ${f} .${f}
      ((TOTAL_PROCESSING_TIME=TOTAL_PROCESSING_TIME+($(get_current_time)-PROCESSING_TIME)))
      ((TOTAL_DAEMON_RUN_TIME=$(get_current_time)-DAEMON_START_TIME))
      # Todo: This needs to go to the log file.
      echo "TOTALS: STATS=${TOTAL_STAT_COUNT} PROCESSING_TIME=${TOTAL_PROCESSING_TIME} RUN_TIME=${TOTAL_DAEMON_RUN_TIME}"
   done
   # Pause and wait a bit before check for new files.
   # ToDo: This needs to be an option and must be >= 1.
   sleep 5
done

exit 0

