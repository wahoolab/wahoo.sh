#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$0"

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

ALLOWABLE_TRYS=0
NOCHANGE=
NOHEADER=
COMMAND_LINE="$0 $*"
CLEAR=
while (( $# > 0)); do
   case $1 in
      --key) shift; SENSOR_KEY="${1}" ;;
      --try) shift; ALLOWABLE_TRYS="${1}" ;; 
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

cd ${SENSOR_DIR}

if [[ -n "${CLEAR}" ]]; then
   rm in-1 in-2 t d 2> /dev/null     
   exit 0
fi

cp /dev/null in-1
while read -r INPUT; do
   echo "${INPUT}" >> in-1
done

function return_with_header {
cat <<EOF
The following sensor has been triggered.

   "${COMMAND_LINE}"

Differences detected shown below.
${LINE1}
$(cat d)

Most recent sensor input shown below.
${LINE1}
$(cat in-2)
EOF
}

function return_without_header {
$(cat d)
}

if [[ ! -f in-2 ]]; then
   cp in-1 in-2
else
   diff in-2 in-1 > d
   if [[ -z ${NOCHANGE} && -s d ]]; then
      date >> t
      if (( $(cat t | wc -l) > ${ALLOWABLE_TRYS} )); then
         [[ -n ${NOHEADER} ]] && return_without_header || return_with_header
         cp in-1 in-2
      fi 
   elif [[ -n ${NOCHANGE} && ! -s d ]]; then
      date >> t
      if (( $(cat t | wc -l) > ${ALLOWABLE_TRYS} )); then
         [[ -n ${NOHEADER} ]] && return_without_header || return_with_header
         cp in-1 in-2
      fi
   else
      cp /dev/null t
   fi
fi

exit 0
