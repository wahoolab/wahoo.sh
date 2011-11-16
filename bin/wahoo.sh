
# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

# ToDo: Make sure "setup" runs automatically anytime the WAHOO_VERSION changes.
WAHOO_VERSION=1

function usage {
cat <<EOF
$LINE1
Usage: wahoo.sh [options] [arguments] 

Perform misc. actions within Wahoo.

Options:
   "set"
      Set a parameter in the ~/.wahoo config file.
      wahoo.sh set SIMPLE_HOST_NAME="dev-db"
   "setup"
      Run setup.
   "version"
      Return Wahoo version number.

Future:
   "start"
      Start Wahoo.
   "stop"
      Stop Wahoo.
   "save"
      Create a backup copy of current Wahoo install.
   "restore"
      Restore a backup copy of Wahoo to current install.

EOF
exit 0
}

(( $# == 0)) && usage

function set_wahoo_parm {
   TEMPFILE=$$.temp
   PARAMETER="${1}"
   VALUE="${2}"
   # Get line # for this parameter.
   LINE_NUMBER=$(grep -n "^${PARAMETER}=" ~/.wahoo | awk -F":" '{print $1}' | tail -1)
   if [[ -n ${LINE_NUMBER} ]]; then
      (
      ((LINE_NUMBER=LINE_NUMBER-1))
      if (( $LINE_NUMBER > 0 )); then
         # Output up to the previous line number.
         sed -n "1,${LINE_NUMBER}p" ~/.wahoo
      fi
      # Output the new parameter=value string.
      echo "${PARAMETER}=${VALUE}"
      # Output from the next line number to the end of the file.
      ((LINE_NUMBER=LINE_NUMBER+2))
      sed -n "${LINE_NUMBER},999999p" ~/.wahoo
      ) > ${TEMPFILE}
   fi
   [[ -s ${TEMPFILE} ]] && mv ${TEMPFILE} ~/.wahoo
}

case ${1} in  
   "set") 
      shift; set_wahoo_parm "$(echo $* | cut -d"=" -f1)" "$(echo $* | cut -d"=" -f2)"
      ;;
   "setup") 
      if [[ $0 != "wahoo.sh" && $0 != "./wahoo.sh" && $0 != $(pwd)/wahoo.sh ]]; then
         echo "Error: setup must be run from the \${WAHOO_HOME}/bin directory." && exit 1
      else
         ./.wahoo-setup.sh
      fi
      ;;
   "version")
      echo ${WAHOO_VERSION} 
      ;;
   *) # Option is not recognized. ToDo: Throw error and usage.
      ;;
esac

