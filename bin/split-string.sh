
SPLITTER=${1:-":"}

while read INPUT; do
   echo "${INPUT}" | tr "${SPLITTER}" "\n"
done

