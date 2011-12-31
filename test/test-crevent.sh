
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/crevent.sh
beginTest "--help Option"
assertHelp
endTest

# Unique ID
UID="${RANDOM}$$"
rm -rf ${WAHOO}/event/*

beginTest "Call crevent.sh with no option and return error"
crevent.sh 2> ${TEST_LOG}
assertPositive $?
assertMissing ${WAHOO}/event/test1
assertPositive $(hasSize ${TEST_LOG})
endTest

beginTest "Create a simple event"
crevent.sh --key "test1" 2> ${TEST_LOG}
assertZero $?
assertDir ${WAHOO}/event/test1
assertMissing ${WAHOO}/event/test1/.schedule
assertFile ${WAHOO}/event/test1/.allow
endTest

beginTest "Add an event with a schedule (1)"
chevent.sh --key "test1" --schedule "* * * * *" 
assertZero $?
assertOne $(grepMatch ${WAHOO}/event/test1/.schedule "\* \* \* \* \*")
endTest

beginTest "Add a command to the event and run (1)"
echo "echo 071108 > ${TEST_FILE}1" > ${WAHOO}/event/test1/hello-world.sh
chmod 700 ${WAHOO}/event/test1/hello-world.sh
${WAHOO}/run.sh
assertZero $?
sleep 4
assertOne $(grepMatch ${TEST_FILE}1 "071108")
endTest

beginTest "Add another command to the event and run"
echo "echo 100176 > ${TEST_FILE}2" > ${WAHOO}/event/test1/hello-nation.sh
chmod 700 ${WAHOO}/event/test1/hello-nation.sh
${WAHOO}/run.sh
assertZero $?
sleep 4
assertOne $(grepMatch ${TEST_FILE}1 "071108")
assertOne $(grepMatch ${TEST_FILE}2 "100176")
endTest

beginTest "Add localhost to .allow file and run"
chevent.sh --key "test1" --allow "$(hostname)"
assertOne $(grepMatch ${WAHOO}/event/test1/.allow "$(hostname)")
${WAHOO}/run.sh
assertZero $?
sleep 4
assertOne $(grepMatch ${TEST_FILE}1 "071108")
endTest

beginTest "Add localhost to .deny file and run"
chevent.sh --key "test1" --deny "$(hostname)" 2> /dev/null
# That should have created an error because we can't switch from an allow to a deny.
assertOne $?
cp /dev/null ${WAHOO}/event/test1/.allow
chevent.sh --key "test1" --deny "$(hostname)" 
assertZero $?
assertOne $(grepMatch ${WAHOO}/event/test1/.deny "$(hostname)")
${WAHOO}/run.sh
assertZero $?
sleep 4
assertZero $(grepMatch ${TEST_FILE}1 "071108")
endTest

beginTest "Try to override .deny file with .allow file"
chevent.sh --key "test1" --allow "$(hostname)" 2> ${TEST_FILE}
assertOne $?
assertZero $(grepMatch ${WAHOO}/event/test1/.allow "$(hostname)")
endTest

beginTest "Duplicate event without --silent throws error"
crevent.sh --key "test1" 2> ${TEST_FILE}
assertOne $?
assertOne $(hasSize ${TEST_FILE})
endTest

beginTest "Duplicate event with --silent option does not throw error"
crevent.sh --key "test1" --silent 2> ${TEST_FILE}
assertZero $?
assertZero $(hasSize ${TEST_FILE})
endTest

beginTest "Change a schedule"
chevent.sh --key "test1" --schedule "1 1 1 1 1"
assertZero $?
assertOne $(grepMatch ${WAHOO}/event/test1/.schedule "1 1 1 1 1")
endTest

beginTest "Remove event"
crevent.sh --remove "test1"
assertZero $?
assertMissing ${WAHOO}/event/test1
endTest

beginTest "Create duplicate event in subdirectory - local/test1"
crevent.sh --key local/test1 --schedule "* * * * *" 
assertZero $?
assertDir ${WAHOO}/event/local/test1
endTest

beginTest "Add an event with a schedule (2)"
chevent.sh --key "local/test1" --schedule "* * * * *"
assertZero $?
assertOne $(grepMatch ${WAHOO}/event/local/test1/.schedule "\* \* \* \* \*")
endTest

beginTest "Add a command to the event and run (2)"
echo "echo 071108 > ${TEST_FILE}3" > ${WAHOO}/event/local/test1/hello-world.sh
chmod 700 ${WAHOO}/event/local/test1/hello-world.sh
${WAHOO}/run.sh
assertZero $?
sleep 4
assertOne $(grepMatch ${TEST_FILE}3 "071108")
endTest

