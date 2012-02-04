
function usage {
cat <<EOF
usage: file.sh [option] 

A library of file related functionality.

Options:

    check_file_for_literal [literal-expression] [filename]

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

# During initial setup TMP will not be defined yet, so we might need to define it.
TMP=${TMP:-/tmp}
TMPFILE=${TMP}/$$.tmp
trap 'rm ${TMPFILE}* 2> /dev/null' 0

touch ${TMPFILE}

function check_file_exists {
   if [[ ! -f ${FILE} ]]; then
      error.sh "file.sh - File ${FILE} does not exist!"
      exit 1
   fi
}

function check_file_for_literal {
   # Return 1 if literal exists in file. This function is used when you want to check if a string
   # appears in file and the string contains special characters. This function escapes most of 
   # the special characters before greping the file for the string.
   check_file_exists
   # Escape \ $ ; [ ] * ^ . 
   EXPRESSION=$(echo "${LITERAL}" | sed 's/\\/\\\\/g' | sed 's/\$/\\$/g' | sed 's/;/\\;/g' | \
      sed 's/\[/\\\[/g' | sed 's/\]/\\\]/g' | sed 's/\*/\\\*/g' | sed 's/\^/\\^/g' | sed 's/\./\\./g') 
   if $(grep "${EXPRESSION}" ${FILE} 1> /dev/null); then
      echo 1
   else
      echo 0
   fi
}

while (( $# > 0 )); do
   case "${1}" in
      "check_file_for_literal")
         LITERAL="${2}"
         FILE="${3}"
         check_file_for_literal
         ;;
   esac
   shift
done

