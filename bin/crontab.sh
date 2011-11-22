#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$0"

set -x

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
      *) break ;;
   esac
   shift
done
(( $(has.sh option) )) && error.sh "$0 - $* contains an unrecognized option." && exit 1

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

echo "match=${MATCH}"

if [[ "${MATCH}" == "MATCH" ]]; then
   exit 0
else
   exit 1 
fi
