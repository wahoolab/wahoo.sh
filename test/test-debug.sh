
. ${WAHOO}/test/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "debug.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/debug.sh | wc -l)
endTest

beginTest "Writing to default debug.log file"
WAHOO_DEBUG_LEVEL=3
DEBUG_STRING="x$(date)x" && sleep 1
debug.sh "${DEBUG_STRING}"
assertTrue $(grep "${DEBUG_STRING}" ${WAHOO_DEBUG_LOG} | wc -l)
endTest

WAHOO_DEBUG_LOG=${TMP}/tdd/debug.log

beginTest "Writing to non-default debug.log file"
DEBUG_STRING="x$(date)x" && sleep 1
debug.sh "${DEBUG_STRING}"
assertTrue $(grep "${DEBUG_STRING}" ${WAHOO_DEBUG_LOG} | wc -l)
endTest

for l in 0 1 2 3; do 
   WAHOO_DEBUG_LEVEL=${l}
   # No zero in the next list, you can't make a "debug.sh -0" call.
   for i in 1 2 3; do
      beginTest "Writing debug -${i} with WAHOO_DEBUG_LEVEL=${l}"
      DEBUG_STRING="x$(date)x" && sleep 1
      debug.sh -${i} "${DEBUG_STRING}"
      if (( ${WAHOO_DEBUG_LEVEL} > 0 && ${i} <= ${WAHOO_DEBUG_LEVEL} )); then      
         assertTrue $(grepFile "debug.log" "${DEBUG_STRING}") 
      elif (( ${WAHOO_DEBUG_LEVEL} > 0 && ${i} > ${WAHOO_DEBUG_LEVEL})); then
         assertFalse $(grepFile "debug.log" "${DEBUG_STRING}")
      else 
         assertFalse $(grepFile "debug.log" "${DEBUG_STRING}")
      fi
      endTest
   done
done

