#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

# WAHOO_DEBUG_LEVEL=2
debug.sh -2 "$0 $*"

function usage {
cat <<EOF
usage: crontab.sh [options] 

Check if cron style options match current time. Exit 0 or 1.
0 on match, 1 on no match.

Options:

   --minute [minute(s)]              

      # Match if time is like 12:05, 01:05, 02:05...
      crontab.sh --minute 5

      # Match if minutes after hour between 15 and 30.
      crontab.sh --minute 15-30

      # Match if minutes after hour either 10, 20 or 30.
      crontab.sh --minute 10,20,30

   --hour [hour(s)]
      
      # Match if time is 6:00 AM.
      crontab.sh --minute 0 --hour 6

      # Match if time is 6:00 PM.
      crontab.sh --minute 0 -hour 18

      # Match every minute between 6:00 AM and 6:59 AM.
      crontab.sh -hour 6

   --day-of-month [day(s) of month]
   
      # Match if it is 3:15 PM on the 8'th day of the month.
      crontab.sh --minute 15 -hour 15 -day-of-month 8

   --month [month(s)]

     # Match if it is Aug at 8:00 AM
     crontab.sh --minute 0 -hour 8 -month 8

   --day-of-week [day(s) of week]

     # Match if it is 5:15 PM on Monday.
     crontab.sh --minute 15 -hour 17 -day-of-week 1

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

MINUTE="*"
HOUR="*"
DAY_OF_WEEK="*"
MONTH="*"
DAY_OF_MONTH="*"

while (( $# > 0)); do
   case $1 in
      --minute) shift; MINUTE="${1}" ;;
      --hour) shift; HOUR="${1}" ;;
      --day-of-week) shift; DAY_OF_WEEK="${1}" ;;
      --month) shift; MONTH="${1}" ;;
      --day-of-month) shift; DAY_OF_MONTH="${1}" ;;
      --schedule) 
         shift
         echo "${1}" | sed 's/\*/\\\*/g' | read MINUTE HOUR DAY_OF_WEEK MONTH DAY_OF_MONTH
         ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option) )) && error.sh "$0 - $* contains an unrecognized option." && exit 1

for o in "${MINUTE}" "${HOUR}" "${DAY_OF_WEEK}" "${MONTH}" "${DAY_OF_MONTH}"; do
   [[ -z ${o} ]] && error.sh "$0 - Schedule has an error. MINUTE=${MINUTE},HOUR=${HOUR},DAY_OF_WEEK=${DAY_OF_WEEK},MONTH=${MONTH},DAY_OF_MONTH=${DAY_OF_MONTH}" && exit 1
done

function exact_match {
   (( $1 == $2 )) && echo "${MATCH}"
}

function within_range {
   LEFT=$(echo ${1}  | awk -F"-" '{ print $1 }')
   RIGHT=$(echo ${1} | awk -F"-" '{ print $2 }')
   (( ${2} >= ${LEFT} && ${2} <= ${RIGHT} )) && echo "${MATCH}"
}

function in_list {
   echo ${1} | str.sh split "," | while read VALUE; do
      (( ${VALUE} == ${2} )) && echo "${MATCH}" && break
   done
}

function check_for_match {
# If $1 contains a "-" then we have a range.
if (( $(echo ${1} | grep "-" | wc -l) )); then
   MATCH=$(within_range ${1} ${2})
# If #1 contains a "," we have a list.
elif (( $(echo ${1} | grep "," | wc -l) )); then
   MATCH=$(in_list ${1} ${2})
# Else we have a single number to match on.
else
   MATCH=$(exact_match ${1} ${2})
fi
echo ${MATCH}
}

MATCH="MATCH"
[[ ${MATCH} == "MATCH" && ${MINUTE} != "*" ]] && MATCH=$(check_for_match "${MINUTE}" $(date "+%M"))
[[ ${MATCH} == "MATCH" && ${HOUR} != "*" ]] && MATCH=$(check_for_match "${HOUR}" $(date +"%H"))
[[ ${MATCH} == "MATCH" && ${DAY_OF_MONTH} != "*" ]] && MATCH=$(check_for_match "${DAY_OF_MONTH}" $(date +"%d"))
[[ ${MATCH} == "MATCH" && ${MONTH} != "*" ]] && MATCH=$(check_for_match "${MONTH}" $(date +"%m"))
[[ ${MATCH} == "MATCH" && ${DAY_OF_WEEK} != "*" ]] && MATCH=$(check_for_match "${DAY_OF_WEEK}" $(date +"%w"))

if [[ "${MATCH}" == "MATCH" ]]; then
   exit 0
else
   exit 1 
fi
