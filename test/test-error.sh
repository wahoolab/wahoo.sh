
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/error.sh
beginTest "--help Option"
assertHelp
endTest

beginTest "error.sh \"foo\""
error.sh "foo" 2> ${TEST_FILE}
assertMatch ${TEST_FILE} "foo"
endTest

beginTest "echo foo | error.sh"
echo "foo" | error.sh 2> ${TEST_FILE}
assertMatch ${TEST_FILE} "foo"
endTest
