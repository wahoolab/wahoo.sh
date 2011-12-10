#!/tmp/wahoo

TMP=${TMP:-/tmp}
OLDFILE="${1}"
NEWFILE="${2}"
TMPFILE=${TMP}/$$.tmp
trap 'rm ${TMPFILE} 2> /dev/null' 0

(
cat ${NEWFILE} | while read -r NEWLINE; do
   # If the line is a parameter...
   if $(echo "${NEWLINE}" | egrep "^[A-Z].*=" | egrep -v "^#|^WAHOO=|^WAHOO_HOME=" 1> /dev/null); then
      # Get the line from the old file.
      NEW_PARAMETER=$(echo ${NEWLINE} | awk -F"=" '{print $1}')
      OLDLINE=$(grep "^${NEW_PARAMETER}=" ${OLDFILE})
      # If the lines do not match.
      if [[ "${NEWLINE}" != "${OLDLINE}" && -n ${OLDLINE} ]]; then
         NEWLINE="${OLDLINE}"
      fi
   fi
   echo "${NEWLINE}"
done
) > ${TMPFILE}

mv ${TMPFILE} ${NEWFILE}

exit 0

