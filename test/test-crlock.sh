
. ${WAHOO}/test/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"

nowTesting "crlock.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/crlock.sh | wc -l)
endTest

beginTest "crlock.sh foo"
rmlock.sh foo; crlock.sh foo
# If the lock was aquired we won't be able to get it.
if $(crlock.sh foo); then
   fail
fi
endTest

beginTest "crlock.sh --remove foo"
rmlock.sh foo && crlock.sh foo
crlock.sh --remove foo
# We should be able to get the lock.
crlock.sh foo || fail
endTest

beginTest "crlock.sh --try 10 (fail to obtain lock)"
rmlock.sh foo && crlock.sh foo
START=$(time.sh epoch)
crlock.sh --try 10 foo
END=$(time.sh epoch)
(( ((END-START)) > 8 )) || fail
endTest

beginTest "crlock.sh --try 10 (obtain lock)"
rmlock.sh foo && crlock.sh --expire 7 foo
START=$(time.sh epoch)
crlock.sh --try 10 foo
END=$(time.sh epoch)
(( ((END-START)) > 3 )) || fail
endTest

beginTest "crlock.sh --try 5 --grab"
rmlock.sh foo && crlock.sh foo
START=$(time.sh epoch)
$(crlock.sh --try 5 --grab foo) || fail
END=$(time.sh epoch)
(( ((END-START)) > 3 )) || fail
endTest

beginTest "crlock.sh --expire 5"
rmlock.sh foo && crlock.sh --expire 5 foo
$(crlock.sh foo) && fail
sleep 8
$(crlock.sh foo) || fail

beginTest "crlock.sh --fail 3"
rmlock.sh foo && crlock.sh foo
$(crlock.sh --fail 3 foo) && fail
$(crlock.sh --fail 3 foo) && fail
$(crlock.sh --fail 3 foo) && fail
crlock.sh --fail 3 foo 2> ${TMP}/tdd/stderr
assertTrue $(grepFile stderr "Failure limit has been reached trying to aquire lock foo") 
endTest

beginTest "crlock.sh --max-processes 2"
rmlock.sh foo && crlock.sh foo
crlock.sh --try 60 --max-processes 2 foo &
crlock.sh --try 60 --max-processes 2 foo &
# Give a little time for the .trying files to show up.
sleep 5
crlock.sh --try 60 --max-processes 2 foo 2> ${TMP}/tdd/stderr
assertTrue $(grepFile stderr "Too many processes are trying to aquire lock")
endTest


