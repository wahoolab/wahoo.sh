

# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/time.sh
beginTest "--help Option"
assertHelp
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

