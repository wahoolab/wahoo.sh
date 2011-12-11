#!/tmp/wahoo

[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

debug.sh "$0 $*"

function usage {
cat <<EOF
usage: fire-event.sh [read-below]

Triggers execution of scripts found in the event folder for this event.

This script can be called in one of two ways.

fire-event.sh --event [name-of-event]

fire-event.sh [name-of-event]
  
[name-of-event] should match one of the folder names in \${WAHOO}/event 
or \${WAHOO}/event/\$(hostname).

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

while (( $# > 0)); do
   case $1 in
      --event) shift; EVENT_NAME="${1}" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

[[ -z ${EVENT_NAME} ]] && EVENT_NAME="${1}" 

# Event name should be defined by now!
[[ -z ${EVENT_NAME} ]] && exit 1 

FOUND_EVENT_FLAG=
# Search through the two possibile directories for a folder matching the event name.
for f in ${WAHOO}/event ${WAHOO}/event/$(hostname); do
   # The directory should exist because it is created during install.
   cd ${f} || (error.sh "$0 - Directory ${f} not found!" && exit 1)
   # It is possible the event does not exist in both directories, continue if not found.
   cd ${EVENT_NAME} 2> /dev/null || continue
   # Set a flag that we found the event in at least one of the two directories.
   FOUND_EVENT_FLAG="Y"
   # Execute all files found with the exception of the patterns here.
   for f in $(ls | egrep -v "README|\.txt$|\.log$"); do
      # Sleep here in the event we hit some sort of recursive error we don't totally spin out of control too fast.
      sleep 1
      runscript.sh ${f} &
   done
done

# Not finding the event in one of the two directories is an error.
[[ -z ${FOUND_EVENT_FLAG} ]] && error.sh "$0 - Event \"${EVENT_NAME}\" was not recognized!" && exit 1

exit 0
