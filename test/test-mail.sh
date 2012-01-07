
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/mail.sh
beginTest "--help Option"
assertHelp
endTest

[[ -z ${WAHOO_EMAILS} ]] && WAHOO_EMAILS="spam@wahoolab.com"

export WAHOO_MAIL_LOG=${TEST_FILE}

beginTest "echo foo | mail.sh Test ${WAHOO_EMAILS}"
echo foo | mail.sh "Test" "${WAHOO_EMAILS}"
assertMatch ${TEST_FILE} "(lines=1)"
endTest

beginTest "Test max lines --max 5"
ls ${WAHOO}/bin | mail.sh --max 5 "Test" "${WAHOO_EMAILS}"
assertMatch ${TEST_FILE} "(lines=5)"
endTest

