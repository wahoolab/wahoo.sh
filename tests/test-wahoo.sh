
. ${WAHOO}/tests/functions.sh

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


