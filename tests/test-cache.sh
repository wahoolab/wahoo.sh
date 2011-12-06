
. ${WAHOO}/tests/functions.sh

nowTesting "cache.sh"

beginTest "--help Option"
assertTrue $(grep "\-\-help" ${WAHOO}/bin/route-message.sh | wc -l)
endTest

exit

NAME="cache.sh set foo bar" 
NAME="cache.sh get foo"
NAME="cat foo.txt | cache.sh set foo" 
NAME="cache.sh get foo" 

