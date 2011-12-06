
. ${WAHOO}/tests/functions.sh

nowTesting "fire-event.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/fire-event.sh | wc -l)
endTest

NAME="-" && failure

