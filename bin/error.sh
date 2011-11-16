
function WriteError {
   echo "$(date) ERROR: ${1}" 3>&1 1>&2 2>&3
}

if [[ -n "${1}" ]]; then
   WriteError "${1}"
else
   while read INPUT; do
      WriteError "${INPUT}"
   done
fi

debug.sh -1 "ERROR: ${1}"

