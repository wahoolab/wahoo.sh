
. ${WAHOO}/test/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "monitor_localhost_for_reboot.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/monitor_localhost_for_reboot.sh | wc -l)
endTest
