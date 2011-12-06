
function usage {
cat <<EOF
usage: tdd.sh [option] [arguments]

Test Driven Development support utility.

Options:

   touch [filename]

      Create empty file [filename] in tdd folder.

   copy [filename]

      Copy a file to tdd folder.
   
   log ["message"]

      Log a mesage to the tdd.log file.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

[[ -z "${WAHOO_TESTING}" ]] && return

[[ ! -d ${TMP}/tdd ]] && mkdir ${TMP}/tdd

case "${1}" in
    "touch")
       touch ${TMP}/tdd/${2}
       ;;
    "copy")
       cp "${2}" ${TMP}/tdd/
       ;;
    "log")
       echo "${2}" >> ${TMP}/tdd/tdd.log
       ;;
esac
