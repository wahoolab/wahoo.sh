
. ${WAHOO}/tests/functions.sh

cd ${TMP}
export WAHOO_TESTING="Y"
KEYWORD_OVERRIDES=

nowTesting "route-message.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/route-message.sh | wc -l)
endTest

beginTest "Testing no input (cat /dev/null)"
cat /dev/null | route-message.sh
assertFalse $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertFalse $(exist .emails .header .subject .message .send .pagers .incident .document)
endTest

beginTest "Testing without any options (same as --keywords LOG)"
echo foo | route-message.sh 
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
endTest

beginTest "Testing --keywords INFO"
echo foo | route-message.sh --keywords INFO
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertFalse $(exist .emails .header .subject .message .send .pagers .incident .document)
endTest

beginTest "Testing --keywords LOG"
echo foo | route-message.sh --keywords LOG
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertFalse $(exist .emails .header .subject .message .send .pagers .incident .document)
endTest

beginTest "Testing --keywords WARNING"
echo foo | route-message.sh --keywords WARNING
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(exist .emails .header .subject .message .send)
assertFalse $(exist .pagers .incident .document)
endTest

beginTest "Testing --keywords EMAIL"
echo foo | route-message.sh --keywords EMAIL
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(exist .emails .header .subject .message .send)
assertFalse $(exist .pagers .incident .document)
endTest

beginTest "Testing --keywords CRITICAL"
echo foo | route-message.sh --keywords CRITICAL
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(exist .pagers .emails .header .subject .message .send)
assertFalse $(exist .incident .document)
endTest

beginTest "Testing --keywords PAGE"
echo foo | route-message.sh --keywords PAGE
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(exist .pagers .emails .header .subject .message .send)
assertFalse $(exist .incident .document)
endTest

beginTest "Testing --keywords TRASH"
echo foo | route-message.sh --keywords TRASH
assertFalse $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertFalse $(exist .pagers .emails .header .subject .message .send .incident .document)
endTest

beginTest "Testing --emails option"
echo foo | route-message.sh --keywords EMAIL --emails "john@doe.com" 
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(exist .emails .header .subject .message .send)
assertFalse $(exist .pagers .incident .document)
endTest

beginTest "Testing --pagers option"
echo foo | route-message.sh --keywords PAGE --pagers "jane@doe.com"
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(exist .pagers .emails .header .subject .message .send)
assertFalse $(exist .incident .document) 
assertTrue $(grepFile ".pagers" "jane@doe.com")
endTest

beginTest "Testing --nolog option"
echo foo | route-message.sh --nolog
assertFalse $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertFalse $(exist .emails .header .subject .message .send .pagers .incident .document)
endTest

beginTest "Testing --audit"
echo foo | route-message.sh --audit 
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(grepLog "LOGFILE=${WAHOO_AUDIT_LOG}")
assertFalse $(exist .emails .header .subject .message .send .pagers .incident .document)
endTest

beginTest "Testing --audit --nolog"
echo foo | route-message.sh --audit --nolog
assertFalse $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(grepLog "LOGFILE=${WAHOO_AUDIT_LOG}")
assertFalse $(exist .emails .header .subject .message .send .pagers .incident .document)
endTest

beginTest "Testing --log ${TMP}/tdd/alt.log"
echo foo | route-message.sh --log ${TMP}/tdd/alt.log
assertFalse $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(grepFile "alt.log" "foo")
assertFalse $(exist .emails .header .subject .message .send .pagers .incident .document)
endTest

beginTest "Testing --incident foo"
echo foo | route-message.sh --incident foo
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(exist .header .subject .message .send .incident)
assertFalse $(exist .emails .pagers .documents)
endTest

beginTest "Testing --incident foo --keywords EMAIL"
echo foo | route-message.sh --incident foo --keywords EMAIL
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(exist .header .subject .message .send .incident .emails)
assertFalse $(exist .pagers .documents)
endTest

beginTest "Testing --document foo.txt"
echo foo | route-message.sh --document foo.txt
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(grepFile ".document" "foo.txt")
assertTrue $(exist .header .subject .message .send)
assertFalse $(exist .emails .pagers .incident)
endTest

KEYWORD_OVERRIDES="CRITICAL=LOG, WARNING=LOG, PAGE=EMAIL"

beginTest "Testing --keywords CRITICAL with KEYWORD_OVERRIDE"
echo foo | route-message.sh --keywords CRITICAL 
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertFalse $(exist .emails .header .subject .message .send .pagers .incident .document)
endTest

beginTest "Testing --keywords WARNING with KEYWORD_OVERRIDE"
echo foo | route-message.sh --keywords WARNING
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertFalse $(exist .emails .header .subject .message .send .pagers .incident .document)
endTest

beginTest "Testing --keywords PAGE with KEYWORD_OVERRIDE"
echo foo | route-message.sh --keywords PAGE
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(exist .emails .header .subject .message .send)
assertFalse $(exist .pagers .incident .document)
endTest

KEYWORD_OVERRIDES="CRITICAL=LOG,WARNING=TRASH,PAGE=TYPO,INFO=EMAIL"
NAME="Testing --keywords PAGE with an invalid KEYWORD_OVERRIDE"
echo foo | route-message.sh --keywords PAGE 2> ${TMP}/tdd/stderr
# An error in the keyword should still result in the message being logged.
assertTrue $(grepLog "LOGFILE=${WAHOO_MESSAGE_LOG}")
assertTrue $(grepFile "stderr" "KEYWORD TYPO is not recognized")
endTest

