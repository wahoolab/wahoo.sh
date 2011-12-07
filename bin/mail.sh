#!/tmp/wahoo

# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$0 $*"

function usage {
cat <<EOF
usage: mail.sh [options] [subject] [addresses]

Script for sending email.

Options:

   --max [integer]

     Maximum number of lines allowed in the email. If limit is
     reached, the remaining lines are discarded.

Examples:

   mail.sh "This is the subject" "john@doe.com,jane@doe.com" < some_file.txt

   echo foo | mail.sh "This is the subject" "john@doe.com,jane@doe.com"

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

TMPFILE=${TMP}/$$.tmp
trap 'rm ${TMPFILE}* 2> /dev/null' 0

MAX_LINES=1000000
while (( $# > 0)); do
   case $1 in
      --max) shift; MAX_LINES="${1}" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

SUBJECT="${1}"
WAHOO_MAIL_TO="${2}"

[[ -z ${SUBJECT} ]] && SUBJECT="Mail: $(hostname) @ $(date) from $(whoami)"
WAHOO_MAIL_TO=${WAHOO_MAIL_TO:-${WAHOO_EMAILS}}
[[ -z ${WAHOO_MAIL_TO} ]] && (error.sh "$0 - One or more email addresses must be defined." && exit 1)

while read -r INPUT; do
   echo "${INPUT}" >> ${TMPFILE}
done

head -${MAX_LINES} ${TMPFILE} > ${TMPFILE}.2 

# mail or mailx works for mail program.
${WAHOO_MAIL_PROGRAM} -s "${SUBJECT}" "${WAHOO_MAIL_TO}" < ${TMPFILE}.2

tdd.sh log "LINES=$(cat ${TMPFILE}.2 | wc -l)"

exit 0

