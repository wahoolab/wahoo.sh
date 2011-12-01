#!/tmp/wahoo

# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$0"

function usage {
cat <<EOF
usage: mail.sh [options] [subject] [addresses]

Script that...

Options:

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

TMPFILE=${TMP}/$$.tmp
trap 'rm ${TMPFILE} 2> /dev/null' 0

MAX_LINES=1000000
while (( $# > 0)); do
   case $1 in
      --max) shift; MAX_LINES="${1}" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option) )) && error.sh "$0 - $* contains an unrecognized option." && exit 1

SUBJECT="${1}"
WAHOO_MAIL_TO="${2}"

c=0
while read -r INPUT; do
   echo "${INPUT}" >> ${TMPFILE}
   ((c=c+1))
   if (( ${c} > ${MAX_LINES} )); then
      echo "Wahoo: Emails are limited to ${MAX_LINES}!" && break
   fi
done

if [[ -s ${TMPFILE} ]]; then
   ${WAHOO_MAIL_PROGRAM} -s "${SUBJECT}" "${WAHOO_MAIL_TO}" < ${TMPFILE}
fi

exit 0

