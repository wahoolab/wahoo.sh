
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

if [[ -z ${1} ]]; then
   echo ""
   echo "Select an option."
   echo "-----------------"
   if [[ $(wahoo_status) == "STOPPED" ]]; then
      echo "1) Start"      
      MENU_1=".wahoo-start.sh"
   else
      echo "1) Stop"
      MENU_1=".wahoo-stop.sh"
   fi
   printf "\n%s" "> "
   read MENU
   case ${MENU} in
      1) 
         ${MENU_1} 
         ;;
      *) echo "foo" ;;
   esac
fi

exit 0

case ${1} in  
   "stop")
      ;; 
   "start")
      ;;
   *) 
      error.sh "$0 - Command ${1} is not recognized. Try \"wahoo.sh --help\"." 
      exit 1
      ;;
esac

exit 0
