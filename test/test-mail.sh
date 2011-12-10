

. ${WAHOO}/test/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "mail.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/has.sh | wc -l)
endTest

beginTest "echo foo | mail.sh Test ${WAHOO_EMAILS}"
echo foo | mail.sh "Test" "${WAHOO_EMAILS}"
assertTrue $(grepLog "LINES=")
endTest

beginTest "Test max lines --max 5"
ls ${WAHOO}/bin | mail.sh --max 5 "Test" "${WAHOO_EMAILS}"
assertTrue $(grepLog "LINES=5")
endTest


