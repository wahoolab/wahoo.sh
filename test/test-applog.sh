

# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/applog.sh
beginTest "--help Option"
assertHelp
endTest

# Override the standard app log with the standard test log.
WAHOO_APP_LOG=${TEST_LOG}

beginTest "applog.sh \"test1\""
applog.sh "test1"
assertPositive $(grepMatch ${TEST_LOG} "test1")
endTest

beginTest "echo \"test2\" | applog.sh"
echo "test2" | applog.sh 
assertPositive $(grepMatch ${TEST_LOG} "test2")
endTest

