#!/tmp/wahoo

# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh -2 "$0"

# pages and logs should get at least one time in log file so they are simple to see when sent.

function usage {
cat <<EOF
usage: route-message.sh [options] [subject] [addresses]

Routes a message using the keywords provided.

Options:

  --keywords ["KEYWORD,KEYWORD"]

    List of keywords to associate with this message. Keywords are used
    to map the message to a particular action (such as log, email or
    page). A keyword also triggers an event by the same name. 

  --emails ["email@foo.com,email@foo.com"]

    List of emails to send the message to. Typically messages
    which are routed to email are sent to \${WAHOO_EMAILS} unless
    this option is defined.  Note this does not mean the message will be 
    sent to these addresses. The message is only sent if the message
    triggers an email based upon the keywords provided.

  --pagers ["email@foo.com,email@foo.com"]
   
    Same as above with the exception that the email addresses should
    trigger pages and the default addresses are defined by 
    \${WAHOO_PAGERS}. Note this does not mean the message will be 
    sent to these addresses. The message is only sent if the message
    triggers a page based upon the keywords provided.

  --nolog

    Prevents message from being written to log files. 

  --audit

    Message is logged to the file defined by \${WAHOO_AUDIT_LOG}.

  --log [filename]

    Message is logged to the file defined by [filename] instead
    of the default log file defined by \${WAHOO_MESSAGE_LOG}.  

  --incident [id]

    Id to identify an incident. This causes the message to get grouped 
    into a single folder.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

MESSAGE_FOLDER=${TMP}/messages/$(time.sh epoch)-$$
mkdir -p ${MESSAGE_FOLDER}

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

cd ${MESSAGE_FOLDER} || (error.sh "$0 - Message folder ${MESSAGE_FOLDER} not found!" && exit 1)

if [[ -n ${MESSAGE_KEYWORDS} ]]; then
   .wahoo-keyword-override.sh "${MESSAGE_KEYWORDS}" | while read k; do
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

while read -r INPUT; do
   echo "${INPUT}" >> .message
done

if [[ -s .message ]]; then

   # If there is a message and --fire is defined, we need to fire the event.
   [[ -n ${FIRE_EVENT} ]] && fire-event.sh --event "${FILE_EVENT}" 

   [[ -z ${SUBJECT} ]] && SUBJECT=$(cat .message | str.sh noblank | head -1) 
   echo ${SUBJECT} > .subject 
   header > .header 
   for f in ${WAHOO_MESSAGE_LOG} ${MESSAGE_LOGS} ${AUDIT_LOG}; do
      cat .header .message >> ${f} 
      tdd.sh log "LOGFILE=${f}"
   done 
   if [[ -n ${DOCUMENT} ]]; then 
      echo "${DOCUMENT}" > .document
   fi
   if [[ -n ${INCIDENT} ]]; then
      echo "${INCIDENT}" > .incident 
   fi
   touch .send
fi

if [[ ! -f .emails && ! -f .pagers && ! -f .document && ! -f .incident ]]; then
   cd ..; rm -rf ${MESSAGE_FOLDER}
else
   for f in $(find ${MESSAGE_FOLDER} -type f); do
      tdd.sh copy ${f}
   done
fi

exit 0
