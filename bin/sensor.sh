#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0) $*"

function usage {
cat <<EOF
usage: sensor.sh

Returns output when change in input is detected.

Options:

   --key

     Unique string which identifies the sensor.

   --try

     # of times to test the sensor before triggering output.

   --no-change

     Output returned when no changes are detected.

   --no-header

     Do not include a header in the sensor output.     

   --clear [key]

     Used to reset a sensor using the unique sensor key.
 
EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

SENSOR_DIR=${TMP}/sensor
[[ ! -d ${SENSOR_DIR} ]] && mkdir ${SENSOR_DIR}

ALLOWABLE_TRIES=0
NOCHANGE=
NOHEADER=
COMMAND_LINE="$0 $*"
CLEAR=
while (( $# > 0)); do
   case $1 in
      --key) shift; SENSOR_KEY="${1}" ;;
      --try) shift; ALLOWABLE_TRIES="${1}" ;; 
      --no-change) NOCHANGE="NOCHANGE" ;;
      --no-header) NOHEADER="NOHEADER" ;;
      --clear) CLEAR="CLEAR" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

SENSOR_DIR=${SENSOR_DIR}/${SENSOR_KEY}
[[ ! -d ${SENSOR_DIR} ]] && mkdir ${SENSOR_DIR}

cd ${SENSOR_DIR} || error.sh "$0 - Count not change to directory ${SENSOR_DIR}."

if [[ -n "${CLEAR}" ]]; then
   rm .sensor-input .sensor-input-old .tries .diff 2> /dev/null     
   exit 0
fi

# debug.sh -3 "$0 - pwd=$(pwd)"
cp /dev/null .sensor-input
while read -r INPUT; do
   echo "${INPUT}" >> .sensor-input
done

function return_with_header {
cat <<EOF
$(date) Triggered!

"${COMMAND_LINE}"

Differences detected shown below.
${LINE1}
$(cat .diff)
Most recent sensor input shown below.
${LINE1}
$(cat .sensor-input)
EOF
}

function return_without_header {
$(cat .diff)
}

function trigger_sensor {
( [[ -n ${NOHEADER} ]] && return_without_header || return_with_header ) | tee -a ${SENSOR_KEY}.log
}

if [[ ! -f .sensor-input-old ]]; then
   cp .sensor-input .sensor-input-old
else
   # cat .sensor-input | debug.sh -3
   # cat .sensor-input-old | debug.sh -3
   diff .sensor-input-old .sensor-input > .diff
   # debug.sh -3 "$$ NOCHANGE=${NOCHANGE}"
   # debug.sh -3 "$$ $(ls -alrt .diff)"
   if [[ -z ${NOCHANGE} && -s .diff ]] || [[ -n ${NOCHANGE} && ! -s .diff ]]; then
      echo "$(date) Miss!" >> ${SENSOR_KEY}.log
      date >> .tries
      debug.sh -3 "$$ TRIES=$(wc -l < .tries) ALLOWABLE_TRIES=${ALLOWABLE_TRIES}"
      if (( $(wc -l < .tries) > ${ALLOWABLE_TRIES} )); then
         trigger_sensor
         cp .sensor-input .sensor-input-old
         debug.sh -2 "$$ Sensor \"${SENSOR_KEY}\" Triggered"
      fi
   else
      cp /dev/null .tries
   fi
fi

exit 0
