
. ${WAHOO}/tests/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "crtask.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/crtask.sh | wc -l)
endTest

beginTest "crtask.sh --key foo --command \"echo foo\""
crtask.sh --remove foo
crtask.sh --key foo --command "echo foo > ${TMP}/tdd/foo.log" || fail
assertTrue $(grep "echo foo" ${TMP}/tasks/foo | wc -l)
endTest

exit 0

beginTest "crtask.sh --remove foo"
crtask.sh --remove foo
assertFalse $(grep "echo foo" ${TMP}/tasks/foo 2> /dev/null | wc -l)
endTest

