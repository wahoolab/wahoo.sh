
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/monitor_localhost_for_reboot.sh
beginTest "--help Option"
assertHelp
endTest

