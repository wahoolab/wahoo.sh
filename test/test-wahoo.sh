
. ${WAHOO}/tests/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "wahoo.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/wahoo.sh | wc -l)
endTest

beginTest "wahoo.sh version"
assertTrue $(wahoo.sh version)
endTest

beginTest "wahoo.sh log"
PATTERN="x $(date) x"
wahoo.sh log "${PATTERN}"
assertTrue $(grep "${PATTERN}" ${WAHOO_APP_LOG} | wc -l)
endTest

beginTest "wahoo.sh config WAHOO_TEST \"\""
wahoo.sh config WAHOO_TEST ""
assertUndefined $(grep "WAHOO_TEST" ${LOCAL_CONFIG_FILE} | awk -F"=" '{print $2}')
endTest

beginTest "wahoo.sh config WAHOO_TEST \"X Y Z\""
wahoo.sh config WAHOO_TEST "X Y Z"
assertTrue $([[ "\"X Y Z\"" == $(grep "WAHOO_TEST=\"X Y Z\"" ${LOCAL_CONFIG_FILE} | awk -F"=" '{print $2}') ]] && echo 1)
endTest

beginTest "wahoo.sh tar"
TARFILE=$(wahoo.sh tar)
assertTrue $([[ -s ${TARFILE} ]] && echo 1)
endTest


