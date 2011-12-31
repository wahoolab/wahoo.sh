#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$(basename $0) $*"

# ToDo: Add logging.

function usage {
cat <<EOF
usage: chevent.sh [options]

Change an event. 

Options:

   --key "[key]"
   --schedule "[schedule]"
   --allow "[list of hosts]"
   --deny "[list of hosts]"

   Please see crevent.sh for explanations of the above options.

   --deny-host "[hostname]"
 
   Add a single host to the list of denied hosts.

   --allow-host "[hostname]"

   Add a single host to the list of allowed hosts.

Examples:

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

EVENT_DIR=${WAHOO}/event
EVENT_KEY=
SCHEDULE=
EVENT_HOST=
ADD_HOST_TO_ALLOW=
ADD_HOST_TO_DENY=
while (( $# > 0)); do
   case $1 in
      --key)         shift; EVENT_KEY="${1}"         ;;
      --schedule)    shift; SCHEDULE="${1}"          ;;
      --allowhost)   shift; ALLOW_HOST="${1}"        ;;
      --denyhost)    shift; DENY_HOST="${1}"         ;;
      --allow)       shift; ADD_HOST_TO_ALLOW="${1}" ;;
      --deny)        shift; ADD_HOST_TO_DENY="${1}"  ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

[[ -z ${EVENT_KEY} ]] && error.sh "$0 - Option \"--key [key]\" is required." && exit 1

EVENT_DIR=${EVENT_DIR}/${EVENT_KEY}

if [[ -d ${EVENT_DIR} ]]; then

   cd ${EVENT_DIR}

   [[ -n "${SCHEDULE}" ]] && echo "${SCHEDULE}" > .schedule  && chmod 600 .schedule

   if [[ -n "${LIST_OF_HOSTS_TO_ALLOW}" ]]; then
      cp /dev/null .allow
      [[ -f .deny ]] && rm .deny
      echo "${LIST_OF_HOSTS_TO_ALLOW}" | str.sh split "," | while read h; do
         echo "${h}" >> .allow
      done
   elif [[ -n ${LIST_OF_HOSTS_TO_DENY} ]]; then
      cp /dev/null .deny
      [[ -f .allow ]] && rm .allow 
      echo "${LIST_OF_HOSTS_TO_DENY}" | str.sh split "," | while read h; do
         echo "${h}" >> .deny
      done
   elif [[ -n ${ADD_HOST_TO_ALLOW} ]]; then
      if [[ ! -f .deny ]]; then
         echo "${ADD_HOST_TO_ALLOW}" >> .allow
      else
         error.sh "$0 - Cannot allow host ${ADD_HOST_TO_ALLOW} to event \"${EVENT_KEY}\". This event uses a deny list."
         exit 1
      fi
   elif [[ -n ${ADD_HOST_TO_DENY} ]]; then
      if [[ ! -s .allow ]]; then
         rm .allow 2> /dev/null
         echo "${ADD_HOST_TO_DENY}" >> .deny
      else
         error.sh "$0 - Cannot deny host ${ADD_HOST_TO_DENY} to event \"${EVENT_KEY}\". This event uses a allow list."
         exit 1
      fi
   fi 

else
   error.sh "$0 - Event \"${EVENT_KEY}\" not found."
   exit 1
fi

exit 0
