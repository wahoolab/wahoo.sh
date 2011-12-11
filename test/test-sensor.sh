
. ${WAHOO}/test/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "sensor.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/sensor.sh | wc -l)
endTest
