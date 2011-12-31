#!/tmp/wahoo

TMPFILE=${TMP}/$$.tmp
trap 'rm ${TMPFILE} 2> /dev/null' 0

FILE=
while (( $# > 0)); do
   case $1 in
      --file) shift; FILE="${1}" ;;
      --line) shift; LINE="${1}" ;;
      *) break ;;
   esac
   shift
done
(( $(has.sh option $*) )) && error.sh "$0 - \"$*\" contains an unrecognized option." && exit 1

LINE_REGEX=$(echo "${LINE}" | sed 's/\\/\\\\/g' | sed 's/\$/\\$/g' | sed 's/;/\\;/g' | sed 's/\[/\\\[/g' | sed 's/\]/\\\]/g' | sed 's/\*/\\\*/g')

[[ ! -f ${FILE} ]] && touch ${FILE}

if ! $(grep "${LINE_REGEX}" ${FILE} 1> /dev/null); then
   echo "${LINE}" >> ${FILE}
fi

exit 0

