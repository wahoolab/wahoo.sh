
. ${WAHOO}/tests/functions.sh

now_testing "debug.sh"

check_for_help_option ${WAHOO}/bin/debug.sh

NAME="Writing to default debug.log file"
WAHOO_DEBUG_LEVEL=3
DEBUG_STRING="x$(date)x" && sleep 1
debug.sh "${DEBUG_STRING}"
if $(grep "${DEBUG_STRING}" ${WAHOO_DEBUG_LOG} 1> /dev/null); then
   success
else
   failure
fi

NAME="Writing to non-default debug.log file"
WAHOO_DEBUG_LOG=/tmp/debug.log
DEBUG_STRING="x$(date)x" && sleep 1
debug.sh "${DEBUG_STRING}"
if $(grep "${DEBUG_STRING}" ${WAHOO_DEBUG_LOG} 1> /dev/null); then
   success
else
   failure
fi

for l in 0 1 2 3; do 
   WAHOO_DEBUG_LEVEL=${l}
   # No zero in the next list, you can't make a "debug.sh -0" call.
   for i in 1 2 3; do
      NAME="Writing debug -${i} with WAHOO_DEBUG_LEVEL=${l}"
      DEBUG_STRING="x$(date)x" && sleep 1
      debug.sh -${i} "${DEBUG_STRING}"
      if $(grep "${DEBUG_STRING}" ${WAHOO_DEBUG_LOG} 1> /dev/null); then
         if (( ${WAHOO_DEBUG_LEVEL} > 0 && ${i} <= ${WAHOO_DEBUG_LEVEL} )); then
            success
         else
            failure
         fi
      else
         if (( ${WAHOO_DEBUG_LEVEL} > 0 && ${i} <= ${WAHOO_DEBUG_LEVEL} )); then
            failure
         else
            success
         fi         
      fi
   done
done


