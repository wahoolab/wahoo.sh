
# Standard test file header.
. ${WAHOO}/test/functions.sh
cd ${TMP}
export WAHOO_TESTING="Y"
nowTesting ${WAHOO}/bin/route-message.sh
beginTest "--help Option"
assertHelp
endTest

export KEYWORD_OVERRIDES=
export MESSAGE_FOLDER="${TEST_DIR}"
export WAHOO_MESSAGE_LOG="${TEST_LOG}"
export WAHOO_AUDIT_LOG="${TEST_FILE}"

beginTest "Testing no input (cat /dev/null)"
cat /dev/null | route-message.sh
assertMissing .emails .header .subject .message .send .pagers .incident .document
endTest

beginTest "Testing without any options (same as --keywords LOG)"
echo "cake" | route-message.sh 
assertMissing .emails .header .subject .message .send .pagers .incident .document
assertMatch ${TEST_LOG} "cake"
endTest

beginTest "Testing --keywords INFO"
echo "rice" | route-message.sh --keywords INFO
assertMissing .emails .header .subject .message .send .pagers .incident .document
assertMatch ${TEST_LOG} "rice"
endTest

beginTest "Testing --keywords LOG"
echo "gator" | route-message.sh --keywords INFO
assertMissing .emails .header .subject .message .send .pagers .incident .document
assertMatch ${TEST_LOG} "gator"
endTest

beginTest "Testing --keywords WARNING"
echo "peak" | route-message.sh --keywords WARNING
assertMissing .pagers .incident .document
assertFile .emails .header .subject .message .send
assertMatch ${TEST_LOG} "peak"
endTest

beginTest "Testing --keywords EMAIL"
echo "lark" | route-message.sh --keywords EMAIL
assertFile .emails .header .subject .message .send
assertMissing .pagers .incident .document
assertMatch ${TEST_LOG} "lark"
endTest

beginTest "Testing --keywords CRITICAL"
echo "vine" | route-message.sh --keywords CRITICAL
assertFile .pagers .emails .header .subject .message .send
assertMissing .incident .document
assertMatch ${TEST_LOG} "vine"
endTest

beginTest "Testing --keywords PAGE"
echo "flask" | route-message.sh --keywords PAGE
assertFile .pagers .emails .header .subject .message .send
assertMissing .incident .document
assertMatch ${TEST_LOG} "flask"
endTest

beginTest "Testing --keywords TRASH"
echo "trash" | route-message.sh --keywords TRASH
assertMissing .pagers .emails .header .subject .message .send .incident .document
assertNomatch ${TEST_LOG} "trash"
endTest

beginTest "Testing --emails option"
echo "bass" | route-message.sh --keywords EMAIL --emails "john@doe.com" 
assertFile .emails .header .subject .message .send
assertMissing .pagers .incident .document
assertMatch .emails "john@doe.com"
assertMatch ${TEST_LOG} "bass"
endTest

beginTest "Testing --pagers option"
echo "henry" | route-message.sh --keywords PAGE --pagers "jane@doe.com"
assertFile .pagers .emails .header .subject .message .send
assertMissing .incident .document
assertMatch .pagers "jane@doe.com"
assertMatch ${TEST_LOG} "henry"
endTest

beginTest "Testing --nolog option"
echo "game" | route-message.sh --nolog
assertMissing .emails .header .subject .message .send .pagers .incident .document
assertNomatch ${TEST_LOG} "game"
endTest

beginTest "Testing --audit"
echo "taco" | route-message.sh --audit 
assertMissing .emails .header .subject .message .send .pagers .incident .document
endTest

beginTest "Testing --audit --nolog"
echo "bell" | route-message.sh --audit --nolog
assertMissing .emails .header .subject .message .send .pagers .incident .document
assertMatch ${WAHOO_AUDIT_LOG} "bell"
assertNomatch ${TEST_LOG} "bell"
endTest

beginTest "Testing --log ${TEST_FILE}1"
echo "machine" | route-message.sh --log ${TEST_FILE}1
assertFile ${TEST_FILE}1
assertMissing .emails .header .subject .message .send .pagers .incident .document
assertMatch ${TEST_FILE}1 "machine"
endTest

beginTest "Testing --incident foo"
echo "beep" | route-message.sh --incident foo
assertFile .header .subject .message .send .incident
assertMissing .emails .pagers .documents
assertMatch ${TEST_LOG} "beep"
endTest

beginTest "Testing --incident foo --keywords EMAIL"
echo "coffee" | route-message.sh --incident foo --keywords EMAIL
assertFile .header .subject .message .send .incident .emails
assertMissing .pagers .documents
assertMatch ${TEST_LOG} "coffee"
endTest

beginTest "Testing --document foo.txt"
echo "camper" | route-message.sh --document foo.txt
assertMatch .document "foo.txt"
assertFile .document .header .subject .message .send
assertMissing .emails .pagers .incident
endTest

export KEYWORD_OVERRIDES="CRITICAL=LOG, WARNING=LOG, PAGE=EMAIL"

beginTest "Testing --keywords CRITICAL with KEYWORD_OVERRIDE"
echo "belt" | route-message.sh --keywords CRITICAL 
assertMissing .emails .header .subject .message .send .pagers .incident .document
assertMatch ${TEST_LOG} "belt"
endTest

beginTest "Testing --keywords WARNING with KEYWORD_OVERRIDE"
echo "think" | route-message.sh --keywords WARNING
assertMissing .emails .header .subject .message .send .pagers .incident .document
assertMatch ${TEST_LOG} "think"
endTest

beginTest "Testing --keywords PAGE with KEYWORD_OVERRIDE"
echo "habit" | route-message.sh --keywords PAGE
assertFile .emails .header .subject .message .send
assertMissing .pagers .incident .document
assertMatch ${TEST_LOG} "habit"
endTest

export KEYWORD_OVERRIDES="CRITICAL=LOG,WARNING=TRASH,PAGE=TYPO,INFO=EMAIL"

NAME="Testing --keywords PAGE with an invalid KEYWORD_OVERRIDE"
echo "dark" | route-message.sh --keywords PAGE 2> ${TEST_FILE}2
# An error in the keyword should still result in the message being logged.
assertMatch ${TEST_FILE}2 "KEYWORD TYPO is not recognized"
assertMatch ${TEST_LOG} "dark"
endTest

