

function usage {
cat <<EOF
usage: error.sh "[string]"

Takes input and directs it back out to standard error. If "[string]" is not 
provided then it is assumed input is being piped in.

Note:

   error.sh "Program Name - Your error message here."
   # Returns the following to standard error.
   Thu Nov 17 00:52:31 CST 2011 ERROR: Program Name - Your error message here.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

function WriteError {
   echo "${1}" 3>&1 1>&2 2>&3
}

if [[ -n "${1}" ]]; then
   WriteError "${1}"
else
   # Not liking this for now.
   # WriteError "$(date) WRITING INPUT FROM STANDARD IN"
   while read INPUT; do
      WriteError "${INPUT}"
   done
   # WriteError "$(date) DONE"
fi

# This does not work with std in so removing for now.
# debug.sh -1 "ERROR: ${1}"
