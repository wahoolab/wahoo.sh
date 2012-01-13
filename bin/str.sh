
function usage {
cat <<EOF
usage: str.sh [option] 

Perform string related actions to standard input.

Options:

   "ucase" or "upper"
      
      Convert input to uppercase.
      # Example
      echo "foo" | str.sh ucase

   "lcase" or "lower"

      Convert input to lower case.

   "split" [delim]

      Split list of items using [delim]. Default [delim]
      is a colon ":".

   "nospace"

      Remove spaces.

   "noblank"

      Remove blank lines.

   "nocomment"
  
      Remove Unix syle comments.

   "left"

      Left justify.

   "remove" [character]

      Remove all occurances of character.

   "count" [character]

      Return the count of characters found in input.

   "replace" [characters] [character]

      Replace any characters with character.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

# During initial setup TMP will not be defined yet, so we might need to define it.
TMP=${TMP:-/tmp}
TMPFILE=${TMP}/$$.tmp
trap 'rm ${TMPFILE}* 2> /dev/null' 0

touch ${TMPFILE}
# OIFS="${IFS}"; IFS=
while read -r INPUT; do
   echo "${INPUT}" >> ${TMPFILE}
done
# IFS=${OIFS}

function character_count {
   COUNT=$(grep "${1}" -o ${TMPFILE} | wc -l)
   debug.sh -3 "$$ str.sh character_count found ${COUNT} ${1}"
   echo ${COUNT}
}

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

function remove_character {
   tr -d "${1}" < ${TMPFILE} > ${TMPFILE}.2
   mv ${TMPFILE}.2 ${TMPFILE}   
}

function replace_characters {
   tr "${1}" "${2}" < ${TMPFILE} > ${TMPFILE}.2
   mv ${TMPFILE}.2 ${TMPFILE}
}

function left {
   # typeset -L INPUT
   (
   while read -r INPUT; do
      echo "${INPUT}"
   done
   ) < ${TMPFILE} > ${TMPFILE}.2
   mv ${TMPFILE}.2 ${TMPFILE}
}

NOCAT=
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
      "remove")
         shift
         remove_character ${1}
         ;;
      "count")
         character_count "${2}"
         NOCAT=Y
         ;;
      "replace")
         replace_characters "${2}" "${3}"
         shift; shift
         ;;
   esac
   shift
done

[[ -z ${NOCAT} ]] && cat ${TMPFILE}
