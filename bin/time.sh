
function usage {
cat <<EOF
usage: time.sh [options] 

Misc. time functions.

Options:

   "epoch"
       
      # Return seconds since epoch.
      time.sh epoch

      # Return minutes since epoch.
      time.sh epoch --minutes

      # Return hours (not rounded) since epoch.
      time.sh epoch --hours 
      
EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

case "${1}" in
   "epoch") 
       EPOCH=$(perl -e 'printf "%d\n", time;')
       case "${2}" in
         "--hours"  ) printf $(echo "${EPOCH} / 3600" | bc -l) | awk -F"." '{print $1}' ;;
         "--minutes") printf $(echo "${EPOCH} / 60" | bc -l) | awk -F"." '{print $1}'   ;;
         *          ) printf "${EPOCH}"                                                 ;;
       esac
       ;;
esac

