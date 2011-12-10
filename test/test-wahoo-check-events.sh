
. ${WAHOO}/test/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting ".wahoo-check-events.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/.wahoo-check-events.sh | wc -l)
endTest

rm ${WAHOO}/log/stderr ${WAHOO}/log/stdout 2> /dev/null

(
cat <<EOF
# Every minute.
@ * * * * * 
  # Touch a file
  touch "\${TMP}/tdd/test1"
  # This is an intentional error, file does not exist. 
  ls file_does_not_exist
  # Testing running a command.
  echo "CONVERT THIS STRING" | str.sh lcase > \${TMP}/tdd/test2
  # Will run on localhost.
  + ${HOSTNAME}
     echo "localhost-schedule1" > \${TMP}/tdd/test3
  # Will not run.
  + NOT${HOSTNAME}
     echo "NOT${HOSTNAME}" > \${TMP}/tdd/failure 
  # Will run.
  + NOT${HOSTNAME}, NOT${HOSTNAME}2,NOT${HOSTNAME}3,${HOSTNAME},NOT${HOSTNAME}4
     touch \${TMP}/tdd/test4 
  # Will not run.
  + NOT${HOSTNAME}, NOT${HOSTNAME}2,NOT${HOSTNAME}3,NOT${HOSTNAME}4
     touch \${TMP}/tdd/failure

! TestEvent
  touch \${TMP}/tdd/test5
    + ${HOSTNAME}
      echo "localhost-event1" > \${TMP}/tdd/test6
    + NOT${HOSTNAME}
      touch \${TMP}/tdd/failure
    + NOT${HOSTNAME}, NOT${HOSTNAME}2,NOT${HOSTNAME}3,${HOSTNAME},NOT${HOSTNAME}4
      touch > \${TMP}/tdd/test7
    + NOT${HOSTNAME}, NOT${HOSTNAME}2,NOT${HOSTNAME}3,NOT${HOSTNAME}4
      touch \${TMP}/tdd/failure

EOF
) > ${TMP}/.wahoo-events

beginTest ".wahoo-check-events.sh"
.wahoo-check-events.sh --file ${TMP}/.wahoo-events
sleep 10
assertTrue $(exist test1 test2 test3 test4)
assertTrue $(grepFile "test2" "convert this string")
endTest

beginTest "Testing --event"
.wahoo-check-events.sh --file ${TMP}/.wahoo-events --event TestEvent
sleep 10
assertTrue $(exist test5 test6 test7)
endTest

beginTest "Errors are written to stderr file."
assertTrue $(grep "ls: cannot access file_does_not_exist: No such file or directory" ${WAHOO}/log/stderr | wc -l)
endTest

# Test an invalid entry.
beginTest "Testing invalid schedule."
echo "@ ** * * * *" > ${TMP}/.wahoo-events
.wahoo-check-events.sh --event TestEvent --file ${TMP}/.wahoo-events 2> ${TMP}/tdd/errors.log
assertTrue $(exist errors.log)
endTest

nowTesting "fire-event.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/fire-event.sh | wc -l)
endTest

beginTest "fire-event.sh TestEvent"
fire-event.sh "TestEvent"
endTest

rm ${WAHOO}/log/stderr ${WAHOO}/log/stdout 2> /dev/null

