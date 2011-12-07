

. ${WAHOO}/tests/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "time.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/time.sh | wc -l)
endTest

beginTest "time.sh epoch"
assertDefined $(time.sh epoch) 
assertTrue $(time.sh epoch)
endTest

beginTest "time.sh epoch --hours"
assertDefined $(time.sh epoch --hours)
assertTrue $(time.sh epoch --hours)
assertTrue $( (($(time.sh epoch) > $(time.sh epoch --hours))) && echo 1)
endTest

beginTest "time.sh epoch --minutes"
assertDefined $(time.sh epoch --minutes)
assertTrue $(time.sh epoch --minutes)
assertTrue $( (($(time.sh epoch) > $(time.sh epoch --minutes))) && echo 1)
endTest

