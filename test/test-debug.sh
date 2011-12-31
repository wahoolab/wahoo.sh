
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/debug.sh
beginTest "--help Option"
assertHelp
endTest

beginTest "Writing to default debug.log file"
WAHOO_DEBUG_LEVEL=3
DEBUG_STRING="x$(date)x" && sleep 1
debug.sh "${DEBUG_STRING}"
assertOne $(grepMatch ${WAHOO_DEBUG_LOG} "${DEBUG_STRING}")
endTest

WAHOO_DEBUG_LOG=${TEST_FILE}

beginTest "Writing to non-default debug.log file"
DEBUG_STRING="x$(date)x" && sleep 1
debug.sh "${DEBUG_STRING}"
assertOne $(grepMatch ${WAHOO_DEBUG_LOG} "${DEBUG_STRING}")
endTest

for l in 0 1 2 3; do 
   WAHOO_DEBUG_LEVEL=${l}
   # No zero in the next list, you can't make a "debug.sh -0" call.
   for i in 1 2 3; do
      beginTest "Writing debug -${i} with WAHOO_DEBUG_LEVEL=${l}"
      DEBUG_STRING="x$(date)x" && sleep 1
      debug.sh -${i} "${DEBUG_STRING}"
      if (( ${WAHOO_DEBUG_LEVEL} > 0 && ${i} <= ${WAHOO_DEBUG_LEVEL} )); then      
         assertOne $(grepMatch ${TEST_FILE} "${DEBUG_STRING}")
      elif (( ${WAHOO_DEBUG_LEVEL} > 0 && ${i} > ${WAHOO_DEBUG_LEVEL})); then
         assertZero $(grepMatch ${TEST_FILE} "${DEBUG_STRING}")
      else 
         assertZero $(grepMatch ${TEST_FILE} "${DEBUG_STRING}")
      fi
      endTest
   done
done

