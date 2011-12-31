
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/statengine.sh
beginTest "--help Option"
assertHelp
endTest

function statengined_processes {
   echo $(ps -ef | grep statengined.sh | egrep -cv "grep") 
}

# Test --start option
# -------------------

beginTest "--start option"
statengine.sh --stop 1> /dev/null
assertZero $(statengined_processes)
statengine.sh --start
assertPositive $(statengined_processes)
endTest

beginTest "--start option when service is already running"
BEFORE=$(statengined_processes)
statengine.sh --start
AFTER=$(statengined_processes)
assertEquals ${BEFORE} ${AFTER}
endTest

# Test --stop option
# ------------------

beginTest "--stop option"
assertPositive $(statengined_processes)
statengine.sh --stop 1> /dev/null
assertZero $(statengined_processes)
endTest

# Test --check-daemon option
# --------------------------

beginTest "--check-daemon \${STATENGINE} is non-zero"
statengine.sh --stop 1> /dev/null
assertZero $(statengined_processes)
export STATENGINE=60
statengine.sh --check-daemon
assertPositive $(statengined_processes)
endTest

beginTest "--check-daemon with \${STATENGINE} is zero"
statengine.sh --stop > ${TEST_LOG}
assertPositive $(grepMatch ${TEST_LOG} "NOTE:")
assertZero $(statengined_processes)
export STATENGINE=0
statengine.sh --check-daemon
sleep 1
assertZero $(statengined_processes)
endTest

beginTest "--check-daemon with \${STATENGINE} is not defined"
assertZero $(statengined_processes)
export STATENGINE=
statengine.sh --check-daemon
assertZero $(statengined_processes)
endTest

# Test
# ----

beginTest "statengine.sh --group \"test\""
find ${TMP}/statengined/in -type f -name "*test*" -exec rm {} \;
echo "$(time.sh epoch) some_key 0" | statengine.sh --group "test" 
assertEquals $(find ${TMP}/statengined/in -type f -name "*test*" | wc -l) 2
endTest

