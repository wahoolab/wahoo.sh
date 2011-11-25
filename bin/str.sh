
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

   "split"

   "nospace"

   "noblank"

   "nocomment"
  
   "left"

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

TMPFILE=${TMP}/$$.tmp
trap 'rm ${TMPFILE}* 2> /dev/null' 0

OIFS="${IFS}"; IFS=
while read -r INPUT; do
   echo "${INPUT}" >> ${TMPFILE}
done
IFS=${OIFS}

function convert_case {
   (
   while read -r INPUT; do
      echo "${INPUT}"
   done
   ) < ${TMPFILE} > ${TMPFILE}.2 
   mv ${TMPFILE}.2 ${TMPFILE}
}

function split_string {
   cat ${TMPFILE} | tr "${SPLITTER}" "\n" > ${TMPFILE}.2
   mv ${TMPFILE}.2 ${TMPFILE}
}

function nospace {
   sed 's/ //g' ${TMPFILE} > ${TMPFILE}.2
   mv ${TMPFILE}.2 ${TMPFILE}
}

function noblank {
   egrep -v "^ *$|^$" ${TMPFILE} > ${TMPFILE}.2
   mv ${TMPFILE}.2 ${TMPFILE}
}

function nocomment {
   egrep -v "^ *#" ${TMPFILE} > ${TMPFILE}.2
   mv ${TMPFILE}.2 ${TMPFILE}
}

function left {
   typeset -l INPUT
   (
   while read -r INPUT; do
      echo "${INPUT}"
   done
   ) < ${TMPFILE} > ${TMPFILE}.2
   mv ${TMPFILE}.2 ${TMPFILE}
}

while (( $# > 0 )); do
   case "${1}" in
      "upper"|"ucase") 
         typeset -u INPUT
         convert_case
         ;;
      "lower"|"lcase")
         typeset -l INPUT
         convert_case
         ;;
      "split")
         SPLITTER=${2:-":"}
         split_string
         ;;
      "nospace")
         nospace
         ;;
      "noblank")
         noblank     
         ;;
      "nocomment")
         nocomment
         ;;
      "left")
         left
         ;;
   esac
   shift
done

cat ${TMPFILE}
