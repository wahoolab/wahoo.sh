
# Attempt to load ~/.wahoo configuration file.
[[ -f .wahoo ]] && $(. .wahoo 2> /dev/null)
[[ -f ~/.wahoo ]] && . ~/.wahoo

function usage {
cat <<EOF
usage: wahoo.sh [command] [options] [arguments] 

General command utility for Wahoo.

   wahoo.sh start

      Start running scheduled tasks.

   wahoo.sh stop 

      Stop running scheduled tasks.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

function wahoo_status {
   if [[ -f /tmp/.wahoo-stop ]]; then
      echo "STOPPED"
   else
      echo "STARTED"
   fi
}

if [[ -n ${1} ]]; then
   COMMAND="${1}"
else
   COMMAND1=
   echo ""
   echo "Select an option."
   echo "-----------------"
   if [[ $(wahoo_status) == "STOPPED" ]]; then
      echo "1) Start"      
      COMMAND1="start"
   else
      echo "1) Stop"
      COMMAND1="stop"
   fi
   printf "\n%s" "> "
   read MENU
   case ${MENU} in
      1) 
         COMMAND=${COMMAND1}
         ;;
   esac
fi

case "${COMMAND}" in
   "stop")
      .wahoo-stop.sh
      ;; 
   "start")
      .wahoo-start.sh
      ;;
   *) 
      error.sh "$0 - Command ${1} is not recognized. Try \"wahoo.sh --help\"." 
      exit 1
      ;;
esac

exit 0
