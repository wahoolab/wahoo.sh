
. ${WAHOO}/tests/functions.sh

now_testing ".wahoo-check-jobs.sh"
# Prep
(
rm ${TMP}/test 
rm ${WAHOO}/log/stderr ${WAHOO}/log/stdout 
rm ${TMP}/test-convert.tmp 
) 2> /dev/null
(
cat <<EOF
# Every minute.
@ * * * * * 
  touch "\${TMP}/test"
  ls /file_does_not_exist
  echo "CONVERT THIS STRING" | str.sh lcase > \${TMP}/test-convert.tmp
  + ${HOSTNAME}
     echo "localhost-schedule1"
  + NOT${HOSTNAME}
     echo "localhost-schedule2"
  + NOT${HOSTNAME}, NOT${HOSTNAME}2,NOT${HOSTNAME}3,${HOSTNAME},NOT${HOSTNAME}4
     echo "localhost-schedule3"
  + NOT${HOSTNAME}, NOT${HOSTNAME}2,NOT${HOSTNAME}3,NOT${HOSTNAME}4
     echo "localhost-schedule4"

! ExampleEvent
  touch "\${TMP}/test"
    + ${HOSTNAME}
      echo "localhost-event1"
    + NOT${HOSTNAME}
      echo "localhost-event2"
    + NOT${HOSTNAME}, NOT${HOSTNAME}2,NOT${HOSTNAME}3,${HOSTNAME},NOT${HOSTNAME}4
      echo "localhost-event3"
    + NOT${HOSTNAME}, NOT${HOSTNAME}2,NOT${HOSTNAME}3,NOT${HOSTNAME}4
      echo "localhost-event4"

EOF
) > ${TMP}/.wahoo-jobs

check_for_help_option ${WAHOO}/bin/.wahoo-check-jobs.sh
NAME="Touch file every minute."
rm ${TMP}/test 2> /dev/null
.wahoo-check-jobs.sh --file ${TMP}/.wahoo-jobs
sleep 10
if [[ -f ${TMP}/test ]]; then
   success
else
   failure
fi
rm ${TMP}/test 2> /dev/null

NAME="Writing to standard error."
if $(grep "cannot access \/file_does_not_exist" ${WAHOO}/log/stderr > /dev/null 2>&1); then
   success
else
   failure
fi

NAME="Running .sh script from \${WAHOO}/bin"
if $( grep "convert this string" ${TMP}/test-convert.tmp > /dev/null 2>&1); then
   success
else
   failure   
fi

NAME="Testing ExampleEvent"
rm ${TMP}/test 2> /dev/null
.wahoo-check-jobs.sh --event ExampleEvent --file ${TMP}/.wahoo-jobs
sleep 10
if [[ -f ${TMP}/test ]]; then
   success
else
   failure
fi
rm ${TMP}/test 2> /dev/null

NAME="Event runs on localhost."
if $(grep "localhost-event1" ${WAHOO}/log/stdout > /dev/null 2>&1); then
   success
else
   failure
fi

NAME="Event runs on localhost (list of hosts)."
if $(grep "localhost-event3" ${WAHOO}/log/stdout > /dev/null 2>&1); then
   success
else
   failure
fi

NAME="Event does not runs on localhost (list of hosts)."
if $(grep "localhost-event4" ${WAHOO}/log/stdout > /dev/null 2>&1); then
   failure
else
   success
fi

NAME="Schedule runs on localhost only."
if $(grep "localhost-schedule1" ${WAHOO}/log/stdout > /dev/null 2>&1); then
   success
else
   failure
fi

NAME="Schedule does not run on localhost."
if $(grep "localhost-schedule2" ${WAHOO}/log/stdout > /dev/null 2>&1); then
   failure
else
   success
fi

NAME="Schedule runs on localhost only (list of hosts)."
if $(grep "localhost-schedule3" ${WAHOO}/log/stdout > /dev/null 2>&1); then
   success
else
   failure
fi

NAME="Schedule does not run on localhost (list of hosts)."
if $(grep "localhost-schedule4" ${WAHOO}/log/stdout > /dev/null 2>&1); then
   failure
else
   success
fi

# Test an invalid entry.
(
cat <<EOF
@ ** * * * *
EOF
) > ${TMP}/.wahoo-jobs
.wahoo-check-jobs.sh --event Foo --file ${TMP}/.wahoo-jobs


