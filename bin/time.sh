
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

   "y-m-d h:m:s"
   
      Return time in format YYYY-MM-DD HH:MI:SS.

   "ymd-hms"

      Return time in format YYYYMMDD-HHMISS.

   "csv"

      Return multiple date fields in a comma separated list.
      Format returns 
      epoch,year,month,day,hour,minute,seconds,date time

    "statengine"

      Returns date time in format required for statengine input.
      Format returns
      epoch,YYYY-MM-DD HH:MI:SS 
     

EOF
exit 0
}

[[ "${1}" == "--help" ]] && usage

debug.sh -3 "$$ $(basename $0) $*"

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
   "y-m-d h:m:s")
       date +"%Y-%m-%d %H:%M:%S"
      ;;
   "csv")
      echo "$(epoch),$(date +'%Y,%m,%d,%H,%M,%S,%m/%d/%Y %H:%M')"
      ;;
   "statengine")
      echo "$(epoch),$(date +'%Y-%m-%d %H:%M:%S')"
      ;;
esac

