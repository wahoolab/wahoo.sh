
. ${WAHOO}/tests/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "error.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/error.sh | wc -l)
endTest

beginTest "error.sh \"foo\""
error.sh "foo" 2> ${TMP}/tdd/error.log
assertTrue $(grepFile "error.log" "foo")
endTest

beginTest "echo foo | error.sh"
echo "foo" | error.sh 2> ${TMP}/tdd/error.log
assertTrue $(grepFile "error.log" "foo")
endTest
