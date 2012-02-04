#!/tmp/wahoo 

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0)"

function usage {
cat <<EOF
usage: .wahoo-mock-mail [options] [name@domain.com,name@domain.com]

This is a mock email program if mail or mailx is not configured 
and only meant to be used for testing environments.

Options:

   -s [subject]

Arguments:

   [name@domain.com,name@domain.com]
 
      List of one or more email addresses.
   
exit 0
EOF
}

[[ "${1}" == "--help" ]] && usage

mkdir -p ${TMP}/test

SUBJECT=
MOCK_MAIL_LOG="${TMP}/test/mail.log"

while (( $# > 0)); do
   case $1 in
      -s) shift; SUBJECT="${1}" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

[[ -z "${EMAILS}" ]] && exit 1

echo "SUBJECT=${SUBJECT} EMAILS=${1}"  >> ${MOCK_MAIL_LOG}
while read -r INPUT; do 
   echo "${INPUT}" >> ${MOCK_MAIL_LOG}
done

exit 0
