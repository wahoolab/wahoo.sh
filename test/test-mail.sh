
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/mail.sh
beginTest "--help Option"
assertHelp
endTest

[[ -z ${WAHOO_EMAILS} ]] && WAHOO_EMAILS="spam@wahoolab.com"

beginTest "echo foo | mail.sh Test ${WAHOO_EMAILS}"
echo foo | mail.sh "Test" "${WAHOO_EMAILS}"
assertTrue $(grepLog "LINES=")
endTest

beginTest "Test max lines --max 5"
ls ${WAHOO}/bin | mail.sh --max 5 "Test" "${WAHOO_EMAILS}"
assertTrue $(grepLog "LINES=5")
endTest


