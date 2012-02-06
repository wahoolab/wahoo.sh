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

  --keywords [keyword1,keyword2]

      Keywords associated with the message.

      PAGE      Sends message to emails defined by \${WAHOO_PAGERS}.
      CRITICAL  Maps to PAGE unless overridden.
      EMAIL     Sends message to emails defined by \${WAHOO_EMAILS}.
      WARNING   Maps to EMAIL unless overridden.
      INFO      Logs the message to \${WAHOO_MESSAGE_LOGS}.
      LOG       Maps to INFO unless overridden.
      INCIDENT  Open an incident.
      TRASH     Don't do anything. Ignore this message.

   --emails [name@domain.com,name@domain.com]

      Send message to these addresses instead of \${WAHOO_EMAILS}.

   --pagers [name@domain.com,name@domain.com]
   
      Send message to these addresses instead of \${WAHOO_PAGERS}.   

   --nolog

      Do not write message to the \${WAHOO_MESSAGE_LOGS}.

   --audit [Directory]
      
      Triggers an audit. The optionsal [Directory] should contain 
      objects expected by the audit.sh script.
     
   --logs [filename1,filename2]

      Log message to one or more files. Message will not be logged to
      \${WAHOO_MESSAGE_LOGS}.

   --incident [key]

      Opens incident using key.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

TMPFILE=${TMP}/$$.tmp
trap 'rm ${TMPFILE} 2> /dev/null' 0

while read -r INPUT; do
   echo "${INPUT}" >> ${TMPFILE}
done

if [[ ! -s ${TMPFILE} ]]; then
   debug.sh -3 "$$ no input, exiting"
   exit 0
fi

debug.sh -1 "$$ $(basename $0) $*"

. ${WAHOO}/bin/.wahoo-functions.sh

# Create a unique directory which will store the message for processing.
MESSAGE_DIR=${TMP}/messages/$(time.sh epoch)-$$
mkdir -p ${MESSAGE_DIR}

HOSTNAME=$(hostname)
NOLOG=
DOCUMENT=
SUBJECT=
EVENT_NAME=
FIRE_EVENT=
TESTING="Y"
WAHOO_MESSAGE_LOGS="${WAHOO_MESSAGE_LOGS}"
while (( $# > 0)); do
   case $1 in
      --subject) 
         shift
         SUBJECT="${1}" 
         ;;
      --nolog)
         WAHOO_MESSAGE_LOGS= 
         ;;
      --logs|--log) 
         shift; 
         WAHOO_MESSAGE_LOGS="${1}" 
         ;;
      --keywords|--keyword )
         shift
         MESSAGE_KEYWORDS="${1}"
         ;;
      --audit)
         # Feature not complete, just stubbing out for now.
         audit.sh 
         ;;
      --document) 
         shift
         DOCUMENT="${1}"
         ;;
      --emails|--email) 
         shift
         WAHOO_EMAILS="${1}" 
         ;;
      --pagers|--pager) 
         shift
         WAHOO_PAGERS="${1}"
         ;;
      --incident)
         shift
         INCIDENT="${1}"
         ;;
      --fire)
         shift
         FIRE_EVENT="${1}" 
         ;;
      --test) 
         TESTING="Y"
         MESSAGE_DIR="${TMP}/test"
         ;;
      *) break 
         ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

cd ${MESSAGE_DIR} || (error.sh "$0 - Message folder ${MESSAGE_DIR} not found!" && exit 1)
mv ${TMPFILE} ${MESSAGE_DIR}/.message

if [[ -n ${MESSAGE_KEYWORDS} ]]; then
   # This is from .wahoo-functions.sh
   replace_keywords_using_overrides "${MESSAGE_KEYWORDS}" | while read k; do
      debug.sh -3 "$$ k=${k}"
      case ${k} in
         CRITICAL|PAGE)
            [[ -n "${WAHOO_PAGERS}" ]] && echo ${WAHOO_PAGERS} > .pagers
            [[ -n "${WAHOO_EMAILS}" ]] && echo ${WAHOO_EMAILS} > .emails
            ;;
         WARNING|EMAIL)
            [[ -n "${WAHOO_EMAILS}" ]] && echo ${WAHOO_EMAILS} > .emails
            ;;
         INFO|LOG)
            # Nothing to do here, logging is on by default for all keywords.
            ;;
         INCIDENT)
            # If a key is not provided create a generic one.
            [[ -z ${INCIDENT} ]] && INCIDENT="$(time.sh ymd-hms)-$$"
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

# Ensure there is a subject.
[[ -z ${SUBJECT} ]] && SUBJECT=$(cat .message | str.sh "noblank" | head -1)
echo "${SUBJECT}" > .subject

# Build the header file.
header > .header

# Write to one or more log files.
echo "${WAHOO_MESSAGE_LOGS}" | str.sh "split" "," | while read f; do
   [[ -n ${f} ]] && cat .header .message >> ${f} 
done 

# Write document name to .document if defined.
[[ -n ${DOCUMENT} ]] && echo "${DOCUMENT}" > .document

# Write incident ID to .incident if defined.
[[ -n ${INCIDENT} ]] && echo "${INCIDENT}" > .incident 

# This is the "ready to process" flag.
touch .send

exit 0
