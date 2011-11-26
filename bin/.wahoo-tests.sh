
. ~/.wahoo

function now_testing {
   cat <<EOF
${LINE1}
${1}
${LINE1}
EOF
}

function success {
   printf "%-60s%20s\n" "${NAME}" "OK"    
}

function failure {
   printf "%-60s%20s\n" "${NAME}" "*FAIL*"
}

function todo {
   printf "%-60s%20s\n" "${NAME}" "?"
}

function check_for_help_option {
   FILE="${1}"
   NAME="Check for --help option"
   if $(grep "\-\-help" "${FILE}" 1> /dev/null); then
      success
   else
      failure
   fi
}

now_testing "Configuration Files"

NAME="Check for LOCAL_CONFIG_FILE"
if [[ -f ${LOCAL_CONFIG_FILE} ]]; then
   success
else
   failure
fi

NAME="Check for DOMAIN_CONFIG_FILE"
if [[ -f ${DOMAIN_CONFIG_FILE} ]]; then
   success
else
   failure
fi

now_testing "PATH Variable"
NAME="${WAHOO}/bin In Path"
if (( $(echo ${PATH} | egrep "${WAHOO}/bin" | wc -l) )); then
   success
else
   failure
fi

NAME="${WAHOO}/domains/${WAHOO_DOMAIN}/bin In Path"
if (( $(echo ${PATH} | egrep "${WAHOO}/domains/${WAHOO_DOMAIN}/bin" | wc -l) )); then
   success
else
   failure
fi


now_testing "wahoo.sh"
check_for_help_option ${WAHOO}/bin/wahoo.sh

NAME="log to wahoo.log" && todo

NAME="version returns value"
if (( $(wahoo.sh version) > 0 )); then
   success
else
   failure
fi

NAME="Set WAHOO_TEST parameter to Null"
wahoo.sh config WAHOO_TEST ""
CHECK=$(grep "WAHOO_TEST" ${LOCAL_CONFIG_FILE} | awk -F"=" '{print $2}')
if [[ -z ${CHECK} ]]; then
   success
else
   failure
fi

NAME="Set WAHOO_TEST parameter to 'X Y Z'"
wahoo.sh config WAHOO_TEST "X Y Z"
CHECK=$(grep "WAHOO_TEST=\"X Y Z\"" ${LOCAL_CONFIG_FILE} | awk -F"=" '{print $2}')
if [[ -n ${CHECK} ]]; then
   success
else
   failure
fi

now_testing "has.sh"

check_for_help_option ${WAHOO}/bin/has.sh

for t in "x x" " x" "x " " "; do
   NAME="Looking for a spaces in \"${t}\""
   if (( $(has.sh space "${t}") == 1 )); then
      success
   else
      failure
   fi
done

for t in "xx" "x" ""; do
   NAME="Looking for no spaces in \"${t}\""
   if (( $(has.sh space "${t}") == 0 )); then
      success
   else
      failure
   fi
done

for t in "x --x" "--x "--123 " --123" "--foo --A"; do
   NAME="Looking for options in \"${t}\""
   if (( $(has.sh option "${t}") == 1 )); then
      success
   else
      failure
   fi
done

for t in "x--x" " " ""; do
   NAME="Looking for no options in \"${t}\""
   if (( $(has.sh option "${t}") == 0 )); then
      success
   else
      failure
   fi
done

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

now_testing "str.sh"
check_for_help_option ${WAHOO}/bin/str.sh

NAME="String to upper-case"
TEST="$(echo 'a|][_*@z' | str.sh upper) $(echo 'a|][_*@z' | str.sh ucase)"
if [[ "${TEST}" == "A|][_*@Z A|][_*@Z" ]]; then
   success
else
   failure
fi

NAME="String to lower-case"
TEST="$(echo 'A|][_*@Z' | str.sh lower) $(echo 'A|][_*@Z' | str.sh lcase)"
if [[ "${TEST}" == "a|][_*@z a|][_*@z" ]]; then
   success
else
   failure
fi

NAME="Split string a:b:c"
(
cat <<EOF
a
b
c
EOF
) > /tmp/A$$
echo "a:b:c" | str.sh split > /tmp/B$$
if (( $(diff /tmp/A$$ /tmp/B$$ | wc -l) == 0 )); then
   success
else
   failure
fi

for d in ";" "-" "," "|"; do
   NAME="Split string a${d}b${d}c"
   echo "a${d}b${d}c" | str.sh split "${d}" > /tmp/B$$
   if (( $(diff /tmp/A$$ /tmp/B$$ | wc -l) == 0 )); then
      success
   else
      failure
   fi
done

rm /tmp/A$$ /tmp/B$$ 2> /dev/null

now_testing "time.sh"
check_for_help_option ${WAHOO}/bin/time.sh
NAME="time.sh epoch" && todo
NAME="time.sh epoch --hours" && todo
NAME="time.sh epoch --minutes" && todo

now_testing "cache.sh"
check_for_help_option ${WAHOO}/bin/cache.sh
NAME="cache.sh set foo bar" && todo
NAME="cache.sh get foo" && todo
NAME="cat foo.txt | cache.sh set foo" && todo
NAME="cache.sh get foo" && todo

now_testing "error.sh"
check_for_help_option ${WAHOO}/bin/error.sh

now_testing ".wahoo-setup.sh"
check_for_help_option ${WAHOO}/bin/.wahoo-setup.sh

now_testing ".wahoo-path.sh"
check_for_help_option ${WAHOO}/bin/.wahoo-path.sh

now_testing "crlock.sh"
NAME="No Tests Defined" && todo

now_testing "rmlock.sh"
NAME="No Tests Defined" && todo

now_testing ".wahoo-check-jobs.sh"
# Prep
(
rm ${TMP}/test 
rm ${WAHOO}/log/stderr ${WAHOO}/log/stdout 
rm ${TMP}/test-convert.tmp 
) 2> /dev/null
check_for_help_option ${WAHOO}/bin/.wahoo-check-jobs.sh
NAME="Touch file every minute."
rm ${TMP}/test 2> /dev/null
.wahoo-check-jobs.sh --file ${WAHOO}/bin/.wahoo-jobs-test
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
.wahoo-check-jobs.sh --event ExampleEvent --file ${WAHOO}/bin/.wahoo-jobs-test
sleep 10
if [[ -f ${TMP}/test ]]; then
   success
else
   failure
fi
rm ${TMP}/test 2> /dev/null


