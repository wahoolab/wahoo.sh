
function usage {
cat <<EOF
$LINE1
usage: str.sh [option] 

Perform string related actions to standard input.

Options:

   "ucase" or "upper"
      
      Convert input to uppercase.
      # Example
      echo "foo" | str.sh ucase

   "lcase" or "lower"

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

function convert_case {
   echo "${1}"
}

CONVERSION_FUNCTION=
case "${1}" in
   "upper"|"ucase") 
      typeset -u INPUT
      CONVERSION_FUNCTION="convert_case"
      ;;
   "lower"|"lcase")
      typeset -l INPUT
      CONVERSION_FUNCTION="convert_case"
      ;;
esac

while read INPUT; do
   ${CONVERSION_FUNCTION} "${INPUT}"
done
