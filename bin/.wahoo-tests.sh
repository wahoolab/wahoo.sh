
. ~/.wahoo

function now_testing {
   cat <<EOF
${LINE1}
${1}
${LINE1}
EOF
}

function success {
   printf "%-60s%20s\n" "${NAME}" "success"    
}

function failure {
   printf "%-60s%20s\n" "${NAME}" "failed"
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

now_testing "wahoo.sh"

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






