
. ${WAHOO}/test/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting ".wahoo-setup.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/.wahoo-setup.sh | wc -l)
endTest

