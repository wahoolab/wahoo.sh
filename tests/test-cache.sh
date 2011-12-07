
. ${WAHOO}/tests/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "cache.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/cache.sh | wc -l)
endTest

beginTest "cache.sh set foo bar"
KEY=$(time.sh epoch)
assertUndefined $(cache.sh get ${KEY})
cache.sh set ${KEY} "bar"
assertTrue $([[ $(cache.sh get ${KEY}) == "bar" ]] && echo 1)
endTest

beginTest "cat file | cache.sh set \"foo\""
set > ${TMP}/tdd/file1
cat ${TMP}/tdd/file1 | cache.sh set "foo"
cache.sh get "foo" > ${TMP}/tdd/file2
assertFalse $(diff ${TMP}/tdd/file1 ${TMP}/tdd/file2 | wc -l)
endTest

