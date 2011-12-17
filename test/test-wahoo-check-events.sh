
. ${WAHOO}/test/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting ".wahoo-check-events.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/.wahoo-check-events.sh | wc -l)
endTest

