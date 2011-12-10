
. ${WAHOO}/test/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "wahoo-path.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/.wahoo-path.sh | wc -l)
endTest


