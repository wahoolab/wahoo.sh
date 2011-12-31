
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/.wahoo-check-events.sh
beginTest "--help Option"
assertHelp
endTest

