#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$(basename $0) $*"

function usage {
cat <<EOF
usage: rmevent.sh [options]

Remove an event. 

Options:

   --key "[key]"

     Unique string used to identify the event.

Examples:

    # Remove event foo, return error if event does not exist.
    rmevent.sh --key foo

    # Remove event foo and do not return error if event does not exist.
    rmevent.sh --key foo --silent

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

EVENT_DIR=${WAHOO}/event
EVENT_KEY=
SILENT=
while (( $# > 0)); do
   case $1 in
      --key) shift; EVENT_KEY="${1}" ;;
      --silent) SILENT="Y" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

[[ -z ${EVENT_KEY} ]] && error.sh "$0 - Option \"--key [key]\" is required." && exit 1

if [[ -n ${SILENT} ]]; then
   crevent.sh --remove "${EVENT_KEY}" 
else
   crevent.sh --remove "${EVENT_KEY}" --silent
fi

exit 0
