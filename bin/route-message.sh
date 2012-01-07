#!/tmp/wahoo

# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

# pages and logs should get at least one time in log file so they are simple to see when sent.

function usage {
cat <<EOF
usage: route-message.sh [options] [subject] [addresses]

Routes a message using the keywords provided.

Options:

  --keywords [one-or-more-keywords]

    List of keywords associated with this message. Keywords map the message 
    to one or more actions. Separate multiple keywords with commas.

    PAGE      Send message to "\${WAHOO_PAGERS}" address list.
    CRITICAL  Same as PAGE.
    EMAIL     Send message to "\${WAHOO_EMAILS}" address list.
    WARNING   Same as EMAIL.
    INFO      Log the message in the \${WAHOO_MESSAGE_LOG}.
    LOG       Same as INFO.
    INCIDENT  This message triggers the opening of an incident ticket.
    TRASH     Ignore this message and exit.

  --emails [one-or-more-emails]

    Overrides the default email list (\${WAHOO_EMAILS}). Separate multiple
    addresses with commas.

  --pagers [one-or-more-emails]
   
    Overrides the default pager list (\${WAHOO_PAGERS}). Separate multiple
    addresses with commas.

  --nolog [filename]

    Prevents message from being written to log files. 

  --audit [filename]

    Message is logged to the file defined by \${WAHOO_AUDIT_LOG}. Note, the 
    --nolog option does not prevent writing to the audit log.

  --log [filename]

    Message is logged to the file defined by [filename] instead
    of the default log file (\${WAHOO_MESSAGE_LOG}).

  --incident [incident-id]

    Unique ID used to open a new incident if one is not already open.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

TMPFILE=${TMP}/$$.tmp
trap 'rm ${TMPFILE} 2> /dev/null' 0

while read -r INPUT; do
   echo "${INPUT}" >> ${TMPFILE}
done

[[ ! -s ${TMPFILE} ]] && exit 0

debug.sh -1 "$$ $(basename $0) $*"

. ${WAHOO}/bin/.wahoo-functions.sh

# This should only already be set when running test-route-message.sh
MESSAGE_FOLDER=${MESSAGE_FOLDER:-${TMP}/messages/$(time.sh epoch)-$$}

mkdir -p ${MESSAGE_FOLDER}
cd ${MESSAGE_FOLDER} || (error.sh "$0 - Message folder ${MESSAGE_FOLDER} not found!" && exit 1)
mv ${TMPFILE} ${MESSAGE_FOLDER}/.message

MESSAGE_DIRS=
AUDIT_LOG=
NOLOG=
DOCUMENT=
SUBJECT=
EVENT_NAME=
FIRE_EVENT=
while (( $# > 0)); do
   case $1 in
      --subject  ) shift; SUBJECT="${1}" ;;
      --nolog    )        WAHOO_MESSAGE_LOG="" ;;
      --log      ) shift; WAHOO_MESSAGE_LOG="${1}" ;;
      --keywords ) shift; MESSAGE_KEYWORDS="${1}" ;;
      --audit    )        AUDIT_LOG="${WAHOO_AUDIT_LOG}" ;;
      --document ) shift; DOCUMENT="${1}" ;;
      --emails   ) shift; WAHOO_EMAILS="${1}" ;;
      --pagers   ) shift; WAHOO_PAGERS="${1}" ;;
      --incident ) shift; INCIDENT="${1}" ;;
      --fire     ) shift; FIRE_EVENT="${1}" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

if [[ -n ${MESSAGE_KEYWORDS} ]]; then
   # This is from .wahoo-functions.sh
   replace_keywords_using_overrides "${MESSAGE_KEYWORDS}" | while read k; do
      case ${k} in
         CRITICAL|PAGE)
            echo ${WAHOO_PAGERS} > .pagers
            echo ${WAHOO_EMAILS} > .emails
            ;;
         WARNING|EMAIL)
            echo ${WAHOO_EMAILS} > .emails
            ;;
         INFO|LOG)
            # Nothing to do here, logging is on by default for all keywords.
            WAHOO_MESSAGE_LOG=${WAHOO_MESSAGE_LOG}
            ;;
         INCIDENT)
            if [[ -z ${INCIDENT} ]]; then
               INCIDENT="$(time.sh ymd-hms)-$$"
            fi
            ;;
         TRASH)
            return
            ;;
         *)
            error.sh "$0 - KEYWORD ${k} is not recognized! Will use \"LOG\" instead."
            ;;
      esac
   done
fi

function header {
cat <<EOF
${LINE1}
[${WAHOO_DOMAIN}] ${SIMPLE_HOSTNAME:-${HOSTNAME}} ${SUBJECT}
$(date)
$(whoami)@$(hostname)
${LINE1}
EOF
}

# If there is a message and --fire is defined, we need to fire the event.
[[ -n ${FIRE_EVENT} ]] && fire-event.sh --event "${FILE_EVENT}" 

[[ -z ${SUBJECT} ]] && SUBJECT=$(cat .message | str.sh noblank | head -1) 
echo ${SUBJECT} > .subject 
header > .header 
for f in ${WAHOO_MESSAGE_LOG} ${MESSAGE_LOGS} ${AUDIT_LOG}; do
   cat .header .message >> ${f} 
done 
if [[ -n ${DOCUMENT} ]]; then 
   echo "${DOCUMENT}" > .document
fi
if [[ -n ${INCIDENT} ]]; then
   echo "${INCIDENT}" > .incident 
fi
touch .send

if [[ ! -f .emails && ! -f .pagers && ! -f .document && ! -f .incident ]]; then
   if [[ "${MESSAGE_FOLDER}" != "${TMP}/test" ]]; then
      cd ..; rm -rf ${MESSAGE_FOLDER}
   fi
fi

exit 0
