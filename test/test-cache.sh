
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/cache.sh
beginTest "--help Option"
assertHelp
endTest

beginTest "cache.sh set foo bar"
KEY=$(time.sh epoch)
assertUndefined $(cache.sh get ${KEY})
cache.sh set ${KEY} "bar"
assertEquals $(cache.sh get ${KEY})  "bar"
endTest

beginTest "cat file | cache.sh set \"foo\""
set > ${TEST_FILE}1
cat ${TEST_FILE}1 | cache.sh set "foo"
cache.sh get "foo" > ${TEST_FILE}2
assertSame ${TEST_FILE}1 ${TEST_FILE}2
endTest

