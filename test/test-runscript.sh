
. ${WAHOO}/test/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "runscript.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/runscript.sh | wc -l)
endTest

