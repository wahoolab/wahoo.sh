

. ${WAHOO}/tests/functions.sh

nowTesting "error.sh"
beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/error.sh | wc -l)
endTest


