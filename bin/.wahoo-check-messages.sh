#!/tmp/wahoo 

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$$ $(basename $0)"

function usage {
cat <<EOF
usage: .wahoo-check-messages.sh

Check for new messages and process them.

exit 0
EOF
}

[[ "${1}" == "--help" ]] && usage

MESSAGE_DIR="${TMP}/messages"
mkdir -p ${MESSAGE_DIR}
WAHOO_MAIL_PROGRAM=${WAHOO_MAIL_PROGRAM}

debug.sh -3 "WAHOO_MAIL_PROGRAM=${WAHOO_MAIL_PROGRAM}"

while (( $# > 0)); do
   case $1 in
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

find ${MESSAGE_DIR} -type d | while read d; do
   # Ready to process if .send file exists.
   if [[ -f ${d}/.send ]]; then
      debug.sh -2 "$$ Found new message in ${d}"
      if [[ -f ${d}/.emails && -n "${WAHOO_MAIL_PROGRAM}" ]]; then
         debug.sh -3 "$$ Sending emails"
         cat ${d}/.header ${d}/.message | ${WAHOO_MAIL_PROGRAM} -s "$(cat ${d}/.subject)" "$(cat ${d}/.emails)"
      fi          
      if [[ -f ${d}/.pagers && -n "${WAHOO_MAIL_PROGRAM}" ]]; then
         debug.sh -3 "$$ Sending pages"
         cat ${d}/.subject | ${WAHOO_MAIL_PROGRAM} -s "[${WAHOO_DOMAIN}] $(hostname) Page!" "$(cat ${d}/.pagers)"
      fi
      if [[ -f ${d}/.incident ]]; then
         debug.sh -3 "$$ Opening incident"
         # ToDo 
      fi
      if [[ -f ${d}/.document ]]; then
         debug.sh -3 "$$ Saving document"
         # ToDo 
      fi
      rm -rf ${d}
   fi
done

exit 0
