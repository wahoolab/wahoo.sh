
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
      
   "y-m-d"

     Return date in format YYYY-MM-DD.

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

function epoch {
echo $(perl -e 'printf "%d\n", time;')
}
case "${1}" in
   "epoch") 
       EPOCH=$(epoch)
       case "${2}" in
         "--hours"  ) printf $(echo "${EPOCH} / 3600" | bc -l) | awk -F"." '{print $1}' ;;
         "--minutes") printf $(echo "${EPOCH} / 60" | bc -l) | awk -F"." '{print $1}'   ;;
         *          ) printf "${EPOCH}"                                                 ;;
       esac
       ;;
   "y-m-d")
      date +"%Y-%m-%d"
      ;;
   "ymd-hms")
      date +"%Y%m%d-%H%M%S"
      ;;
   "tuple")
      echo "$(epoch),$(date +'%Y,%m,%d,%H,%M,%S,%m/%d/%Y %H:%M')"
      ;;
esac

