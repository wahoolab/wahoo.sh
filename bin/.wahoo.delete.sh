
# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

WAHOO_VERSION=20110203

function usage {
cat <<EOF
usage: wahoo.sh [command] [options] [arguments] 

General command utility for Wahoo.

   wahoo.sh status

      Return a list of statistics regarding the operation of Wahoo.

   wahoo.sh find "string"

      Search for a string in all wahoo related scripts and files.

   wahoo.sh tar

      Create a tarball in \${WAHOO_HOME}/.. which can be used to install
      Wahoo. tmp, log and domain directories are removed before
      packaging the current \${WAHOO_HOME}.

   wahoo.sh log
 
      # Log a message to application log file \${WAHOO}/log/wahoo.log
      wahoo.sh log "Message"

   wahoo.sh test

      Run the test suite.

   wahoo.sh version

      Return Wahoo version number.

   wahoo.sh config [options] {PARAMETER} "{VALUE}"

      Set or add parameter value, or edit parameter file. If PARAMETER is not
      specified the config file is opened for direct edits.

      Options:

      --domain              Use domain config file.

      Examples:

      # Edit the LOCAL_CONFIG_FILE (~/.wahoo).
      wahoo.sh config 
 
      # Edit the DOMAIN_CONFIG_FILE (\${WAHOO}/domain/\${WAHOO_DOMAIN}/.wahoo)
      wahoo.sh config --domain

      # Set or add parameter "PROD" to "Y" in LOCAL_CONFIG_FILE.
      wahoo.sh config PROD "Y"

   # Items below this line have not been implemented yet.

   wahoo.sh start

      Start running scheduled tasks.

   wahoo.sh stop 

      Stop running scheduled tasks.

   wahoo.sh save [path]

      Create a backup copy of current Wahoo home. [path] is an optional
      argument and defaults to the directory above \${WAHOO_HOME}. The 
      file will be saved as a compressed tarball.
   
   wahoo.sh restore [file]    

      Restore a backup copy of Wahoo to current install. [file] is an 
      optional argument and defaults to the most recently saved tarball if it
      is not provided.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

[[ -n ${WAHOO} ]] && . ${WAHOO}/bin/.wahoo-functions.sh

function set_wahoo_parm {
   TEMPFILE=$$.temp
   PARAMETER="${1}"
   VALUE="${2}"
   (( $(has.sh "space" "${VALUE}") )) && VALUE="\"${VALUE}\""
   CONFIG_FILE="${3}"
   # Get line # for this parameter.
   LINE_NUMBER=$(grep -n "^${PARAMETER}=" ${CONFIG_FILE} | awk -F":" '{print $1}' | tail -1)
   if [[ -n ${LINE_NUMBER} ]]; then
      (
      ((LINE_NUMBER=LINE_NUMBER-1))
      if (( $LINE_NUMBER > 0 )); then
         # Output up to the previous line number.
         sed -n "1,${LINE_NUMBER}p" ${CONFIG_FILE}
      fi
      # Output the new parameter=value string.
      echo "${PARAMETER}=${VALUE}"
      # Output from the next line number to the end of the file.
      ((LINE_NUMBER=LINE_NUMBER+2))
      sed -n "${LINE_NUMBER},999999p" ${CONFIG_FILE}
      ) > ${TEMPFILE}
   else
      ( echo "# Added on $(date) by wahoo.sh config."
        echo "${PARAMETER}=${VALUE}" ) >> ${CONFIG_FILE}
   fi
   [[ -s ${TEMPFILE} ]] && mv ${TEMPFILE} ${CONFIG_FILE}
}

function wahoo_status {
cat <<EOF
Wahoo Size (MB)              : $(expr $(du -sk $WAHOO | awk '{print $1}') / 1024)
EOF
}

case ${1} in  
   "status")
      wahoo_status
      ;; 
   "find")
      for d in bin domain event plugin; do
         find ${WAHOO}/${d} -type f | while read f; do
            egrep -iH "${2}" ${f}
         done
      done
      ;;
   "log")
      # We just re-use debug.sh for our purposes here.
      WAHOO_DEBUG_LEVEL=1
      WAHOO_DEBUG_LOG=${WAHOO}/log/wahoo.log
      debug.sh "${2}"
      ;;
   "config") 
      shift
      if [[ "${1}" == "--domain" ]]; then
          shift; CONFIG_FILE=${DOMAIN_CONFIG_FILE}
      else
          CONFIG_FILE=${LOCAL_CONFIG_FILE}
      fi
      if [[ -z "${1}" ]]; then
         vi ${CONFIG_FILE}
      else
         set_wahoo_parm "${1}" "${2}" "${CONFIG_FILE}"
      fi
      ;;
   "test")
      ${WAHOO}/tests/run-all.sh
      ;;
   "version")
      echo ${WAHOO_VERSION} 
      ;;
   "tar") 
      create_tarball_for_release
      ;;
   *) error.sh "$0 - Command ${1} is not recognized. Try \"wahoo.sh --help\"." && exit 1
      ;;
esac

exit 0
